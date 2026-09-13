import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { LevantamientosService } from './levantamientos.service';
import { LevantamientosController } from './levantamientos.controller';

@Module({
  imports: [PassportModule.register({ defaultStrategy: 'jwt' })],
  providers: [LevantamientosService],
  controllers: [LevantamientosController],
})
export class LevantamientosModule {}
