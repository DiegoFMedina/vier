import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { CapturasService } from './capturas.service';
import { CapturasController } from './capturas.controller';
import { StorageModule } from '../storage/storage.module';

@Module({
  imports: [StorageModule, PassportModule.register({ defaultStrategy: 'jwt' })],
  providers: [CapturasService],
  controllers: [CapturasController],
})
export class CapturasModule {}
