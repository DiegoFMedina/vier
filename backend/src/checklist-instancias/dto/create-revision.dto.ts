import { IsOptional, IsString, MinLength } from 'class-validator';

export class CreateRevisionDto {
  @IsString()
  @MinLength(1)
  revision: string;

  @IsString()
  @MinLength(1)
  descripcion: string;

  @IsOptional()
  @IsString()
  aprobacionGerenciaGeneral?: string;

  @IsOptional()
  @IsString()
  aprobacionDeptoIngenieria?: string;

  @IsOptional()
  @IsString()
  aprobacionClienteJefeProyecto?: string;
}
