#  Learning Hub - Team Distribution Document

##  Project Overview
**Project Name**: Smart Learning Hub  
**Team Size**: 4 Members  
**Total Features**: 12 Major Features  
**Total Screens**: 27+ Screens  
**Backend Files**: 6 Route Files  
**Database Tables**: 12 Tables  

---

##  Team Member Distribution

### **Member 1: Authentication & User Management** 

#### **Responsibility**: User authentication, profile management, and user-related features

#### **Offline Features** 
- **Local Authentication**: Login/Register using SQLite database
- **Profile Management**: Edit profile, change password offline
- **User Data Storage**: Store user information locally

#### **Online Features** 
- **Cloud Authentication**: Sync user data with Firebase Firestore
- **User Management API**: Backend user CRUD operations
- **Session Management**: Token-based authentication

---

#### **Frontend Pages** (4 Screens)

##### 1. **Login Screen** (`lib/features/auth/screens/login_screen.dart`)
- **Description**: User login interface with email/password
- **Key Features**:
  - Email and password input fields
  - Form validation
  - Error handling
  - Remember me functionality
  - Navigation to register screen
- **Code Details**:
  - Uses `AuthProvider` for state management
  - Validates credentials against SQLite database
  - Stores user session locally
  - Material Design UI with custom text fields

##### 2. **Register Screen** (`lib/features/auth/screens/register_screen.dart`)
- **Description**: New user registration interface
- **Key Features**:
  - Name, email, password, phone input
  - Password confirmation
  - Form validation
  - Auto-login after registration
- **Code Details**:
  - Creates new user in SQLite database
  - Password hashing for security
  - Duplicate email checking
  - Automatic navigation to dashboard

##### 3. **Profile Screen** (`lib/features/profile/screens/profile_screen.dart`)
- **Description**: User profile view and settings
- **Key Features**:
  - Display user information
  - Avatar/profile picture
  - Statistics (enrolled courses, completed lessons)
  - Logout functionality
  - Navigation to edit profile
- **Code Details**:
  - Fetches user data from database
  - Displays enrollment count
  - Shows user progress statistics
  - Material Card-based layout

##### 4. **Edit Profile Screen** (`lib/features/profile/screens/edit_profile_screen.dart`)
- **Description**: Edit user profile information
- **Key Features**:
  - Update name, email, phone
  - Avatar upload
  - Form validation
  - Save changes to database
- **Code Details**:
  - Updates user table in SQLite
  - Real-time validation
  - Success/error notifications
  - Auto-sync with cloud when online

##### 5. **Change Password Screen** (`lib/features/profile/screens/change_password_screen.dart`)
- **Description**: Secure password change interface
- **Key Features**:
  - Current password verification
  - New password input
  - Password strength indicator
  - Confirmation field
- **Code Details**:
  - Validates current password
  - Updates password in database
  - Password hashing
  - Security notifications

---

#### **Backend Files** (1 File)

##### 1. **Users API** (`backend/routes/users.js`)
- **Description**: RESTful API for user management
- **Endpoints**:
  - `POST /api/users/register` - Create new user
  - `POST /api/users/login` - Authenticate user
  - `GET /api/users/:id` - Get user details
  - `PUT /api/users/:id` - Update user profile
  - `DELETE /api/users/:id` - Delete user account
  - `GET /api/users` - List all users (admin)
- **Code Details**:
  - Express.js routes
  - Firebase Firestore integration
  - Password hashing with bcrypt
  - JWT token generation
  - Input validation and sanitization
  - Error handling middleware

---

#### **Database Tables** (1 Table)

##### 1. **Users Table** (`users`)
- **Description**: Stores user account information
- **Schema**:
  ```sql
  CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT NOT NULL,              -- 'admin' or 'user'
    phone TEXT,
    avatar TEXT,
    is_active INTEGER DEFAULT 1,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )
  ```
- **Operations**:
  - INSERT: Register new user
  - SELECT: Login, fetch profile
  - UPDATE: Edit profile, change password
  - DELETE: Remove account
- **Relationships**:
  - One-to-many with enrollments
  - One-to-many with notes
  - One-to-many with quiz_results

---

#### **Services/Models** (2 Files)

##### 1. **Auth Service** (`lib/services/auth_service.dart`)
- **Description**: Authentication business logic
- **Functions**:
  - `login()` - User login
  - `register()` - User registration
  - `logout()` - Clear session
  - `validateToken()` - Check authentication
