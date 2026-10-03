import uuid
from datetime import datetime, timezone
from typing import List, Dict, Any
from schemas import GeneratePlanRequest, GeneratePlanResponse, DayRoutine, ExercisePlanItem

EXERCISE_CATALOG: Dict[str, Dict[str, Any]] = {
    # Chest
    "Dumbbell Bench Press": {
        "muscle": "Chest",
        "equipment": "dumbbells",
        "goals": ["muscle_gain", "strength", "functional_fitness"],
        "base_sets": 4, "base_reps": "8-12", "rest": 90,
        "default_rationale": "High-recruitment compound exercise targeting pectorals and triceps with unilateral stability."
    },
    "Push-ups": {
        "muscle": "Chest / Core",
        "equipment": "bodyweight",
        "goals": ["muscle_gain", "weight_loss", "endurance", "functional_fitness"],
        "base_sets": 3, "base_reps": "15-20", "rest": 60,
        "default_rationale": "Foundational closed-kinetic chain pressing movement that activates the anterior chest while reinforcing core stabilization."
    },
    "Barbell Bench Press": {
        "muscle": "Chest",
        "equipment": "barbell",
        "goals": ["muscle_gain", "strength"],
        "base_sets": 4, "base_reps": "6-10", "rest": 120,
        "default_rationale": "Primary maximum-load horizontal press for progressive chest overload and power."
    },

    # Back
    "Dumbbell Bent-Over Row": {
        "muscle": "Upper Back / Lats",
        "equipment": "dumbbells",
        "goals": ["muscle_gain", "weight_loss", "functional_fitness"],
        "base_sets": 3, "base_reps": "10-12", "rest": 75,
        "default_rationale": "Essential horizontal pull that counters forward-rolled posture and reinforces upper back thickness."
    },
    "Pull-ups / Chin-ups": {
        "muscle": "Lats / Biceps",
        "equipment": "pullup_bar",
        "goals": ["muscle_gain", "strength", "functional_fitness"],
        "base_sets": 3, "base_reps": "6-10", "rest": 90,
        "default_rationale": "Premier vertical pulling motion to develop latissimus dorsi width and functional relative body strength."
    },
    "Inverted Bodyweight Row": {
        "muscle": "Mid Back / Biceps",
        "equipment": "bodyweight",
        "goals": ["weight_loss", "endurance", "functional_fitness"],
        "base_sets": 3, "base_reps": "12-15", "rest": 60,
        "default_rationale": "Accessible bodyweight pulling variation to strengthen scapular retractors without heavy spinal compression."
    },

    # Legs
    "Goblet Squats": {
        "muscle": "Quadriceps / Glutes",
        "equipment": "dumbbells",
        "goals": ["muscle_gain", "weight_loss", "functional_fitness"],
        "base_sets": 4, "base_reps": "10-12", "rest": 90,
        "default_rationale": "Anterior load placement reinforces an upright torso while building quad hypertrophy and hip mobility."
    },
    "Barbell Back Squat": {
        "muscle": "Quadriceps / Glutes / Hamstrings",
        "equipment": "barbell",
        "goals": ["muscle_gain", "strength"],
        "base_sets": 4, "base_reps": "6-8", "rest": 120,
        "default_rationale": "Gold standard multi-joint lower body movement for systemic strength and hormonal adaptation."
    },
    "Bodyweight Jump Squats": {
        "muscle": "Quadriceps / Calves",
        "equipment": "bodyweight",
        "goals": ["weight_loss", "endurance"],
        "base_sets": 4, "base_reps": "15-20", "rest": 45,
        "default_rationale": "Explosive triple-extension plyometric that spikes heart rate and accelerates caloric expenditure."
    },
    "Romanian Deadlift (Dumbbell)": {
        "muscle": "Hamstrings / Glutes",
        "equipment": "dumbbells",
        "goals": ["muscle_gain", "functional_fitness"],
        "base_sets": 3, "base_reps": "10-12", "rest": 90,
        "default_rationale": "Hip-hinge pattern prioritizing hamstring eccentric stretch and glute recruitment without excessive lower back shear."
    },

    # Shoulders & Arms
    "Dumbbell Overhead Shoulder Press": {
        "muscle": "Deltoids / Triceps",
        "equipment": "dumbbells",
        "goals": ["muscle_gain", "strength", "functional_fitness"],
        "base_sets": 3, "base_reps": "8-12", "rest": 75,
        "default_rationale": "Compound vertical press developing balanced front and lateral deltoid heads."
    },
    "Pike Push-ups": {
        "muscle": "Shoulders / Upper Chest",
        "equipment": "bodyweight",
        "goals": ["muscle_gain", "functional_fitness", "endurance"],
        "base_sets": 3, "base_reps": "10-12", "rest": 60,
        "default_rationale": "Bodyweight overhead pressing progression to safely load anterior delts without equipment."
    },
    "Dumbbell Bicep Curls": {
        "muscle": "Biceps",
        "equipment": "dumbbells",
        "goals": ["muscle_gain"],
        "base_sets": 3, "base_reps": "12-15", "rest": 60,
        "default_rationale": "Direct isolation for elbow flexor hypertrophy and tendon resilience."
    },
    "Dumbbell Overhead Tricep Extension": {
        "muscle": "Triceps",
        "equipment": "dumbbells",
        "goals": ["muscle_gain"],
        "base_sets": 3, "base_reps": "12-15", "rest": 60,
        "default_rationale": "Places triceps long head under maximum stretch for complete upper-arm muscular symmetry."
    },

    # Core & Conditioning
    "Plank to Shoulder Taps": {
        "muscle": "Core / Anti-Rotation",
        "equipment": "bodyweight",
        "goals": ["weight_loss", "functional_fitness", "endurance"],
        "base_sets": 3, "base_reps": "30-45 sec", "rest": 45,
        "default_rationale": "Dynamic anti-rotational core stability challenge that protects the lumbar spine during daily movement."
    },
    "Mountain Climbers": {
        "muscle": "Core / Cardiovascular",
        "equipment": "bodyweight",
        "goals": ["weight_loss", "endurance"],
        "base_sets": 3, "base_reps": "40 sec", "rest": 30,
        "default_rationale": "High-cadence core conditioning that maximizes cardiovascular output without requiring machines."
    },
    "Resistance Band Face Pulls": {
        "muscle": "Rear Delts / Rotator Cuff",
        "equipment": "resistance_bands",
        "goals": ["muscle_gain", "functional_fitness", "endurance"],
        "base_sets": 3, "base_reps": "15-20", "rest": 60,
        "default_rationale": "Postural correction and rotator cuff health essential for long-term shoulder longevity."
    }
}

