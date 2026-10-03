import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { LogWorkoutDto, UpdateWorkoutLogDto } from './dto/workout.dto';

@Injectable()
export class WorkoutsService {
  constructor(private readonly prisma: PrismaService) {}

  async getTodayScheduledWorkout() {
    const workout = await this.prisma.workout.findFirst({
      where: { isScheduledToday: true },
    });
    if (!workout) {
      // If no scheduled workout is tagged for today, fetch the first available workout
      const fallback = await this.prisma.workout.findFirst();
      if (!fallback) {
        throw new NotFoundException('No workouts found in database. Run database seed.');
      }
      return fallback;
    }
    return workout;
  }

  async findAll(category?: string, maxDuration?: number, difficulty?: string) {
    const where: any = {};
    if (category && category !== 'All') {
      where.category = { equals: category, mode: 'insensitive' };
    }
    if (maxDuration) {
      where.durationMinutes = { lte: Number(maxDuration) };
    }
    if (difficulty) {
      where.difficulty = { equals: difficulty, mode: 'insensitive' };
    }

    return await this.prisma.workout.findMany({
      where,
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    const workout = await this.prisma.workout.findUnique({ where: { id } });
    if (!workout) {
      throw new NotFoundException(`Workout with ID ${id} not found`);
    }
    return workout;
  }

  async logWorkout(userId: string, dto: LogWorkoutDto) {
    return await this.prisma.workoutLog.create({
      data: {
        userId,
        workoutId: dto.workoutId || null,
        workoutTitle: dto.workoutTitle,
        category: dto.category,
        durationMinutes: dto.durationMinutes,
        caloriesBurned: dto.caloriesBurned,
        perceivedExertion: dto.perceivedExertion || null,
        notes: dto.notes || null,
      },
    });
  }

  async getWorkoutHistory(userId: string, category?: string, maxDuration?: number) {
    const where: any = { userId };
    if (category && category !== 'All') {
      where.category = { equals: category, mode: 'insensitive' };
    }
    if (maxDuration) {
      where.durationMinutes = { lte: Number(maxDuration) };
    }

    return await this.prisma.workoutLog.findMany({
      where,
      orderBy: { completedAt: 'desc' },
    });
  }

  async updateWorkoutLog(id: string, userId: string, dto: UpdateWorkoutLogDto) {
    const existing = await this.prisma.workoutLog.findFirst({
      where: { id, userId },
    });
    if (!existing) {
      throw new NotFoundException(`Workout log with ID ${id} not found for this user`);
    }

    return await this.prisma.workoutLog.update({
      where: { id },
      data: {
        durationMinutes: dto.durationMinutes,
        caloriesBurned: dto.caloriesBurned,
        perceivedExertion: dto.perceivedExertion,
        notes: dto.notes,
      },
    });
  }

  async getWeeklyComparisonStats(userId: string) {
    const now = new Date();
    const dayMs = 24 * 60 * 60 * 1000;
    const sevenDaysAgo = new Date(now.getTime() - 7 * dayMs);
    const fourteenDaysAgo = new Date(now.getTime() - 14 * dayMs);

    const logs = await this.prisma.workoutLog.findMany({
      where: {
        userId,
        completedAt: { gte: fourteenDaysAgo },
      },
      orderBy: { completedAt: 'asc' },
    });

    const thisWeekLogs = logs.filter((l) => l.completedAt >= sevenDaysAgo);
    const lastWeekLogs = logs.filter(
      (l) => l.completedAt >= fourteenDaysAgo && l.completedAt < sevenDaysAgo
    );

    const sumDuration = (items: typeof logs) => items.reduce((acc, curr) => acc + curr.durationMinutes, 0);
    const sumCalories = (items: typeof logs) => items.reduce((acc, curr) => acc + curr.caloriesBurned, 0);

    const thisWeekTotalMinutes = sumDuration(thisWeekLogs);
    const lastWeekTotalMinutes = sumDuration(lastWeekLogs);
    const thisWeekTotalCalories = sumCalories(thisWeekLogs);
    const lastWeekTotalCalories = sumCalories(lastWeekLogs);

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const dailyBreakdown = days.map((day, idx) => {
      const twMin = thisWeekLogs.reduce((acc, l) => {
        const d = l.completedAt.getDay();
        const adjustedDay = d === 0 ? 6 : d - 1;
        return adjustedDay === idx ? acc + l.durationMinutes : acc;
      }, 0);

      const lwMin = lastWeekLogs.reduce((acc, l) => {
        const d = l.completedAt.getDay();
        const adjustedDay = d === 0 ? 6 : d - 1;
        return adjustedDay === idx ? acc + l.durationMinutes : acc;
      }, 0);

      return {
        day,
        thisWeekMinutes: twMin,
        lastWeekMinutes: lwMin,
      };
    });

    return {
      legend: {
        thisWeekLabel: 'This Week',
        thisWeekColor: '#10B981',
        lastWeekLabel: 'Last Week',
        lastWeekColor: '#6B7280',
      },
      summary: {
        thisWeekTotalMinutes,
        lastWeekTotalMinutes,
        thisWeekTotalCalories,
        lastWeekTotalCalories,
        thisWeekSessions: thisWeekLogs.length,
        lastWeekSessions: lastWeekLogs.length,
        durationChangePercent:
          lastWeekTotalMinutes > 0
            ? Math.round(((thisWeekTotalMinutes - lastWeekTotalMinutes) / lastWeekTotalMinutes) * 100)
            : 0,
      },
      dailyBreakdown,
    };
  }
}
