import { IsLatitude, IsLongitude, IsOptional, IsString } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateCapturaDto {
  @IsOptional()
  @IsString()
  notas?: string;

  @IsOptional()
  @Type(() => Number)
  @IsLatitude()
  latitud?: number;

  @IsOptional()
  @Type(() => Number)
  @IsLongitude()
  longitud?: number;
}
