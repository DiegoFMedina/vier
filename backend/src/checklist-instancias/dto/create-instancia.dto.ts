import { IsOptional, IsString, IsUUID } from 'class-validator';

export class CreateInstanciaDto {
  @IsUUID()
  plantillaId: string;

  @IsOptional()
  @IsString()
  nombre?: string;
}
