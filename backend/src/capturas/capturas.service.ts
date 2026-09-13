import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { StorageService } from '../storage/storage.service';
import { CreateCapturaDto } from './dto/create-captura.dto';

@Injectable()
export class CapturasService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: StorageService,
  ) {}

  async findByLevantamiento(levantamientoId: string) {
    const capturas = await this.prisma.captura.findMany({
      where: { levantamientoId },
      orderBy: { createdAt: 'desc' },
      include: { subidoPor: { select: { id: true, nombre: true } } },
    });

    return Promise.all(
      capturas.map(async (c) => ({
        ...c,
        url: await this.storage.getPresignedUrl(c.fileKey),
      })),
    );
  }

  async create(
    levantamientoId: string,
    file: Express.Multer.File,
    dto: CreateCapturaDto,
    userId: string,
  ) {
    const levantamiento = await this.prisma.levantamiento.findUnique({
      where: { id: levantamientoId },
    });
    if (!levantamiento) {
      throw new NotFoundException('Levantamiento no encontrado');
    }

    const { key, mimetype, originalname, size } = await this.storage.upload(file);
    const tipo = mimetype.startsWith('image/') ? 'foto' : 'documento';

    return this.prisma.captura.create({
      data: {
        levantamientoId,
        fileKey: key,
        fileName: originalname,
        mimeType: mimetype,
        size,
        tipo,
        notas: dto.notas,
        latitud: dto.latitud,
        longitud: dto.longitud,
        subidoPorId: userId,
      },
    });
  }

  async remove(id: string) {
    const captura = await this.prisma.captura.findUnique({ where: { id } });
    if (!captura) {
      throw new NotFoundException('Captura no encontrada');
    }
    await this.storage.remove(captura.fileKey);
    await this.prisma.captura.delete({ where: { id } });
  }
}
