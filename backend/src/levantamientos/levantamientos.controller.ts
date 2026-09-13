import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { LevantamientosService } from './levantamientos.service';
import { CreateLevantamientoDto } from './dto/create-levantamiento.dto';
import { UpdateLevantamientoDto } from './dto/update-levantamiento.dto';

@Controller('levantamientos')
@UseGuards(JwtAuthGuard)
export class LevantamientosController {
  constructor(private readonly service: LevantamientosService) {}

  @Get()
  findAll() {
    return this.service.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }

  @Post()
  create(@Body() dto: CreateLevantamientoDto, @CurrentUser() user: { userId: string }) {
    return this.service.create(dto, user.userId);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateLevantamientoDto) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.service.remove(id);
  }
}
