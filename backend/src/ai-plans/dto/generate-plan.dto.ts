import { IsString, IsNotEmpty, IsArray, IsOptional, IsInt, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class GeneratePlanDto {
  @ApiProperty({ example: 'muscle_gain', description: 'Target goal: muscle_gain, weight_loss, endurance, functional_fitness' })
  @IsNotEmpty()
  @IsString()
  goal: string;

  @ApiProperty({ example: ['dumbbells', 'pullup_bar'], description: 'List of available equipment' })
  @IsArray()
  @IsString({ each: true })
  availableEquipment: string[];

  @ApiPropertyOptional({ example: 'intermediate' })
  @IsOptional()
  @IsString()
  experienceLevel?: string;

  @ApiPropertyOptional({ example: 4, minimum: 2, maximum: 6 })
  @IsOptional()
  @IsInt()
  @Min(2)
  @Max(6)
  daysPerWeek?: number;
}
