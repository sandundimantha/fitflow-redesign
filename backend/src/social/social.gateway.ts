import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayInit,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  MessageBody,
} from '@nestjs/websockets';
import { Logger } from '@nestjs/common';
import { Server, Socket } from 'socket.io';
import { RedisService } from '../redis/redis.service';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
  namespace: '/ws/feed',
})
export class SocialGateway implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(SocialGateway.name);

  constructor(private readonly redis: RedisService) {}

  afterInit() {
    this.logger.log('Social WebSocket Gateway initialized at namespace /ws/feed');

    // Subscribe to Redis Pub/Sub channel
    this.redis.subscribe('social_feed', (messageStr: string) => {
      try {
        const parsed = JSON.parse(messageStr);
        this.logger.log(`Broadcasting event ${parsed.type} to WebSocket clients`);
        this.server.emit('feed_update', parsed);
      } catch (err) {
        this.logger.warn(`Failed to parse redis message: ${err.message}`);
      }
    });
  }

  handleConnection(client: Socket) {
    this.logger.log(`Client connected to feed WebSocket: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected from feed WebSocket: ${client.id}`);
  }

  @SubscribeMessage('ping_feed')
  handlePing(@MessageBody() data: any): string {
    return 'pong_feed';
  }
}
