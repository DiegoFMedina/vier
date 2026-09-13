import { IsOptional, IsString, IsUUID, MinLength } from 'class-validator';

export class CreatePlantillaDto {
  @IsString()
  @MinLength(3)
  nombre: string;

  @IsOptional()
  @IsString()
  descripcion?: string;

  @IsOptional()
  @IsUUID()
  duplicarDeId?: string;
}