- **Code Details**:
  - SQLite database queries
  - Password hashing
  - Session management
  - Error handling

##### 2. **User Model** (`lib/models/user_model.dart`)
- **Description**: User data model
- **Properties**:
  - `id`, `name`, `email`, `password`
  - `role`, `phone`, `avatar`
  - `isActive`, `createdAt`, `updatedAt`
- **Methods**:
  - `fromMap()` - Convert from database
  - `toMap()` - Convert to database
  - `toJson()` - Convert to JSON for API

---

### **Member 2: Course & Lesson Management** 

#### **Responsibility**: Course browsing, enrollment, lessons, and content delivery

#### **Offline Features** 
- **Browse Courses**: View all courses from local database
- **View Lessons**: Access lesson content offline
- **Course Enrollment**: Enroll in courses locally
- **Favorites**: Bookmark courses offline

#### **Online Features** 
- **Course Sync**: Sync courses from Firebase
- **Enrollment Sync**: Sync enrollments with cloud
- **Course Updates**: Get latest course content
- **Real-time Enrollment Count**: Update enrollment statistics

---

#### **Frontend Pages** (6 Screens)

##### 1. **User Dashboard Screen** (`lib/features/courses/screens/user_dashboard_screen.dart`)
- **Description**: Main dashboard for students
- **Key Features**:
  - Welcome message with user name
  - Quick stats (enrolled courses, completed lessons, quiz scores)
  - Featured courses carousel
  - Recent courses list
  - Quick access to all features
  - Search functionality
- **Code Details**:
  - Fetches user statistics from database
  - Displays enrollment count
  - Shows progress metrics
  - Grid layout with navigation cards
  - Pull-to-refresh functionality

##### 2. **Courses Screen** (`lib/features/courses/screens/courses_screen.dart`)
- **Description**: Browse all available courses
- **Key Features**:
  - List of all courses
  - Search and filter by category/level
  - Course cards with thumbnail, title, instructor
  - Rating and enrolled count
  - Favorite/bookmark toggle
  - Navigation to course details
- **Code Details**:
  - Queries courses table
  - Implements search functionality
  - Filter by category (Programming, Design, Business, etc.)
  - GridView/ListView layout
  - Real-time favorite updates

##### 3. **Course Detail Screen** (`lib/features/courses/screens/course_detail_screen.dart`)
- **Description**: Detailed view of a single course
- **Key Features**:
  - Course title, description, instructor
  - Course thumbnail/banner
  - Duration, level, category
  - Lessons list preview
  - Enroll/Unenroll button
  - Favorite toggle
  - Progress indicator (if enrolled)
- **Code Details**:
  - Fetches course by ID
  - Checks enrollment status
  - Displays lesson count
  - Enrollment service integration
  - Navigation to lessons screen

##### 4. **My Courses Screen** (`lib/features/courses/screens/my_courses_screen.dart`)
- **Description**: User's enrolled courses
- **Key Features**:
  - List of enrolled courses
  - Progress percentage per course
  - Continue learning button
  - Unenroll option
  - Completion badges
  - Empty state for no enrollments
- **Code Details**:
  - Joins enrollments and courses tables
  - Calculates progress percentage
  - Filters by user ID
  - Shows completion status
  - Quick navigation to lessons

##### 5. **Lessons Screen** (`lib/features/lessons/screens/lessons_screen.dart`)
- **Description**: List of lessons in a course
- **Key Features**:
  - Ordered lesson list
  - Lesson title, duration
  - Completion checkmarks
  - Locked/unlocked status
  - Sequential access
  - Progress bar
- **Code Details**:
  - Queries lessons by course_id
  - Orders by order_index
  - Checks completion status
  - Implements lesson locking logic
  - ListView with custom tiles

##### 6. **Lesson Detail Screen** (`lib/features/lessons/screens/lesson_detail_screen.dart`)
- **Description**: Individual lesson content viewer
- **Key Features**:
  - Lesson title and description
  - Rich text content
  - Video player (if video_url exists)
  - Mark as complete button
  - Previous/Next lesson navigation
  - Reading time estimate
- **Code Details**:
  - Displays lesson content
  - Updates completion status
  - Tracks user progress
  - Updates user_progress table
  - Scrollable content view

---

#### **Backend Files** (2 Files)

