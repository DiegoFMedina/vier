import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { StorageModule } from '../storage/storage.module';
import { FirmasService } from './firmas.service';
import { FirmasController } from './firmas.controller';

@Module({
  imports: [StorageModule, PassportModule.register({ defaultStrategy: 'jwt' })],
  providers: [FirmasService],
  controllers: [FirmasController],
})
export class FirmasModule {}
