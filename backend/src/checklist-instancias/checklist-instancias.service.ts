import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { StorageService } from '../storage/storage.service';
import { ChecklistPlantillasService } from '../checklist-plantillas/checklist-plantillas.service';
import { CreateInstanciaDto } from './dto/create-instancia.dto';
import { UpdateInstanciaDto } from './dto/update-instancia.dto';
import { ResponderItemDto } from './dto/responder-item.dto';
import { CreateRevisionDto } from './dto/create-revision.dto';

const ORDEN = { orden: 'asc' as const };
const INCLUDE_ESTRUCTURA = {
  orderBy: ORDEN,
  include: {
    grupos: {
      orderBy: ORDEN,
      include: { items: { orderBy: ORDEN } },
    },
    items: { where: { grupoId: null }, orderBy: ORDEN },
  },
};

@Injectable()
export class ChecklistInstanciasService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: StorageService,
    private readonly plantillas: ChecklistPlantillasService,
  ) {}

  async findByLevantamiento(levantamientoId: string) {
    return this.prisma.checklistInstancia.findMany({
      where: { levantamientoId },
      orderBy: { createdAt: 'desc' },
      include: { _count: { select: { secciones: true } } },
    });
  }

  async findOne(id: string) {
    const instancia = await this.prisma.checklistInstancia.findUnique({
      where: { id },
      include: {
        secciones: INCLUDE_ESTRUCTURA,
        revisiones: { orderBy: { createdAt: 'asc' } },
      },
    });
    if (!instancia) {
      throw new NotFoundException('Checklist no encontrado');
    }
    return {
      ...instancia,
      logoEmpresaUrl: instancia.logoEmpresaKey
        ? await this.storage.getPresignedUrl(instancia.logoEmpresaKey)
        : null,
      logoClienteUrl: instancia.logoClienteKey
        ? await this.storage.getPresignedUrl(instancia.logoClienteKey)
        : null,
    };
  }

  async create(levantamientoId: string, dto: CreateInstanciaDto, userId: string) {
    const levantamiento = await this.prisma.levantamiento.findUnique({ where: { id: levantamientoId } });
    if (!levantamiento) {
      throw new NotFoundException('Levantamiento no encontrado');
    }
    const plantilla = await this.plantillas.findOne(dto.plantillaId);

    const instancia = await this.prisma.checklistInstancia.create({
      data: {
        levantamientoId,
        plantillaId: plantilla.id,
        nombre: dto.nombre?.trim() || plantilla.nombre,
        logoEmpresaKey: plantilla.logoEmpresaKey,
        logoClienteKey: plantilla.logoClienteKey,
        estacion: levantamiento.titulo,
        creadoPorId: userId,
      },
    });

    for (const seccion of plantilla.secciones) {
      const seccionCreada = await this.prisma.checklistInstanciaSeccion.create({
        data: {
          instanciaId: instancia.id,
          numero: seccion.numero,
          titulo: seccion.titulo,
          orden: seccion.orden,
        },
      });

      for (const item of seccion.items) {
        await this.prisma.checklistInstanciaItem.create({
          data: {
            seccionId: seccionCreada.id,
            descripcion: item.descripcion,
            requiereObservacion: item.requiereObservacion,
            orden: item.orden,
          },
        });
      }

      for (const grupo of seccion.grupos) {
        const grupoCreado = await this.prisma.checklistInstanciaGrupo.create({
          data: { seccionId: seccionCreada.id, titulo: grupo.titulo, orden: grupo.orden },
        });

        for (const item of grupo.items) {
          await this.prisma.checklistInstanciaItem.create({
            data: {
              seccionId: seccionCreada.id,
              grupoId: grupoCreado.id,
              descripcion: item.descripcion,
              requiereObservacion: item.requiereObservacion,
              orden: item.orden,
            },
          });
        }
      }
    }

    return this.findOne(instancia.id);
  }

  async update(id: string, dto: UpdateInstanciaDto) {
    await this.findOne(id);
    return this.prisma.checklistInstancia.update({
      where: { id },
      data: {
        ...dto,
        fecha: dto.fecha ? new Date(dto.fecha) : undefined,
        preparadoPorFecha: dto.preparadoPorFecha ? new Date(dto.preparadoPorFecha) : undefined,
        revisadoPorFecha: dto.revisadoPorFecha ? new Date(dto.revisadoPorFecha) : undefined,
        aprobadoPorFecha: dto.aprobadoPorFecha ? new Date(dto.aprobadoPorFecha) : undefined,
      },
    });
  }

  async responderItem(instanciaId: string, itemId: string, dto: ResponderItemDto) {
    const item = await this.prisma.checklistInstanciaItem.findFirst({
      where: { id: itemId, seccion: { instanciaId } },
    });
    if (!item) {
      throw new NotFoundException('Ítem no encontrado en este checklist');
    }
    await this.prisma.checklistInstanciaItem.update({
      where: { id: itemId },
      data: { valor: dto.valor ?? null, observaciones: dto.observaciones },
    });
    return this.findOne(instanciaId);
  }

  async addRevision(instanciaId: string, dto: CreateRevisionDto) {
    await this.findOne(instanciaId);
    await this.prisma.checklistRevisionHistorial.create({
      data: { instanciaId, ...dto },
    });
    return this.findOne(instanciaId);
  }

  async uploadLogo(id: string, tipo: 'empresa' | 'cliente', file: Express.Multer.File) {
    await this.findOne(id);
    const { key } = await this.storage.upload(file, 'logos');
    const data = tipo === 'empresa' ? { logoEmpresaKey: key } : { logoClienteKey: key };
    await this.prisma.checklistInstancia.update({ where: { id }, data });
    return this.findOne(id);
  }

  async remove(id: string) {
    await this.findOne(id);
    await this.prisma.checklistInstancia.delete({ where: { id } });
  }
}
