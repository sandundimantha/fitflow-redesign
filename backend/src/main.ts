import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const logger = new Logger('FitFlowBootstrap');
  const app = await NestFactory.create(AppModule, {
    cors: {
      origin: '*',
      methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
      credentials: true,
    },
  });

  // Global prefix for all REST endpoints
  app.setGlobalPrefix('api');

  // Input validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: false,
    }),
  );

  // OpenAPI / Swagger Documentation
  const swaggerConfig = new DocumentBuilder()
    .setTitle('FitFlow Core API Gateway')
    .setDescription(
      'FitFlow Fitness Redesign Backend API — powering authentication, workouts, nutrition caching, AI plans, and social feeds.'
    )
    .setVersion('1.0.0')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('api/docs', app, document);

  const port = process.env.PORT || 3000;
  await app.listen(port);
  logger.log(`🚀 FitFlow Core API Gateway running at http://localhost:${port}/api`);
  logger.log(`📚 OpenAPI / Swagger documentation active at http://localhost:${port}/api/docs`);
  logger.log(`⚡ WebSocket Social Gateway listening on ws://localhost:${port}/ws/feed`);
}

bootstrap();
