import { Controller, Post, Get, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AiPlansService } from './ai-plans.service';
import { GeneratePlanDto } from './dto/generate-plan.dto';
import { FirebaseAuthGuard } from '../auth/firebase-auth.guard';
import { CurrentUser, AuthUser } from '../auth/current-user.decorator';

@ApiTags('AI Workout Generator')
@Controller('ai-plans')
@UseGuards(FirebaseAuthGuard)
@ApiBearerAuth()
export class AiPlansController {
  constructor(private readonly aiPlansService: AiPlansService) {}

  @Post('generate')
  @ApiOperation({
    summary: 'Generate personalized workout plan via FastAPI microservice with one-line exercise rationale',
  })
  async generatePlan(@CurrentUser() user: AuthUser, @Body() dto: GeneratePlanDto) {
    return await this.aiPlansService.generateAndSavePlan(user.id, dto);
  }

  @Get('my-plans')
  @ApiOperation({ summary: 'Retrieve historical AI-generated plans saved for the current user' })
  async getMyPlans(@CurrentUser() user: AuthUser) {
    return await this.aiPlansService.getUserPlans(user.id);
  }
}
