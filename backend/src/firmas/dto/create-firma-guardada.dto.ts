import { IsEnum, IsOptional, IsString } from 'class-validator';

export enum TipoFirmaDto {
  DIBUJADA = 'DIBUJADA',
  FOTO = 'FOTO',
}

export class CreateFirmaGuardadaDto {
  @IsOptional()
  @IsString()
  etiqueta?: string;

  @IsEnum(TipoFirmaDto)
  tipo: TipoFirmaDto;
}
