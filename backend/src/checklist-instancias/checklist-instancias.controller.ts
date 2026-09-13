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
  Res,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import type { Response } from 'express';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ChecklistInstanciasService } from './checklist-instancias.service';
import { ChecklistPdfService, ChecklistInstanciaDetalle } from './checklist-pdf.service';
import { ChecklistDocxService } from './checklist-docx.service';
import { CreateInstanciaDto } from './dto/create-instancia.dto';
import { UpdateInstanciaDto } from './dto/update-instancia.dto';
import { ResponderItemDto } from './dto/responder-item.dto';
import { CreateRevisionDto } from './dto/create-revision.dto';
import { UpdateFirmaDto } from './dto/update-firma.dto';
import { FirmarConGuardadaDto, FirmarDto } from './dto/firmar.dto';

enum LogoTipo {
  empresa = 'empresa',
  cliente = 'cliente',
}

@Controller()
@UseGuards(JwtAuthGuard)
export class ChecklistInstanciasController {
  constructor(
    private readonly service: ChecklistInstanciasService,
    private readonly pdf: ChecklistPdfService,
    private readonly docx: ChecklistDocxService,
  ) {}

  @Get('levantamientos/:levantamientoId/checklists')
  findByLevantamiento(@Param('levantamientoId') levantamientoId: string) {
    return this.service.findByLevantamiento(levantamientoId);
  }

  @Post('levantamientos/:levantamientoId/checklists')
  create(
    @Param('levantamientoId') levantamientoId: string,
    @Body() dto: CreateInstanciaDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.service.create(levantamientoId, dto, user.userId);
  }

  @Get('checklists/:id')
  findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }

  @Patch('checklists/:id')
  update(@Param('id') id: string, @Body() dto: UpdateInstanciaDto) {
    return this.service.update(id, dto);
  }

  @Patch('checklists/:id/items/:itemId')
  responderItem(
    @Param('id') id: string,
    @Param('itemId') itemId: string,
    @Body() dto: ResponderItemDto,
  ) {
    return this.service.responderItem(id, itemId, dto);
  }

  @Post('checklists/:id/revisiones')
  addRevision(@Param('id') id: string, @Body() dto: CreateRevisionDto) {
    return this.service.addRevision(id, dto);
  }

  @Patch('checklists/:id/firmas/:firmaId')
  actualizarFirma(
    @Param('id') id: string,
    @Param('firmaId') firmaId: string,
    @Body() dto: UpdateFirmaDto,
  ) {
    return this.service.actualizarFirma(id, firmaId, dto);
  }

  @Post('checklists/:id/firmas/:firmaId/imagen')
  @UseInterceptors(FileInterceptor('file'))
  firmarConArchivo(
    @Param('id') id: string,
    @Param('firmaId') firmaId: string,
    @Body() dto: FirmarDto,
    @UploadedFile() file: Express.Multer.File,
    @CurrentUser() user: { userId: string },
  ) {
    return this.service.firmarConArchivo(id, firmaId, dto.tipo, file, dto.guardarComo, user.userId);
  }

  @Post('checklists/:id/firmas/:firmaId/usar-guardada')
  firmarConGuardada(
    @Param('id') id: string,
    @Param('firmaId') firmaId: string,
    @Body() dto: FirmarConGuardadaDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.service.firmarConGuardada(id, firmaId, dto.firmaGuardadaId, user.userId);
  }

  @Delete('checklists/:id/firmas/:firmaId/imagen')
  borrarFirma(@Param('id') id: string, @Param('firmaId') firmaId: string) {
    return this.service.borrarFirma(id, firmaId);
  }

  @Post('checklists/:id/logo')
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

  @Get('checklists/:id/pdf')
  async descargarPdf(@Param('id') id: string, @Res() res: Response) {
    const instancia = await this.service.findOne(id);
    const buffer = await this.pdf.generar(instancia as unknown as ChecklistInstanciaDetalle);
    res.set({
      'Content-Type': 'application/pdf',
      'Content-Disposition': `attachment; filename="checklist-${id}.pdf"`,
      'Content-Length': buffer.length,
    });
    res.end(buffer);
  }

  @Get('checklists/:id/docx')
  async descargarDocx(@Param('id') id: string, @Res() res: Response) {
    const instancia = await this.service.findOne(id);
    const buffer = await this.docx.generar(instancia as unknown as ChecklistInstanciaDetalle);
    res.set({
      'Content-Type': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'Content-Disposition': `attachment; filename="checklist-${id}.docx"`,
      'Content-Length': buffer.length,
    });
    res.end(buffer);
  }

  @Delete('checklists/:id')
  remove(@Param('id') id: string) {
    return this.service.remove(id);
  }
}
