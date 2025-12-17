# Smart Learning Hub - Architecture Diagram

##  Application Architecture

### **Clean Architecture with Feature-Based Structure**

```

                        PRESENTATION LAYER                        
                         (UI Screens)                             
    
    User Screens (17)            Admin Screens (10)          
    - Login/Register             - Admin Dashboard           
    - Dashboard                  - Manage Courses            
    - Courses List               - Manage Lessons            
    - My Courses                 - Manage Quizzes            
    - Course Detail              - Manage Questions          
    - Lesson View                - Manage Users              
    - Quizzes                    - Manage Notifications      
    - Quiz Detail                - Add/Edit Screens          
    - Notes                                                  
    - Add/Edit Note                                          
    - AI Chatbot                                             
    - Progress Tracker                                       
    - Notifications                                          
    - Profile                                                
    - Edit Profile                                           
    

                             
                             

                   STATE MANAGEMENT LAYER                         
                      (Provider Pattern)                          
    
    AuthProvider                                              
    - currentUser                                             
    - isAuthenticated                                         
    - login() / logout() / register()                         
                                                              
    Reactive UI Updates                                       
    - notifyListeners()                                       
    - Consumer widgets                                        
    

                             
                             

                      BUSINESS LOGIC LAYER                        
                         (Services)                               
    
    DatabaseHelper            NotificationService            
    - SQLite operations       - Local notifications          
    - CRUD methods            - Scheduled reminders          
    - Query builder           - Achievement alerts           
                                                             
    AuthService               EnrollmentService              
    - User authentication     - Course enrollment            
    - Session management      - Favorites management         
    - Password hashing        - Progress tracking            
                                                             
    ApiService                SyncService                    
    - REST API calls          - Data synchronization         
    - Firebase integration    - Connectivity monitoring      
    - HTTP requests           - Conflict resolution          
    

                             
                             

                         DATA LAYER                               
                    (Data Sources)                                
     
     LOCAL STORAGE             CLOUD STORAGE                 
     (Offline Mode)            (Online Mode)                 
                
      SQLite Database         Firebase Firestore        
                                                        
      12 Tables:              Collections:              
      - users           - courses                 
      - courses               - lessons                 
      - lessons               - quizzes                 
      - quizzes               - quiz_results            
      - quiz_questions        - users                   
      - quiz_results          - user_progress           
      - notes                 - notifications           
      - user_progress                                   
      - chat_messages             
      - notifications                                     
      - enrollments               
      - favorites             REST API Backend          
                              (Node.js + Express)       
      Sync Fields:                                      
      - sync_status           30+ Endpoints:            
      - last_updated          - GET /courses            
            - POST /courses           
                                 - PUT /courses/:id        
                                 - DELETE /courses         
                                 - GET /lessons            
                                 - POST /quiz-results      
                                 - And more...             
                                     
     

```

---

##  Data Flow Diagram

### **Offline Mode (No Internet)**
```
User Action
    ↓
UI Screen
    ↓
Provider (State Management)
    ↓
Service Layer
    ↓
SQLite Database (Local)
    ↓
Data Returned
    ↓
UI Updated
```

### **Online Mode (With Internet)**
```
User Action
    ↓
UI Screen
    ↓
Provider (State Management)
    ↓
Service Layer
    ↓

  Check Network  

         
    
     Online? 
    
         
    
                             
    YES                      NO
                             
                             
SQLite + API            SQLite Only
                             
                             
Firebase Firestore            
                             
    
              
        Data Returned
              ↓
         UI Updated
```

### **Synchronization Flow**
```
App Starts
    ↓
Check Connectivity
    ↓

  Is Online?    

     
     

  Sync Service Activated     
                             
  1. Get pending records     
     (sync_status = 0)       
                             
  2. Upload to Firebase      
     - Quiz results          
     - User progress         
     - Notes                 
                             
  3. Download from Firebase  
     - Latest courses        
     - New lessons           
     - Updates               
                             
  4. Resolve conflicts       
     (timestamp comparison)  
                             
  5. Update sync_status = 1  
                             
  6. Update last_updated     

```

---

##  Feature Modules Architecture

```
features/

 auth/
    screens/
       login_screen.dart
       register_screen.dart
    providers/
       auth_provider.dart
    widgets/
        custom_text_field.dart

 courses/
    screens/
       courses_screen.dart
       course_detail_screen.dart
       my_courses_screen.dart
    widgets/
        course_card.dart

 lessons/
    screens/
       lesson_detail_screen.dart
    widgets/
        lesson_content.dart

 quizzes/
    screens/
       quizzes_screen.dart
       quiz_detail_screen.dart
    widgets/
        quiz_option_button.dart

 notes/
    screens/
       notes_screen.dart
       add_edit_note_screen.dart
    widgets/
        note_card.dart

 chatbot/
    screens/
       chatbot_screen.dart
    widgets/
        chat_bubble.dart

 progress/
    screens/
       progress_screen.dart
    widgets/
        progress_chart.dart

 notifications/
    screens/
       notifications_screen.dart
    widgets/
        notification_card.dart

 profile/
    screens/
       profile_screen.dart
       edit_profile_screen.dart
       change_password_screen.dart
    widgets/
        profile_header.dart

 admin/
     screens/
        admin_dashboard_screen.dart
        manage_courses_screen.dart
        manage_lessons_screen.dart
        manage_quizzes_screen.dart
        manage_users_screen.dart
        manage_notifications_screen.dart
     widgets/
         admin_card.dart
```

