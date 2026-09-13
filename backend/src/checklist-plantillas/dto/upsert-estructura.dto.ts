import { Type } from 'class-transformer';
import { ArrayMinSize, IsArray, IsBoolean, IsOptional, IsString, MinLength, ValidateNested } from 'class-validator';

export class PlantillaItemDto {
  @IsString()
  @MinLength(1)
  descripcion: string;

  @IsOptional()
  @IsBoolean()
  requiereObservacion?: boolean;
}

export class PlantillaGrupoDto {
  @IsString()
  @MinLength(1)
  titulo: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => PlantillaItemDto)
  items: PlantillaItemDto[];
}

export class PlantillaSeccionDto {
  @IsString()
  @MinLength(1)
  titulo: string;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => PlantillaItemDto)
  items?: PlantillaItemDto[];

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => PlantillaGrupoDto)
  grupos?: PlantillaGrupoDto[];
}

export class UpsertEstructuraDto {
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => PlantillaSeccionDto)
  secciones: PlantillaSeccionDto[];
}
