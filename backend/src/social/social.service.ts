import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { SocialPost, PostDocument } from './schemas/post.schema';
import { RedisService } from '../redis/redis.service';
import { PrismaService } from '../prisma/prisma.service';
import { SYSTEM_CONSTANTS } from '../common/constants/system.constants';

export interface CreatePostDto {
  content: string;
  mediaUrl?: string;
  challengeId?: string;
  challengeName?: string;
}

@Injectable()
export class SocialService {
  private readonly logger = new Logger(SocialService.name);

  constructor(
    @InjectModel(SocialPost.name)
    private readonly postModel: Model<PostDocument>,
    private readonly redis: RedisService,
    private readonly prisma: PrismaService,
  ) {}

  async getFeed(
    page: number = SYSTEM_CONSTANTS.PAGINATION.DEFAULT_PAGE,
    limit: number = SYSTEM_CONSTANTS.PAGINATION.DEFAULT_LIMIT,
  ) {
    try {
      return await this.postModel
        .find()
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .exec();
    } catch (e) {
      this.logger.warn(`Failed to fetch social feed from MongoDB: ${e.message}`);
      return [];
    }
  }

  async createPost(user: any, dto: CreatePostDto) {
    const postPayload = {
      userId: user.id,
      authorName: user.displayName || 'FitFlow Athlete',
      authorAvatar: user.avatarUrl || null,
      content: dto.content,
      mediaUrl: dto.mediaUrl || null,
      challengeId: dto.challengeId || null,
      challengeName: dto.challengeName || null,
      likesCount: 0,
      likedBy: [],
      comments: [],
    };

    let createdPost;
    try {
      createdPost = await this.postModel.create(postPayload);
    } catch (e) {
      this.logger.error(`Error saving post to MongoDB: ${e.message}`);
      throw e;
    }

    // Publish to Redis Pub/Sub for WebSocket distribution
    await this.redis.publish(
      SYSTEM_CONSTANTS.REDIS_CHANNELS.SOCIAL_FEED,
      JSON.stringify({ type: 'NEW_POST', data: createdPost }),
    );

    return createdPost;
  }

  async toggleLike(postId: string, userId: string) {
    const post = await this.postModel.findById(postId);
    if (!post) {
      throw new NotFoundException(`Post with ID ${postId} not found`);
    }

    const idx = post.likedBy.indexOf(userId);
    if (idx === -1) {
      post.likedBy.push(userId);
      post.likesCount += 1;
    } else {
      post.likedBy.splice(idx, 1);
      post.likesCount = Math.max(0, post.likesCount - 1);
    }

    await post.save();

    await this.redis.publish(
      SYSTEM_CONSTANTS.REDIS_CHANNELS.SOCIAL_FEED,
      JSON.stringify({ type: 'POST_LIKED', data: post }),
    );

    return post;
  }

  async addComment(postId: string, user: any, text: string) {
    const post = await this.postModel.findById(postId);
    if (!post) {
      throw new NotFoundException(`Post with ID ${postId} not found`);
    }

    const comment = {
      id: `c_${Date.now()}`,
      userId: user.id,
      authorName: user.displayName || 'FitFlow Athlete',
      authorAvatar: user.avatarUrl || null,
      text,
      createdAt: new Date(),
    };

    post.comments.push(comment);
    await post.save();

    await this.redis.publish(
      SYSTEM_CONSTANTS.REDIS_CHANNELS.SOCIAL_FEED,
      JSON.stringify({ type: 'NEW_COMMENT', data: { postId, comment } }),
    );

    return comment;
  }

  async getChallenges(userId: string) {
    const challenges = await this.prisma.challenge.findMany({
      include: {
        userChallenges: {
          where: { userId },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    return challenges.map((ch) => ({
      id: ch.id,
      title: ch.title,
      category: ch.category,
      participantsCount: ch.participantsCount,
      daysRemaining: ch.daysRemaining,
      imageUrl: ch.imageUrl,
      description: ch.description,
      isJoined: ch.userChallenges.length > 0,
    }));
  }

  async joinChallenge(challengeId: string, userId: string) {
    const challenge = await this.prisma.challenge.findUnique({
      where: { id: challengeId },
    });
    if (!challenge) {
      throw new NotFoundException(`Challenge with ID ${challengeId} not found`);
    }

    await this.prisma.userChallenge.upsert({
      where: {
        userId_challengeId: {
          userId,
          challengeId,
        },
      },
      update: {},
      create: {
        userId,
        challengeId,
      },
    });

    await this.prisma.challenge.update({
      where: { id: challengeId },
      data: { participantsCount: { increment: 1 } },
    });

    return { success: true, challengeId, isJoined: true };
  }
}
