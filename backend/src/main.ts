import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const config = app.get(ConfigService);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: false,
    }),
  );

  app.enableCors({
    origin: config.get<string>('CORS_ORIGIN', '*'),
    credentials: true,
  });

  app.setGlobalPrefix('api');

  const port = config.get<number>('PORT', 3000);
  await app.listen(port, '0.0.0.0');
  // eslint-disable-next-line no-console
  console.log(`Backend escuchando en http://0.0.0.0:${port}/api`);
}

bootstrap();
