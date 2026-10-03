import { Controller, Get, Patch, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { UpdateProfileDto } from './dto/update-user.dto';
import { FirebaseAuthGuard } from '../auth/firebase-auth.guard';
import { CurrentUser, AuthUser } from '../auth/current-user.decorator';

@ApiTags('Account & User Profile')
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('profile')
  @UseGuards(FirebaseAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Retrieve user profile, language preference, and stats' })
  async getProfile(@CurrentUser() user: AuthUser) {
    return await this.usersService.getProfile(user.id);
  }

  @Patch('profile')
  @UseGuards(FirebaseAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update profile details (name, goal, weight, language)' })
  async updateProfile(@CurrentUser() user: AuthUser, @Body() dto: UpdateProfileDto) {
    return await this.usersService.updateProfile(user.id, dto);
  }

  @Get('privacy-policy')
  @ApiOperation({ summary: 'Access FitFlow privacy policy and GDPR terms' })
  getPrivacyPolicy() {
    return this.usersService.getPrivacyPolicy();
  }
}
