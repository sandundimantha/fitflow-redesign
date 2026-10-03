import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { LogWorkoutDto, UpdateWorkoutLogDto } from './dto/workout.dto';

const DEFAULT_WORKOUTS = [
  {
    id: 'wk_today_01',
    title: 'Functional Full-Body Hypertrophy',
    category: 'Strength',
    durationMinutes: 45,
    difficulty: 'Intermediate',
    caloriesBurnEstimate: 380,
    imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',
    description: 'Target compound movement chains focusing on chest, upper back, and quads for balanced power and posture.',
    isScheduledToday: true,
    exercisesJson: JSON.stringify([
      { name: 'Goblet Squats', sets: 4, reps: '10-12', rest: 90, target: 'Quads & Glutes' },
      { name: 'Dumbbell Bench Press', sets: 4, reps: '8-10', rest: 90, target: 'Chest & Triceps' },
      { name: 'Dumbbell Bent-Over Row', sets: 3, reps: '10-12', rest: 75, target: 'Lats & Rhomboids' },
      { name: 'Plank Shoulder Taps', sets: 3, reps: '45 sec', rest: 45, target: 'Core Anti-Rotation' },
    ]),
  },
  {
    id: 'wk_hiit_02',
    title: 'Metabolic HIIT Blaze',
    category: 'HIIT',
    durationMinutes: 25,
    difficulty: 'Advanced',
    caloriesBurnEstimate: 320,
    imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800',
    description: 'High-intensity interval training designed to accelerate anaerobic capacity and EPOC calorie afterburn.',
    isScheduledToday: false,
    exercisesJson: JSON.stringify([
      { name: 'Burpees to Jump', sets: 4, reps: '40 sec on / 20 off', rest: 45, target: 'Cardiovascular' },
      { name: 'Mountain Climbers', sets: 4, reps: '40 sec on / 20 off', rest: 45, target: 'Core' },
      { name: 'Kettlebell / Dumbbell Swings', sets: 4, reps: '15 reps', rest: 60, target: 'Glutes & Hamstrings' },
    ]),
  },
  {
    id: 'wk_cardio_03',
    title: 'Zone 2 Aerobic Conditioning',
    category: 'Cardio',
    durationMinutes: 35,
    difficulty: 'Beginner',
    caloriesBurnEstimate: 260,
    imageUrl: 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=800',
    description: 'Low-impact steady state cardio building mitochondrial density and heart-rate recovery efficiency.',
    isScheduledToday: false,
    exercisesJson: JSON.stringify([
      { name: 'Incline Treadmill Walk / Steady Run', sets: 1, reps: '35 min', rest: 0, target: 'Cardiovascular' },
    ]),
  },
  {
    id: 'wk_mobility_04',
    title: 'Deep Hip & Thoracic Spine Mobility',
    category: 'Mobility',
    durationMinutes: 20,
    difficulty: 'Beginner',
    caloriesBurnEstimate: 110,
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800',
    description: 'Decompress lumbar tension, open tight hips, and increase thoracic rotation for injury prevention.',
    isScheduledToday: false,
    exercisesJson: JSON.stringify([
      { name: 'World Greatest Stretch', sets: 3, reps: '5 per side', rest: 30, target: 'Thoracic & Hips' },
      { name: '90/90 Hip Flow', sets: 3, reps: '60 sec', rest: 30, target: 'Hip Rotators' },
      { name: 'Cat-Cow Breathing', sets: 2, reps: '10 breaths', rest: 30, target: 'Spinal Articulation' },
    ]),
  },
];

@Injectable()
export class WorkoutsService {
  private inMemoryLogs: any[] = [];

