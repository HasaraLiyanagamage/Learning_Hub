import 'database_helper.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';
import '../core/constants/app_constants.dart';

class DataSeeder {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<void> seedDatabase({bool force = false}) async {
    try {
      // Check if data already exists
      final users = await _db.query('users');
      if (users.isNotEmpty && !force) {
        print('Database already seeded');
        return;
      }

      // Clear existing data if force seeding
      if (force && users.isNotEmpty) {
        print('Force re-seeding database...');
        await _clearAllData();
      }

      await _seedUsers();
      await _seedCourses();
      await _seedLessons();
      await _seedQuizzes();
      await _seedQuizQuestions();
      
      print('Database seeded successfully!');
    } catch (e) {
      print('Error seeding database: $e');
    }
  }

  Future<void> _clearAllData() async {
    final db = await _db.database;
    await db.execute('DELETE FROM favorites');
    await db.execute('DELETE FROM notifications');
    await db.execute('DELETE FROM enrollments');
    await db.execute('DELETE FROM chat_messages');
    await db.execute('DELETE FROM user_progress');
    await db.execute('DELETE FROM notes');
    await db.execute('DELETE FROM quiz_results');
    await db.execute('DELETE FROM quiz_questions');
    await db.execute('DELETE FROM quizzes');
    await db.execute('DELETE FROM lessons');
    await db.execute('DELETE FROM courses');
    await db.execute('DELETE FROM users');
  }

  Future<void> _seedUsers() async {
    final now = DateTime.now().toIso8601String();
    
    // Admin user
    final admin = UserModel(
      name: 'Admin User',
      email: 'admin@learninghub.com',
      password: 'admin123', // In production, use hashed passwords
      role: AppConstants.roleAdmin,
      phone: '+1234567890',
      createdAt: now,
      updatedAt: now,
    );
    
    // Regular users
    final users = [
      UserModel(
        name: 'John Doe',
        email: 'john@example.com',
        password: 'user123',
        role: AppConstants.roleUser,
        phone: '+1234567891',
        createdAt: now,
        updatedAt: now,
      ),
      UserModel(
        name: 'Jane Smith',
        email: 'jane@example.com',
        password: 'user123',
        role: AppConstants.roleUser,
        phone: '+1234567892',
        createdAt: now,
        updatedAt: now,
      ),
    ];
    
    await _db.insert('users', admin.toMap());
    for (var user in users) {
      await _db.insert('users', user.toMap());
    }
  }

