import { IsDateString, IsOptional, IsString } from 'class-validator';

export class UpdateFirmaDto {
  @IsOptional()
  @IsString()
  nombrePersona?: string;

  @IsOptional()
  @IsDateString()
  fecha?: string;
}
