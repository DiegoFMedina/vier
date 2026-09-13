import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { LevantamientosModule } from './levantamientos/levantamientos.module';
import { CapturasModule } from './capturas/capturas.module';
import { ChecklistPlantillasModule } from './checklist-plantillas/checklist-plantillas.module';
import { ChecklistInstanciasModule } from './checklist-instancias/checklist-instancias.module';
import { FirmasModule } from './firmas/firmas.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    LevantamientosModule,
    CapturasModule,
    ChecklistPlantillasModule,
    ChecklistInstanciasModule,
    FirmasModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
