import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateLevantamientoDto } from './dto/create-levantamiento.dto';
import { UpdateLevantamientoDto } from './dto/update-levantamiento.dto';

@Injectable()
export class LevantamientosService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.levantamiento.findMany({
      orderBy: { createdAt: 'desc' },
      include: {
        creadoPor: { select: { id: true, nombre: true } },
        _count: { select: { capturas: true } },
      },
    });
  }

  async findOne(id: string) {
    const levantamiento = await this.prisma.levantamiento.findUnique({
      where: { id },
      include: {
        creadoPor: { select: { id: true, nombre: true } },
        _count: { select: { capturas: true } },
      },
    });
    if (!levantamiento) {
      throw new NotFoundException('Levantamiento no encontrado');
    }
    return levantamiento;
  }

  async create(dto: CreateLevantamientoDto, userId: string) {
    return this.prisma.levantamiento.create({
      data: {
        titulo: dto.titulo,
        descripcion: dto.descripcion,
        direccion: dto.direccion,
        creadoPorId: userId,
      },
    });
  }

  async update(id: string, dto: UpdateLevantamientoDto) {
    await this.findOne(id);
    return this.prisma.levantamiento.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    await this.findOne(id);
    await this.prisma.levantamiento.delete({ where: { id } });
  }
}
