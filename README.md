# Smart Learning Hub 

A comprehensive mobile learning platform built with Flutter and Dart for the Education & Learning sector. This app provides a complete learning experience with courses, quizzes, notes, AI chatbot assistance, and progress tracking.

##  Project Overview

**Smart Learning Hub** is a feature-rich educational mobile application designed for students and managed by administrators. It combines offline learning capabilities with modern UI/UX design and AI-powered assistance.

### Group Project Information
- **Course**: Mobile Application Development
- **Institution**: Kingston University, BSc (Hons) (top-up)
- **Topic**: Education & Learning
- **Package Name**: com.example.learninghub

##  Features (8 Core Features)

### User Features
1. ** Course Management**
   - Browse and enroll in courses
   - View course details, lessons, and materials
   - Filter courses by category and difficulty
   - Track course progress

2. ** Lesson Viewer**
   - Access detailed lesson content
   - Video support (placeholder for video URLs)
   - Mark lessons as complete
   - Track lesson duration

3. ** Interactive Quizzes**
   - Take timed quizzes with multiple-choice questions
   - Real-time timer and progress tracking
   - Instant results with score calculation
   - Pass/fail status based on passing score

4. ** Personal Notes**
   - Create, edit, and delete notes
   - Tag notes for easy organization
   - Mark notes as favorites
   - Link notes to courses and lessons

5. ** AI Study Assistant (Chatbot)**
   - Get study help and explanations
   - Ask questions about topics
   - Context-aware responses
   - Chat history saved locally

6. ** Progress Tracking**
   - Visual progress indicators
   - Weekly activity charts
   - Course completion statistics
   - Performance analytics

7. ** User Profile**
   - Manage personal information
   - Change password
   - App settings and preferences
   - Logout functionality

8. ** Authentication System**
   - User registration and login
   - Role-based access (User/Admin)
   - Session management
   - Secure password handling

### Admin Features
- ** Admin Dashboard**
  - Overview of all platform statistics
  - Total courses, lessons, quizzes, and users
  - Management access controls

- ** Content Management**
  - Manage courses, lessons, and quizzes
  - User management
  - Send notifications to users
  - View reports and analytics

##  Architecture & Design

### Architecture Pattern
- **Pattern**: Feature-based architecture with Provider state management
- **Structure**: Organized by feature modules for scalability and maintainability

### Project Structure
```
lib/
 core/
    constants/        # App constants and configuration
    themes/          # App themes (User & Admin)
    widgets/         # Reusable custom widgets
 features/
    auth/            # Authentication (Login/Register)
    courses/         # Course browsing and details
    lessons/         # Lesson viewer
    quizzes/         # Quiz system
    notes/           # Note-taking
    chatbot/         # AI chatbot
    progress/        # Progress tracking
    profile/         # User profile
    admin/           # Admin dashboard
 models/              # Data models
 services/            # Database and API services
 main.dart           # App entry point
```

### State Management
- **Provider**: Used for authentication and app-wide state management
- **Local State**: StatefulWidget for component-level state

### Database
- **SQLite (sqflite)**: Local database for offline functionality
- **Tables**: users, courses, lessons, quizzes, quiz_questions, quiz_results, notes, chat_messages, user_progress, enrollments, notifications, favorites

##  Technologies & Dependencies

### Core Dependencies
- **flutter**: SDK for building the app
- **provider**: ^6.1.1 - State management
- **sqflite**: ^2.3.0 - Local database
- **path_provider**: ^2.1.1 - File system paths
- **shared_preferences**: ^2.2.2 - Local storage

### Firebase Integration
- **firebase_core**: ^2.24.2
- **firebase_auth**: ^4.15.3
- **firebase_database**: ^10.4.0
- **firebase_storage**: ^11.5.6
- **cloud_firestore**: ^4.13.6

### UI/UX Libraries
- **google_fonts**: ^6.1.0 - Custom fonts
- **flutter_svg**: ^2.0.9 - SVG support
- **cached_network_image**: ^3.3.0 - Image caching
- **shimmer**: ^3.0.0 - Loading effects
- **lottie**: ^2.7.0 - Animations

### Charts & Visualization
- **fl_chart**: ^0.65.0 - Charts and graphs
- **percent_indicator**: ^4.2.3 - Progress indicators

### Utilities
- **http**: ^1.1.2 - HTTP requests
- **dio**: ^5.4.0 - Advanced HTTP client
- **intl**: ^0.18.1 - Internationalization
- **image_picker**: ^1.0.5 - Image selection

