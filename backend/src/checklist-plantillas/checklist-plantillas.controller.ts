import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseEnumPipe,
  Patch,
  Post,
  Put,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ChecklistPlantillasService } from './checklist-plantillas.service';
import { CreatePlantillaDto } from './dto/create-plantilla.dto';
import { UpdatePlantillaDto } from './dto/update-plantilla.dto';
import { UpsertEstructuraDto } from './dto/upsert-estructura.dto';

enum LogoTipo {
  empresa = 'empresa',
  cliente = 'cliente',
}

@Controller('checklist-plantillas')
@UseGuards(JwtAuthGuard)
export class ChecklistPlantillasController {
  constructor(private readonly service: ChecklistPlantillasService) {}

  @Get()
  findAll() {
    return this.service.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }

  @Post()
  create(@Body() dto: CreatePlantillaDto, @CurrentUser() user: { userId: string }) {
    return this.service.create(dto, user.userId);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdatePlantillaDto) {
    return this.service.update(id, dto);
  }

  @Put(':id/estructura')
  reemplazarEstructura(@Param('id') id: string, @Body() dto: UpsertEstructuraDto) {
    return this.service.reemplazarEstructura(id, dto);
  }

  @Post(':id/logo')
  @UseInterceptors(FileInterceptor('file'))
  uploadLogo(
    @Param('id') id: string,
    @Body('tipo', new ParseEnumPipe(LogoTipo)) tipo: LogoTipo,
    @UploadedFile() file: Express.Multer.File,
  ) {
    if (!file) {
      throw new BadRequestException('Falta el archivo del logo');
    }
    return this.service.uploadLogo(id, tipo, file);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.service.remove(id);
  }
}
