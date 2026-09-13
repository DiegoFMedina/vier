import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { StorageModule } from '../storage/storage.module';
import { ChecklistPlantillasService } from './checklist-plantillas.service';
import { ChecklistPlantillasController } from './checklist-plantillas.controller';

@Module({
  imports: [StorageModule, PassportModule.register({ defaultStrategy: 'jwt' })],
  providers: [ChecklistPlantillasService],
  controllers: [ChecklistPlantillasController],
  exports: [ChecklistPlantillasService],
})
export class ChecklistPlantillasModule {}
