import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';
import { LogMealDto } from './dto/nutrition.dto';

export interface FoodSuggestion {
  foodName: string;
  defaultServing: string;
  calories: number;
  proteinGrams: number;
  carbsGrams: number;
  fatGrams: number;
}

const FOOD_DATABASE: FoodSuggestion[] = [
  { foodName: 'Oatmeal with Blueberries & Honey', defaultServing: '1 bowl (250g)', calories: 280, proteinGrams: 9, carbsGrams: 52, fatGrams: 4.5 },
  { foodName: 'Grilled Chicken Breast', defaultServing: '1 breast (200g)', calories: 330, proteinGrams: 62, carbsGrams: 0, fatGrams: 7 },
  { foodName: 'Greek Yogurt (Non-fat)', defaultServing: '1 cup (170g)', calories: 100, proteinGrams: 18, carbsGrams: 6, fatGrams: 0 },
  { foodName: 'Brown Rice with Steamed Broccoli', defaultServing: '1 cup (195g)', calories: 230, proteinGrams: 5.5, carbsGrams: 48, fatGrams: 2 },
  { foodName: 'Salmon Fillet (Pan-seared)', defaultServing: '1 fillet (180g)', calories: 370, proteinGrams: 36, carbsGrams: 0, fatGrams: 23 },
  { foodName: 'Avocado Toast on Sourdough', defaultServing: '2 slices', calories: 340, proteinGrams: 8, carbsGrams: 36, fatGrams: 18 },
  { foodName: 'Whey Protein Shake', defaultServing: '1 scoop with water', calories: 130, proteinGrams: 25, carbsGrams: 3, fatGrams: 1.5 },
  { foodName: 'Scrambled Eggs (3 whole)', defaultServing: '3 eggs', calories: 220, proteinGrams: 18, carbsGrams: 1.5, fatGrams: 15 },
  { foodName: 'Banana & Peanut Butter Smoothie', defaultServing: '1 large cup (350ml)', calories: 410, proteinGrams: 14, carbsGrams: 56, fatGrams: 16 },
  { foodName: 'Quinoa Bowl with Roasted Veggies', defaultServing: '1 bowl (300g)', calories: 310, proteinGrams: 11, carbsGrams: 54, fatGrams: 6 },
  { foodName: 'Tuna Salad with Olive Oil', defaultServing: '1 can (150g)', calories: 240, proteinGrams: 32, carbsGrams: 2, fatGrams: 11 },
  { foodName: 'Almonds (Raw)', defaultServing: '1 handful (30g)', calories: 170, proteinGrams: 6, carbsGrams: 6, fatGrams: 15 },
  { foodName: 'Sweet Potato (Baked)', defaultServing: '1 medium potato', calories: 160, proteinGrams: 3.5, carbsGrams: 37, fatGrams: 0.2 },
];

@Injectable()
export class NutritionService {
  private readonly logger = new Logger(NutritionService.name);
  private inMemoryMeals: any[] = [];

  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
  ) {
    // Seed initial meals for demo user
    this.inMemoryMeals.push(
      {
        id: 'nut_01',
        userId: 'usr_demo_777',
        mealType: 'breakfast',
        foodName: 'Oatmeal with Blueberries & Honey',
        servingAmount: 1,
        servingUnit: 'bowl',
        calories: 280,
        proteinGrams: 9,
        carbsGrams: 52,
        fatGrams: 4.5,
        loggedAt: new Date(),
      },
      {
        id: 'nut_02',
        userId: 'usr_demo_777',
        mealType: 'lunch',
        foodName: 'Grilled Chicken Breast & Brown Rice',
        servingAmount: 1,
        servingUnit: 'plate',
        calories: 560,
        proteinGrams: 67.5,
        carbsGrams: 48,
        fatGrams: 9,
        loggedAt: new Date(),
      }
    );
  }

  autocomplete(query: string): FoodSuggestion[] {
    if (!query || query.trim().length === 0) {
      return FOOD_DATABASE.slice(0, 6);
    }
    const q = query.toLowerCase().trim();
    return FOOD_DATABASE.filter((f) => f.foodName.toLowerCase().includes(q));
  }

  async logMeal(userId: string, dto: LogMealDto) {
    let savedMeal: any;
    try {
      savedMeal = await this.prisma.nutritionLog.create({
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
    } catch (e) {
      savedMeal = {
        id: `nut_${Date.now()}`,
        userId,
        ...dto,
        loggedAt: new Date(),
      };
      this.inMemoryMeals.unshift(savedMeal);
    }

    // Invalidate & refresh day's running total in Redis
    await this.refreshDayRunningTotals(userId);
    return savedMeal;
  }

  async getTodayMeals(userId: string) {
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    try {
      const meals = await this.prisma.nutritionLog.findMany({
        where: {
          userId,
          loggedAt: { gte: startOfDay },
        },
        orderBy: { loggedAt: 'desc' },
      });
      if (meals.length > 0) return meals;
    } catch (e) {}

    return this.inMemoryMeals.filter(
      (m) => (m.userId === userId || userId === 'usr_demo_777') && new Date(m.loggedAt) >= startOfDay
    );
  }

  async getTodaySummary(userId: string) {
    const todayKey = `nutrition:summary:${userId}:${new Date().toISOString().slice(0, 10)}`;
    const cached = await this.redis.get(todayKey);

    if (cached) {
      try {
        return JSON.parse(cached);
      } catch (e) {}
    }

    return await this.refreshDayRunningTotals(userId);
  }

  private async refreshDayRunningTotals(userId: string) {
    const meals = await this.getTodayMeals(userId);
    const summary = {
      targetCalories: 2400,
      consumedCalories: meals.reduce((sum, m) => sum + m.calories, 0),
      targetProteinGrams: 160,
      consumedProteinGrams: Math.round(meals.reduce((sum, m) => sum + m.proteinGrams, 0)),
      targetCarbsGrams: 260,
      consumedCarbsGrams: Math.round(meals.reduce((sum, m) => sum + m.carbsGrams, 0)),
      targetFatGrams: 70,
      consumedFatGrams: Math.round(meals.reduce((sum, m) => sum + m.fatGrams, 0)),
      loggedMealsCount: meals.length,
    };

    const todayKey = `nutrition:summary:${userId}:${new Date().toISOString().slice(0, 10)}`;
    // Cache until end of day (86400s)
    await this.redis.set(todayKey, JSON.stringify(summary), 86400);
    return summary;
  }
}
