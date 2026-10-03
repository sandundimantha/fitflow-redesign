import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { SocialController } from './social.controller';
import { SocialService } from './social.service';
import { SocialGateway } from './social.gateway';
import { SocialPost, SocialPostSchema } from './schemas/post.schema';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: SocialPost.name, schema: SocialPostSchema }]),
  ],
  controllers: [SocialController],
  providers: [SocialService, SocialGateway],
  exports: [SocialService],
})
export class SocialModule {}
