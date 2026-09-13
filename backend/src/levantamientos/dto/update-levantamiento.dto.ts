import { IsEnum, IsOptional, IsString } from 'class-validator';

export enum LevantamientoEstadoDto {
  PENDIENTE = 'PENDIENTE',
  EN_PROGRESO = 'EN_PROGRESO',
  COMPLETADO = 'COMPLETADO',
}

export class UpdateLevantamientoDto {
  @IsOptional()
  @IsString()
  titulo?: string;

  @IsOptional()
  @IsString()
  descripcion?: string;

  @IsOptional()
  @IsString()
  direccion?: string;

  @IsOptional()
  @IsEnum(LevantamientoEstadoDto)
  estado?: LevantamientoEstadoDto;
}
