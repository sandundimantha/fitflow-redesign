import { IsString, IsNotEmpty, IsNumber, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LogMealDto {
  @ApiProperty({ example: 'lunch' })
  @IsNotEmpty()
  @IsString()
  mealType: string;

  @ApiProperty({ example: 'Grilled Chicken Salad' })
  @IsNotEmpty()
  @IsString()
  foodName: string;

  @ApiProperty({ example: 1.5 })
  @IsNumber()
  @Min(0.1)
  servingAmount: number;

  @ApiProperty({ example: 'bowl' })
  @IsNotEmpty()
  @IsString()
  servingUnit: string;

  @ApiProperty({ example: 380 })
  @IsNumber()
  @Min(0)
  calories: number;

  @ApiProperty({ example: 42.0 })
  @IsNumber()
  @Min(0)
  proteinGrams: number;

  @ApiProperty({ example: 14.5 })
  @IsNumber()
  @Min(0)
  carbsGrams: number;

  @ApiProperty({ example: 12.0 })
  @IsNumber()
  @Min(0)
  fatGrams: number;
}
