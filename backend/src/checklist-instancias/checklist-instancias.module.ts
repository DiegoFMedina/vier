import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { StorageModule } from '../storage/storage.module';
import { ChecklistPlantillasModule } from '../checklist-plantillas/checklist-plantillas.module';
import { ChecklistInstanciasService } from './checklist-instancias.service';
import { ChecklistInstanciasController } from './checklist-instancias.controller';
import { ChecklistPdfService } from './checklist-pdf.service';
import { ChecklistDocxService } from './checklist-docx.service';

@Module({
  imports: [StorageModule, ChecklistPlantillasModule, PassportModule.register({ defaultStrategy: 'jwt' })],
  providers: [ChecklistInstanciasService, ChecklistPdfService, ChecklistDocxService],
  controllers: [ChecklistInstanciasController],
})
export class ChecklistInstanciasModule {}
