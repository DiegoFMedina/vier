import { IsOptional, IsString, MinLength } from 'class-validator';

export class CreateLevantamientoDto {
  @IsString()
  @MinLength(3)
  titulo: string;

  @IsOptional()
  @IsString()
  descripcion?: string;

  @IsOptional()
  @IsString()
  direccion?: string;
}
