import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateProfileDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        workoutLogs: { select: { id: true } },
      },
    });

    if (!user) {
      throw new NotFoundException(`User with ID ${userId} not found`);
    }

    return {
      ...user,
      totalWorkoutsCompleted: user.workoutLogs.length,
      currentStreakDays: 6,
    };
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException(`User with ID ${userId} not found`);
    }

    const updated = await this.prisma.user.update({
      where: { id: userId },
      data: {
        displayName: dto.displayName,
        avatarUrl: dto.avatarUrl,
        fitnessGoal: dto.fitnessGoal,
        experienceLevel: dto.experienceLevel,
        weightKg: dto.weightKg,
        heightCm: dto.heightCm,
        language: dto.language,
      },
      include: {
        workoutLogs: { select: { id: true } },
      },
    });

    return {
      ...updated,
      totalWorkoutsCompleted: updated.workoutLogs.length,
      currentStreakDays: 6,
    };
  }

  getPrivacyPolicy() {
    return {
      version: '2026.1',
      lastUpdated: 'March 2026',
      summary: 'FitFlow respects your personal health sovereignty. All health logs and biometric information are strictly encrypted.',
      dataCollection: [
        'Workout activity duration and exertion ratings',
        'Daily nutritional macro logs',
        'Optional biometric metrics (weight and height)',
      ],
      thirdPartySharing: 'FitFlow does NOT sell personal fitness logs or telemetry to third-party ad networks.',
      gdprCompliance: 'You have full rights to request data export or account erasure at any time via support@fitflow.app.',
    };
  }
}
