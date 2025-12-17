#  Quick Start Guide - Smart Learning Hub

##  Get Started in 3 Steps

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Run the App
```bash
flutter run
```

### Step 3: Login and Explore
Use these credentials to test:

**Admin Account:**
- Email: `admin@learninghub.com`
- Password: `admin123`

**User Account:**
- Email: `john@example.com`
- Password: `user123`

---

##  What to Test

### As a User
1. **Login** → Use john@example.com / user123
2. **Dashboard** → See your learning overview
3. **Courses** → Browse and view course details
4. **Lessons** → Read lesson content and mark complete
5. **Quizzes** → Take a quiz and see results
6. **Notes** → Create, edit, and manage notes
7. **AI Chat** → Ask the chatbot study questions
8. **Progress** → View your learning statistics
9. **Profile** → Manage your account

### As an Admin
1. **Login** → Use admin@learninghub.com / admin123
2. **Dashboard** → See platform statistics
3. **Management** → Access admin controls

---

##  Key Features to Demonstrate

### 1. Course System
- Browse 5 pre-loaded courses
- Filter by category
- Search courses
- View course details
- Enroll in courses

### 2. Quiz System
- Take "Flutter Basics Quiz" (10 questions)
- Timer counts down
- Get instant results
- See pass/fail status

### 3. Notes Feature
- Create a new note
- Add tags (comma-separated)
- Mark as favorite
- Edit and delete notes

### 4. AI Chatbot
- Ask: "What is Flutter?"
- Ask: "How do I use SQLite?"
- Ask: "Help me with quizzes"
- See conversation history

### 5. Progress Tracking
- View overall progress (65%)
- See weekly activity chart
- Check course completion

---

##  Build APK

### For Testing
```bash
flutter build apk
```

### For Release
```bash
flutter build apk --release
```

APK will be in: `build/app/outputs/flutter-apk/app-release.apk`

---

##  Troubleshooting

### Issue: Dependencies not installing
**Solution:**
```bash
flutter clean
flutter pub get
```

### Issue: App not running
**Solution:**
1. Check Flutter is installed: `flutter doctor`
2. Ensure device/emulator is connected: `flutter devices`
3. Run: `flutter run`

### Issue: Database not seeding
**Solution:**
- Delete app from device/emulator
- Run again (database seeds on first launch)

---

##  Pre-loaded Data

### Courses (5)
1. Introduction to Flutter
2. Advanced Dart Programming
3. UI/UX Design Fundamentals
4. Database Management with SQLite
5. State Management in Flutter

### Quizzes (3)
1. Flutter Basics Quiz (10 questions)
2. Dart Advanced Concepts Quiz (15 questions)
3. SQLite Database Quiz (12 questions)

### Users (3)
1. Admin (admin@learninghub.com)
2. John Doe (john@example.com)
3. Jane Smith (jane@example.com)

---

##  UI Themes

### User Theme
- **Primary Color**: Purple (#6C63FF)
- **Font**: Poppins
- **Style**: Modern and engaging

### Admin Theme
- **Primary Color**: Blue (#1E3A8A)
- **Font**: Inter
- **Style**: Professional

---

##  Important Files

### Configuration
- `pubspec.yaml` - Dependencies
- `android/app/google-services.json` - Firebase config
- `lib/core/constants/app_constants.dart` - App settings

### Entry Point
- `lib/main.dart` - App starts here

### Database
- Auto-created on first launch
- Location: App's documents directory
- Name: `learning_hub.db`

---

##  API Keys (Optional)

### To Enable Real AI Chatbot
1. Get API key from OpenAI or Google Gemini
2. Open `lib/core/constants/app_constants.dart`
3. Update:
   ```dart
   static const String openAIApiKey = 'YOUR_API_KEY_HERE';
   ```
4. Implement API call in `lib/features/chatbot/screens/chatbot_screen.dart`

---

##  Testing Checklist

- [ ] App launches successfully
- [ ] Login with user credentials
- [ ] Browse courses
- [ ] View lesson content
- [ ] Take a quiz
- [ ] Create a note
- [ ] Chat with AI bot
- [ ] View progress
- [ ] Logout
- [ ] Login with admin credentials
- [ ] View admin dashboard

---

##  Supported Platforms

-  Android
-  iOS (with minor configuration)
-  Web (needs additional setup)
-  Desktop (needs additional setup)

---

##  Need Help?

1. **Check README.md** - Comprehensive documentation
2. **Check PROJECT_SUMMARY.md** - Project overview
3. **Review code comments** - Inline documentation
4. **Run flutter doctor** - Check Flutter setup

---

##  For Submission

### Required Files
1.  Source code (entire project folder)
2.  README.md (documentation)
3.  APK file (build/app/outputs/flutter-apk/)
4.  Screenshots (take from running app)
5.  Presentation (create based on features)

### Build Final APK
```bash
flutter build apk --release
```

### Test APK
1. Copy APK to Android device
2. Install and test
3. Verify all features work

---

**Ready to Go! **

Your Smart Learning Hub app is complete and ready to run!
