import { IsDateString, IsEnum, IsOptional, IsString } from 'class-validator';

export enum ChecklistEstadoDto {
  BORRADOR = 'BORRADOR',
  EN_REVISION = 'EN_REVISION',
  APROBADO = 'APROBADO',
}

export class UpdateInstanciaDto {
  @IsOptional()
  @IsString()
  nombre?: string;

  @IsOptional()
  @IsString()
  contratoNumero?: string;

  @IsOptional()
  @IsString()
  numeroDocumentoCliente?: string;

  @IsOptional()
  @IsString()
  numeroDocumentoInterno?: string;

  @IsOptional()
  @IsString()
  estacion?: string;

  @IsOptional()
  @IsString()
  revisionActual?: string;

  @IsOptional()
  @IsDateString()
  fecha?: string;

  @IsOptional()
  @IsString()
  preparadoPorNombre?: string;

  @IsOptional()
  @IsDateString()
  preparadoPorFecha?: string;

  @IsOptional()
  @IsString()
  revisadoPorNombre?: string;

  @IsOptional()
  @IsDateString()
  revisadoPorFecha?: string;

  @IsOptional()
  @IsString()
  aprobadoPorNombre?: string;

  @IsOptional()
  @IsDateString()
  aprobadoPorFecha?: string;

  @IsOptional()
  @IsEnum(ChecklistEstadoDto)
  estado?: ChecklistEstadoDto;

  @IsOptional()
  @IsString()
  comentarios?: string;
}
