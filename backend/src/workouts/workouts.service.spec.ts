import { Test, TestingModule } from '@nestjs/testing';
import { WorkoutsService } from './workouts.service';
import { PrismaService } from '../prisma/prisma.service';

describe('WorkoutsService', () => {
  let service: WorkoutsService;
  let prismaMock: any;

  const sampleWorkout = {
    id: 'wk_today_01',
    title: 'Functional Full-Body Hypertrophy',
    category: 'Strength',
    durationMinutes: 45,
    difficulty: 'Intermediate',
    caloriesBurnEstimate: 380,
    imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',
    description: 'Target compound movement chains.',
    isScheduledToday: true,
    exercisesJson: '[]',
    createdAt: new Date(),
  };

  const sampleLogs = [
    {
      id: 'log_1',
      userId: 'usr_demo_777',
      workoutTitle: 'Strength Workout',
      category: 'Strength',
      durationMinutes: 45,
      caloriesBurned: 350,
      completedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // This week
    },
    {
      id: 'log_2',
      userId: 'usr_demo_777',
      workoutTitle: 'Cardio Run',
      category: 'Cardio',
      durationMinutes: 30,
      caloriesBurned: 260,
      completedAt: new Date(Date.now() - 9 * 24 * 60 * 60 * 1000), // Last week
    },
  ];

  beforeEach(async () => {
    prismaMock = {
      workout: {
        findFirst: jest.fn().mockResolvedValue(sampleWorkout),
        findMany: jest.fn().mockResolvedValue([sampleWorkout]),
        findUnique: jest.fn().mockResolvedValue(sampleWorkout),
      },
      workoutLog: {
        findMany: jest.fn().mockResolvedValue(sampleLogs),
        findFirst: jest.fn().mockResolvedValue(sampleLogs[0]),
        create: jest.fn().mockImplementation((args) => Promise.resolve({ id: 'log_mock', ...args.data })),
        update: jest.fn().mockImplementation((args) => Promise.resolve({ ...sampleLogs[0], ...args.data })),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        WorkoutsService,
        {
          provide: PrismaService,
          useValue: prismaMock,
        },
      ],
    }).compile();

    service = module.get<WorkoutsService>(WorkoutsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should return today scheduled workout from database', async () => {
    const today = await service.getTodayScheduledWorkout();
    expect(today).toBeDefined();
    expect(today.title).toBe('Functional Full-Body Hypertrophy');
    expect(prismaMock.workout.findFirst).toHaveBeenCalledWith({ where: { isScheduledToday: true } });
  });

  it('should calculate weekly comparison stats with clearly labeled legend', async () => {
    const stats = await service.getWeeklyComparisonStats('usr_demo_777');
    expect(stats.legend).toBeDefined();
    expect(stats.legend.thisWeekLabel).toBe('This Week');
    expect(stats.legend.lastWeekLabel).toBe('Last Week');
    expect(stats.dailyBreakdown.length).toBe(7);
    expect(stats.summary.thisWeekTotalMinutes).toBe(45);
    expect(stats.summary.lastWeekTotalMinutes).toBe(30);
  });

  it('should log and allow editing a workout entry duration', async () => {
    const logged = await service.logWorkout('usr_demo_777', {
      workoutTitle: 'Bench Press',
      category: 'Strength',
      durationMinutes: 40,
      caloriesBurned: 300,
    });
    expect(logged).toBeDefined();
    expect(prismaMock.workoutLog.create).toHaveBeenCalled();

    const updated = await service.updateWorkoutLog('log_1', 'usr_demo_777', {
      durationMinutes: 50,
      caloriesBurned: 380,
    });
    expect(updated.durationMinutes).toBe(50);
    expect(updated.caloriesBurned).toBe(380);
    expect(prismaMock.workoutLog.update).toHaveBeenCalled();
  });
});
