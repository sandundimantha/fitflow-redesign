import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type PostDocument = SocialPost & Document;

@Schema({ timestamps: true })
export class SocialComment {
  @Prop({ required: true })
  id: string;

  @Prop({ required: true })
  userId: string;

  @Prop({ required: true })
  authorName: string;

  @Prop()
  authorAvatar?: string;

  @Prop({ required: true })
  text: string;

  @Prop({ default: Date.now })
  createdAt: Date;
}

@Schema({ timestamps: true })
export class SocialPost {
  @Prop({ required: true })
  userId: string;

  @Prop({ required: true })
  authorName: string;

  @Prop()
  authorAvatar?: string;

  @Prop({ required: true })
  content: string;

  @Prop()
  mediaUrl?: string;

  @Prop()
  challengeId?: string;

  @Prop()
  challengeName?: string;

  @Prop({ default: 0 })
  likesCount: number;

  @Prop({ type: [String], default: [] })
  likedBy: string[];

  @Prop({ type: [Object], default: [] })
  comments: SocialComment[];
}

export const SocialPostSchema = SchemaFactory.createForClass(SocialPost);
