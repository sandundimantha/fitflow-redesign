import { PrismaClient } from '@prisma/client';
import mongoose from 'mongoose';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting FitFlow Database Seeding...');

  // 1. Seed Demo User
  const user = await prisma.user.upsert({
    where: { firebaseUid: 'usr_demo_777' },
    update: {},
    create: {
      id: 'usr_demo_777',
      firebaseUid: 'usr_demo_777',
      email: 'alex.morgan@fitflow.app',
      displayName: 'Alex Morgan',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
      fitnessGoal: 'muscle_gain',
      experienceLevel: 'intermediate',
      weightKg: 74.5,
      heightCm: 178.0,
      language: 'en',
    },
  });
  console.log(`✅ Seeded User: ${user.displayName} (${user.id})`);

  // 2. Seed Workouts
  await prisma.workout.deleteMany({});
  const todayWorkout = await prisma.workout.create({
    data: {
      id: 'wk_today_01',
      title: 'Functional Full-Body Hypertrophy',
      category: 'Strength',
      durationMinutes: 45,
      difficulty: 'Intermediate',
      caloriesBurnEstimate: 380,
      imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',
      description: 'Target compound movement chains focusing on chest, upper back, and quads for balanced power and posture.',
      isScheduledToday: true,
      exercisesJson: JSON.stringify([
        { name: 'Goblet Squats', sets: 4, reps: '10-12', rest: 90, target: 'Quads & Glutes' },
        { name: 'Dumbbell Bench Press', sets: 4, reps: '8-10', rest: 90, target: 'Chest & Triceps' },
        { name: 'Dumbbell Bent-Over Row', sets: 3, reps: '10-12', rest: 75, target: 'Lats & Rhomboids' },
        { name: 'Plank Shoulder Taps', sets: 3, reps: '45 sec', rest: 45, target: 'Core Anti-Rotation' },
      ]),
    },
  });

  await prisma.workout.createMany({
    data: [
      {
        id: 'wk_hiit_02',
        title: 'Metabolic HIIT Blaze',
        category: 'HIIT',
        durationMinutes: 25,
        difficulty: 'Advanced',
        caloriesBurnEstimate: 320,
        imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800',
        description: 'High-intensity interval training designed to accelerate anaerobic capacity and EPOC calorie afterburn.',
        isScheduledToday: false,
        exercisesJson: JSON.stringify([
          { name: 'Burpees to Jump', sets: 4, reps: '40 sec on / 20 off', rest: 45, target: 'Cardiovascular' },
          { name: 'Mountain Climbers', sets: 4, reps: '40 sec on / 20 off', rest: 45, target: 'Core' },
        ]),
      },
      {
        id: 'wk_cardio_03',
        title: 'Zone 2 Aerobic Conditioning',
        category: 'Cardio',
        durationMinutes: 35,
        difficulty: 'Beginner',
        caloriesBurnEstimate: 260,
        imageUrl: 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=800',
        description: 'Low-impact steady state cardio building mitochondrial density and heart-rate recovery efficiency.',
        isScheduledToday: false,
        exercisesJson: JSON.stringify([
          { name: 'Incline Treadmill Walk / Steady Run', sets: 1, reps: '35 min', rest: 0, target: 'Cardiovascular' },
        ]),
      },
      {
        id: 'wk_mobility_04',
        title: 'Deep Hip & Thoracic Spine Mobility',
        category: 'Mobility',
        durationMinutes: 20,
        difficulty: 'Beginner',
        caloriesBurnEstimate: 110,
        imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800',
        description: 'Decompress lumbar tension, open tight hips, and increase thoracic rotation for injury prevention.',
        isScheduledToday: false,
        exercisesJson: JSON.stringify([
          { name: 'World Greatest Stretch', sets: 3, reps: '5 per side', rest: 30, target: 'Thoracic & Hips' },
          { name: '90/90 Hip Flow', sets: 3, reps: '60 sec', rest: 30, target: 'Hip Rotators' },
        ]),
      },
    ],
  });
  console.log(`✅ Seeded Workouts (including today's scheduled workout: ${todayWorkout.title})`);

  // 3. Seed Past Workout Logs for Progress Chart Comparison (This week vs Last week)
  await prisma.workoutLog.deleteMany({});
  const now = new Date();
  const dayMs = 24 * 60 * 60 * 1000;

  await prisma.workoutLog.createMany({
    data: [
      // This week
      {
        userId: user.id,
        workoutTitle: 'Functional Full-Body Hypertrophy',
        category: 'Strength',
        durationMinutes: 45,
        caloriesBurned: 380,
        perceivedExertion: 8,
        notes: 'Pushed hard on goblet squats.',
        completedAt: new Date(now.getTime() - 1 * dayMs),
      },
      {
        userId: user.id,
        workoutTitle: 'Metabolic HIIT Blaze',
        category: 'HIIT',
        durationMinutes: 30,
        caloriesBurned: 340,
        perceivedExertion: 9,
        notes: 'Sweat drenched interval session.',
        completedAt: new Date(now.getTime() - 2 * dayMs),
      },
      {
        userId: user.id,
        workoutTitle: 'Zone 2 Aerobic Conditioning',
        category: 'Cardio',
        durationMinutes: 40,
        caloriesBurned: 290,
        perceivedExertion: 6,
        notes: 'Recovery run in the park.',
        completedAt: new Date(now.getTime() - 4 * dayMs),
      },
      // Last week
      {
        userId: user.id,
        workoutTitle: 'Upper Body Blast',
        category: 'Strength',
        durationMinutes: 40,
        caloriesBurned: 320,
        perceivedExertion: 7,
        notes: 'Dumbbell bench press progression.',
        completedAt: new Date(now.getTime() - 8 * dayMs),
      },
      {
        userId: user.id,
        workoutTitle: 'Interval Cycling Sprint',
        category: 'Cardio',
        durationMinutes: 25,
        caloriesBurned: 240,
        perceivedExertion: 8,
        notes: 'Tabata cycling protocol.',
        completedAt: new Date(now.getTime() - 10 * dayMs),
      },
      {
        userId: user.id,
        workoutTitle: 'Total Body Functional Circuit',
        category: 'Strength',
        durationMinutes: 35,
        caloriesBurned: 280,
        perceivedExertion: 7,
        notes: 'Circuit training with dumbbells.',
        completedAt: new Date(now.getTime() - 12 * dayMs),
      },
    ],
  });
  console.log(`✅ Seeded 6 Workout Logs for weekly comparison charts`);

  // 4. Seed Nutrition Logs for Today
  await prisma.nutritionLog.deleteMany({});
  await prisma.nutritionLog.createMany({
    data: [
      {
        userId: user.id,
        mealType: 'breakfast',
        foodName: 'Oatmeal with Blueberries & Honey',
        servingAmount: 1,
        servingUnit: 'bowl',
        calories: 280,
        proteinGrams: 9,
        carbsGrams: 52,
        fatGrams: 4.5,
        loggedAt: new Date(now.getTime() - 4 * 3600 * 1000),
      },
      {
        userId: user.id,
        mealType: 'lunch',
        foodName: 'Grilled Chicken Breast & Brown Rice',
        servingAmount: 1,
        servingUnit: 'plate',
        calories: 560,
        proteinGrams: 67.5,
        carbsGrams: 48,
        fatGrams: 9,
        loggedAt: new Date(now.getTime() - 1 * 3600 * 1000),
      },
    ],
  });
  console.log(`✅ Seeded Today's Nutrition Meals`);

  // 5. Seed MongoDB Social Feed Posts (if Mongo is reachable)
  try {
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/fitflow_mongo';
    await mongoose.connect(mongoUri, { serverSelectionTimeoutMS: 2000 });
    const postCollection = mongoose.connection.collection('socialposts');
    await postCollection.deleteMany({});
    await postCollection.insertMany([
      {
        userId: 'usr_sarah_11',
        authorName: 'Sarah Jenkins',
        authorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        content: 'Crushed Day 12 of the Spring Lean Muscle challenge! Hit a new 5-rep PR on Goblet Squats (28kg). The AI progressive plan is genuinely working 🔥💪',
        mediaUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800',
        challengeId: 'ch_01',
        challengeName: 'Spring 30-Day Lean Muscle Protocol',
        likesCount: 24,
        likedBy: ['usr_demo_777', 'usr_mike_99'],
        comments: [
          {
            id: 'c_1',
            userId: 'usr_mike_99',
            authorName: 'Mike Chen',
            authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
            text: 'Huge work Sarah! Form looked clean!',
            createdAt: new Date(),
          },
        ],
        createdAt: new Date(),
      },
      {
        userId: 'usr_david_22',
        authorName: 'David Miller',
        authorAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        content: 'Hit 12,400 steps today before 6 PM. Zone 2 recovery walk completed around the park. Keep moving team! 👟🌿',
        challengeId: 'ch_02',
        challengeName: '10,000 Daily Steps Consistency Quest',
        likesCount: 19,
        likedBy: [],
        comments: [],
        createdAt: new Date(),
      },
    ]);
    await mongoose.disconnect();
    console.log(`✅ Seeded MongoDB Social Feed Posts`);
  } catch (err) {
    console.log(`ℹ️  MongoDB not reachable during seed (${err.message}). In-memory feed fallback will be used.`);
  }

  console.log('🎉 FitFlow database seeding completed successfully!');
}

main()
  .catch((e) => {
    console.error('❌ Seeding error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
