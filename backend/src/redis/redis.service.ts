import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';
import { EventEmitter } from 'events';

@Injectable()
export class RedisService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(RedisService.name);
  private client: Redis | null = null;
  private subClient: Redis | null = null;
  private readonly inMemoryCache = new Map<string, string>();
  private readonly inMemoryEmitter = new EventEmitter();
  private isConnected = false;

  constructor(private readonly configService: ConfigService) {}

  async onModuleInit() {
    const host = this.configService.get<string>('REDIS_HOST', 'localhost');
    const port = this.configService.get<number>('REDIS_PORT', 6379);
    const password = this.configService.get<string>('REDIS_PASSWORD', '');

    try {
      this.client = new Redis({
        host,
        port,
        password: password || undefined,
        lazyConnect: true,
        maxRetriesPerRequest: 1,
        retryStrategy: () => null,
      });

      this.subClient = this.client.duplicate();

      await this.client.connect();
      await this.subClient.connect();
      this.isConnected = true;
      this.logger.log(`Connected to Redis at ${host}:${port}`);
    } catch (err) {
      this.isConnected = false;
      this.logger.warn(`Redis connection failed (${err.message}). Using in-memory fallback cache and pub/sub.`);
    }
  }

  async get(key: string): Promise<string | null> {
    if (this.isConnected && this.client) {
      try {
        return await this.client.get(key);
      } catch (err) {
        this.logger.warn(`Redis get failed for ${key}, falling back to memory`);
      }
    }
    return this.inMemoryCache.get(key) || null;
  }

  async set(key: string, value: string, ttlSeconds?: number): Promise<void> {
    if (this.isConnected && this.client) {
      try {
        if (ttlSeconds) {
          await this.client.set(key, value, 'EX', ttlSeconds);
        } else {
          await this.client.set(key, value);
        }
        return;
      } catch (err) {
        this.logger.warn(`Redis set failed for ${key}, falling back to memory`);
      }
    }
    this.inMemoryCache.set(key, value);
  }

  async del(key: string): Promise<void> {
    if (this.isConnected && this.client) {
      try {
        await this.client.del(key);
        return;
      } catch (err) {}
    }
    this.inMemoryCache.delete(key);
  }

  async publish(channel: string, message: string): Promise<void> {
    if (this.isConnected && this.client) {
      try {
        await this.client.publish(channel, message);
        return;
      } catch (err) {}
    }
    this.inMemoryEmitter.emit(channel, message);
  }

  subscribe(channel: string, callback: (message: string) => void): void {
    if (this.isConnected && this.subClient) {
      try {
        this.subClient.subscribe(channel);
        this.subClient.on('message', (chan, msg) => {
          if (chan === channel) {
            callback(msg);
          }
        });
        return;
      } catch (err) {}
    }
    this.inMemoryEmitter.on(channel, callback);
  }

  async onModuleDestroy() {
    if (this.client) {
      await this.client.quit().catch(() => {});
    }
    if (this.subClient) {
      await this.subClient.quit().catch(() => {});
    }
  }
}
