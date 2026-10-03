import { Test, TestingModule } from '@nestjs/testing';
import { WorkoutsService } from './workouts.service';
import { PrismaService } from '../prisma/prisma.service';

describe('WorkoutsService', () => {
  let service: WorkoutsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        WorkoutsService,
        {
          provide: PrismaService,
          useValue: {
            workout: {
              findFirst: jest.fn().mockResolvedValue(null),
              findMany: jest.fn().mockResolvedValue([]),
              findUnique: jest.fn().mockResolvedValue(null),
            },
            workoutLog: {
              findMany: jest.fn().mockResolvedValue([]),
              create: jest.fn().mockImplementation((args) => Promise.resolve({ id: 'mock_log', ...args.data })),
              update: jest.fn().mockImplementation((args) => Promise.resolve({ id: args.where.id, ...args.data })),
            },
          },
        },
      ],
    }).compile();

    service = module.get<WorkoutsService>(WorkoutsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should return today scheduled workout above the fold', async () => {
    const today = await service.getTodayScheduledWorkout();
    expect(today).toBeDefined();
    expect(today.title).toBe('Functional Full-Body Hypertrophy');
    expect(today.isScheduledToday).toBe(true);
  });

  it('should calculate weekly comparison stats with clearly labeled legend', async () => {
    const stats = await service.getWeeklyComparisonStats('usr_demo_777');
    expect(stats.legend).toBeDefined();
    expect(stats.legend.thisWeekLabel).toBe('This Week');
    expect(stats.legend.lastWeekLabel).toBe('Last Week');
    expect(stats.dailyBreakdown.length).toBe(7);
  });

  it('should log and allow editing a workout entry duration', async () => {
    const logged = await service.logWorkout('usr_demo_777', {
      workoutTitle: 'Test Bench Press',
      category: 'Strength',
      durationMinutes: 40,
      caloriesBurned: 300,
    });
    expect(logged).toBeDefined();

    const updated = await service.updateWorkoutLog(logged.id, 'usr_demo_777', {
      durationMinutes: 50,
      caloriesBurned: 380,
    });
    expect(updated.durationMinutes).toBe(50);
    expect(updated.caloriesBurned).toBe(380);
  });
});
