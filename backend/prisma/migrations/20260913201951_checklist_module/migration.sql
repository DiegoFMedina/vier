-- CreateEnum
CREATE TYPE "ChecklistRespuesta" AS ENUM ('SI', 'NO');

-- CreateEnum
CREATE TYPE "ChecklistEstado" AS ENUM ('BORRADOR', 'EN_REVISION', 'APROBADO');

-- CreateTable
CREATE TABLE "checklist_plantillas" (
    "id" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "descripcion" TEXT,
    "logoEmpresaKey" TEXT,
    "logoClienteKey" TEXT,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "creadoPorId" TEXT NOT NULL,

    CONSTRAINT "checklist_plantillas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checklist_plantilla_secciones" (
    "id" TEXT NOT NULL,
    "numero" INTEGER NOT NULL,
    "titulo" TEXT NOT NULL,
    "orden" INTEGER NOT NULL,
    "plantillaId" TEXT NOT NULL,

    CONSTRAINT "checklist_plantilla_secciones_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checklist_plantilla_grupos" (
    "id" TEXT NOT NULL,
    "titulo" TEXT NOT NULL,
    "orden" INTEGER NOT NULL,
    "seccionId" TEXT NOT NULL,

    CONSTRAINT "checklist_plantilla_grupos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checklist_plantilla_items" (
    "id" TEXT NOT NULL,
    "descripcion" TEXT NOT NULL,
    "orden" INTEGER NOT NULL,
    "requiereObservacion" BOOLEAN NOT NULL DEFAULT true,
    "seccionId" TEXT NOT NULL,
    "grupoId" TEXT,

    CONSTRAINT "checklist_plantilla_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checklist_instancias" (
    "id" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "logoEmpresaKey" TEXT,
    "logoClienteKey" TEXT,
    "estado" "ChecklistEstado" NOT NULL DEFAULT 'BORRADOR',
    "contratoNumero" TEXT,
    "numeroDocumentoCliente" TEXT,
    "numeroDocumentoInterno" TEXT,
    "estacion" TEXT,
    "revisionActual" TEXT NOT NULL DEFAULT 'A',
    "fecha" TIMESTAMP(3),
    "preparadoPorNombre" TEXT,
    "preparadoPorFecha" TIMESTAMP(3),
    "revisadoPorNombre" TEXT,
    "revisadoPorFecha" TIMESTAMP(3),
    "aprobadoPorNombre" TEXT,
    "aprobadoPorFecha" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "levantamientoId" TEXT NOT NULL,
    "plantillaId" TEXT,
    "creadoPorId" TEXT NOT NULL,

    CONSTRAINT "checklist_instancias_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checklist_instancia_secciones" (
    "id" TEXT NOT NULL,
    "numero" INTEGER NOT NULL,
    "titulo" TEXT NOT NULL,
    "orden" INTEGER NOT NULL,
    "instanciaId" TEXT NOT NULL,

    CONSTRAINT "checklist_instancia_secciones_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checklist_instancia_grupos" (
    "id" TEXT NOT NULL,
    "titulo" TEXT NOT NULL,
    "orden" INTEGER NOT NULL,
    "seccionId" TEXT NOT NULL,

    CONSTRAINT "checklist_instancia_grupos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checklist_instancia_items" (
    "id" TEXT NOT NULL,
    "descripcion" TEXT NOT NULL,
    "orden" INTEGER NOT NULL,
    "requiereObservacion" BOOLEAN NOT NULL DEFAULT true,
    "valor" "ChecklistRespuesta",
    "observaciones" TEXT,
    "seccionId" TEXT NOT NULL,
    "grupoId" TEXT,

    CONSTRAINT "checklist_instancia_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checklist_revision_historial" (
    "id" TEXT NOT NULL,
    "revision" TEXT NOT NULL,
    "descripcion" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "aprobacionGerenciaGeneral" TEXT,
    "aprobacionDeptoIngenieria" TEXT,
    "aprobacionClienteJefeProyecto" TEXT,
    "instanciaId" TEXT NOT NULL,

    CONSTRAINT "checklist_revision_historial_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "checklist_plantillas" ADD CONSTRAINT "checklist_plantillas_creadoPorId_fkey" FOREIGN KEY ("creadoPorId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_plantilla_secciones" ADD CONSTRAINT "checklist_plantilla_secciones_plantillaId_fkey" FOREIGN KEY ("plantillaId") REFERENCES "checklist_plantillas"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_plantilla_grupos" ADD CONSTRAINT "checklist_plantilla_grupos_seccionId_fkey" FOREIGN KEY ("seccionId") REFERENCES "checklist_plantilla_secciones"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_plantilla_items" ADD CONSTRAINT "checklist_plantilla_items_seccionId_fkey" FOREIGN KEY ("seccionId") REFERENCES "checklist_plantilla_secciones"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_plantilla_items" ADD CONSTRAINT "checklist_plantilla_items_grupoId_fkey" FOREIGN KEY ("grupoId") REFERENCES "checklist_plantilla_grupos"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_instancias" ADD CONSTRAINT "checklist_instancias_levantamientoId_fkey" FOREIGN KEY ("levantamientoId") REFERENCES "levantamientos"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_instancias" ADD CONSTRAINT "checklist_instancias_plantillaId_fkey" FOREIGN KEY ("plantillaId") REFERENCES "checklist_plantillas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_instancias" ADD CONSTRAINT "checklist_instancias_creadoPorId_fkey" FOREIGN KEY ("creadoPorId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_instancia_secciones" ADD CONSTRAINT "checklist_instancia_secciones_instanciaId_fkey" FOREIGN KEY ("instanciaId") REFERENCES "checklist_instancias"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_instancia_grupos" ADD CONSTRAINT "checklist_instancia_grupos_seccionId_fkey" FOREIGN KEY ("seccionId") REFERENCES "checklist_instancia_secciones"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_instancia_items" ADD CONSTRAINT "checklist_instancia_items_seccionId_fkey" FOREIGN KEY ("seccionId") REFERENCES "checklist_instancia_secciones"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_instancia_items" ADD CONSTRAINT "checklist_instancia_items_grupoId_fkey" FOREIGN KEY ("grupoId") REFERENCES "checklist_instancia_grupos"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_revision_historial" ADD CONSTRAINT "checklist_revision_historial_instanciaId_fkey" FOREIGN KEY ("instanciaId") REFERENCES "checklist_instancias"("id") ON DELETE CASCADE ON UPDATE CASCADE;
