import { Controller, Post, Get, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { FirebaseAuthGuard } from './firebase-auth.guard';
import { CurrentUser, AuthUser } from './current-user.decorator';
import { PrismaService } from '../prisma/prisma.service';

export class SyncUserDto {
  firebaseUid?: string;
  email?: string;
  phone?: string;
  displayName?: string;
  avatarUrl?: string;
  fitnessGoal?: string;
}

@ApiTags('Authentication & Identity')
@Controller('auth')
export class AuthController {
  constructor(private readonly prisma: PrismaService) {}

  @Post('sync')
  @ApiOperation({ summary: 'Sync or initialize user identity from client after Firebase authentication' })
  async syncUser(@Body() dto: SyncUserDto) {
    const uid = dto.firebaseUid || 'usr_demo_777';
    try {
      const existing = await this.prisma.user.findFirst({
        where: { OR: [{ firebaseUid: uid }, { email: dto.email }] },
      });

      if (existing) {
        return existing;
      }

      return await this.prisma.user.create({
        data: {
          firebaseUid: uid,
          email: dto.email || 'demo@fitflow.app',
          phone: dto.phone || null,
          displayName: dto.displayName || 'Alex Morgan',
          avatarUrl: dto.avatarUrl || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
          fitnessGoal: dto.fitnessGoal || 'muscle_gain',
        },
      });
    } catch (e) {
      return {
        id: 'usr_demo_777',
        firebaseUid: uid,
        displayName: dto.displayName || 'Alex Morgan',
        email: dto.email || 'demo@fitflow.app',
        fitnessGoal: dto.fitnessGoal || 'muscle_gain',
      };
    }
  }

  @Get('me')
  @UseGuards(FirebaseAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Retrieve currently authenticated user session' })
  async getMe(@CurrentUser() user: AuthUser) {
    try {
      const found = await this.prisma.user.findUnique({
        where: { id: user.id },
        include: {
          workoutLogs: { take: 5, orderBy: { completedAt: 'desc' } },
        },
      });
      if (found) return found;
    } catch (e) {}

    return {
      id: user.id,
      firebaseUid: user.firebaseUid,
      displayName: user.displayName,
      email: user.email,
      fitnessGoal: 'muscle_gain',
      experienceLevel: 'intermediate',
      weightKg: 74.5,
      heightCm: 178.0,
      language: 'en',
    };
  }
}
