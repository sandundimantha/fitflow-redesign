import { Controller, Get, Post, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { NutritionService } from './nutrition.service';
import { LogMealDto } from './dto/nutrition.dto';
import { FirebaseAuthGuard } from '../auth/firebase-auth.guard';
import { CurrentUser, AuthUser } from '../auth/current-user.decorator';

@ApiTags('Nutrition & Meals')
@Controller('nutrition')
@UseGuards(FirebaseAuthGuard)
@ApiBearerAuth()
export class NutritionController {
  constructor(private readonly nutritionService: NutritionService) {}

  @Get('autocomplete')
  @ApiOperation({ summary: 'Food-name autocomplete suggesting macro breakdown as user types' })
  @ApiQuery({ name: 'q', required: false, description: 'Partial food query' })
  autocomplete(@Query('q') query?: string) {
    return this.nutritionService.autocomplete(query || '');
  }

  @Post('log')
  @ApiOperation({ summary: 'Log a meal with full calorie/macro breakdown, updating Redis cache' })
  async logMeal(@CurrentUser() user: AuthUser, @Body() dto: LogMealDto) {
    return await this.nutritionService.logMeal(user.id, dto);
  }

  @Get('today-summary')
  @ApiOperation({ summary: "Get today's running calories & macro breakdown cached in Redis for fast dashboard display" })
  async getTodaySummary(@CurrentUser() user: AuthUser) {
    return await this.nutritionService.getTodaySummary(user.id);
  }

  @Get('logs/today')
  @ApiOperation({ summary: "List all meals logged today" })
  async getTodayMeals(@CurrentUser() user: AuthUser) {
    return await this.nutritionService.getTodayMeals(user.id);
  }
}
