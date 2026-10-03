import { Injectable, Logger, Optional } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { SocialPost, PostDocument } from './schemas/post.schema';
import { RedisService } from '../redis/redis.service';

export interface CreatePostDto {
  content: string;
  mediaUrl?: string;
  challengeId?: string;
  challengeName?: string;
}

const DEFAULT_CHALLENGES = [
  {
    id: 'ch_01',
    title: 'Spring 30-Day Lean Muscle Protocol',
    category: 'Hypertrophy',
    participantsCount: 1420,
    daysRemaining: 18,
    imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=600',
    description: 'Commit to 4 strength workouts per week, hitting minimum 1.6g/kg protein daily.',
  },
  {
    id: 'ch_02',
    title: '10,000 Daily Steps Consistency Quest',
    category: 'Endurance',
    participantsCount: 3840,
    daysRemaining: 12,
    imageUrl: 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=600',
    description: 'Keep your daily active movement streak alive and log every step for cardiovascular longevity.',
  },
  {
    id: 'ch_03',
    title: 'Zero Sugar & Macro Cleanse',
    category: 'Nutrition',
    participantsCount: 980,
    daysRemaining: 5,
    imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=600',
    description: 'Eliminate refined sugars and hit your fiber targets every single day.',
  },
];

@Injectable()
export class SocialService {
  private readonly logger = new Logger(SocialService.name);
  private inMemoryPosts: any[] = [];
  private joinedChallenges = new Set<string>(['ch_01']);

  constructor(
    @Optional()
    @InjectModel(SocialPost.name)
    private readonly postModel: Model<PostDocument> | null,
    private readonly redis: RedisService,
  ) {
    // Seed initial social feed
    this.inMemoryPosts.push(
      {
        id: 'post_01',
        userId: 'usr_sarah_11',
        authorName: 'Sarah Jenkins',
        authorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        content: 'Crushed Day 12 of the Spring Lean Muscle challenge! Hit a new 5-rep PR on Goblet Squats (28kg). The AI progressive plan is genuinely working 🔥💪',
        mediaUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800',
        challengeId: 'ch_01',
        challengeName: 'Spring 30-Day Lean Muscle Protocol',
        likesCount: 24,
        likedBy: ['usr_demo_777', 'usr_mike_99'],
        comments: [
          {
            id: 'c_1',
            userId: 'usr_mike_99',
            authorName: 'Mike Chen',
            authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
            text: 'Huge work Sarah! Form looked clean!',
            createdAt: new Date(Date.now() - 3600000),
          },
        ],
        createdAt: new Date(Date.now() - 7200000),
      },
      {
        id: 'post_02',
        userId: 'usr_david_22',
        authorName: 'David Miller',
        authorAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        content: 'Hit 12,400 steps today before 6 PM. Zone 2 recovery walk completed around the park. Keep moving team! 👟🌿',
        challengeId: 'ch_02',
        challengeName: '10,000 Daily Steps Consistency Quest',
        likesCount: 19,
        likedBy: [],
        comments: [],
        createdAt: new Date(Date.now() - 14400000),
      }
    );
  }

  async getFeed(page = 1, limit = 20) {
    if (this.postModel) {
      try {
        const posts = await this.postModel
          .find()
          .sort({ createdAt: -1 })
          .skip((page - 1) * limit)
          .limit(limit)
          .exec();
        if (posts.length > 0) return posts;
      } catch (e) {
        this.logger.warn(`MongoDB query failed: ${e.message}. Using in-memory feed fallback.`);
      }
    }
    return this.inMemoryPosts;
  }

  async createPost(user: any, dto: CreatePostDto) {
    const postPayload = {
      id: `post_${Date.now()}`,
      userId: user.id,
      authorName: user.displayName || 'FitFlow Athlete',
      authorAvatar: user.avatarUrl || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      content: dto.content,
      mediaUrl: dto.mediaUrl || null,
      challengeId: dto.challengeId || null,
      challengeName: dto.challengeName || null,
      likesCount: 0,
      likedBy: [],
      comments: [],
      createdAt: new Date(),
    };

    if (this.postModel) {
      try {
        const created = await this.postModel.create(postPayload);
        postPayload.id = created._id.toString();
      } catch (e) {
        this.logger.warn(`Could not save post to MongoDB: ${e.message}`);
      }
    }

    this.inMemoryPosts.unshift(postPayload);

    // 1. Publish to Redis Pub/Sub for real-time WebSocket distribution
    try {
      await this.redis.publish('social_feed', JSON.stringify({ type: 'NEW_POST', data: postPayload }));
      this.logger.log(`Published new post to Redis channel social_feed`);
    } catch (e) {
      this.logger.warn(`Redis publish failed: ${e.message}`);
    }

    // 2. Dispatch FCM Push Notification for offline followers (stubbed integration)
    this.sendFcmPushToOfflineFollowers(user, postPayload);

    return postPayload;
  }

  async toggleLike(postId: string, userId: string) {
    const post = this.inMemoryPosts.find((p) => p.id === postId || p._id?.toString() === postId);
    if (!post) return { success: false };

    const idx = post.likedBy.indexOf(userId);
    if (idx === -1) {
      post.likedBy.push(userId);
      post.likesCount += 1;
    } else {
      post.likedBy.splice(idx, 1);
      post.likesCount = Math.max(0, post.likesCount - 1);
    }

    await this.redis.publish('social_feed', JSON.stringify({ type: 'POST_LIKED', data: post }));
    return post;
  }

  async addComment(postId: string, user: any, text: string) {
    const post = this.inMemoryPosts.find((p) => p.id === postId || p._id?.toString() === postId);
    if (!post) return null;

    const comment = {
      id: `c_${Date.now()}`,
      userId: user.id,
      authorName: user.displayName || 'FitFlow Athlete',
      authorAvatar: user.avatarUrl || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      text,
      createdAt: new Date(),
    };

    post.comments.push(comment);
    await this.redis.publish('social_feed', JSON.stringify({ type: 'NEW_COMMENT', data: { postId, comment } }));
    return comment;
  }

  getChallenges() {
    return DEFAULT_CHALLENGES.map((ch) => ({
      ...ch,
      isJoined: this.joinedChallenges.has(ch.id),
    }));
  }

  joinChallenge(challengeId: string) {
    this.joinedChallenges.add(challengeId);
    return { success: true, challengeId, isJoined: true };
  }

  private sendFcmPushToOfflineFollowers(author: any, post: any) {
    // In production, uses firebase-admin.messaging().sendEachForMulticast()
    this.logger.log(`[FCM Mock] Push notification dispatched: "${author.displayName} posted an update in ${post.challengeName || 'FitFlow Community'}"`);
  }
}
