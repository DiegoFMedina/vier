import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import {
  CHECKLIST_EFE_DESCRIPCION,
  CHECKLIST_EFE_NOMBRE,
  CHECKLIST_EFE_SECCIONES,
} from './seed-data/checklist-efe';

const prisma = new PrismaClient();

async function main() {
  const passwordHash = await bcrypt.hash('vier1234', 10);

  const admin = await prisma.user.upsert({
    where: { email: 'admin@vier.cl' },
    update: {},
    create: {
      email: 'admin@vier.cl',
      passwordHash,
      nombre: 'Administrador',
      role: 'ADMIN',
    },
  });

  console.log('Usuario de prueba:', admin.email, '/ password: vier1234');

  await seedChecklistPorDefecto(admin.id);
}

async function seedChecklistPorDefecto(creadoPorId: string) {
  const existente = await prisma.checklistPlantilla.findFirst({
    where: { nombre: CHECKLIST_EFE_NOMBRE },
  });

  if (existente) {
    console.log('Plantilla de checklist por defecto ya existe, se omite.');
    return;
  }

  const plantilla = await prisma.checklistPlantilla.create({
    data: {
      nombre: CHECKLIST_EFE_NOMBRE,
      descripcion: CHECKLIST_EFE_DESCRIPCION,
      creadoPorId,
    },
  });

  for (const [seccionIndex, seccion] of CHECKLIST_EFE_SECCIONES.entries()) {
    const seccionCreada = await prisma.checklistPlantillaSeccion.create({
      data: {
        plantillaId: plantilla.id,
        numero: seccionIndex + 1,
        titulo: seccion.titulo,
        orden: seccionIndex,
      },
    });

    for (const [grupoIndex, grupo] of seccion.grupos.entries()) {
      const grupoCreado = await prisma.checklistPlantillaGrupo.create({
        data: { seccionId: seccionCreada.id, titulo: grupo.titulo, orden: grupoIndex },
      });

      for (const [itemIndex, item] of grupo.items.entries()) {
        await prisma.checklistPlantillaItem.create({
          data: {
            seccionId: seccionCreada.id,
            grupoId: grupoCreado.id,
            descripcion: item.descripcion,
            orden: itemIndex,
          },
        });
      }
    }
  }

  const totalItems = CHECKLIST_EFE_SECCIONES.reduce(
    (sum, s) => sum + s.grupos.reduce((sg, g) => sg + g.items.length, 0),
    0,
  );
  console.log(
    `Plantilla de checklist por defecto creada: "${CHECKLIST_EFE_NOMBRE}" (${CHECKLIST_EFE_SECCIONES.length} secciones, ${totalItems} ítems).`,
  );
}

main()
  .catch((err) => {
    console.error(err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
