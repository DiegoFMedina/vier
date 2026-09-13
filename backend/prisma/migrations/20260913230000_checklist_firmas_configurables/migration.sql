-- CreateEnum
CREATE TYPE "TipoFirma" AS ENUM ('DIBUJADA', 'FOTO');

-- CreateTable
CREATE TABLE "firmas_guardadas" (
    "id" TEXT NOT NULL,
    "etiqueta" TEXT NOT NULL,
    "tipo" "TipoFirma" NOT NULL,
    "fileKey" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "userId" TEXT NOT NULL,

    CONSTRAINT "firmas_guardadas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checklist_plantilla_roles_firma" (
    "id" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "orden" INTEGER NOT NULL,
    "plantillaId" TEXT NOT NULL,

    CONSTRAINT "checklist_plantilla_roles_firma_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checklist_instancia_firmas" (
    "id" TEXT NOT NULL,
    "rolNombre" TEXT NOT NULL,
    "orden" INTEGER NOT NULL,
    "nombrePersona" TEXT,
    "fecha" TIMESTAMP(3),
    "firmaKey" TEXT,
    "firmaTipo" "TipoFirma",
    "instanciaId" TEXT NOT NULL,

    CONSTRAINT "checklist_instancia_firmas_pkey" PRIMARY KEY ("id")
);

-- AlterTable: se agrega la columna nueva de aprobaciones, pero las 3
-- columnas fijas viejas se conservan por ahora para poder migrar sus datos.
ALTER TABLE "checklist_revision_historial" ADD COLUMN "aprobaciones" JSONB;

-- AddForeignKey
ALTER TABLE "firmas_guardadas" ADD CONSTRAINT "firmas_guardadas_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_plantilla_roles_firma" ADD CONSTRAINT "checklist_plantilla_roles_firma_plantillaId_fkey" FOREIGN KEY ("plantillaId") REFERENCES "checklist_plantillas"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_instancia_firmas" ADD CONSTRAINT "checklist_instancia_firmas_instanciaId_fkey" FOREIGN KEY ("instanciaId") REFERENCES "checklist_instancias"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Datos: se agregan los 3 roles por defecto (Preparó/Revisó/Aprobó) a las
-- plantillas existentes, para que no queden sin roles de firma configurados.
INSERT INTO "checklist_plantilla_roles_firma" ("id", "nombre", "orden", "plantillaId")
SELECT gen_random_uuid(), 'Preparó', 0, "id" FROM "checklist_plantillas"
UNION ALL
SELECT gen_random_uuid(), 'Revisó', 1, "id" FROM "checklist_plantillas"
UNION ALL
SELECT gen_random_uuid(), 'Aprobó', 2, "id" FROM "checklist_plantillas";

-- Datos: se preservan los valores ya cargados de Preparó/Revisó/Aprobó de
-- cada checklist existente, migrándolos a la nueva tabla de firmas.
INSERT INTO "checklist_instancia_firmas" ("id", "rolNombre", "orden", "nombrePersona", "fecha", "instanciaId")
SELECT gen_random_uuid(), 'Preparó', 0, "preparadoPorNombre", "preparadoPorFecha", "id" FROM "checklist_instancias"
UNION ALL
SELECT gen_random_uuid(), 'Revisó', 1, "revisadoPorNombre", "revisadoPorFecha", "id" FROM "checklist_instancias"
UNION ALL
SELECT gen_random_uuid(), 'Aprobó', 2, "aprobadoPorNombre", "aprobadoPorFecha", "id" FROM "checklist_instancias";

-- Datos: se migran las 3 columnas fijas de aprobación del historial de
-- revisiones al nuevo campo JSON "aprobaciones".
UPDATE "checklist_revision_historial"
SET "aprobaciones" = jsonb_build_array(
  jsonb_build_object('rol', 'Gerencia General', 'valor', "aprobacionGerenciaGeneral"),
  jsonb_build_object('rol', 'Depto. Ingeniería', 'valor', "aprobacionDeptoIngenieria"),
  jsonb_build_object('rol', 'Jefe Proyecto', 'valor', "aprobacionClienteJefeProyecto")
);

-- AlterTable: ahora sí se eliminan las columnas fijas ya migradas.
ALTER TABLE "checklist_instancias"
  DROP COLUMN "aprobadoPorFecha",
  DROP COLUMN "aprobadoPorNombre",
  DROP COLUMN "preparadoPorFecha",
  DROP COLUMN "preparadoPorNombre",
  DROP COLUMN "revisadoPorFecha",
  DROP COLUMN "revisadoPorNombre";

ALTER TABLE "checklist_revision_historial"
  DROP COLUMN "aprobacionClienteJefeProyecto",
  DROP COLUMN "aprobacionDeptoIngenieria",
  DROP COLUMN "aprobacionGerenciaGeneral";