##  Screens (Minimum 5 Independent Screens)

### User Screens
1. **Login Screen** - User authentication
2. **Register Screen** - New user registration
3. **User Dashboard** - Home screen with quick actions
4. **Courses Screen** - Browse all courses
5. **Course Detail Screen** - View course information
6. **Lesson Detail Screen** - View lesson content
7. **Quiz Screen** - Take quizzes
8. **Notes Screen** - Manage personal notes
9. **Chatbot Screen** - AI study assistant
10. **Progress Screen** - View learning progress
11. **Profile Screen** - User profile management

### Admin Screens
12. **Admin Dashboard** - Admin control panel

##  UI/UX Design

### Design Principles
- **Material Design 3**: Modern Material Design guidelines
- **Custom Components**: Custom buttons, text fields, and cards
- **Color Schemes**: 
  - User Theme: Purple gradient (#6C63FF)
  - Admin Theme: Blue gradient (#1E3A8A)
- **Google Fonts**: Poppins (User), Inter (Admin)
- **Responsive**: Adapts to different screen sizes

### Custom Components
1. **CustomButton** - Reusable button with loading state
2. **CustomTextField** - Enhanced text input with validation
3. **Custom Cards** - Styled cards for content display
4. **Gradient Containers** - Beautiful gradient backgrounds

##  Database Schema

### Key Tables
- **users**: User accounts (admin/user roles)
- **courses**: Course information
- **lessons**: Lesson content linked to courses
- **quizzes**: Quiz metadata
- **quiz_questions**: MCQ questions with answers
- **quiz_results**: User quiz scores
- **notes**: User-created notes
- **chat_messages**: AI chatbot conversation history
- **user_progress**: Learning progress tracking

##  CRUD Operations

All major entities support full CRUD operations:
- **Create**: Add new courses, lessons, quizzes, notes
- **Read**: View and browse all content
- **Update**: Edit existing content
- **Delete**: Remove content with confirmation

##  API Integration

### AI Chatbot API
- **Endpoint**: Configurable in `app_constants.dart`
- **Current**: Simulated responses (rule-based)
- **Production**: Ready for OpenAI/Gemini API integration
- **Note**: Add your API key in `AppConstants.openAIApiKey`

##  Installation & Setup

### Prerequisites
- Flutter SDK (^3.9.2)
- Dart SDK
- Android Studio / VS Code
- Android Emulator or Physical Device

### Steps
1. **Clone the repository**
   ```bash
   cd learninghub
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Build APK**
   ```bash
   flutter build apk --release
   ```

##  Demo Credentials

### Admin Account
- **Email**: admin@learninghub.com
- **Password**: admin123

### User Account
- **Email**: john@example.com
- **Password**: user123

##  Dummy Data

The app automatically seeds the database with:
- 3 Users (1 Admin, 2 Regular Users)
- 5 Courses across different categories
- 13 Lessons with detailed content
- 3 Quizzes with multiple questions
- Sample quiz questions (MCQs with explanations)

##  Features Implementation

### Offline Capabilities
-  Full offline data access
-  SQLite local database
-  Data persistence
-  Offline-first architecture

### State Management
-  Provider for global state
-  Authentication state management
-  Reactive UI updates

### Backend Integration
-  SQLite for local storage
-  Firebase configuration ready
-  API integration structure in place

##  Notes for Development

### To Add Real AI Chatbot
1. Get API key from OpenAI or Google Gemini
2. Update `AppConstants.openAIApiKey` or `AppConstants.geminiApiKey`
3. Implement API call in `chatbot_screen.dart` `_generateResponse()` method

### To Enable Firebase
1. Complete Firebase project setup
2. Download and replace `google-services.json`
3. Implement Firebase sync in services

### To Add More Features
- Follow the feature-based structure
- Create new folders in `lib/features/`
- Add models, screens, services, and providers

##  Academic Requirements Met

 Backend service integration (SQLite + Firebase ready)  
 Offline capabilities (Full offline support)  
 Minimum 5 independent screens (12+ screens)  
 Custom components (CustomButton, CustomTextField)  
 State management (Provider)  
 Feature-based architecture  
 Material Design guidelines  
 CRUD operations  
 Dummy data for testing  
 Clean code structure  

##  License

This project is created for educational purposes as part of Kingston University coursework.

##  Contributors

Group project for Mobile Application Development course.

---

**Built with  using Flutter & Dart**
# Learning_Hub
