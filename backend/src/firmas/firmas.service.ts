import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { StorageService } from '../storage/storage.service';
import { TipoFirmaDto } from './dto/create-firma-guardada.dto';

@Injectable()
export class FirmasService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: StorageService,
  ) {}

  async findMine(userId: string) {
    const firmas = await this.prisma.firmaGuardada.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
    return Promise.all(
      firmas.map(async (f) => ({ ...f, url: await this.storage.getPresignedUrl(f.fileKey) })),
    );
  }

  async create(userId: string, tipo: TipoFirmaDto, etiqueta: string | undefined, file: Express.Multer.File) {
    const { key } = await this.storage.upload(file, 'firmas');
    return this.prisma.firmaGuardada.create({
      data: {
        userId,
        tipo,
        etiqueta: etiqueta?.trim() || 'Mi firma',
        fileKey: key,
      },
    });
  }

  async remove(userId: string, id: string) {
    const firma = await this.prisma.firmaGuardada.findFirst({ where: { id, userId } });
    if (!firma) {
      throw new NotFoundException('Firma no encontrada');
    }
    await this.storage.remove(firma.fileKey);
    await this.prisma.firmaGuardada.delete({ where: { id } });
  }
}
