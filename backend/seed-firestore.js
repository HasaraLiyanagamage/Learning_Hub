const admin = require('firebase-admin');

// Initialize Firebase Admin
try {
  const serviceAccount = require('./firebase-service-account.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log('✅ Firebase Admin initialized');
} catch (error) {
  console.error('❌ Error initializing Firebase:', error.message);
  console.log('Make sure firebase-service-account.json exists in backend folder');
  process.exit(1);
}

const db = admin.firestore();

async function seedFirestore() {
  console.log('🌱 Starting Firestore seeding...\n');

  try {
    // ==================== USERS ====================
    console.log('📝 Seeding users...');
    
    await db.collection('users').doc('1').set({
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      password: 'user123',
      role: 'user',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    });

    await db.collection('users').doc('2').set({
      id: '2',
      name: 'Admin User',
      email: 'admin@learninghub.com',
      password: 'admin123',
      role: 'admin',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    });

    console.log('✅ Users seeded (2 documents)\n');

    // ==================== COURSES ====================
    console.log('📝 Seeding courses...');
    
    const courses = [
      {
        id: '1',
        title: 'Introduction to Flutter',
        description: 'Learn the basics of Flutter development and build your first mobile app',
        instructor: 'John Doe',
        duration: '10 hours',
        difficulty: 'Beginner',
        rating: 4.5,
        enrolled_count: 150,
        lessons_count: 5,
        category: 'Mobile Development'
      },
      {
        id: '2',
        title: 'Advanced Dart Programming',
        description: 'Master advanced Dart concepts including async programming, streams, and more',
        instructor: 'Jane Smith',
        duration: '8 hours',
        difficulty: 'Advanced',
        rating: 4.8,
        enrolled_count: 89,
        lessons_count: 4,
        category: 'Programming'
      },
      {
        id: '3',
        title: 'UI/UX Design Fundamentals',
        description: 'Learn the principles of great user interface and user experience design',
        instructor: 'Mike Johnson',
        duration: '6 hours',
        difficulty: 'Beginner',
        rating: 4.6,
        enrolled_count: 200,
        lessons_count: 3,
        category: 'Design'
      },
      {
        id: '4',
        title: 'Database Management with SQLite',
        description: 'Master SQLite database management for mobile applications',
        instructor: 'Sarah Williams',
        duration: '7 hours',
        difficulty: 'Intermediate',
        rating: 4.7,
        enrolled_count: 120,
        lessons_count: 4,
        category: 'Database'
      },
      {
        id: '5',
        title: 'State Management in Flutter',
        description: 'Learn different state management approaches in Flutter applications',
        instructor: 'David Brown',
        duration: '9 hours',
        difficulty: 'Intermediate',
        rating: 4.9,
        enrolled_count: 180,
        lessons_count: 5,
        category: 'Mobile Development'
      }
    ];

    for (const course of courses) {
      await db.collection('courses').doc(course.id).set({
        ...course,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      });
    }

    console.log(`✅ Courses seeded (${courses.length} documents)\n`);

    // ==================== LESSONS ====================
    console.log('📝 Seeding lessons...');
    
    const lessons = [
      // Course 1 lessons
      {
        id: '1',
        course_id: '1',
        title: 'Getting Started with Flutter',
        content: 'Welcome to Flutter! In this lesson, you\'ll learn about Flutter framework, its architecture, and how to set up your development environment. Flutter is Google\'s UI toolkit for building natively compiled applications.',
        duration: 30,
        order_index: 1,
        is_completed: 0
      },
      {
        id: '2',
        course_id: '1',
        title: 'Understanding Widgets',
        content: 'Widgets are the building blocks of Flutter apps. Learn about StatelessWidget, StatefulWidget, and how to create custom widgets. Everything in Flutter is a widget!',
        duration: 45,
        order_index: 2,
        is_completed: 0
      },
      {
        id: '3',
        course_id: '1',
        title: 'Layouts and Navigation',
        content: 'Master Flutter layouts using Row, Column, Stack, and Container. Learn how to navigate between screens using Navigator and named routes.',
        duration: 50,
        order_index: 3,
        is_completed: 0
      },
      // Course 2 lessons
      {
        id: '4',
        course_id: '2',
        title: 'Async Programming in Dart',
        content: 'Learn about Future, async/await, and how to handle asynchronous operations in Dart. Master error handling and best practices.',
        duration: 40,
        order_index: 1,
        is_completed: 0
      },
      {
        id: '5',
        course_id: '2',
        title: 'Streams and Reactive Programming',
        content: 'Understand Dart Streams, StreamController, and reactive programming patterns. Build responsive applications with streams.',
        duration: 55,
        order_index: 2,
        is_completed: 0
      }
    ];

    for (const lesson of lessons) {
      await db.collection('lessons').doc(lesson.id).set({
        ...lesson,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      });
    }

    console.log(`✅ Lessons seeded (${lessons.length} documents)\n`);

    // ==================== QUIZZES ====================
    console.log('📝 Seeding quizzes...');
    
    const quizzes = [
      {
        id: '1',
        course_id: '1',
        title: 'Flutter Basics Quiz',
        description: 'Test your understanding of Flutter fundamentals',
        duration: 15,
        passing_score: 70,
        total_questions: 5
      },
      {
        id: '2',
        course_id: '2',
        title: 'Dart Advanced Concepts',
        description: 'Challenge yourself with advanced Dart questions',
        duration: 20,
        passing_score: 75,
        total_questions: 5
      },
      {
        id: '3',
        course_id: '3',
        title: 'UI/UX Principles Quiz',
        description: 'Test your knowledge of design principles',
        duration: 10,
        passing_score: 70,
        total_questions: 5
      }
    ];

    for (const quiz of quizzes) {
      await db.collection('quizzes').doc(quiz.id).set({
        ...quiz,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      });
    }

    console.log(`✅ Quizzes seeded (${quizzes.length} documents)\n`);

    // ==================== QUIZ QUESTIONS ====================
    console.log('📝 Seeding quiz questions...');
    
    const questions = [
      // Quiz 1 questions
      {
        id: '1',
        quiz_id: '1',
        question: 'What is Flutter?',
        option_a: 'A UI framework for building mobile apps',
        option_b: 'A programming language',
        option_c: 'A database system',
        option_d: 'An IDE',
        correct_answer: 'A',
        explanation: 'Flutter is Google\'s UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.'
      },
      {
        id: '2',
        quiz_id: '1',
        question: 'What language does Flutter use?',
        option_a: 'Java',
        option_b: 'Kotlin',
        option_c: 'Dart',
        option_d: 'Swift',
        correct_answer: 'C',
        explanation: 'Flutter uses Dart programming language, which is optimized for building user interfaces.'
      },
      {
        id: '3',
        quiz_id: '1',
        question: 'Which widget is used for mutable state?',
        option_a: 'StatelessWidget',
        option_b: 'StatefulWidget',
        option_c: 'Container',
        option_d: 'Text',
        correct_answer: 'B',
        explanation: 'StatefulWidget is used when the widget needs to maintain mutable state that can change over time.'
      },
      // Quiz 2 questions
      {
        id: '4',
        quiz_id: '2',
        question: 'What does async keyword do in Dart?',
        option_a: 'Makes function synchronous',
        option_b: 'Returns a Future',
        option_c: 'Blocks execution',
        option_d: 'Creates a thread',
        correct_answer: 'B',
        explanation: 'The async keyword marks a function as asynchronous and makes it return a Future.'
      },
      {
        id: '5',
        quiz_id: '2',
        question: 'What is a Stream in Dart?',
        option_a: 'A file reader',
        option_b: 'A sequence of asynchronous events',
        option_c: 'A database connection',
        option_d: 'A network protocol',
        correct_answer: 'B',
        explanation: 'A Stream is a sequence of asynchronous events that can be listened to over time.'
      }
    ];

    for (const question of questions) {
      await db.collection('quiz_questions').doc(question.id).set({
        ...question,
        created_at: new Date().toISOString()
      });
    }

    console.log(`✅ Quiz questions seeded (${questions.length} documents)\n`);

    // ==================== SAMPLE NOTIFICATIONS ====================
    console.log('📝 Seeding sample notifications...');
    
    const notifications = [
      {
        id: '1',
        user_id: '1',
        title: 'Welcome to Learning Hub!',
        message: 'Start your learning journey today',
        type: 'announcement',
        is_read: 0,
        action_data: ''
      },
      {
        id: '2',
        user_id: '1',
        title: 'New Course Available!',
        message: 'Check out our new Advanced Flutter course',
        type: 'course',
        is_read: 0,
        action_data: '{"course_id": "2"}'
      }
    ];

    for (const notification of notifications) {
      await db.collection('notifications').doc(notification.id).set({
        ...notification,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      });
    }

    console.log(`✅ Notifications seeded (${notifications.length} documents)\n`);

    // ==================== SAMPLE ENROLLMENT ====================
    console.log('📝 Seeding sample enrollment...');
    
    await db.collection('enrollments').doc('1').set({
      id: '1',
      user_id: '1',
      course_id: '1',
      enrolled_at: new Date().toISOString(),
      progress: 40,
      status: 'active',
      completed_at: null
    });

    console.log('✅ Enrollment seeded (1 document)\n');

    // ==================== SAMPLE FAVORITE ====================
    console.log('📝 Seeding sample favorite...');
    
    await db.collection('favorites').doc('1').set({
      id: '1',
      user_id: '1',
      course_id: '2',
      created_at: new Date().toISOString()
    });

    console.log('✅ Favorite seeded (1 document)\n');

    // ==================== SUMMARY ====================
    console.log('═══════════════════════════════════════');
    console.log('🎉 Firestore Seeding Complete!');
    console.log('═══════════════════════════════════════');
    console.log('Collections created:');
    console.log('  ✅ users (2 documents)');
    console.log('  ✅ courses (5 documents)');
    console.log('  ✅ lessons (5 documents)');
    console.log('  ✅ quizzes (3 documents)');
    console.log('  ✅ quiz_questions (5 documents)');
    console.log('  ✅ notifications (2 documents)');
    console.log('  ✅ enrollments (1 document)');
    console.log('  ✅ favorites (1 document)');
    console.log('═══════════════════════════════════════');
    console.log('\n✨ Your Firestore database is ready!');
    console.log('🔗 Visit: https://console.firebase.google.com/');
    console.log('\n');

  } catch (error) {
    console.error('❌ Error seeding Firestore:', error);
    process.exit(1);
  }

  process.exit(0);
}

// Run the seeder
seedFirestore();
