-- CreateEnum
CREATE TYPE "Role" AS ENUM ('ADMIN', 'SUPERVISOR', 'TECNICO');

-- CreateEnum
CREATE TYPE "LevantamientoEstado" AS ENUM ('PENDIENTE', 'EN_PROGRESO', 'COMPLETADO');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'TECNICO',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "levantamientos" (
    "id" TEXT NOT NULL,
    "titulo" TEXT NOT NULL,
    "descripcion" TEXT,
    "direccion" TEXT,
    "estado" "LevantamientoEstado" NOT NULL DEFAULT 'PENDIENTE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "creadoPorId" TEXT NOT NULL,

    CONSTRAINT "levantamientos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "capturas" (
    "id" TEXT NOT NULL,
    "fileKey" TEXT NOT NULL,
    "fileName" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "size" INTEGER NOT NULL,
    "tipo" TEXT NOT NULL DEFAULT 'foto',
    "notas" TEXT,
    "latitud" DOUBLE PRECISION,
    "longitud" DOUBLE PRECISION,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "levantamientoId" TEXT NOT NULL,
    "subidoPorId" TEXT NOT NULL,

    CONSTRAINT "capturas_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- AddForeignKey
ALTER TABLE "levantamientos" ADD CONSTRAINT "levantamientos_creadoPorId_fkey" FOREIGN KEY ("creadoPorId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "capturas" ADD CONSTRAINT "capturas_levantamientoId_fkey" FOREIGN KEY ("levantamientoId") REFERENCES "levantamientos"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "capturas" ADD CONSTRAINT "capturas_subidoPorId_fkey" FOREIGN KEY ("subidoPorId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
