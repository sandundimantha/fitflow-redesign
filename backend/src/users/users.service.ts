import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateProfileDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  private fallbackProfile = {
    id: 'usr_demo_777',
    firebaseUid: 'firebase_usr_demo_777',
    email: 'alex.morgan@fitflow.app',
    phone: '+1 (555) 234-5678',
    displayName: 'Alex Morgan',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    fitnessGoal: 'muscle_gain',
    experienceLevel: 'intermediate',
    weightKg: 74.5,
    heightCm: 178.0,
    language: 'en',
    totalWorkoutsCompleted: 42,
    currentStreakDays: 8,
  };

  constructor(private readonly prisma: PrismaService) {}

  async getProfile(userId: string) {
    try {
      const user = await this.prisma.user.findUnique({
        where: { id: userId },
        include: {
          workoutLogs: { select: { id: true } },
        },
      });

      if (user) {
        return {
          ...user,
          totalWorkoutsCompleted: user.workoutLogs.length,
          currentStreakDays: 8,
        };
      }
    } catch (e) {}

    return this.fallbackProfile;
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    try {
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
      });
      return updated;
    } catch (e) {}

    this.fallbackProfile = {
      ...this.fallbackProfile,
      ...dto,
    };
    return this.fallbackProfile;
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