  Future<void> _seedCourses() async {
    final now = DateTime.now().toIso8601String();
    
    final courses = [
      CourseModel(
        title: 'Introduction to Flutter',
        description: 'Learn the basics of Flutter development and build beautiful mobile apps.',
        instructor: 'Dr. Sarah Johnson',
        category: 'Mobile Development',
        difficulty: 'Beginner',
        level: 'Beginner',
        duration: '5 hours',
        lessonsCount: 10,
        enrolledCount: 150,
        rating: 4.5,
        isFeatured: true,
        createdBy: 1,
        createdAt: now,
        updatedAt: now,
      ),
      CourseModel(
        title: 'Advanced Dart Programming',
        description: 'Master advanced Dart concepts including async programming, generics, and more.',
        instructor: 'Prof. Michael Chen',
        category: 'Programming',
        difficulty: 'Advanced',
        level: 'Advanced',
        duration: '7 hours',
        lessonsCount: 15,
        enrolledCount: 89,
        rating: 4.7,
        isFeatured: true,
        createdBy: 1,
        createdAt: now,
        updatedAt: now,
      ),
      CourseModel(
        title: 'UI/UX Design Fundamentals',
        description: 'Learn the principles of great user interface and user experience design.',
        instructor: 'Emma Williams',
        category: 'Design',
        difficulty: 'Beginner',
        level: 'Beginner',
        duration: '4 hours',
        lessonsCount: 8,
        enrolledCount: 200,
        rating: 4.3,
        isFeatured: false,
        createdBy: 1,
        createdAt: now,
        updatedAt: now,
      ),
      CourseModel(
        title: 'Database Management with SQLite',
        description: 'Understand database concepts and learn to work with SQLite in mobile apps.',
        instructor: 'Dr. James Anderson',
        category: 'Database',
        difficulty: 'Intermediate',
        level: 'Intermediate',
        duration: '6 hours',
        lessonsCount: 12,
        enrolledCount: 120,
        rating: 4.6,
        isFeatured: true,
        createdBy: 1,
        createdAt: now,
        updatedAt: now,
      ),
      CourseModel(
        title: 'State Management in Flutter',
        description: 'Master different state management approaches including Provider, Riverpod, and BLoC.',
        instructor: 'Lisa Martinez',
        category: 'Mobile Development',
        difficulty: 'Intermediate',
        level: 'Intermediate',
        duration: '8 hours',
        lessonsCount: 18,
        enrolledCount: 95,
        rating: 4.8,
        isFeatured: true,
        createdBy: 1,
        createdAt: now,
        updatedAt: now,
      ),
      CourseModel(
        title: 'Python for Beginners',
        description: 'Start your programming journey with Python - the most beginner-friendly language.',
        instructor: 'Dr. Robert Taylor',
        category: 'Programming',
        difficulty: 'Beginner',
        level: 'Beginner',
        duration: '10 hours',
        lessonsCount: 20,
        enrolledCount: 300,
        rating: 4.9,
        isFeatured: true,
        createdBy: 1,
        createdAt: now,
        updatedAt: now,
      ),
      CourseModel(
        title: 'React Native Development',
        description: 'Build cross-platform mobile apps using React Native and JavaScript.',
        instructor: 'Jennifer Lee',
        category: 'Mobile Development',
        difficulty: 'Intermediate',
        level: 'Intermediate',
        duration: '12 hours',
        lessonsCount: 25,
        enrolledCount: 180,
        rating: 4.6,
        isFeatured: true,
        createdBy: 1,
        createdAt: now,
        updatedAt: now,
      ),
      CourseModel(
        title: 'Machine Learning Basics',
        description: 'Introduction to machine learning concepts, algorithms, and practical applications.',
        instructor: 'Dr. Alan Kumar',
        category: 'Data Science',
        difficulty: 'Advanced',
        level: 'Advanced',
        duration: '15 hours',
        lessonsCount: 30,
        enrolledCount: 145,
        rating: 4.7,
        isFeatured: false,
        createdBy: 1,
        createdAt: now,
        updatedAt: now,
      ),
      CourseModel(
        title: 'Web Development with HTML, CSS & JavaScript',
        description: 'Complete guide to building modern, responsive websites from scratch.',
        instructor: 'Chris Anderson',
        category: 'Web Development',
        difficulty: 'Beginner',
        level: 'Beginner',
        duration: '14 hours',
        lessonsCount: 28,
        enrolledCount: 450,
        rating: 4.8,
        isFeatured: true,
        createdBy: 1,
        createdAt: now,
        updatedAt: now,
      ),
      CourseModel(
        title: 'Firebase for Mobile Apps',
        description: 'Learn to integrate Firebase services including authentication, database, and cloud storage.',
        instructor: 'Maria Garcia',
        category: 'Backend',
        difficulty: 'Intermediate',
        level: 'Intermediate',
        duration: '9 hours',
        lessonsCount: 16,
        enrolledCount: 210,
        rating: 4.5,
        isFeatured: false,
        createdBy: 1,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    
    for (var course in courses) {
      await _db.insert('courses', course.toMap());
    }
  }

  Future<void> _seedLessons() async {
    final now = DateTime.now().toIso8601String();
    
    // Lessons for Course 1 (Introduction to Flutter)
    final course1Lessons = [
      LessonModel(
        courseId: 1,
        title: 'What is Flutter?',
        description: 'Introduction to Flutter framework and its benefits',
        content: 'Flutter is Google\'s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase. It uses the Dart programming language and provides a rich set of pre-built widgets.',
        duration: '15 min',
        orderIndex: 1,
        createdAt: now,
        updatedAt: now,
      ),
      LessonModel(
        courseId: 1,
        title: 'Setting Up Your Development Environment',
        description: 'Install Flutter SDK and set up your IDE',
        content: 'To start developing with Flutter, you need to install the Flutter SDK, set up an IDE (VS Code or Android Studio), and configure the necessary tools. This lesson will guide you through the complete setup process.',
        duration: '20 min',
        orderIndex: 2,
        createdAt: now,
        updatedAt: now,
      ),
      LessonModel(
        courseId: 1,
        title: 'Your First Flutter App',
        description: 'Create and run your first Flutter application',
        content: 'In this lesson, you\'ll create your first Flutter app using the flutter create command. We\'ll explore the project structure, understand the main.dart file, and run the app on an emulator or physical device.',
        duration: '25 min',
        orderIndex: 3,
        createdAt: now,
        updatedAt: now,
      ),
      LessonModel(
        courseId: 1,
        title: 'Understanding Widgets',
        description: 'Learn about Flutter\'s widget system',
        content: 'Everything in Flutter is a widget. Widgets describe what their view should look like given their current configuration and state. We\'ll explore StatelessWidget and StatefulWidget, and learn how to compose complex UIs from simple widgets.',
        duration: '30 min',
        orderIndex: 4,
        createdAt: now,
        updatedAt: now,
      ),
      LessonModel(
        courseId: 1,
        title: 'Layouts and Positioning',
        description: 'Master Flutter layout widgets',
        content: 'Learn how to use layout widgets like Container, Row, Column, Stack, and Expanded to create responsive and beautiful layouts. Understanding layouts is crucial for building professional Flutter apps.',
        duration: '35 min',
        orderIndex: 5,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    
    // Lessons for Course 2 (Advanced Dart)
    final course2Lessons = [
      LessonModel(
        courseId: 2,
        title: 'Async Programming Basics',
        description: 'Understanding Future and async/await',
        content: 'Asynchronous programming is essential for building responsive applications. Learn how to use Future, async, and await keywords to handle asynchronous operations in Dart.',
        duration: '30 min',
        orderIndex: 1,
        createdAt: now,
        updatedAt: now,
      ),
      LessonModel(
        courseId: 2,
        title: 'Streams and Stream Controllers',
        description: 'Working with continuous data flows',
        content: 'Streams provide a way to receive a sequence of events. Learn how to create, listen to, and transform streams in Dart applications.',
        duration: '35 min',
        orderIndex: 2,
        createdAt: now,
        updatedAt: now,
      ),
      LessonModel(
        courseId: 2,
        title: 'Generics in Dart',
        description: 'Type-safe code with generics',
        content: 'Generics allow you to write flexible, reusable code while maintaining type safety. Learn how to use generic types, methods, and classes in Dart.',
        duration: '25 min',
        orderIndex: 3,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    
    // Lessons for Course 4 (Database Management)
    final course4Lessons = [
      LessonModel(
        courseId: 4,
        title: 'Introduction to SQLite',
        description: 'Understanding relational databases',
        content: 'SQLite is a lightweight, embedded database that\'s perfect for mobile applications. Learn the basics of relational databases and SQL syntax.',
        duration: '20 min',
        orderIndex: 1,
        createdAt: now,
        updatedAt: now,
      ),
      LessonModel(
        courseId: 4,
        title: 'CRUD Operations',
        description: 'Create, Read, Update, Delete data',
        content: 'Master the fundamental database operations: Create, Read, Update, and Delete. Learn how to implement these operations using the sqflite package in Flutter.',
        duration: '40 min',
        orderIndex: 2,
        createdAt: now,
        updatedAt: now,
      ),
      LessonModel(
        courseId: 4,
        title: 'Database Relationships',
        description: 'Working with foreign keys and joins',
        content: 'Learn how to establish relationships between tables using foreign keys, and how to query related data using SQL joins.',
        duration: '35 min',
        orderIndex: 3,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    
    // Lessons for Course 6 (Python for Beginners)
    final course6Lessons = [
      LessonModel(
        courseId: 6,
        title: 'Introduction to Python',
        description: 'Why Python and getting started',
        content: 'Python is one of the most popular programming languages in the world. Learn why Python is great for beginners and how to set up your Python environment.',
        duration: '15 min',
        orderIndex: 1,
        createdAt: now,
        updatedAt: now,
      ),
      LessonModel(
        courseId: 6,
        title: 'Variables and Data Types',
        description: 'Understanding Python data types',
        content: 'Learn about Python\'s built-in data types including strings, integers, floats, booleans, lists, tuples, and dictionaries.',
        duration: '25 min',
        orderIndex: 2,
        createdAt: now,
        updatedAt: now,
      ),
      LessonModel(
        courseId: 6,
        title: 'Control Flow',
        description: 'If statements and loops',
        content: 'Master conditional statements (if, elif, else) and loops (for, while) to control the flow of your Python programs.',
        duration: '30 min',
        orderIndex: 3,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    
    // Lessons for Course 7 (React Native)
    final course7Lessons = [
      LessonModel(
        courseId: 7,
        title: 'React Native Fundamentals',
        description: 'Introduction to React Native',
        content: 'Learn what React Native is, how it differs from React, and why it\'s a great choice for cross-platform mobile development.',
        duration: '20 min',
        orderIndex: 1,
        createdAt: now,
        updatedAt: now,
      ),
      LessonModel(
        courseId: 7,
        title: 'Components and Props',
        description: 'Building blocks of React Native',
        content: 'Understand React Native components, how to create custom components, and how to pass data using props.',
        duration: '35 min',
        orderIndex: 2,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    
    // Lessons for Course 9 (Web Development)
    final course9Lessons = [
      LessonModel(
        courseId: 9,
        title: 'HTML Basics',
        description: 'Structure of web pages',
        content: 'Learn HTML tags, elements, and attributes. Understand how to create the structure of a web page using semantic HTML.',
        duration: '30 min',
        orderIndex: 1,
        createdAt: now,
        updatedAt: now,
      ),
      LessonModel(
        courseId: 9,
        title: 'CSS Styling',
        description: 'Making websites beautiful',
        content: 'Master CSS selectors, properties, and values. Learn how to style your HTML elements and create responsive layouts.',
        duration: '40 min',
        orderIndex: 2,
        createdAt: now,
        updatedAt: now,
      ),
      LessonModel(
        courseId: 9,
        title: 'JavaScript Basics',
        description: 'Adding interactivity',
        content: 'Introduction to JavaScript programming. Learn variables, functions, events, and DOM manipulation to make your websites interactive.',
        duration: '45 min',
        orderIndex: 3,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    
    final allLessons = [...course1Lessons, ...course2Lessons, ...course4Lessons, ...course6Lessons, ...course7Lessons, ...course9Lessons];
    for (var lesson in allLessons) {
      await _db.insert('lessons', lesson.toMap());
    }
  }

  Future<void> _seedQuizzes() async {
    final now = DateTime.now().toIso8601String();
    
    final quizzes = [
      QuizModel(
        courseId: 1,
        title: 'Flutter Basics Quiz',
        description: 'Test your knowledge of Flutter fundamentals',
        duration: 1200, // 20 minutes
        passingScore: 60,
        totalQuestions: 10,
        createdAt: now,
        updatedAt: now,
      ),
      QuizModel(
        courseId: 2,
        title: 'Dart Advanced Concepts Quiz',
        description: 'Challenge yourself with advanced Dart questions',
        duration: 1800, // 30 minutes
        passingScore: 70,
        totalQuestions: 15,
        createdAt: now,
        updatedAt: now,
      ),
      QuizModel(
        courseId: 4,
        title: 'SQLite Database Quiz',
        description: 'Test your database management skills',
        duration: 1500, // 25 minutes
        passingScore: 65,
        totalQuestions: 12,
        createdAt: now,
        updatedAt: now,
      ),
      QuizModel(
        courseId: 6,
        title: 'Python Fundamentals Quiz',
        description: 'Test your Python programming basics',
        duration: 1200, // 20 minutes
        passingScore: 60,
        totalQuestions: 10,
        createdAt: now,
        updatedAt: now,
      ),
      QuizModel(
        courseId: 7,
        title: 'React Native Basics Quiz',
        description: 'Assess your React Native knowledge',
        duration: 1500, // 25 minutes
        passingScore: 65,
        totalQuestions: 10,
        createdAt: now,
        updatedAt: now,
      ),
      QuizModel(
        courseId: 9,
        title: 'Web Development Quiz',
        description: 'Test your HTML, CSS, and JavaScript skills',
        duration: 1800, // 30 minutes
        passingScore: 70,
        totalQuestions: 15,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    
    for (var quiz in quizzes) {
      await _db.insert('quizzes', quiz.toMap());
    }
  }

  Future<void> _seedQuizQuestions() async {
    final now = DateTime.now().toIso8601String();
    
    // Quiz 1 Questions (Flutter Basics)
    final quiz1Questions = [
      QuizQuestionModel(
        quizId: 1,
        question: 'What programming language does Flutter use?',
        optionA: 'Java',
        optionB: 'Dart',
        optionC: 'Kotlin',
        optionD: 'Swift',
        correctAnswer: 'B',
        explanation: 'Flutter uses Dart as its programming language.',
        orderIndex: 1,
        createdAt: now,
        updatedAt: now,
      ),
      QuizQuestionModel(
        quizId: 1,
        question: 'Which widget is used for creating a scrollable list in Flutter?',
        optionA: 'Container',
        optionB: 'Column',
        optionC: 'ListView',
        optionD: 'Stack',
        correctAnswer: 'C',
        explanation: 'ListView is the widget used for creating scrollable lists.',
        orderIndex: 2,
        createdAt: now,
        updatedAt: now,
      ),
      QuizQuestionModel(
        quizId: 1,
        question: 'What is the difference between StatelessWidget and StatefulWidget?',
        optionA: 'StatelessWidget can change state',
        optionB: 'StatefulWidget cannot change state',
        optionC: 'StatefulWidget can maintain and update state',
        optionD: 'There is no difference',
        correctAnswer: 'C',
        explanation: 'StatefulWidget can maintain and update its state, while StatelessWidget cannot.',
        orderIndex: 3,
        createdAt: now,
        updatedAt: now,
      ),
      QuizQuestionModel(
        quizId: 1,
        question: 'Which command is used to create a new Flutter project?',
        optionA: 'flutter new',
        optionB: 'flutter create',
        optionC: 'flutter init',
        optionD: 'flutter start',
        correctAnswer: 'B',
        explanation: 'The "flutter create" command is used to create a new Flutter project.',
        orderIndex: 4,
        createdAt: now,
        updatedAt: now,
      ),
      QuizQuestionModel(
        quizId: 1,
        question: 'What does the "hot reload" feature do?',
        optionA: 'Restarts the entire app',
        optionB: 'Updates UI without losing state',
        optionC: 'Clears all data',
        optionD: 'Closes the app',
        correctAnswer: 'B',
        explanation: 'Hot reload updates the UI without losing the current state of the app.',
        orderIndex: 5,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    
    // Quiz 2 Questions (Dart Advanced)
    final quiz2Questions = [
      QuizQuestionModel(
        quizId: 2,
        question: 'What keyword is used to handle asynchronous operations in Dart?',
        optionA: 'sync',
        optionB: 'async',
        optionC: 'wait',
        optionD: 'promise',
        correctAnswer: 'B',
        explanation: 'The "async" keyword is used to mark functions that perform asynchronous operations.',
        orderIndex: 1,
        createdAt: now,
        updatedAt: now,
      ),
      QuizQuestionModel(
        quizId: 2,
        question: 'What does a Stream represent in Dart?',
        optionA: 'A single value',
        optionB: 'A sequence of asynchronous events',
        optionC: 'A synchronous loop',
        optionD: 'A static variable',
        correctAnswer: 'B',
        explanation: 'A Stream represents a sequence of asynchronous events.',
        orderIndex: 2,
        createdAt: now,
        updatedAt: now,
      ),
      QuizQuestionModel(
        quizId: 2,
        question: 'What is the purpose of generics in Dart?',
        optionA: 'To make code slower',
        optionB: 'To enable type-safe code reuse',
        optionC: 'To remove type checking',
        optionD: 'To create errors',
        correctAnswer: 'B',
        explanation: 'Generics enable type-safe code reuse and help catch errors at compile time.',
        orderIndex: 3,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    
    // Quiz 3 Questions (SQLite)
    final quiz3Questions = [
      QuizQuestionModel(
        quizId: 3,
        question: 'What does CRUD stand for?',
        optionA: 'Create, Read, Update, Delete',
        optionB: 'Copy, Read, Update, Delete',
        optionC: 'Create, Remove, Update, Delete',
        optionD: 'Create, Read, Upload, Download',
        correctAnswer: 'A',
        explanation: 'CRUD stands for Create, Read, Update, and Delete operations.',
        orderIndex: 1,
        createdAt: now,
        updatedAt: now,
      ),
      QuizQuestionModel(
        quizId: 3,
        question: 'Which SQL command is used to retrieve data from a database?',
        optionA: 'GET',
        optionB: 'FETCH',
        optionC: 'SELECT',
        optionD: 'RETRIEVE',
        correctAnswer: 'C',
        explanation: 'The SELECT command is used to retrieve data from a database.',
        orderIndex: 2,
        createdAt: now,
        updatedAt: now,
      ),
      QuizQuestionModel(
        quizId: 3,
        question: 'What is a foreign key?',
        optionA: 'A key from another country',
        optionB: 'A primary key in another table',
        optionC: 'A field that links two tables together',
        optionD: 'An encrypted key',
        correctAnswer: 'C',
        explanation: 'A foreign key is a field that links two tables together by referencing the primary key of another table.',
        orderIndex: 3,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    
    // Quiz 4 Questions (Python Fundamentals)
    final quiz4Questions = [
      QuizQuestionModel(
        quizId: 4,
        question: 'What is the correct file extension for Python files?',
        optionA: '.python',
        optionB: '.py',
        optionC: '.pt',
        optionD: '.pyt',
        correctAnswer: 'B',
        explanation: 'Python files use the .py extension.',
        orderIndex: 1,
        createdAt: now,
        updatedAt: now,
      ),
      QuizQuestionModel(
        quizId: 4,
        question: 'Which keyword is used to define a function in Python?',
        optionA: 'function',
        optionB: 'func',
        optionC: 'def',
        optionD: 'define',
        correctAnswer: 'C',
        explanation: 'The "def" keyword is used to define functions in Python.',
        orderIndex: 2,
        createdAt: now,
        updatedAt: now,
      ),
      QuizQuestionModel(
        quizId: 4,
        question: 'What is the output of print(type([]))?',
        optionA: '<class \'array\'>',
        optionB: '<class \'list\'>',
        optionC: '<class \'tuple\'>',
        optionD: '<class \'dict\'>',
        correctAnswer: 'B',
        explanation: '[] creates an empty list in Python.',
        orderIndex: 3,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    
    // Quiz 5 Questions (React Native Basics)
    final quiz5Questions = [
      QuizQuestionModel(
        quizId: 5,
        question: 'What language is React Native primarily written in?',
        optionA: 'Java',
        optionB: 'Swift',
        optionC: 'JavaScript',
        optionD: 'Kotlin',
        correctAnswer: 'C',
        explanation: 'React Native uses JavaScript (and TypeScript) for development.',
        orderIndex: 1,
        createdAt: now,
        updatedAt: now,
      ),
      QuizQuestionModel(
        quizId: 5,
        question: 'Which component is used to display text in React Native?',
        optionA: 'TextView',
        optionB: 'Text',
        optionC: 'Label',
        optionD: 'TextComponent',
        correctAnswer: 'B',
        explanation: 'The Text component is used to display text in React Native.',
        orderIndex: 2,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    
    // Quiz 6 Questions (Web Development)
    final quiz6Questions = [
      QuizQuestionModel(
        quizId: 6,
        question: 'What does HTML stand for?',
        optionA: 'Hyper Text Markup Language',
        optionB: 'High Tech Modern Language',
        optionC: 'Home Tool Markup Language',
        optionD: 'Hyperlinks and Text Markup Language',
        correctAnswer: 'A',
        explanation: 'HTML stands for Hyper Text Markup Language.',
        orderIndex: 1,
        createdAt: now,
        updatedAt: now,
      ),
      QuizQuestionModel(
        quizId: 6,
        question: 'Which CSS property is used to change text color?',
        optionA: 'text-color',
        optionB: 'font-color',
        optionC: 'color',
        optionD: 'text-style',
        correctAnswer: 'C',
        explanation: 'The "color" property is used to change text color in CSS.',
        orderIndex: 2,
        createdAt: now,
        updatedAt: now,
      ),
      QuizQuestionModel(
        quizId: 6,
        question: 'How do you declare a variable in JavaScript?',
        optionA: 'variable x = 5',
        optionB: 'var x = 5',
        optionC: 'v x = 5',
        optionD: 'int x = 5',
        correctAnswer: 'B',
        explanation: 'Variables in JavaScript can be declared using var, let, or const keywords.',
        orderIndex: 3,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    
    final allQuestions = [...quiz1Questions, ...quiz2Questions, ...quiz3Questions, ...quiz4Questions, ...quiz5Questions, ...quiz6Questions];
    for (var question in allQuestions) {
      await _db.insert('quiz_questions', question.toMap());
    }
  }
}