##### 1. **Courses API** (`backend/routes/courses.js`)
- **Description**: RESTful API for course management
- **Endpoints**:
  - `GET /api/courses` - List all courses
  - `GET /api/courses/:id` - Get course details
  - `POST /api/courses` - Create course (admin)
  - `PUT /api/courses/:id` - Update course (admin)
  - `DELETE /api/courses/:id` - Delete course (admin)
  - `POST /api/courses/:id/enroll` - Enroll user
  - `POST /api/courses/:id/unenroll` - Unenroll user
- **Code Details**:
  - Firebase Firestore queries
  - Enrollment count updates
  - Search and filter logic
  - Admin authorization checks
  - Pagination support

##### 2. **Lessons API** (`backend/routes/lessons.js`)
- **Description**: RESTful API for lesson management
- **Endpoints**:
  - `GET /api/lessons` - List lessons by course
  - `GET /api/lessons/:id` - Get lesson details
  - `POST /api/lessons` - Create lesson (admin)
  - `PUT /api/lessons/:id` - Update lesson (admin)
  - `DELETE /api/lessons/:id` - Delete lesson (admin)
  - `POST /api/lessons/:id/complete` - Mark complete
- **Code Details**:
  - Firestore collection queries
  - Order by order_index
  - Progress tracking
  - Content delivery
  - Video URL management

---

#### **Database Tables** (3 Tables)

##### 1. **Courses Table** (`courses`)
- **Description**: Stores course information
- **Schema**:
  ```sql
  CREATE TABLE courses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    instructor TEXT NOT NULL,
    duration TEXT NOT NULL,
    category TEXT NOT NULL,          -- Programming, Design, Business, etc.
    level TEXT NOT NULL,              -- Beginner, Intermediate, Advanced
    thumbnail_url TEXT,
    rating REAL DEFAULT 0.0,
    enrolled_count INTEGER DEFAULT 0,
    lessons_count INTEGER DEFAULT 0,
    is_featured INTEGER DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )
  ```
- **Operations**: CRUD operations, search, filter

##### 2. **Lessons Table** (`lessons`)
- **Description**: Stores lesson content
- **Schema**:
  ```sql
  CREATE TABLE lessons (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    content TEXT NOT NULL,            -- Rich text content
    video_url TEXT DEFAULT '',
    duration TEXT NOT NULL,
    order_index INTEGER NOT NULL,     -- Lesson order in course
    is_completed INTEGER DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (course_id) REFERENCES courses(id)
  )
  ```
- **Operations**: CRUD, order management, completion tracking

##### 3. **Enrollments Table** (`enrollments`)
- **Description**: Tracks user course enrollments
- **Schema**:
  ```sql
  CREATE TABLE enrollments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    enrolled_at TEXT NOT NULL,
    progress REAL DEFAULT 0.0,        -- 0-100 percentage
    is_completed INTEGER DEFAULT 0,
    completed_at TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (course_id) REFERENCES courses(id),
    UNIQUE(user_id, course_id)
  )
  ```
- **Operations**: Enroll, unenroll, progress tracking

---

#### **Services/Models** (3 Files)

##### 1. **Enrollment Service** (`lib/services/enrollment_service.dart`)
- **Description**: Manages course enrollments
- **Functions**:
  - `enrollCourse()` - Enroll user in course
  - `unenrollCourse()` - Remove enrollment
  - `getEnrollments()` - Get user's courses
  - `updateProgress()` - Update course progress
- **Code Details**:
  - SQLite enrollment operations
  - Progress calculation
  - Duplicate enrollment prevention
  - Enrollment count updates

##### 2. **Course Model** (`lib/models/course_model.dart`)
- **Description**: Course data model
- **Properties**: All course fields
- **Methods**: `fromMap()`, `toMap()`, `toJson()`

##### 3. **Lesson Model** (`lib/models/lesson_model.dart`)
- **Description**: Lesson data model
- **Properties**: All lesson fields
- **Methods**: `fromMap()`, `toMap()`, `toJson()`

---

### **Member 3: Quiz System & Progress Tracking** 

#### **Responsibility**: Quiz management, assessments, progress tracking, and analytics

#### **Offline Features** 
- **Take Quizzes**: Complete quizzes offline
- **View Results**: Access quiz history locally
- **Progress Tracking**: View learning progress offline
- **Quiz History**: Access past quiz attempts

