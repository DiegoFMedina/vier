import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Client } from 'minio';
import { randomUUID } from 'crypto';
import sharp from 'sharp';
import { requestHostContext } from './request-host.context';

@Injectable()
export class StorageService implements OnModuleInit {
  private readonly logger = new Logger(StorageService.name);
  private readonly client: Client;
  /** Cliente separado usado solo para firmar URLs alcanzables desde el navegador. */
  private readonly publicClient: Client;
  private readonly bucket: string;
  private readonly accessKey: string;
  private readonly secretKey: string;
  private readonly publicPort: number;
  private readonly publicUseSSL: boolean;

  constructor(private readonly config: ConfigService) {
    this.bucket = this.config.get<string>('MINIO_BUCKET', 'vier-capturas');

    const accessKey = this.config.get<string>('MINIO_ACCESS_KEY', 'vier');
    const secretKey = this.config.get<string>('MINIO_SECRET_KEY', 'vier12345');
    this.accessKey = accessKey;
    this.secretKey = secretKey;
    this.publicPort = Number(
      this.config.get('MINIO_PUBLIC_PORT', this.config.get('MINIO_PORT', 9000)),
    );
    this.publicUseSSL =
      this.config.get(
        'MINIO_PUBLIC_USE_SSL',
        this.config.get('MINIO_USE_SSL', 'false'),
      ) === 'true';

    this.client = new Client({
      endPoint: this.config.get<string>('MINIO_ENDPOINT', 'localhost'),
      port: Number(this.config.get('MINIO_PORT', 9000)),
      useSSL: this.config.get('MINIO_USE_SSL') === 'true',
      accessKey,
      secretKey,
      region: this.config.get<string>('MINIO_REGION', 'us-east-1'),
    });

    this.publicClient = new Client({
      endPoint: this.config.get<string>(
        'MINIO_PUBLIC_ENDPOINT',
        this.config.get<string>('MINIO_ENDPOINT', 'localhost'),
      ),
      port: Number(
        this.config.get('MINIO_PUBLIC_PORT', this.config.get('MINIO_PORT', 9000)),
      ),
      useSSL: this.config.get(
        'MINIO_PUBLIC_USE_SSL',
        this.config.get('MINIO_USE_SSL', 'false'),
      ) === 'true',
      accessKey,
      secretKey,
      // Sin esto, el cliente intenta resolver la región llamando al host
      // configurado (el "endpoint público"), que desde dentro del contenedor
      // del backend no es alcanzable: firmar la URL fallaría con ECONNREFUSED.
      region: this.config.get<string>('MINIO_REGION', 'us-east-1'),
    });
  }

  async onModuleInit() {
    try {
      const exists = await this.client.bucketExists(this.bucket);
      if (!exists) {
        await this.client.makeBucket(this.bucket);
        this.logger.log(`Bucket "${this.bucket}" creado`);
      }
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      this.logger.warn(`No se pudo verificar/crear el bucket MinIO: ${message}`);
    }
  }

  async upload(
    file: Express.Multer.File,
    prefix = 'capturas',
  ): Promise<{ key: string; mimetype: string; originalname: string; size: number }> {
    const normalizado = await this.convertirHeicSiCorresponde(file);
    const ext = normalizado.originalname.split('.').pop();
    const key = `${prefix}/${randomUUID()}.${ext}`;
    await this.client.putObject(this.bucket, key, normalizado.buffer, normalizado.buffer.length, {
      'Content-Type': normalizado.mimetype,
    });
    return {
      key,
      mimetype: normalizado.mimetype,
      originalname: normalizado.originalname,
      size: normalizado.buffer.length,
    };
  }

  /**
   * Las fotos HEIC/HEIF de iPhone se convierten a JPEG para que se puedan
   * previsualizar en cualquier navegador (la mayoría no soporta HEIC de
   * forma nativa, a diferencia de Safari) y para incrustarlas más adelante
   * en documentos generados con Chromium/Puppeteer.
   *
   * La mayoría de esas fotos usan el códec HEVC, que no viene incluido en
   * la build de sharp por restricciones de patente, así que la conversión
   * puede fallar; en ese caso se guarda el archivo original tal cual en vez
   * de rechazar la subida.
   */
  private async convertirHeicSiCorresponde(file: Express.Multer.File): Promise<Express.Multer.File> {
    const esHeic = /heic|heif/i.test(file.mimetype) || /\.(heic|heif)$/i.test(file.originalname);
    if (!esHeic) {
      return file;
    }

    try {
      const buffer = await sharp(file.buffer).jpeg({ quality: 92 }).toBuffer();
      return {
        ...file,
        buffer,
        size: buffer.length,
        mimetype: 'image/jpeg',
        originalname: file.originalname.replace(/\.(heic|heif)$/i, '.jpg'),
      };
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      this.logger.warn(`No se pudo convertir HEIC/HEIF a JPEG, se guarda el original: ${message}`);
      return file;
    }
  }

  /**
   * Usa el host con el que el navegador pidió la página actual (ej. la IP de
   * LAN o el dominio real) para firmar la URL, en vez del host fijo por
   * variable de entorno: así la galería/descargas funcionan también desde el
   * teléfono y no solo desde la máquina donde corre Docker.
   */
  private publicClientParaRequestActual(): Client {
    const host = requestHostContext.getStore()?.host;
    const hostname = host?.split(':')[0];
    if (!hostname) {
      return this.publicClient;
    }
    return new Client({
      endPoint: hostname,
      port: this.publicPort,
      useSSL: this.publicUseSSL,
      accessKey: this.accessKey,
      secretKey: this.secretKey,
      region: this.config.get<string>('MINIO_REGION', 'us-east-1'),
    });
  }

  async getPresignedUrl(key: string, expirySeconds = 3600): Promise<string> {
    return this.publicClientParaRequestActual().presignedGetObject(this.bucket, key, expirySeconds);
  }

  /**
   * URL firmada que fuerza la descarga (Content-Disposition: attachment) con
   * el nombre de archivo original, en vez de mostrarlo inline en el
   * navegador. El atributo HTML "download" no funciona para URLs de otro
   * origen (la de MinIO), así que el nombre de descarga tiene que venir del
   * propio encabezado de la respuesta firmada.
   */
  async getPresignedDownloadUrl(
    key: string,
    fileName: string,
    expirySeconds = 3600,
  ): Promise<string> {
    return this.publicClientParaRequestActual().presignedGetObject(this.bucket, key, expirySeconds, {
      'response-content-disposition': `attachment; filename="${fileName.replace(/"/g, '')}"`,
    });
  }

  /**
   * Descarga el objeto completo usando el cliente interno (alcanzable dentro
   * de la red de Docker). Se usa para incrustar imágenes (ej. logos) como
   * data URI al generar PDFs con Puppeteer, que corre en el mismo contenedor
   * del backend y no puede resolver el endpoint público de MinIO.
   */
  async getObjectBuffer(key: string): Promise<Buffer> {
    const stream = await this.client.getObject(this.bucket, key);
    const chunks: Buffer[] = [];
    for await (const chunk of stream) {
      chunks.push(chunk as Buffer);
    }
    return Buffer.concat(chunks);
  }

  async remove(key: string): Promise<void> {
    await this.client.removeObject(this.bucket, key);
  }
}
