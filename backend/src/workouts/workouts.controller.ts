import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Body,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { WorkoutsService } from './workouts.service';
import { LogWorkoutDto, UpdateWorkoutLogDto } from './dto/workout.dto';
import { FirebaseAuthGuard } from '../auth/firebase-auth.guard';
import { CurrentUser, AuthUser } from '../auth/current-user.decorator';

@ApiTags('Workouts & Tracking')
@Controller('workouts')
@UseGuards(FirebaseAuthGuard)
@ApiBearerAuth()
export class WorkoutsController {
  constructor(private readonly workoutsService: WorkoutsService) {}

  @Get('today')
  @ApiOperation({ summary: "Retrieve today's scheduled workout (surfaced above the fold on the dashboard)" })
  async getTodayWorkout() {
    return await this.workoutsService.getTodayScheduledWorkout();
  }

  @Get()
  @ApiOperation({ summary: 'Browse workouts filterable by category and max duration' })
  @ApiQuery({ name: 'category', required: false, enum: ['All', 'Strength', 'Cardio', 'HIIT', 'Mobility'] })
  @ApiQuery({ name: 'maxDuration', required: false, type: Number })
  @ApiQuery({ name: 'difficulty', required: false })
  async getWorkouts(
    @Query('category') category?: string,
    @Query('maxDuration') maxDuration?: number,
    @Query('difficulty') difficulty?: string,
  ) {
    return await this.workoutsService.findAll(category, maxDuration, difficulty);
  }

  @Get('logs/history')
  @ApiOperation({ summary: 'Get workout history directly accessible from dashboard, filterable by category and duration' })
  @ApiQuery({ name: 'category', required: false })
  @ApiQuery({ name: 'maxDuration', required: false, type: Number })
  async getHistory(
    @CurrentUser() user: AuthUser,
    @Query('category') category?: string,
    @Query('maxDuration') maxDuration?: number,
  ) {
    return await this.workoutsService.getWorkoutHistory(user.id, category, maxDuration);
  }

  @Get('stats/weekly-comparison')
  @ApiOperation({ summary: 'Retrieve progress charts comparing this week vs last week with clearly labeled legend' })
  async getWeeklyComparison(@CurrentUser() user: AuthUser) {
    return await this.workoutsService.getWeeklyComparisonStats(user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get single workout details and exercise plan breakdown' })
  async getWorkout(@Param('id') id: string) {
    return await this.workoutsService.findOne(id);
  }

  @Post('log')
  @ApiOperation({ summary: 'Log a completed workout session' })
  async logWorkout(@CurrentUser() user: AuthUser, @Body() dto: LogWorkoutDto) {
    return await this.workoutsService.logWorkout(user.id, dto);
  }

  @Patch('logs/:id')
  @ApiOperation({ summary: 'Edit an existing logged workout entry (e.g. correct duration, notes)' })
  async updateLog(
    @CurrentUser() user: AuthUser,
    @Param('id') id: string,
    @Body() dto: UpdateWorkoutLogDto,
  ) {
    return await this.workoutsService.updateWorkoutLog(id, user.id, dto);
  }
}
