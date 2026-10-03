import pytest
from schemas import GeneratePlanRequest, WorkoutHistoryItem
from generator import generate_custom_plan

def test_generate_plan_dumbbells_muscle_gain():
    req = GeneratePlanRequest(
        user_id="user_123",
        goal="muscle_gain",
        available_equipment=["dumbbells"],
        experience_level="intermediate",
        days_per_week=3,
        workout_history=[
            WorkoutHistoryItem(category="Strength", duration_minutes=45)
        ]
    )
    plan = generate_custom_plan(req)
    assert plan.plan_id is not None
    assert plan.goal == "muscle_gain"
    assert len(plan.routines) == 3
    for routine in plan.routines:
        assert len(routine.exercises) > 0
        for ex in routine.exercises:
            assert ex.rationale != ""
            assert len(ex.rationale) > 10

def test_generate_plan_bodyweight_weight_loss():
    req = GeneratePlanRequest(
        user_id="user_456",
        goal="weight_loss",
        available_equipment=["bodyweight"],
        experience_level="beginner",
        days_per_week=4,
        workout_history=[]
    )
    plan = generate_custom_plan(req)
    assert plan.days_per_week == 4
    assert len(plan.routines) == 4
    for r in plan.routines:
        for ex in r.exercises:
            assert ex.equipment_required == "bodyweight"
            assert "bodyweight" in ex.rationale.lower() or "calorie" in ex.rationale.lower() or "functional" in ex.rationale.lower() or "core" in ex.rationale.lower()