#### **Online Features** 
- **Quiz Sync**: Sync quizzes from cloud
- **Result Sync**: Upload quiz results to Firebase
- **Leaderboard**: Compare scores online
- **Progress Analytics**: Cloud-based analytics

---

#### **Frontend Pages** (4 Screens)

##### 1. **Quizzes Screen** (`lib/features/quizzes/screens/quizzes_screen.dart`)
- **Description**: Browse available quizzes
- **Key Features**:
  - List of all quizzes
  - Quiz title, description
  - Total questions, duration
  - Passing score percentage
  - Difficulty level
  - Best score indicator
  - Start quiz button
- **Code Details**:
  - Queries quizzes table
  - Shows quiz metadata
  - Filters by course (optional)
  - Displays user's best score
  - Card-based layout

##### 2. **Quiz Detail Screen** (`lib/features/quizzes/screens/quiz_detail_screen.dart`)
- **Description**: Quiz taking interface with timer
- **Key Features**:
  - Quiz instructions screen
  - Timer countdown
  - Question navigation (previous/next)
  - Multiple choice options (A, B, C, D)
  - Progress indicator
  - Submit quiz button
  - Auto-submit on timeout
  - Result screen with score
- **Code Details**:
  - Loads quiz questions from database
  - Implements countdown timer
  - Tracks selected answers
  - Calculates score
  - Saves result to quiz_results table
  - Shows pass/fail status
  - Displays correct answers count
  - Time taken tracking

##### 3. **Progress Screen** (`lib/features/progress/screens/progress_screen.dart`)
- **Description**: User learning progress dashboard
- **Key Features**:
  - Overall progress percentage
  - Completed lessons count
  - Quiz scores summary
  - Course-wise progress
  - Charts and graphs (fl_chart)
  - Achievements/badges
  - Study streak
  - Time spent learning
- **Code Details**:
  - Aggregates data from multiple tables
  - Calculates completion percentages
  - Generates progress charts
  - Shows quiz performance
  - Displays enrolled courses progress
  - Visual progress bars
  - Statistics cards

##### 4. **Quiz Results History** (Part of Progress Screen)
- **Description**: View past quiz attempts
- **Key Features**:
  - List of completed quizzes
  - Score for each attempt
  - Pass/fail status
  - Date and time
  - Time taken
  - Retake option
- **Code Details**:
  - Queries quiz_results table
  - Joins with quizzes table
  - Orders by date (newest first)
  - Shows detailed results
  - Allows quiz retakes

---

#### **Backend Files** (2 Files)

##### 1. **Quizzes API** (`backend/routes/quizzes.js`)
- **Description**: RESTful API for quiz management
- **Endpoints**:
  - `GET /api/quizzes` - List all quizzes
  - `GET /api/quizzes/:id` - Get quiz details
  - `GET /api/quizzes/:id/questions` - Get questions
  - `POST /api/quizzes` - Create quiz (admin)
  - `PUT /api/quizzes/:id` - Update quiz (admin)
  - `DELETE /api/quizzes/:id` - Delete quiz (admin)
  - `POST /api/quizzes/:id/submit` - Submit quiz result
- **Code Details**:
  - Firestore quiz queries
  - Question randomization
  - Score calculation
  - Result storage
  - Leaderboard generation

##### 2. **Progress API** (`backend/routes/progress.js`)
- **Description**: RESTful API for progress tracking
- **Endpoints**:
  - `GET /api/progress/user/:userId` - Get user progress
  - `POST /api/progress/lesson` - Update lesson progress
  - `POST /api/progress/quiz` - Save quiz result
  - `GET /api/progress/stats/:userId` - Get statistics
  - `GET /api/progress/leaderboard` - Get top performers
- **Code Details**:
  - Aggregates progress data
  - Calculates statistics
  - Generates reports
  - Leaderboard queries
  - Progress percentage calculations

---

#### **Database Tables** (3 Tables)

##### 1. **Quizzes Table** (`quizzes`)
- **Description**: Stores quiz metadata
- **Schema**:
  ```sql
  CREATE TABLE quizzes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    duration INTEGER NOT NULL,        -- Duration in seconds
    total_questions INTEGER NOT NULL,
    passing_score INTEGER NOT NULL,   -- Percentage (e.g., 70)
    difficulty TEXT NOT NULL,         -- Easy, Medium, Hard
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (course_id) REFERENCES courses(id)
  )
  ```
- **Operations**: CRUD operations, filter by course

