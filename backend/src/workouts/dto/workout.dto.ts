import { IsString, IsNotEmpty, IsNumber, IsOptional, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class LogWorkoutDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  workoutId?: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  workoutTitle: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  category: string;

  @ApiProperty()
  @IsNumber()
  @Min(1)
  durationMinutes: number;

  @ApiProperty()
  @IsNumber()
  @Min(0)
  caloriesBurned: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(10)
  perceivedExertion?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  notes?: string;
}

export class UpdateWorkoutLogDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  @Min(1)
  durationMinutes?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  @Min(0)
  caloriesBurned?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  perceivedExertion?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  notes?: string;
}
