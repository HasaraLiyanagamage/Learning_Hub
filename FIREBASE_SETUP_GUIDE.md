# 🔥 Firebase Firestore Setup Guide - Smart Learning Hub

## 📋 Complete Guide to Setup Firebase Firestore Database

---

## 🚀 **Step 1: Create Firebase Project**

### **1.1 Go to Firebase Console**
1. Visit: https://console.firebase.google.com/
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: `learninghub` (or your preferred name)
4. Click **Continue**

### **1.2 Configure Google Analytics (Optional)**
1. Enable/Disable Google Analytics (your choice)
2. Click **Continue**
3. Select Analytics account or create new
4. Click **Create project**
5. Wait for project creation (30 seconds)
6. Click **Continue**

---

## 🔧 **Step 2: Setup Firestore Database**

### **2.1 Create Firestore Database**
1. In Firebase Console, click **"Firestore Database"** in left menu
2. Click **"Create database"**
3. Select **"Start in test mode"** (for development)
4. Click **Next**
5. Choose Cloud Firestore location: **us-central** (or nearest to you)
6. Click **Enable**
7. Wait for database creation

### **2.2 Security Rules (Development)**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to all documents (DEVELOPMENT ONLY)
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

**⚠️ For Production, use:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Courses - public read, admin write
    match /courses/{courseId} {
      allow read: if true;
      allow write: if request.auth != null && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Lessons - public read, admin write
    match /lessons/{lessonId} {
      allow read: if true;
      allow write: if request.auth != null && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Quizzes - public read, admin write
    match /quizzes/{quizId} {
      allow read: if true;
      allow write: if request.auth != null && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Quiz results - user can read/write their own
    match /quiz_results/{resultId} {
      allow read: if request.auth != null && resource.data.user_id == request.auth.uid;
      allow write: if request.auth != null && request.resource.data.user_id == request.auth.uid;
    }
    
    // User progress - user can read/write their own
    match /user_progress/{progressId} {
      allow read: if request.auth != null && resource.data.user_id == request.auth.uid;
      allow write: if request.auth != null && request.resource.data.user_id == request.auth.uid;
    }
    
    // Notifications - user can read their own
    match /notifications/{notificationId} {
      allow read: if request.auth != null && resource.data.user_id == request.auth.uid;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 📊 **Step 3: Create Firestore Collections & Documents**

### **Collection 1: `users`**

**Fields:**
```javascript
{
  "id": "1",                          // String (user ID)
  "name": "John Doe",                 // String
  "email": "john@example.com",        // String
  "password": "hashed_password",      // String (hashed)
  "role": "user",                     // String (user/admin)
  "created_at": "2025-12-16T00:00:00Z", // Timestamp
  "updated_at": "2025-12-16T00:00:00Z"  // Timestamp
}
```

**Sample Documents:**
```javascript
// Document ID: "1"
{
  "id": "1",
  "name": "John Doe",
  "email": "john@example.com",
  "password": "user123",
  "role": "user",
  "created_at": "2025-12-16T00:00:00Z",
  "updated_at": "2025-12-16T00:00:00Z"
}

// Document ID: "2"
{
  "id": "2",
  "name": "Admin User",
  "email": "admin@learninghub.com",
  "password": "admin123",
  "role": "admin",
  "created_at": "2025-12-16T00:00:00Z",
  "updated_at": "2025-12-16T00:00:00Z"
}
```

---

### **Collection 2: `courses`**

**Fields:**
```javascript
{
  "id": "1",                          // String
  "title": "Introduction to Flutter", // String
  "description": "Learn Flutter basics...", // String
  "instructor": "John Doe",           // String
  "duration": "10 hours",             // String
  "difficulty": "Beginner",           // String (Beginner/Intermediate/Advanced)
  "rating": 4.5,                      // Number
  "enrolled_count": 150,              // Number
  "lessons_count": 10,                // Number
  "image_url": "",                    // String (optional)
  "category": "Mobile Development",   // String
  "created_at": "2025-12-16T00:00:00Z", // Timestamp
  "updated_at": "2025-12-16T00:00:00Z"  // Timestamp
}
```

**Sample Documents:**
```javascript
// Document ID: "1"
{
  "id": "1",
  "title": "Introduction to Flutter",
  "description": "Learn the basics of Flutter development and build your first mobile app",
  "instructor": "John Doe",
  "duration": "10 hours",
  "difficulty": "Beginner",
  "rating": 4.5,
  "enrolled_count": 150,
  "lessons_count": 5,
  "category": "Mobile Development",
  "created_at": "2025-12-16T00:00:00Z",
  "updated_at": "2025-12-16T00:00:00Z"
}

// Document ID: "2"
{
  "id": "2",
  "title": "Advanced Dart Programming",
  "description": "Master advanced Dart concepts and patterns",
  "instructor": "Jane Smith",
  "duration": "8 hours",
  "difficulty": "Advanced",
  "rating": 4.8,
  "enrolled_count": 89,
  "lessons_count": 4,
  "category": "Programming",
  "created_at": "2025-12-16T00:00:00Z",
  "updated_at": "2025-12-16T00:00:00Z"
}
```

---

### **Collection 3: `lessons`**

**Fields:**
```javascript
{
  "id": "1",                          // String
  "course_id": "1",                   // String (reference to course)
  "title": "Getting Started",         // String
  "content": "Welcome to Flutter...", // String (lesson content)
  "duration": 30,                     // Number (minutes)
  "order_index": 1,                   // Number (lesson order)
  "video_url": "",                    // String (optional)
  "is_completed": 0,                  // Number (0 or 1)
  "created_at": "2025-12-16T00:00:00Z", // Timestamp
  "updated_at": "2025-12-16T00:00:00Z"  // Timestamp
}
```

**Sample Documents:**
```javascript
// Document ID: "1"
{
  "id": "1",
  "course_id": "1",
  "title": "Getting Started with Flutter",
  "content": "Welcome to Flutter! In this lesson, you'll learn about Flutter framework, its architecture, and how to set up your development environment...",
  "duration": 30,
  "order_index": 1,
  "video_url": "",
  "is_completed": 0,
  "created_at": "2025-12-16T00:00:00Z",
  "updated_at": "2025-12-16T00:00:00Z"
}

// Document ID: "2"
{
  "id": "2",
  "course_id": "1",
  "title": "Understanding Widgets",
  "content": "Widgets are the building blocks of Flutter apps. Learn about StatelessWidget, StatefulWidget, and how to create custom widgets...",
  "duration": 45,
  "order_index": 2,
  "video_url": "",
  "is_completed": 0,
  "created_at": "2025-12-16T00:00:00Z",
  "updated_at": "2025-12-16T00:00:00Z"
}
```

---

### **Collection 4: `quizzes`**

**Fields:**
```javascript
{
  "id": "1",                          // String
  "course_id": "1",                   // String (reference to course)
  "title": "Flutter Basics Quiz",     // String
  "description": "Test your knowledge...", // String
  "duration": 15,                     // Number (minutes)
  "passing_score": 70,                // Number (percentage)
  "total_questions": 5,               // Number
  "created_at": "2025-12-16T00:00:00Z", // Timestamp
  "updated_at": "2025-12-16T00:00:00Z"  // Timestamp
}
```

**Sample Documents:**
```javascript
// Document ID: "1"
{
  "id": "1",
  "course_id": "1",
  "title": "Flutter Basics Quiz",
  "description": "Test your understanding of Flutter fundamentals",
  "duration": 15,
  "passing_score": 70,
  "total_questions": 5,
  "created_at": "2025-12-16T00:00:00Z",
  "updated_at": "2025-12-16T00:00:00Z"
}
```

---

### **Collection 5: `quiz_questions`**

**Fields:**
```javascript
{
  "id": "1",                          // String
  "quiz_id": "1",                     // String (reference to quiz)
  "question": "What is Flutter?",     // String
  "option_a": "A framework",          // String
  "option_b": "A language",           // String
  "option_c": "A database",           // String
  "option_d": "An IDE",               // String
  "correct_answer": "A",              // String (A/B/C/D)
  "explanation": "Flutter is a UI framework...", // String
  "created_at": "2025-12-16T00:00:00Z"  // Timestamp
}
```

**Sample Documents:**
```javascript
// Document ID: "1"
{
  "id": "1",
  "quiz_id": "1",
  "question": "What is Flutter?",
  "option_a": "A UI framework for building mobile apps",
  "option_b": "A programming language",
  "option_c": "A database system",
  "option_d": "An IDE",
  "correct_answer": "A",
  "explanation": "Flutter is Google's UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.",
  "created_at": "2025-12-16T00:00:00Z"
}

// Document ID: "2"
{
  "id": "2",
  "quiz_id": "1",
  "question": "What language does Flutter use?",
  "option_a": "Java",
  "option_b": "Kotlin",
  "option_c": "Dart",
  "option_d": "Swift",
  "correct_answer": "C",
  "explanation": "Flutter uses Dart programming language, which is optimized for building user interfaces.",
  "created_at": "2025-12-16T00:00:00Z"
}
```

---

### **Collection 6: `quiz_results`**

**Fields:**
```javascript
{
  "id": "1",                          // String
  "user_id": "1",                     // String (reference to user)
  "quiz_id": "1",                     // String (reference to quiz)
  "score": 80,                        // Number (percentage)
  "total_questions": 5,               // Number
  "correct_answers": 4,               // Number
  "passed": 1,                        // Number (0 or 1)
  "time_taken": 300,                  // Number (seconds)
  "sync_status": 1,                   // Number (0=pending, 1=synced)
  "last_updated": "2025-12-16T00:00:00Z", // Timestamp
  "created_at": "2025-12-16T00:00:00Z"    // Timestamp
}
```

**Sample Documents:**
```javascript
// Document ID: "1"
{
  "id": "1",
  "user_id": "1",
  "quiz_id": "1",
  "score": 80,
  "total_questions": 5,
  "correct_answers": 4,
  "passed": 1,
  "time_taken": 300,
  "sync_status": 1,
  "last_updated": "2025-12-16T00:00:00Z",
  "created_at": "2025-12-16T00:00:00Z"
}
```

---

### **Collection 7: `user_progress`**

**Fields:**
```javascript
{
  "id": "1",                          // String
  "user_id": "1",                     // String (reference to user)
  "lesson_id": "1",                   // String (reference to lesson)
  "course_id": "1",                   // String (reference to course)
  "is_completed": 1,                  // Number (0 or 1)
  "progress_percentage": 100,         // Number (0-100)
  "time_spent": 1800,                 // Number (seconds)
  "sync_status": 1,                   // Number (0=pending, 1=synced)
  "last_updated": "2025-12-16T00:00:00Z", // Timestamp
  "completed_at": "2025-12-16T00:00:00Z"  // Timestamp
}
```

**Sample Documents:**
```javascript
// Document ID: "1"
{
  "id": "1",
  "user_id": "1",
  "lesson_id": "1",
  "course_id": "1",
  "is_completed": 1,
  "progress_percentage": 100,
  "time_spent": 1800,
  "sync_status": 1,
  "last_updated": "2025-12-16T00:00:00Z",
  "completed_at": "2025-12-16T00:00:00Z"
}
```

---

### **Collection 8: `notifications`**

**Fields:**
```javascript
{
  "id": "1",                          // String
  "user_id": "1",                     // String (reference to user)
  "title": "New Course Available",    // String
  "message": "Check out Flutter Advanced...", // String
  "type": "course",                   // String (reminder/achievement/course/quiz)
  "is_read": 0,                       // Number (0 or 1)
  "action_data": "",                  // String (JSON string, optional)
  "created_at": "2025-12-16T00:00:00Z", // Timestamp
  "updated_at": "2025-12-16T00:00:00Z"  // Timestamp
}
```

**Sample Documents:**
```javascript
// Document ID: "1"
{
  "id": "1",
  "user_id": "1",
  "title": "New Course Available!",
  "message": "Check out our new Advanced Flutter course",
  "type": "course",
  "is_read": 0,
  "action_data": "{\"course_id\": \"2\"}",
  "created_at": "2025-12-16T00:00:00Z",
  "updated_at": "2025-12-16T00:00:00Z"
}

// Document ID: "2"
{
  "id": "2",
  "user_id": "1",
  "title": "Quiz Completed!",
  "message": "You scored 80% on Flutter Basics Quiz",
  "type": "achievement",
  "is_read": 0,
  "action_data": "{\"quiz_id\": \"1\", \"score\": 80}",
  "created_at": "2025-12-16T00:00:00Z",
  "updated_at": "2025-12-16T00:00:00Z"
}
```

---

### **Collection 9: `enrollments`**

**Fields:**
```javascript
{
  "id": "1",                          // String
  "user_id": "1",                     // String (reference to user)
  "course_id": "1",                   // String (reference to course)
  "enrolled_at": "2025-12-16T00:00:00Z", // Timestamp
  "progress": 40,                     // Number (0-100)
  "status": "active",                 // String (active/completed/dropped)
  "completed_at": null                // Timestamp (nullable)
}
```

**Sample Documents:**
```javascript
// Document ID: "1"
{
  "id": "1",
  "user_id": "1",
  "course_id": "1",
  "enrolled_at": "2025-12-16T00:00:00Z",
  "progress": 40,
  "status": "active",
  "completed_at": null
}
```

---

### **Collection 10: `favorites`**

**Fields:**
```javascript
{
  "id": "1",                          // String
  "user_id": "1",                     // String (reference to user)
  "course_id": "1",                   // String (reference to course)
  "created_at": "2025-12-16T00:00:00Z"  // Timestamp
}
```

**Sample Documents:**
```javascript
// Document ID: "1"
{
  "id": "1",
  "user_id": "1",
  "course_id": "1",
  "created_at": "2025-12-16T00:00:00Z"
}
```

---

## 🔑 **Step 4: Get Firebase Configuration**

### **4.1 For Flutter App**

1. In Firebase Console, click ⚙️ (Settings) > **Project settings**
2. Scroll down to **"Your apps"**
3. Click **Android icon** (</>) to add Android app
4. Enter Android package name: `com.example.learninghub`
5. Click **Register app**
6. Download `google-services.json`
7. Place in: `android/app/google-services.json`

### **4.2 For Backend (Node.js)**

1. In Firebase Console, go to **Project settings**
2. Click **Service accounts** tab
3. Click **Generate new private key**
4. Save as `firebase-service-account.json`
5. Place in: `backend/firebase-service-account.json`

### **4.3 Get Firebase Database URL**

1. In Firebase Console, go to **Firestore Database**
2. Copy the database URL (format: `https://PROJECT_ID.firebaseio.com`)
3. Add to `.env` file:
   ```
   FIREBASE_DATABASE_URL=https://learninghub-xxxxx.firebaseio.com
   ```

---

## 📝 **Step 5: Manual Data Entry (Firebase Console)**

### **Method 1: Using Firebase Console UI**

1. Go to **Firestore Database** in Firebase Console
2. Click **"Start collection"**
3. Enter collection ID: `users`
4. Click **Next**
5. Add first document:
   - Document ID: `1`
   - Add fields one by one:
     - Field: `id`, Type: `string`, Value: `1`
     - Field: `name`, Type: `string`, Value: `John Doe`
     - Field: `email`, Type: `string`, Value: `john@example.com`
     - Field: `password`, Type: `string`, Value: `user123`
     - Field: `role`, Type: `string`, Value: `user`
     - Field: `created_at`, Type: `timestamp`, Value: (current time)
     - Field: `updated_at`, Type: `timestamp`, Value: (current time)
6. Click **Save**
7. Repeat for all collections

---

### **Method 2: Using Firebase CLI (Faster)**

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project
cd backend
firebase init firestore

# This creates firestore.rules and firestore.indexes.json
```

---

### **Method 3: Using Backend API (Recommended)**

Create a seeder script in your backend:

```javascript
// backend/seed-firestore.js
const admin = require('firebase-admin');
const serviceAccount = require('./firebase-service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function seedData() {
  // Seed Users
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

  // Seed Courses
  await db.collection('courses').doc('1').set({
    id: '1',
    title: 'Introduction to Flutter',
    description: 'Learn the basics of Flutter development',
    instructor: 'John Doe',
    duration: '10 hours',
    difficulty: 'Beginner',
    rating: 4.5,
    enrolled_count: 150,
    lessons_count: 5,
    category: 'Mobile Development',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  });

  // Add more data...
  
  console.log('✅ Firestore seeded successfully!');
  process.exit(0);
}

seedData().catch(console.error);
```

Run seeder:
```bash
cd backend
node seed-firestore.js
```

---

## 🔗 **Step 6: Connect Flutter App to Firestore**

### **6.1 Update pubspec.yaml**
```yaml
dependencies:
  cloud_firestore: ^4.17.5
  firebase_core: ^2.32.0
```

### **6.2 Initialize Firebase in Flutter**

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}
```

### **6.3 Use Firestore in App**

```dart
// Example: Fetch courses from Firestore
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<CourseModel>> fetchCoursesFromFirestore() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('courses')
      .get();
  
  return snapshot.docs
      .map((doc) => CourseModel.fromMap(doc.data()))
      .toList();
}
```

---

## ✅ **Step 7: Verify Setup**

### **Test Firestore Connection**

```dart
// Test in Flutter
Future<void> testFirestore() async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc('1')
        .get();
    
    print('✅ Firestore connected!');
    print('User: ${doc.data()}');
  } catch (e) {
    print('❌ Firestore error: $e');
  }
}
```

---

## 📊 **Complete Collections Summary**

| Collection | Documents | Purpose |
|------------|-----------|---------|
| `users` | 2+ | User accounts |
| `courses` | 10 | Course catalog |
| `lessons` | 30+ | Lesson content |
| `quizzes` | 6+ | Quiz metadata |
| `quiz_questions` | 30+ | Quiz questions |
| `quiz_results` | Variable | User quiz scores |
| `user_progress` | Variable | Learning progress |
| `notifications` | Variable | User notifications |
| `enrollments` | Variable | Course enrollments |
| `favorites` | Variable | Favorite courses |

---

## 🎯 **Quick Setup Checklist**

- [ ] Create Firebase project
- [ ] Enable Firestore Database
- [ ] Set security rules
- [ ] Create 10 collections
- [ ] Add sample documents
- [ ] Download `google-services.json`
- [ ] Download `firebase-service-account.json`
- [ ] Add to Flutter app
- [ ] Add to backend
- [ ] Test connection
- [ ] Seed data (optional)

---

## 🚀 **Your Firestore is Ready!**

You now have a complete cloud database for your Smart Learning Hub app with:
- ✅ 10 collections
- ✅ Proper schema
- ✅ Sample data
- ✅ Security rules
- ✅ Flutter integration
- ✅ Backend integration

**Your app can now sync data between SQLite (offline) and Firestore (online)!** 🎉
