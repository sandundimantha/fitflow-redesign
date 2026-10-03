import os
import json
import uuid
from datetime import datetime, timezone
from typing import List, Dict, Any, Optional
from schemas import GeneratePlanRequest, GeneratePlanResponse, DayRoutine, ExercisePlanItem

class ExerciseCatalogRepository:
    """Data Access Repository for Exercise Definitions."""
    _instance: Optional["ExerciseCatalogRepository"] = None

    def __init__(self, data_path: Optional[str] = None):
        if data_path is None:
            base_dir = os.path.dirname(os.path.abspath(__file__))
            data_path = os.path.join(base_dir, "data", "exercise_catalog.json")
        self.data_path = data_path
        self._catalog: Dict[str, Dict[str, Any]] = {}
        self._load_catalog()

    @classmethod
    def get_instance(cls) -> "ExerciseCatalogRepository":
        if cls._instance is None:
            cls._instance = ExerciseCatalogRepository()
        return cls._instance

    def _load_catalog(self) -> None:
        if not os.path.exists(self.data_path):
            raise FileNotFoundError(f"Exercise catalog file not found at: {self.data_path}")
        with open(self.data_path, "r", encoding="utf-8") as f:
            payload = json.load(f)
            for item in payload.get("exercises", []):
                self._catalog[item["name"]] = item

    def get_all(self) -> Dict[str, Dict[str, Any]]:
        return self._catalog

    def find_by_equipment(self, allowed_equipment: set) -> Dict[str, Dict[str, Any]]:
        return {
            name: data for name, data in self._catalog.items()
            if data.get("equipment", "bodyweight").lower() in allowed_equipment
        }


class WorkoutPlanGeneratorService:
    """Domain service responsible for generating customized workout routines based on user constraints and history."""

    def __init__(self, catalog_repo: Optional[ExerciseCatalogRepository] = None):
        self.catalog_repo = catalog_repo or ExerciseCatalogRepository.get_instance()

    def generate(self, request: GeneratePlanRequest) -> GeneratePlanResponse:
        goal = request.goal.lower()
        equip_set = {e.lower().strip() for e in request.available_equipment}
        equip_set.add("bodyweight")

        # 1. Analyze workout history
        history = request.workout_history or []
        past_categories = [h.category.lower() for h in history]
        avg_past_duration = (
            sum(h.duration_minutes for h in history) // len(history)
            if history else 40
        )
        has_recent_strength = any("strength" in c or "weight" in c for c in past_categories)
        has_recent_cardio = any("cardio" in c or "run" in c or "hiit" in c for c in past_categories)

        # 2. Filter matching exercises from repository
        compatible = self.catalog_repo.find_by_equipment(equip_set)
        if not compatible:
            compatible = self.catalog_repo.find_by_equipment({"bodyweight"})

        days_to_plan = min(max(request.days_per_week or 3, 2), 5)
        routines: List[DayRoutine] = []

        day_templates = [
            {"title": "Day 1: Upper Body Push & Pull", "focus": "Upper Body & Posture", "types": ["Chest", "Upper Back / Lats", "Shoulders / Upper Chest", "Core / Anti-Rotation"]},
            {"title": "Day 2: Lower Body & Core Power", "focus": "Legs & Posterior Chain", "types": ["Quadriceps / Glutes", "Hamstrings / Glutes", "Quadriceps / Calves", "Core / Cardiovascular"]},
            {"title": "Day 3: Full Body Conditioning", "focus": "Metabolic Balance & Mobility", "types": ["Chest / Core", "Mid Back / Biceps", "Core / Anti-Rotation", "Core / Cardiovascular"]},
            {"title": "Day 4: Hypertrophy & Arms Accent", "focus": "Targeted Muscle Definition", "types": ["Chest", "Lats / Biceps", "Biceps", "Triceps"]},
            {"title": "Day 5: Athletic Agility & Stamina", "focus": "Endurance & Speed", "types": ["Quadriceps / Calves", "Chest / Core", "Core / Anti-Rotation", "Rear Delts / Rotator Cuff"]}
        ]

        for d_idx in range(days_to_plan):
            tmpl = day_templates[d_idx % len(day_templates)]
            selected_exercises: List[ExercisePlanItem] = []

            for ex_type in tmpl["types"]:
                candidates = [
                    (name, data) for name, data in compatible.items()
                    if ex_type.lower() in data.get("muscle", "").lower()
                ]

                if not candidates:
                    candidates = list(compatible.items())

                chosen_name, chosen_data = candidates[0]

                # Dynamic 1-line rationale based on goal, equipment, and user historical volume
                custom_rationale = chosen_data.get("defaultRationale", "Targeted movement for physical adaptation.")
                if "dumbbells" in equip_set and chosen_data.get("equipment") == "dumbbells":
                    custom_rationale = f"Utilizes your dumbbells to isolate the {chosen_data['muscle'].lower()} with progressive overload."
                elif chosen_data.get("equipment") == "bodyweight":
                    custom_rationale = f"Leverages bodyweight mechanics to build functional control and metabolic conditioning."

                if has_recent_cardio and "muscle_gain" in goal:
                    custom_rationale += " Chosen to counteract recent cardio volume with hypertrophic stimulus."
                elif has_recent_strength and "weight_loss" in goal:
                    custom_rationale += " Chosen with shortened rest intervals to sustain elevated calorie burn."

                sets = chosen_data.get("baseSets", 3)
                reps = chosen_data.get("baseReps", "10-12")
                rest = chosen_data.get("restSeconds", 60)

                if "muscle_gain" in goal or "strength" in goal:
                    reps = "8-10" if "sec" not in reps else reps
                    rest = min(rest + 15, 120)
                elif "weight_loss" in goal or "endurance" in goal:
                    sets = max(sets, 3)
                    reps = "12-15" if "sec" not in reps else reps
                    rest = max(rest - 15, 30)

                selected_exercises.append(
                    ExercisePlanItem(
                        name=chosen_name,
                        target_muscle=chosen_data["muscle"],
                        equipment_required=chosen_data["equipment"],
                        sets=sets,
                        reps=reps,
                        rest_seconds=rest,
                        rationale=custom_rationale
                    )
                )

            duration = min(max(avg_past_duration, 30), 55)
            routines.append(
                DayRoutine(
                    day_number=d_idx + 1,
                    day_title=tmpl["title"],
                    focus=tmpl["focus"],
                    estimated_duration_minutes=duration,
                    exercises=selected_exercises
                )
            )

        goal_display = goal.replace("_", " ").title()
        level_display = (request.experience_level or "Intermediate").title()

        return GeneratePlanResponse(
            plan_id=str(uuid.uuid4()),
            title=f"AI Personalized {goal_display} Protocol",
            goal=request.goal,
            experience_level=level_display,
            duration_weeks=4,
            days_per_week=days_to_plan,
            summary=f"Customized 4-week {level_display} plan targeting {goal_display} using {', '.join(equip_set)}. Informed by {len(history)} past sessions.",
            generated_at=datetime.now(timezone.utc).isoformat(),
            routines=routines
        )

# Factory helper for backwards compatibility and clean injection
_default_generator = WorkoutPlanGeneratorService()

def generate_custom_plan(request: GeneratePlanRequest) -> GeneratePlanResponse:
    return _default_generator.generate(request)
