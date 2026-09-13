import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { StorageService } from '../storage/storage.service';
import { CreatePlantillaDto } from './dto/create-plantilla.dto';
import { UpdatePlantillaDto } from './dto/update-plantilla.dto';
import { UpsertEstructuraDto } from './dto/upsert-estructura.dto';

const ORDEN_SECCION = { orden: 'asc' as const };
const INCLUDE_ESTRUCTURA = {
  orderBy: ORDEN_SECCION,
  include: {
    grupos: {
      orderBy: ORDEN_SECCION,
      include: { items: { orderBy: ORDEN_SECCION } },
    },
    items: { where: { grupoId: null }, orderBy: ORDEN_SECCION },
  },
};
const ROLES_FIRMA_DEFECTO = ['Preparó', 'Revisó', 'Aprobó'];

@Injectable()
export class ChecklistPlantillasService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: StorageService,
  ) {}

  async findAll() {
    return this.prisma.checklistPlantilla.findMany({
      orderBy: { updatedAt: 'desc' },
      include: { _count: { select: { secciones: true, instancias: true } } },
    });
  }

  async findOne(id: string) {
    const plantilla = await this.prisma.checklistPlantilla.findUnique({
      where: { id },
      include: {
        secciones: INCLUDE_ESTRUCTURA,
        rolesFirma: { orderBy: ORDEN_SECCION },
      },
    });
    if (!plantilla) {
      throw new NotFoundException('Plantilla no encontrada');
    }
    return this.withLogoUrls(plantilla);
  }

  async create(dto: CreatePlantillaDto, userId: string) {
    if (dto.duplicarDeId) {
      const origen = await this.findOne(dto.duplicarDeId);
      const creada = await this.prisma.checklistPlantilla.create({
        data: {
          nombre: dto.nombre,
          descripcion: dto.descripcion,
          logoEmpresaKey: origen.logoEmpresaKey,
          logoClienteKey: origen.logoClienteKey,
          creadoPorId: userId,
        },
      });
      await this.reemplazarEstructura(creada.id, {
        secciones: origen.secciones.map((s) => ({
          titulo: s.titulo,
          items: s.items.map((i) => ({ descripcion: i.descripcion, requiereObservacion: i.requiereObservacion })),
          grupos: s.grupos.map((g) => ({
            titulo: g.titulo,
            items: g.items.map((i) => ({ descripcion: i.descripcion, requiereObservacion: i.requiereObservacion })),
          })),
        })),
        rolesFirma: origen.rolesFirma.map((r) => r.nombre),
      });
      return this.findOne(creada.id);
    }

    const creada = await this.prisma.checklistPlantilla.create({
      data: { nombre: dto.nombre, descripcion: dto.descripcion, creadoPorId: userId },
    });
    await this.prisma.checklistPlantillaRolFirma.createMany({
      data: ROLES_FIRMA_DEFECTO.map((nombre, orden) => ({ plantillaId: creada.id, nombre, orden })),
    });
    return this.findOne(creada.id);
  }

  async update(id: string, dto: UpdatePlantillaDto) {
    await this.findOne(id);
    return this.prisma.checklistPlantilla.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    await this.findOne(id);
    await this.prisma.checklistPlantilla.delete({ where: { id } });
  }

  async reemplazarEstructura(id: string, dto: UpsertEstructuraDto) {
    await this.findOne(id);

    await this.prisma.$transaction(async (tx) => {
      await tx.checklistPlantillaSeccion.deleteMany({ where: { plantillaId: id } });

      for (const [seccionIndex, seccion] of dto.secciones.entries()) {
        const seccionCreada = await tx.checklistPlantillaSeccion.create({
          data: {
            plantillaId: id,
            numero: seccionIndex + 1,
            titulo: seccion.titulo,
            orden: seccionIndex,
          },
        });

        for (const [itemIndex, item] of (seccion.items ?? []).entries()) {
          await tx.checklistPlantillaItem.create({
            data: {
              seccionId: seccionCreada.id,
              descripcion: item.descripcion,
              requiereObservacion: item.requiereObservacion ?? true,
              orden: itemIndex,
            },
          });
        }

        for (const [grupoIndex, grupo] of (seccion.grupos ?? []).entries()) {
          const grupoCreado = await tx.checklistPlantillaGrupo.create({
            data: { seccionId: seccionCreada.id, titulo: grupo.titulo, orden: grupoIndex },
          });

          for (const [itemIndex, item] of grupo.items.entries()) {
            await tx.checklistPlantillaItem.create({
              data: {
                seccionId: seccionCreada.id,
                grupoId: grupoCreado.id,
                descripcion: item.descripcion,
                requiereObservacion: item.requiereObservacion ?? true,
                orden: itemIndex,
              },
            });
          }
        }
      }

      if (dto.rolesFirma) {
        await tx.checklistPlantillaRolFirma.deleteMany({ where: { plantillaId: id } });
        await tx.checklistPlantillaRolFirma.createMany({
          data: dto.rolesFirma.map((nombre, orden) => ({ plantillaId: id, nombre, orden })),
        });
      }
    });

    return this.findOne(id);
  }

  async uploadLogo(id: string, tipo: 'empresa' | 'cliente', file: Express.Multer.File) {
    await this.findOne(id);
    const { key } = await this.storage.upload(file, 'logos');
    const data = tipo === 'empresa' ? { logoEmpresaKey: key } : { logoClienteKey: key };
    await this.prisma.checklistPlantilla.update({ where: { id }, data });
    return this.findOne(id);
  }

  private async withLogoUrls<T extends { logoEmpresaKey: string | null; logoClienteKey: string | null }>(
    plantilla: T,
  ) {
    return {
      ...plantilla,
      logoEmpresaUrl: plantilla.logoEmpresaKey
        ? await this.storage.getPresignedUrl(plantilla.logoEmpresaKey)
        : null,
      logoClienteUrl: plantilla.logoClienteKey
        ? await this.storage.getPresignedUrl(plantilla.logoClienteKey)
        : null,
    };
  }
}
