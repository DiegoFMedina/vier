import { Type } from 'class-transformer';
import { IsArray, IsOptional, IsString, MinLength, ValidateNested } from 'class-validator';

export class AprobacionRevisionDto {
  @IsString()
  @MinLength(1)
  rol: string;

  @IsOptional()
  @IsString()
  valor?: string;
}

export class CreateRevisionDto {
  @IsString()
  @MinLength(1)
  revision: string;

  @IsString()
  @MinLength(1)
  descripcion: string;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => AprobacionRevisionDto)
  aprobaciones?: AprobacionRevisionDto[];
}