  constructor(private readonly prisma: PrismaService) {
    // Seed in-memory past logs for immediate chart comparisons
    const today = new Date();
    const dayMs = 24 * 60 * 60 * 1000;

    // This week logs
    this.inMemoryLogs.push(
      {
        id: 'log_tw_1',
        userId: 'usr_demo_777',
        workoutTitle: 'Functional Full-Body Hypertrophy',
        category: 'Strength',
        durationMinutes: 45,
        caloriesBurned: 380,
        perceivedExertion: 8,
        notes: 'Pushed hard on goblet squats. Felt solid.',
        completedAt: new Date(today.getTime() - 1 * dayMs),
      },
      {
        id: 'log_tw_2',
        userId: 'usr_demo_777',
        workoutTitle: 'Metabolic HIIT Blaze',
        category: 'HIIT',
        durationMinutes: 30,
        caloriesBurned: 340,
        perceivedExertion: 9,
        notes: 'Intense sweat session.',
        completedAt: new Date(today.getTime() - 2 * dayMs),
      },
      {
        id: 'log_tw_3',
        userId: 'usr_demo_777',
        workoutTitle: 'Zone 2 Aerobic Conditioning',
        category: 'Cardio',
        durationMinutes: 40,
        caloriesBurned: 290,
        perceivedExertion: 6,
        notes: 'Recovery run outside.',
        completedAt: new Date(today.getTime() - 4 * dayMs),
      }
    );

    // Last week logs
    this.inMemoryLogs.push(
      {
        id: 'log_lw_1',
        userId: 'usr_demo_777',
        workoutTitle: 'Upper Body Blast',
        category: 'Strength',
        durationMinutes: 40,
        caloriesBurned: 320,
        perceivedExertion: 7,
        notes: 'Bench press progressive overload.',
        completedAt: new Date(today.getTime() - 8 * dayMs),
      },
      {
        id: 'log_lw_2',
        userId: 'usr_demo_777',
        workoutTitle: 'Interval Cycling Sprint',
        category: 'Cardio',
        durationMinutes: 25,
        caloriesBurned: 240,
        perceivedExertion: 8,
        notes: 'High cadence sprints.',
        completedAt: new Date(today.getTime() - 10 * dayMs),
      },
      {
        id: 'log_lw_3',
        userId: 'usr_demo_777',
        workoutTitle: 'Total Body Functional Circuit',
        category: 'Strength',
        durationMinutes: 35,
        caloriesBurned: 280,
        perceivedExertion: 7,
        notes: 'Full body circuit training.',
        completedAt: new Date(today.getTime() - 12 * dayMs),
      }
    );
  }

  async getTodayScheduledWorkout() {
    try {
      const today = await this.prisma.workout.findFirst({
        where: { isScheduledToday: true },
      });
      if (today) return today;
    } catch (e) {}
    return DEFAULT_WORKOUTS[0];
  }

  async findAll(category?: string, maxDuration?: number, difficulty?: string) {
    try {
      const where: any = {};
      if (category && category !== 'All') where.category = { equals: category, mode: 'insensitive' };
      if (maxDuration) where.durationMinutes = { lte: Number(maxDuration) };
      if (difficulty) where.difficulty = { equals: difficulty, mode: 'insensitive' };

      const workouts = await this.prisma.workout.findMany({ where });
      if (workouts.length > 0) return workouts;
    } catch (e) {}

    // Fallback in-memory filter
    return DEFAULT_WORKOUTS.filter((w) => {
      if (category && category !== 'All' && w.category.toLowerCase() !== category.toLowerCase()) return false;
      if (maxDuration && w.durationMinutes > maxDuration) return false;
      if (difficulty && w.difficulty.toLowerCase() !== difficulty.toLowerCase()) return false;
      return true;
    });
  }

  async findOne(id: string) {
    try {
      const workout = await this.prisma.workout.findUnique({ where: { id } });
      if (workout) return workout;
    } catch (e) {}

    const found = DEFAULT_WORKOUTS.find((w) => w.id === id);
    if (!found) throw new NotFoundException(`Workout with ID ${id} not found`);
    return found;
  }

  async logWorkout(userId: string, dto: LogWorkoutDto) {
    try {
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
    } catch (e) {}

    const newLog = {
      id: `log_${Date.now()}`,
      userId,
      workoutId: dto.workoutId || null,
      workoutTitle: dto.workoutTitle,
      category: dto.category,
      durationMinutes: dto.durationMinutes,
      caloriesBurned: dto.caloriesBurned,
      perceivedExertion: dto.perceivedExertion || null,
      notes: dto.notes || null,
      completedAt: new Date(),
    };
    this.inMemoryLogs.unshift(newLog);
    return newLog;
  }

