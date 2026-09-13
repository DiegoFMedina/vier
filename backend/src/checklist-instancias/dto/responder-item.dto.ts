import { IsEnum, IsOptional, IsString } from 'class-validator';

export enum ChecklistRespuestaDto {
  SI = 'SI',
  NO = 'NO',
}

export class ResponderItemDto {
  @IsOptional()
  @IsEnum(ChecklistRespuestaDto)
  valor?: ChecklistRespuestaDto | null;

  @IsOptional()
  @IsString()
  observaciones?: string;
}
