import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { PrismaModule } from './prisma/prisma.module';
import { RedisModule } from './redis/redis.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { WorkoutsModule } from './workouts/workouts.module';
import { NutritionModule } from './nutrition/nutrition.module';
import { AiPlansModule } from './ai-plans/ai-plans.module';
import { SocialModule } from './social/social.module';
import { NotificationsModule } from './notifications/notifications.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    PrismaModule,
    RedisModule,
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => ({
        uri: configService.get<string>('MONGODB_URI', 'mongodb://localhost:27017/fitflow_mongo'),
        serverSelectionTimeoutMS: 2000,
        connectTimeoutMS: 2000,
      }),
      inject: [ConfigService],
    }),
    AuthModule,
    UsersModule,
    WorkoutsModule,
    NutritionModule,
    AiPlansModule,
    SocialModule,
    NotificationsModule,
  ],
})
export class AppModule {}
