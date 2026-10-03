import { Controller, Get, Post, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SocialService } from './social.service';
import { FirebaseAuthGuard } from '../auth/firebase-auth.guard';
import { CurrentUser, AuthUser } from '../auth/current-user.decorator';

@ApiTags('Social Community & Challenges')
@Controller('social')
@UseGuards(FirebaseAuthGuard)
@ApiBearerAuth()
export class SocialController {
  constructor(private readonly socialService: SocialService) {}

  @Get('feed')
  @ApiOperation({ summary: 'Get community feed backed by MongoDB' })
  async getFeed(@Query('page') page?: number, @Query('limit') limit?: number) {
    return await this.socialService.getFeed(page ? Number(page) : undefined, limit ? Number(limit) : undefined);
  }

  @Post('posts')
  @ApiOperation({ summary: 'Create new challenge update post (publishes to Redis & pushes to WebSocket)' })
  async createPost(
    @CurrentUser() user: AuthUser,
    @Body() dto: { content: string; mediaUrl?: string; challengeId?: string; challengeName?: string },
  ) {
    return await this.socialService.createPost(user, dto);
  }

  @Post('posts/:id/like')
  @ApiOperation({ summary: 'Like or unlike a community post' })
  async toggleLike(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return await this.socialService.toggleLike(id, user.id);
  }

  @Post('posts/:id/comments')
  @ApiOperation({ summary: 'Add comment to a post' })
  async addComment(
    @CurrentUser() user: AuthUser,
    @Param('id') id: string,
    @Body() body: { text: string },
  ) {
    return await this.socialService.addComment(id, user, body.text);
  }

  @Get('challenges')
  @ApiOperation({ summary: 'List available community fitness challenges with user join status' })
  async getChallenges(@CurrentUser() user: AuthUser) {
    return await this.socialService.getChallenges(user.id);
  }

  @Post('challenges/:id/join')
  @ApiOperation({ summary: 'Join a community fitness challenge' })
  async joinChallenge(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return await this.socialService.joinChallenge(id, user.id);
  }
}