---

##  Database Schema

### **SQLite Tables (12 Tables)**

```sql
-- Users Table
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT DEFAULT 'user',
    created_at TEXT,
    updated_at TEXT
);

-- Courses Table
CREATE TABLE courses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    instructor TEXT,
    duration TEXT,
    difficulty TEXT,
    rating REAL,
    enrolled_count INTEGER DEFAULT 0,
    lessons_count INTEGER DEFAULT 0,
    created_at TEXT,
    updated_at TEXT
);

-- Lessons Table
CREATE TABLE lessons (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id INTEGER,
    title TEXT NOT NULL,
    content TEXT,
    duration INTEGER,
    order_index INTEGER,
    is_completed INTEGER DEFAULT 0,
    created_at TEXT,
    updated_at TEXT,
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- Quizzes Table
CREATE TABLE quizzes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id INTEGER,
    title TEXT NOT NULL,
    description TEXT,
    duration INTEGER,
    passing_score INTEGER,
    created_at TEXT,
    updated_at TEXT,
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- Quiz Questions Table
CREATE TABLE quiz_questions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    quiz_id INTEGER,
    question TEXT NOT NULL,
    option_a TEXT,
    option_b TEXT,
    option_c TEXT,
    option_d TEXT,
    correct_answer TEXT,
    explanation TEXT,
    created_at TEXT,
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
);

-- Quiz Results Table (with sync)
CREATE TABLE quiz_results (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    quiz_id INTEGER,
    score INTEGER,
    total_questions INTEGER,
    passed INTEGER,
    sync_status INTEGER DEFAULT 0,
    last_updated TEXT,
    created_at TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
);

-- Notes Table (with sync)
CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    title TEXT NOT NULL,
    content TEXT,
    sync_status INTEGER DEFAULT 0,
    last_updated TEXT,
    created_at TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- User Progress Table (with sync)
CREATE TABLE user_progress (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    lesson_id INTEGER,
    is_completed INTEGER DEFAULT 0,
    sync_status INTEGER DEFAULT 0,
    last_updated TEXT,
    completed_at TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (lesson_id) REFERENCES lessons(id)
);

-- Chat Messages Table
CREATE TABLE chat_messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    message TEXT,
    is_user INTEGER,
    created_at TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Notifications Table
CREATE TABLE notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    title TEXT,
    message TEXT,
    type TEXT,
    is_read INTEGER DEFAULT 0,
    created_at TEXT,
    updated_at TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Enrollments Table
CREATE TABLE enrollments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    course_id INTEGER,
    enrolled_at TEXT,
    progress INTEGER DEFAULT 0,
    is_completed INTEGER DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- Favorites Table
CREATE TABLE favorites (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    course_id INTEGER,
    created_at TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);
```

---

##  Security Architecture

```

      Authentication Layer           
                                     
  - Login/Register                   
  - Session Management               
  - Role-Based Access Control        
    (Admin / User)                   

             
             

      Authorization Layer            
                                     
  - Route Guards                     
  - Admin-only Screens               
  - User-specific Data               

             
             

      Data Access Layer              
                                     
  - User can only access own data    
  - Admin can access all data        
  - Secure password storage          

```

---

##  Technology Stack

### **Frontend (Mobile App)**
- **Framework**: Flutter 3.9.2
- **Language**: Dart
- **State Management**: Provider
- **Local Database**: SQLite (sqflite)
- **HTTP Client**: Dio
- **UI Components**: Material Design 3

### **Backend (API)**
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: Firebase Firestore
- **Authentication**: Firebase Admin SDK
- **Security**: Helmet.js, CORS

### **Third-Party Services**
- **AI**: OpenAI / Gemini API
- **Cloud**: Firebase
- **Notifications**: flutter_local_notifications
- **Charts**: fl_chart
- **Fonts**: google_fonts

---

##  Design Patterns Used

1. **Singleton Pattern** - Services (DatabaseHelper, ApiService)
2. **Provider Pattern** - State management
3. **Repository Pattern** - Data access layer
4. **Factory Pattern** - Model creation
5. **Observer Pattern** - Provider notifications
6. **Strategy Pattern** - Offline/Online modes

---

**This architecture ensures**:
-  Scalability
-  Maintainability
-  Testability
-  Separation of concerns
-  Clean code principles
-  SOLID principles
