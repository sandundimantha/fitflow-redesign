from typing import List, Optional
from pydantic import BaseModel, Field

class WorkoutHistoryItem(BaseModel):
    category: str = Field(..., description="Workout category, e.g., Strength, Cardio, HIIT, Yoga")
    duration_minutes: int = Field(..., description="Workout duration in minutes")
    completed_at: Optional[str] = Field(None, description="ISO timestamp of completion")
    perceived_exertion: Optional[int] = Field(None, description="RPE 1-10 rating if available")

class GeneratePlanRequest(BaseModel):
    user_id: str = Field(..., description="ID of the user requesting the plan")
    goal: str = Field(..., description="Primary fitness goal: muscle_gain, weight_loss, endurance, functional_fitness")
    available_equipment: List[str] = Field(default_factory=list, description="List of equipment available: dumbbells, barbell, pullup_bar, bodyweight, resistance_bands")
    experience_level: Optional[str] = Field("intermediate", description="beginner, intermediate, advanced")
    days_per_week: Optional[int] = Field(4, description="Target training frequency per week (2-6)")
    workout_history: Optional[List[WorkoutHistoryItem]] = Field(default_factory=list, description="Historical workouts from PostgreSQL")

class ExercisePlanItem(BaseModel):
    name: str
    target_muscle: str
    equipment_required: str
    sets: int
    reps: str
    rest_seconds: int
    rationale: str = Field(..., description="One-line explanation of why this exercise was chosen for the user")

class DayRoutine(BaseModel):
    day_number: int
    day_title: str
    focus: str
    estimated_duration_minutes: int
    exercises: List[ExercisePlanItem]

class GeneratePlanResponse(BaseModel):
    plan_id: str
    title: str
    goal: str
    experience_level: str
    duration_weeks: int
    days_per_week: int
    summary: str
    generated_at: str
    routines: List[DayRoutine]
