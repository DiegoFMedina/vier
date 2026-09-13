import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { LevantamientosModule } from './levantamientos/levantamientos.module';
import { CapturasModule } from './capturas/capturas.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    LevantamientosModule,
    CapturasModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