##### 2. **Quiz Questions Table** (`quiz_questions`)
- **Description**: Stores quiz questions and answers
- **Schema**:
  ```sql
  CREATE TABLE quiz_questions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    quiz_id INTEGER NOT NULL,
    question TEXT NOT NULL,
    option_a TEXT NOT NULL,
    option_b TEXT NOT NULL,
    option_c TEXT NOT NULL,
    option_d TEXT NOT NULL,
    correct_answer TEXT NOT NULL,     -- 'A', 'B', 'C', or 'D'
    explanation TEXT,
    order_index INTEGER NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
  )
  ```
- **Operations**: CRUD, randomization, order management

##### 3. **Quiz Results Table** (`quiz_results`)
- **Description**: Stores user quiz attempts
- **Schema**:
  ```sql
  CREATE TABLE quiz_results (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    quiz_id INTEGER NOT NULL,
    score INTEGER NOT NULL,           -- Percentage score
    total_questions INTEGER NOT NULL,
    correct_answers INTEGER NOT NULL,
    time_taken INTEGER NOT NULL,      -- Seconds
    passed INTEGER DEFAULT 0,         -- 0 or 1
    completed_at TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
  )
  ```
- **Operations**: Insert results, query history, calculate stats

---

#### **Services/Models** (2 Files)

##### 1. **Quiz Model** (`lib/models/quiz_model.dart`)
- **Description**: Quiz and question data models
- **Classes**:
  - `QuizModel` - Quiz metadata
  - `QuizQuestionModel` - Question details
- **Properties**: All quiz/question fields
- **Methods**: `fromMap()`, `toMap()`, `toJson()`

##### 2. **Progress Calculation Service** (Part of `database_helper.dart`)
- **Description**: Progress calculation logic
- **Functions**:
  - Calculate lesson completion percentage
  - Calculate course progress
  - Aggregate quiz scores
  - Generate statistics
- **Code Details**:
  - Complex SQL queries
  - JOIN operations
  - Aggregation functions
  - Progress formulas

---

### **Member 4: Notes, Chatbot & Notifications** 

#### **Responsibility**: Personal notes, AI chatbot assistant, and notification system

#### **Offline Features** 
- **Personal Notes**: Create, edit, delete notes offline
- **Note Search**: Search notes locally
- **Favorites**: Mark important notes
- **Local Notifications**: Receive study reminders offline

#### **Online Features** 
- **AI Chatbot**: OpenAI/Gemini API integration for learning assistance
- **Note Sync**: Sync notes with cloud
- **Push Notifications**: Cloud-based notifications
- **Broadcast Messages**: Admin notifications to all users

---

#### **Frontend Pages** (6 Screens)

##### 1. **Notes Screen** (`lib/features/notes/screens/notes_screen.dart`)
- **Description**: Personal notes management
- **Key Features**:
  - List of user's notes
  - Note title and preview
  - Tags/categories
  - Favorite toggle (star icon)
  - Search notes
  - Delete note with confirmation
  - Empty state message
  - Floating action button to add note
- **Code Details**:
  - Queries notes table by user_id
  - Orders by created_at (newest first)
  - Displays note preview (first 3 lines)
  - Tag chips display
  - Swipe to delete
  - Navigation to add/edit note

##### 2. **Add/Edit Note Screen** (`lib/features/notes/screens/add_note_screen.dart`)
- **Description**: Create or edit notes
- **Key Features**:
  - Title input field
  - Rich text content editor
  - Tags input (comma-separated)
  - Favorite toggle
  - Save button
  - Auto-save draft
  - Character count
- **Code Details**:
  - Insert or update notes table
  - Form validation
  - Rich text formatting
  - Tag parsing
  - Timestamp management
  - Success notification

##### 3. **Chatbot Screen** (`lib/features/chatbot/screens/chatbot_screen.dart`)
- **Description**: AI-powered learning assistant
- **Key Features**:
  - Chat interface (messages list)
  - User message bubbles
  - AI response bubbles
  - Message input field
  - Send button
  - Typing indicator
  - Chat history
  - Context-aware responses
  - Clear chat option
- **Code Details**:
  - OpenAI/Gemini API integration
  - Stores chat in chat_messages table
  - Real-time message updates
  - API error handling
  - Loading states
  - Markdown response formatting
  - Conversation context management

