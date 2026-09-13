import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { FirmasService } from './firmas.service';
import { CreateFirmaGuardadaDto } from './dto/create-firma-guardada.dto';

@Controller('firmas')
@UseGuards(JwtAuthGuard)
export class FirmasController {
  constructor(private readonly service: FirmasService) {}

  @Get()
  findMine(@CurrentUser() user: { userId: string }) {
    return this.service.findMine(user.userId);
  }

  @Post()
  @UseInterceptors(FileInterceptor('file'))
  create(
    @Body() dto: CreateFirmaGuardadaDto,
    @UploadedFile() file: Express.Multer.File,
    @CurrentUser() user: { userId: string },
  ) {
    if (!file) {
      throw new BadRequestException('Falta el archivo de la firma');
    }
    return this.service.create(user.userId, dto.tipo, dto.etiqueta, file);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @CurrentUser() user: { userId: string }) {
    return this.service.remove(user.userId, id);
  }
}