def generate_custom_plan(request: GeneratePlanRequest) -> GeneratePlanResponse:
    goal = request.goal.lower()
    equip_set = set(e.lower().strip() for e in request.available_equipment)
    # Always allow bodyweight exercises
    equip_set.add("bodyweight")
    
    # Analyze user workout history from PostgreSQL
    history = request.workout_history or []
    past_categories = [h.category.lower() for h in history]
    avg_past_duration = (
        sum(h.duration_minutes for h in history) // len(history)
        if history else 40
    )
    
    has_recent_strength = any("strength" in c or "weight" in c for c in past_categories)
    has_recent_cardio = any("cardio" in c or "run" in c or "hiit" in c for c in past_categories)

    # Filter catalog by available equipment
    compatible_exercises = {
        name: data for name, data in EXERCISE_CATALOG.items()
        if data["equipment"] in equip_set
    }

    # If no specific equipment matches, fallback to bodyweight
    if not compatible_exercises:
        compatible_exercises = {
            name: data for name, data in EXERCISE_CATALOG.items()
            if data["equipment"] == "bodyweight"
        }

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
                (name, data) for name, data in compatible_exercises.items()
                if ex_type.lower() in data["muscle"].lower()
            ]
            
            if not candidates:
                # pick any compatible exercise
                candidates = list(compatible_exercises.items())

            chosen_name, chosen_data = candidates[0]
            
            # Formulate dynamic 1-line rationale based on goal, equipment, and history
            custom_rationale = chosen_data["default_rationale"]
            if "dumbbells" in equip_set and chosen_data["equipment"] == "dumbbells":
                custom_rationale = f"Utilizes your dumbbells to isolate the {chosen_data['muscle'].lower()} with progressive overload."
            elif chosen_data["equipment"] == "bodyweight":
                custom_rationale = f"Leverages bodyweight mechanics to build functional control and metabolic conditioning."
            
            if has_recent_cardio and "muscle_gain" in goal:
                custom_rationale += " Chosen to counteract recent cardio volume with hypertrophic stimulus."
            elif has_recent_strength and "weight_loss" in goal:
                custom_rationale += " Chosen with shortened rest intervals to sustain elevated calorie burn."

            # Adjust sets & reps based on goal
            sets = chosen_data["base_sets"]
            reps = chosen_data["base_reps"]
            rest = chosen_data["rest"]
            
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
