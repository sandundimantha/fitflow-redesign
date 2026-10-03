import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';
import { LogMealDto } from './dto/nutrition.dto';
import { SYSTEM_CONSTANTS } from '../common/constants/system.constants';

@Injectable()
export class NutritionService {
  private readonly logger = new Logger(NutritionService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
  ) {}

  async autocomplete(query: string) {
    if (!query || query.trim().length === 0) {
      return await this.prisma.foodItem.findMany({ take: 6 });
    }

    return await this.prisma.foodItem.findMany({
      where: {
        name: {
          contains: query.trim(),
          mode: 'insensitive',
        },
      },
      take: 8,
    });
  }

  async logMeal(userId: string, dto: LogMealDto) {
    const savedMeal = await this.prisma.nutritionLog.create({
      data: {
        userId,
        mealType: dto.mealType,
        foodName: dto.foodName,
        servingAmount: dto.servingAmount,
        servingUnit: dto.servingUnit,
        calories: dto.calories,
        proteinGrams: dto.proteinGrams,
        carbsGrams: dto.carbsGrams,
        fatGrams: dto.fatGrams,
      },
    });

    // Invalidate and refresh running totals in Redis
    await this.refreshDayRunningTotals(userId);
    return savedMeal;
  }

  async getTodayMeals(userId: string) {
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    return await this.prisma.nutritionLog.findMany({
      where: {
        userId,
        loggedAt: { gte: startOfDay },
      },
      orderBy: { loggedAt: 'desc' },
    });
  }

  async getTodaySummary(userId: string) {
    const todayKey = `nutrition:summary:${userId}:${new Date().toISOString().slice(0, 10)}`;
    const cached = await this.redis.get(todayKey);

    if (cached) {
      try {
        return JSON.parse(cached);
      } catch (e) {
        this.logger.warn(`Failed to parse cached nutrition summary: ${e.message}`);
      }
    }

    return await this.refreshDayRunningTotals(userId);
  }

  private async refreshDayRunningTotals(userId: string) {
    const meals = await this.getTodayMeals(userId);
    const summary = {
      targetCalories: SYSTEM_CONSTANTS.DEFAULT_NUTRITION_TARGETS.CALORIES,
      consumedCalories: meals.reduce((sum, m) => sum + m.calories, 0),
      targetProteinGrams: SYSTEM_CONSTANTS.DEFAULT_NUTRITION_TARGETS.PROTEIN_GRAMS,
      consumedProteinGrams: Math.round(meals.reduce((sum, m) => sum + m.proteinGrams, 0)),
      targetCarbsGrams: SYSTEM_CONSTANTS.DEFAULT_NUTRITION_TARGETS.CARBS_GRAMS,
      consumedCarbsGrams: Math.round(meals.reduce((sum, m) => sum + m.carbsGrams, 0)),
      targetFatGrams: SYSTEM_CONSTANTS.DEFAULT_NUTRITION_TARGETS.FAT_GRAMS,
      consumedFatGrams: Math.round(meals.reduce((sum, m) => sum + m.fatGrams, 0)),
      loggedMealsCount: meals.length,
    };

    const todayKey = `nutrition:summary:${userId}:${new Date().toISOString().slice(0, 10)}`;
    // Cache until end of day (86400 seconds)
    await this.redis.set(todayKey, JSON.stringify(summary), 86400);
    return summary;
  }
}