##### 4. **Notifications Screen** (`lib/features/notifications/screens/notifications_screen.dart`)
- **Description**: Notification center
- **Key Features**:
  - List of notifications
  - Notification title, message, timestamp
  - Read/unread status
  - Notification types (info, success, warning)
  - Mark as read
  - Delete notification
  - Clear all notifications
  - Empty state
- **Code Details**:
  - Queries notifications table
  - Orders by created_at (newest first)
  - Updates is_read status
  - Different icons for types
  - Swipe to dismiss
  - Badge count on app bar

##### 5. **Admin Dashboard** (`lib/features/admin/screens/admin_dashboard_screen.dart`)
- **Description**: Admin control panel
- **Key Features**:
  - Total users count
  - Total courses count
  - Total enrollments
  - Recent activity
  - Quick access to management screens
  - Statistics cards
  - Navigation grid
- **Code Details**:
  - Aggregates data from all tables
  - Admin-only access check
  - Dashboard statistics
  - Navigation to CRUD screens
  - Charts and graphs

##### 6. **Manage Notifications Screen** (`lib/features/admin/screens/manage_notifications_screen.dart`)
- **Description**: Admin notification management
- **Key Features**:
  - Create broadcast notifications
  - Send to all users
  - Send to specific user
  - Notification type selection
  - Title and message input
  - Schedule notifications
  - View sent notifications
- **Code Details**:
  - Inserts into notifications table
  - Bulk insert for all users
  - Notification service integration
  - Local notification triggers
  - Success confirmation

---

#### **Backend Files** (1 File)

##### 1. **Notifications API** (`backend/routes/notifications.js`)
- **Description**: RESTful API for notifications
- **Endpoints**:
  - `GET /api/notifications/user/:userId` - Get user notifications
  - `POST /api/notifications` - Create notification
  - `POST /api/notifications/broadcast` - Send to all users
  - `PUT /api/notifications/:id/read` - Mark as read
  - `DELETE /api/notifications/:id` - Delete notification
  - `POST /api/notifications/schedule` - Schedule notification
- **Code Details**:
  - Firestore notification queries
  - Bulk notification creation
  - FCM push notification integration
  - Scheduling logic
  - Read status updates
  - User-specific filtering

---

#### **Database Tables** (3 Tables)

##### 1. **Notes Table** (`notes`)
- **Description**: Stores user personal notes
- **Schema**:
  ```sql
  CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    tags TEXT,                        -- Comma-separated tags
    is_favorite INTEGER DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
  )
  ```
- **Operations**: CRUD, search, filter by tags, favorites

##### 2. **Chat Messages Table** (`chat_messages`)
- **Description**: Stores chatbot conversation history
- **Schema**:
  ```sql
  CREATE TABLE chat_messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    message TEXT NOT NULL,
    is_user INTEGER NOT NULL,         -- 1 for user, 0 for AI
    created_at TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
  )
  ```
- **Operations**: Insert messages, query conversation history

##### 3. **Notifications Table** (`notifications`)
- **Description**: Stores user notifications
- **Schema**:
  ```sql
  CREATE TABLE notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL,               -- 'info', 'success', 'warning', 'error'
    is_read INTEGER DEFAULT 0,
    created_at TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
  )
  ```
- **Operations**: CRUD, mark as read, filter by user

---

#### **Services/Models** (4 Files)

##### 1. **AI Service** (`lib/services/ai_service.dart`)
- **Description**: AI chatbot integration
- **Functions**:
  - `sendMessage()` - Send message to AI
  - `getChatHistory()` - Get conversation
  - `clearHistory()` - Clear chat
- **Code Details**:
  - OpenAI/Gemini API calls
  - HTTP requests with dio
  - Response parsing
  - Error handling
  - Context management
  - API key configuration

##### 2. **Notification Service** (`lib/services/notification_service.dart`)
- **Description**: Local notification management
- **Functions**:
  - `initialize()` - Setup notifications
  - `showNotification()` - Display notification
  - `scheduleNotification()` - Schedule future notification
  - `createQuizCompletionNotification()` - Quiz result notification
  - `createEnrollmentNotification()` - Enrollment notification
- **Code Details**:
  - flutter_local_notifications plugin
  - Android/iOS notification channels
  - Notification scheduling
  - Custom notification sounds
  - Action buttons
  - Notification tapping handling

