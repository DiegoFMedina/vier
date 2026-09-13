import {
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
import { CapturasService } from './capturas.service';
import { CreateCapturaDto } from './dto/create-captura.dto';

@Controller()
@UseGuards(JwtAuthGuard)
export class CapturasController {
  constructor(private readonly service: CapturasService) {}

  @Get('levantamientos/:levantamientoId/capturas')
  findByLevantamiento(@Param('levantamientoId') levantamientoId: string) {
    return this.service.findByLevantamiento(levantamientoId);
  }

  @Post('levantamientos/:levantamientoId/capturas')
  @UseInterceptors(FileInterceptor('file'))
  create(
    @Param('levantamientoId') levantamientoId: string,
    @UploadedFile() file: Express.Multer.File,
    @Body() dto: CreateCapturaDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.service.create(levantamientoId, file, dto, user.userId);
  }

  @Delete('capturas/:id')
  remove(@Param('id') id: string) {
    return this.service.remove(id);
  }
}