  async getWorkoutHistory(userId: string, category?: string, maxDuration?: number) {
    try {
      const where: any = { userId };
      if (category && category !== 'All') where.category = { equals: category, mode: 'insensitive' };
      if (maxDuration) where.durationMinutes = { lte: Number(maxDuration) };

      const logs = await this.prisma.workoutLog.findMany({
        where,
        orderBy: { completedAt: 'desc' },
      });
      if (logs.length > 0) return logs;
    } catch (e) {}

    return this.inMemoryLogs.filter((l) => {
      if (l.userId !== userId && userId !== 'usr_demo_777') return false;
      if (category && category !== 'All' && l.category.toLowerCase() !== category.toLowerCase()) return false;
      if (maxDuration && l.durationMinutes > maxDuration) return false;
      return true;
    });
  }

  async updateWorkoutLog(id: string, userId: string, dto: UpdateWorkoutLogDto) {
    try {
      const updated = await this.prisma.workoutLog.update({
        where: { id },
        data: {
          durationMinutes: dto.durationMinutes,
          caloriesBurned: dto.caloriesBurned,
          perceivedExertion: dto.perceivedExertion,
          notes: dto.notes,
        },
      });
      return updated;
    } catch (e) {}

    const index = this.inMemoryLogs.findIndex((l) => l.id === id);
    if (index === -1) throw new NotFoundException(`Workout log ${id} not found`);

    const updated = {
      ...this.inMemoryLogs[index],
      ...dto,
    };
    this.inMemoryLogs[index] = updated;
    return updated;
  }

  async getWeeklyComparisonStats(userId: string) {
    const history = await this.getWorkoutHistory(userId);
    const now = new Date();
    const dayMs = 24 * 60 * 60 * 1000;
    const sevenDaysAgo = new Date(now.getTime() - 7 * dayMs);
    const fourteenDaysAgo = new Date(now.getTime() - 14 * dayMs);

    const thisWeekLogs = history.filter((l) => new Date(l.completedAt) >= sevenDaysAgo);
    const lastWeekLogs = history.filter(
      (l) => new Date(l.completedAt) >= fourteenDaysAgo && new Date(l.completedAt) < sevenDaysAgo
    );

    const sumDuration = (logs: any[]) => logs.reduce((acc, curr) => acc + (curr.durationMinutes || 0), 0);
    const sumCalories = (logs: any[]) => logs.reduce((acc, curr) => acc + (curr.caloriesBurned || 0), 0);

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const dailyBreakdown = days.map((day, idx) => {
      // Aggregate minutes for this week vs last week
      const twMin = thisWeekLogs.reduce((acc, l) => {
        const d = new Date(l.completedAt).getDay();
        const adjustedDay = d === 0 ? 6 : d - 1; // Mon=0 .. Sun=6
        return adjustedDay === idx ? acc + l.durationMinutes : acc;
      }, 0);

      const lwMin = lastWeekLogs.reduce((acc, l) => {
        const d = new Date(l.completedAt).getDay();
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
        thisWeekColor: '#10B981', // Emerald neon
        lastWeekLabel: 'Last Week',
        lastWeekColor: '#6B7280', // Muted slate
      },
      summary: {
        thisWeekTotalMinutes: sumDuration(thisWeekLogs),
        lastWeekTotalMinutes: sumDuration(lastWeekLogs),
        thisWeekTotalCalories: sumCalories(thisWeekLogs),
        lastWeekTotalCalories: sumCalories(lastWeekLogs),
        thisWeekSessions: thisWeekLogs.length,
        lastWeekSessions: lastWeekLogs.length,
        durationChangePercent:
          sumDuration(lastWeekLogs) > 0
            ? Math.round(((sumDuration(thisWeekLogs) - sumDuration(lastWeekLogs)) / sumDuration(lastWeekLogs)) * 100)
            : 100,
      },
      dailyBreakdown,
    };
  }
}
