import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { StorageService } from '../storage/storage.service';
import { ChecklistPlantillasService } from '../checklist-plantillas/checklist-plantillas.service';
import { CreateInstanciaDto } from './dto/create-instancia.dto';
import { UpdateInstanciaDto } from './dto/update-instancia.dto';
import { ResponderItemDto } from './dto/responder-item.dto';
import { CreateRevisionDto } from './dto/create-revision.dto';
import { UpdateFirmaDto } from './dto/update-firma.dto';
import { TipoFirmaDto } from './dto/firmar.dto';

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
        firmas: { orderBy: ORDEN },
        revisiones: { orderBy: { createdAt: 'asc' } },
      },
    });
    if (!instancia) {
      throw new NotFoundException('Checklist no encontrado');
    }
    const firmas = await Promise.all(
      instancia.firmas.map(async (f) => ({
        ...f,
        firmaUrl: f.firmaKey ? await this.storage.getPresignedUrl(f.firmaKey) : null,
      })),
    );
    return {
      ...instancia,
      firmas,
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

    if (plantilla.rolesFirma.length > 0) {
      await this.prisma.checklistInstanciaFirma.createMany({
        data: plantilla.rolesFirma.map((rol) => ({
          instanciaId: instancia.id,
          rolNombre: rol.nombre,
          orden: rol.orden,
        })),
      });
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
      data: {
        instanciaId,
        revision: dto.revision,
        descripcion: dto.descripcion,
        aprobaciones: dto.aprobaciones ? JSON.parse(JSON.stringify(dto.aprobaciones)) : undefined,
      },
    });
    return this.findOne(instanciaId);
  }

  private async findFirma(instanciaId: string, firmaId: string) {
    const firma = await this.prisma.checklistInstanciaFirma.findFirst({
      where: { id: firmaId, instanciaId },
    });
    if (!firma) {
      throw new NotFoundException('Firma no encontrada en este checklist');
    }
    return firma;
  }

  async actualizarFirma(instanciaId: string, firmaId: string, dto: UpdateFirmaDto) {
    await this.findFirma(instanciaId, firmaId);
    await this.prisma.checklistInstanciaFirma.update({
      where: { id: firmaId },
      data: {
        nombrePersona: dto.nombrePersona,
        fecha: dto.fecha ? new Date(dto.fecha) : undefined,
      },
    });
    return this.findOne(instanciaId);
  }

  async firmarConArchivo(
    instanciaId: string,
    firmaId: string,
    tipo: TipoFirmaDto,
    file: Express.Multer.File,
    guardarComo: string | undefined,
    userId: string,
  ) {
    await this.findFirma(instanciaId, firmaId);
    if (!file) {
      throw new BadRequestException('Falta la imagen de la firma');
    }
    const { key } = await this.storage.upload(file, 'firmas');

    await this.prisma.checklistInstanciaFirma.update({
      where: { id: firmaId },
      data: { firmaKey: key, firmaTipo: tipo },
    });

    if (guardarComo?.trim()) {
      await this.prisma.firmaGuardada.create({
        data: { userId, etiqueta: guardarComo.trim(), tipo, fileKey: key },
      });
    }

    return this.findOne(instanciaId);
  }

  async firmarConGuardada(instanciaId: string, firmaId: string, firmaGuardadaId: string, userId: string) {
    await this.findFirma(instanciaId, firmaId);
    const guardada = await this.prisma.firmaGuardada.findFirst({
      where: { id: firmaGuardadaId, userId },
    });
    if (!guardada) {
      throw new NotFoundException('Firma guardada no encontrada');
    }
    await this.prisma.checklistInstanciaFirma.update({
      where: { id: firmaId },
      data: { firmaKey: guardada.fileKey, firmaTipo: guardada.tipo },
    });
    return this.findOne(instanciaId);
  }

  async borrarFirma(instanciaId: string, firmaId: string) {
    await this.findFirma(instanciaId, firmaId);
    await this.prisma.checklistInstanciaFirma.update({
      where: { id: firmaId },
      data: { firmaKey: null, firmaTipo: null },
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
