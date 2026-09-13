import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Client } from 'minio';
import { randomUUID } from 'crypto';

@Injectable()
export class StorageService implements OnModuleInit {
  private readonly logger = new Logger(StorageService.name);
  private readonly client: Client;
  /** Cliente separado usado solo para firmar URLs alcanzables desde el navegador. */
  private readonly publicClient: Client;
  private readonly bucket: string;

  constructor(private readonly config: ConfigService) {
    this.bucket = this.config.get<string>('MINIO_BUCKET', 'vier-capturas');

    const accessKey = this.config.get<string>('MINIO_ACCESS_KEY', 'vier');
    const secretKey = this.config.get<string>('MINIO_SECRET_KEY', 'vier12345');

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

  async upload(file: Express.Multer.File, prefix = 'capturas'): Promise<{ key: string }> {
    const ext = file.originalname.split('.').pop();
    const key = `${prefix}/${randomUUID()}.${ext}`;
    await this.client.putObject(this.bucket, key, file.buffer, file.size, {
      'Content-Type': file.mimetype,
    });
    return { key };
  }

  async getPresignedUrl(key: string, expirySeconds = 3600): Promise<string> {
    return this.publicClient.presignedGetObject(this.bucket, key, expirySeconds);
  }

  async remove(key: string): Promise<void> {
    await this.client.removeObject(this.bucket, key);
  }
}
