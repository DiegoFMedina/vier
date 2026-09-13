import { IsEnum, IsOptional, IsString } from 'class-validator';

export enum TipoFirmaDto {
  DIBUJADA = 'DIBUJADA',
  FOTO = 'FOTO',
}

export class FirmarDto {
  @IsEnum(TipoFirmaDto)
  tipo: TipoFirmaDto;

  /** Si viene, además guarda esta firma como reutilizable con esta etiqueta. */
  @IsOptional()
  @IsString()
  guardarComo?: string;
}

export class FirmarConGuardadaDto {
  @IsString()
  firmaGuardadaId: string;
}