##### 3. **Note Model** (`lib/models/note_model.dart`)
- **Description**: Note data model
- **Properties**: id, userId, title, content, tags, isFavorite, timestamps
- **Methods**: `fromMap()`, `toMap()`, `toJson()`

##### 4. **Notification Model** (`lib/models/notification_model.dart`)
- **Description**: Notification data model
- **Properties**: id, userId, title, message, type, isRead, createdAt
- **Methods**: `fromMap()`, `toMap()`, `toJson()`

---

##  Distribution Summary Table

| Member | Features | Screens | Backend Files | Database Tables | Offline | Online |
|--------|----------|---------|---------------|-----------------|---------|--------|
| **Member 1** | Auth & Profile | 5 | 1 | 1 |  |  |
| **Member 2** | Courses & Lessons | 6 | 2 | 3 |  |  |
| **Member 3** | Quizzes & Progress | 4 | 2 | 3 |  |  |
| **Member 4** | Notes, Chat & Notifications | 6 | 1 | 3 |  |  |
| **TOTAL** | 12 Features | 21 | 6 | 10 | - | - |

---

##  Shared Components (All Members)

### **Core Files** (Used by all members)

#### 1. **Database Helper** (`lib/services/database_helper.dart`)
- **Description**: SQLite database management
- **Responsibilities**:
  - Database initialization
  - Table creation
  - CRUD operations
  - Database migrations
- **Usage**: All members use this for local data storage

#### 2. **API Service** (`lib/services/api_service.dart`)
- **Description**: HTTP client for backend communication
- **Responsibilities**:
  - REST API calls
  - Request/response handling
  - Error handling
  - Authentication headers
- **Usage**: All members use this for cloud sync

#### 3. **Sync Service** (`lib/services/sync_service.dart`)
- **Description**: Offline-online data synchronization
- **Responsibilities**:
  - Detect connectivity changes
  - Sync local data to cloud
  - Pull cloud data to local
  - Conflict resolution
- **Usage**: All members use this for data sync

#### 4. **Auth Provider** (`lib/features/auth/providers/auth_provider.dart`)
- **Description**: Global authentication state
- **Responsibilities**:
  - Current user state
  - Login/logout state
  - User role checking
  - Session management
- **Usage**: All screens check authentication

#### 5. **App Theme** (`lib/core/themes/app_theme.dart`)
- **Description**: Application-wide styling
- **Responsibilities**:
  - Color scheme
  - Text styles
  - Button styles
  - Theme data
- **Usage**: All screens use consistent styling

#### 6. **App Constants** (`lib/core/constants/app_constants.dart`)
- **Description**: Global constants
- **Responsibilities**:
  - Database name and version
  - API endpoints
  - App configuration
  - Default values
- **Usage**: All files reference constants

---

##  Additional Database Tables (Shared)

### **Favorites Table** (`favorites`)
- **Description**: Stores user's favorite courses
- **Schema**:
  ```sql
  CREATE TABLE favorites (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (course_id) REFERENCES courses(id),
    UNIQUE(user_id, course_id)
  )
  ```
- **Used by**: Member 2 (Courses)

### **User Progress Table** (`user_progress`)
- **Description**: Tracks lesson completion
- **Schema**:
  ```sql
  CREATE TABLE user_progress (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    lesson_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    is_completed INTEGER DEFAULT 0,
    completed_at TEXT,
    time_spent INTEGER DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (lesson_id) REFERENCES lessons(id),
    FOREIGN KEY (course_id) REFERENCES courses(id),
    UNIQUE(user_id, lesson_id)
  )
  ```
- **Used by**: Member 2 (Lessons), Member 3 (Progress)

---

##  Offline vs Online Feature Breakdown

### **Offline Features** 
All features work offline using SQLite database:
-  Login/Register (local authentication)
-  Browse courses and lessons
-  Take quizzes
-  Create and edit notes
-  View progress and statistics
-  View notifications
-  Enroll in courses
-  Complete lessons

### **Online Features** 
Enhanced features when connected to internet:
-  AI Chatbot (requires API)
-  Data sync with Firebase Firestore
-  Real-time enrollment counts
-  Cloud backup of user data
-  Push notifications
-  Leaderboards
-  Latest course updates
-  Admin broadcast notifications

---

##  Development Guidelines

### **For All Team Members**

1. **Code Style**:
   - Follow Dart style guide
   - Use meaningful variable names
   - Add comments for complex logic
   - Keep functions small and focused

