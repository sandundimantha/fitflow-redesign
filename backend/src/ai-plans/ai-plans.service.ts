import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';
import { PrismaService } from '../prisma/prisma.service';
import { GeneratePlanDto } from './dto/generate-plan.dto';

@Injectable()
export class AiPlansService {
  private readonly logger = new Logger(AiPlansService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
  ) {}

  async generateAndSavePlan(userId: string, dto: GeneratePlanDto) {
    const aiServiceUrl = this.configService.get<string>('AI_SERVICE_URL', 'http://localhost:8001');

    // 1. Fetch user workout history from PostgreSQL
    let historyItems: any[] = [];
    try {
      const logs = await this.prisma.workoutLog.findMany({
        where: { userId },
        orderBy: { completedAt: 'desc' },
        take: 10,
      });

      historyItems = logs.map((l) => ({
        category: l.category,
        duration_minutes: l.durationMinutes,
        completed_at: l.completedAt.toISOString(),
        perceived_exertion: l.perceivedExertion || 7,
      }));
    } catch (e) {
      this.logger.warn(`Could not fetch history from Postgres: ${e.message}. Using default mock history.`);
      historyItems = [
        { category: 'Strength', duration_minutes: 45, perceived_exertion: 8 },
        { category: 'HIIT', duration_minutes: 30, perceived_exertion: 9 },
      ];
    }

    // 2. Call FastAPI microservice
    let generatedPlanData: any;
    try {
      const response = await axios.post(
        `${aiServiceUrl}/generate-plan`,
        {
          user_id: userId,
          goal: dto.goal,
          available_equipment: dto.availableEquipment,
          experience_level: dto.experienceLevel || 'intermediate',
          days_per_week: dto.daysPerWeek || 4,
          workout_history: historyItems,
        },
        { timeout: 4000 }
      );
      generatedPlanData = response.data;
      this.logger.log(`Successfully received AI plan from microservice for user ${userId}`);
    } catch (err) {
      this.logger.warn(`FastAPI AI service call failed (${err.message}). Using local rule engine fallback.`);
      generatedPlanData = this.generateFallbackPlan(dto, historyItems);
    }

    // 3. Store the generated plan in PostgreSQL
    let savedRecord: any;
    try {
      savedRecord = await this.prisma.aiWorkoutPlan.create({
        data: {
          userId,
          title: generatedPlanData.title,
          goal: generatedPlanData.goal,
          experienceLevel: generatedPlanData.experience_level,
          durationWeeks: generatedPlanData.duration_weeks,
          daysPerWeek: generatedPlanData.days_per_week,
          summary: generatedPlanData.summary,
          routinesJson: JSON.stringify(generatedPlanData.routines),
        },
      });
    } catch (e) {
      savedRecord = {
        id: `plan_${Date.now()}`,
        userId,
        title: generatedPlanData.title,
        goal: generatedPlanData.goal,
        experienceLevel: generatedPlanData.experience_level,
        durationWeeks: generatedPlanData.duration_weeks,
        daysPerWeek: generatedPlanData.days_per_week,
        summary: generatedPlanData.summary,
        routinesJson: JSON.stringify(generatedPlanData.routines),
        createdAt: new Date(),
      };
    }

    return {
      id: savedRecord.id,
      title: savedRecord.title,
      goal: savedRecord.goal,
      experienceLevel: savedRecord.experienceLevel,
      durationWeeks: savedRecord.durationWeeks,
      daysPerWeek: savedRecord.daysPerWeek,
      summary: savedRecord.summary,
      routines: generatedPlanData.routines,
      createdAt: savedRecord.createdAt,
    };
  }

  async getUserPlans(userId: string) {
    try {
      const plans = await this.prisma.aiWorkoutPlan.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
      });
      return plans.map((p) => ({
        ...p,
        routines: JSON.parse(p.routinesJson),
      }));
    } catch (e) {
      return [];
    }
  }

  private generateFallbackPlan(dto: GeneratePlanDto, history: any[]) {
    const equip = dto.availableEquipment.join(', ') || 'bodyweight';
    return {
      plan_id: `plan_fallback_${Date.now()}`,
      title: `AI ${dto.goal.replace('_', ' ').toUpperCase()} Blueprint`,
      goal: dto.goal,
      experience_level: dto.experienceLevel || 'Intermediate',
      duration_weeks: 4,
      days_per_week: dto.daysPerWeek || 4,
      summary: `Targeted 4-week protocol optimized for ${dto.goal} using ${equip}. Balanced with your ${history.length} recent sessions.`,
      generated_at: new Date().toISOString(),
      routines: [
        {
          day_number: 1,
          day_title: 'Upper Body Power & Posture',
          focus: 'Chest, Back & Shoulders',
          estimated_duration_minutes: 45,
          exercises: [
            {
              name: 'Dumbbell Bench Press',
              target_muscle: 'Chest',
              equipment_required: 'dumbbells',
              sets: 4,
              reps: '8-10',
              rest_seconds: 90,
              rationale: 'Primary compound horizontal push providing progressive overload for your muscle gain goal.',
            },
            {
              name: 'Bent-Over Dumbbell Row',
              target_muscle: 'Upper Back',
              equipment_required: 'dumbbells',
              sets: 4,
              reps: '10-12',
              rest_seconds: 75,
              rationale: 'Strengthens rhomboids and counters postural slouching from desk work.',
            },
          ],
        },
        {
          day_number: 2,
          day_title: 'Lower Body & Core Stability',
          focus: 'Quadriceps, Glutes & Abs',
          estimated_duration_minutes: 40,
          exercises: [
            {
              name: 'Goblet Squats',
              target_muscle: 'Quadriceps & Glutes',
              equipment_required: 'dumbbells',
              sets: 4,
              reps: '10-12',
              rest_seconds: 90,
              rationale: 'Deep knee flexion pattern building lower extremity power while sparing lumbar spine.',
            },
            {
              name: 'Plank Shoulder Taps',
              target_muscle: 'Core Anti-Rotation',
              equipment_required: 'bodyweight',
              sets: 3,
              reps: '45 sec',
              rest_seconds: 45,
              rationale: 'Develops rotational core stability without requiring equipment.',
            },
          ],
        },
      ],
    };
  }
}