2. **Database Operations**:
   - Always use `DatabaseHelper.instance`
   - Handle null values properly
   - Use transactions for multiple operations
   - Add error handling

3. **API Integration**:
   - Use `ApiService` for all HTTP calls
   - Handle network errors gracefully
   - Show loading indicators
   - Implement retry logic

4. **UI/UX**:
   - Follow Material Design guidelines
   - Use `AppTheme` for consistent styling
   - Add loading states
   - Show error messages
   - Implement pull-to-refresh

5. **State Management**:
   - Use Provider for state
   - Call `setState()` when updating UI
   - Dispose controllers properly
   - Avoid memory leaks

6. **Testing**:
   - Test offline functionality
   - Test online sync
   - Test error scenarios
   - Test edge cases

---

##  Getting Started

### **Setup Instructions**

1. **Clone Repository**:
   ```bash
   git clone <repository-url>
   cd learninghub
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   cd backend
   npm install
   ```

3. **Configure Firebase**:
   - Download `firebase-service-account.json`
   - Place in `backend/` folder
   - Update `.env` file

4. **Run Backend** (Optional for online features):
   ```bash
   cd backend
   npm run dev
   ```

5. **Run Flutter App**:
   ```bash
   flutter run
   ```

### **Test Credentials**

**Admin Account**:
- Email: `admin@learninghub.com`
- Password: `admin123`

**User Account**:
- Email: `john@example.com`
- Password: `user123`

---

##  Documentation References

- **Main README**: `/README.md`
- **Backend Documentation**: `/backend/README.md`
- **API Documentation**: `/backend/DEPLOYMENT.md`
- **Project Summary**: `/FINAL_PROJECT_SUMMARY.md`
- **Requirements Checklist**: `/FINAL_REQUIREMENTS_CHECKLIST.md`

---

##  Completion Checklist

### **Member 1: Authentication & User Management**
- [ ] Login Screen implemented
- [ ] Register Screen implemented
- [ ] Profile Screen implemented
- [ ] Edit Profile Screen implemented
- [ ] Change Password Screen implemented
- [ ] Users API backend completed
- [ ] Auth Service implemented
- [ ] User Model created
- [ ] Offline authentication working
- [ ] Online sync working

### **Member 2: Course & Lesson Management**
- [ ] User Dashboard implemented
- [ ] Courses Screen implemented
- [ ] Course Detail Screen implemented
- [ ] My Courses Screen implemented
- [ ] Lessons Screen implemented
- [ ] Lesson Detail Screen implemented
- [ ] Courses API backend completed
- [ ] Lessons API backend completed
- [ ] Enrollment Service implemented
- [ ] Course/Lesson Models created
- [ ] Offline browsing working
- [ ] Online sync working

### **Member 3: Quiz System & Progress Tracking**
- [ ] Quizzes Screen implemented
- [ ] Quiz Detail Screen implemented
- [ ] Progress Screen implemented
- [ ] Quiz Results History implemented
- [ ] Quizzes API backend completed
- [ ] Progress API backend completed
- [ ] Quiz Models created
- [ ] Offline quiz taking working
- [ ] Online sync working
- [ ] Progress calculations accurate

### **Member 4: Notes, Chatbot & Notifications**
- [ ] Notes Screen implemented
- [ ] Add/Edit Note Screen implemented
- [ ] Chatbot Screen implemented
- [ ] Notifications Screen implemented
- [ ] Admin Dashboard implemented
- [ ] Manage Notifications Screen implemented
- [ ] Notifications API backend completed
- [ ] AI Service implemented
- [ ] Notification Service implemented
- [ ] Note/Notification Models created
- [ ] Offline notes working
- [ ] Chatbot API working
- [ ] Notifications working

---

##  Conclusion

This distribution ensures:
-  **Equal workload** across all 4 members
-  **Clear separation** of features and responsibilities
-  **Both offline and online** features for each member
-  **Frontend and backend** work for each member
-  **Complete feature ownership** from UI to database
-  **Collaborative development** with shared components

Each member has approximately:
- **5-6 screens** to implement
- **1-2 backend API files** to develop
- **2-3 database tables** to manage
- **2-4 models/services** to create
- **Both offline and online** functionality

**Total Project**: 21 screens + 6 backend files + 10 database tables + 12 features

---

**Document Version**: 1.0  
**Last Updated**: 2025-12-16  
**Status**: Ready for Team Distribution 
