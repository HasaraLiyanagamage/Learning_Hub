#  Firestore Quick Start - 5 Minutes Setup

##  **Super Fast Setup Guide**

---

## **Step 1: Create Firebase Project (2 minutes)**

1. Go to: https://console.firebase.google.com/
2. Click **"Create a project"**
3. Name: `learninghub`
4. Disable Google Analytics (faster)
5. Click **"Create project"**
6. Wait 30 seconds
7. Click **"Continue"**

---

## **Step 2: Enable Firestore (1 minute)**

1. Click **"Firestore Database"** in left menu
2. Click **"Create database"**
3. Select **"Start in test mode"**
4. Click **"Next"**
5. Choose location: **us-central**
6. Click **"Enable"**
7. Wait for database creation

---

## **Step 3: Get Credentials (2 minutes)**

### **For Backend:**
1. Click  > **Project settings**
2. Click **"Service accounts"** tab
3. Click **"Generate new private key"**
4. Save as: `backend/firebase-service-account.json`

### **For Flutter:**
1. In Project settings, scroll to **"Your apps"**
2. Click Android icon **</>**
3. Package name: `com.example.learninghub`
4. Click **"Register app"**
5. Download `google-services.json`
6. Place in: `android/app/google-services.json`

---

## **Step 4: Seed Data (30 seconds)**

```bash
cd backend
node seed-firestore.js
```

**Output:**
```
 Users seeded (2 documents)
 Courses seeded (5 documents)
 Lessons seeded (5 documents)
 Quizzes seeded (3 documents)
 Quiz questions seeded (5 documents)
 Notifications seeded (2 documents)
 Enrollments seeded (1 document)
 Favorites seeded (1 document)
 Firestore Seeding Complete!
```

---

## **Step 5: Verify (30 seconds)**

1. Go to Firebase Console
2. Click **"Firestore Database"**
3. You should see 8 collections with data!

---

##  **Done! Your Firestore is Ready!**

**Total Time**: ~5 minutes

**What You Have:**
-  Firebase project created
-  Firestore database enabled
-  8 collections with sample data
-  Credentials downloaded
-  Ready to sync with your app!

---

##  **Firestore Collections Created**

| Collection | Documents | Purpose |
|------------|-----------|---------|
| `users` | 2 | User accounts (john@example.com, admin@learninghub.com) |
| `courses` | 5 | Course catalog |
| `lessons` | 5 | Lesson content |
| `quizzes` | 3 | Quiz metadata |
| `quiz_questions` | 5 | Quiz questions |
| `notifications` | 2 | Sample notifications |
| `enrollments` | 1 | Sample enrollment |
| `favorites` | 1 | Sample favorite |

---

##  **Sample Data Overview**

### **Users**
- **User**: john@example.com / user123
- **Admin**: admin@learninghub.com / admin123

### **Courses**
1. Introduction to Flutter (Beginner)
2. Advanced Dart Programming (Advanced)
3. UI/UX Design Fundamentals (Beginner)
4. Database Management with SQLite (Intermediate)
5. State Management in Flutter (Intermediate)

### **Lessons**
- 5 lessons across different courses
- Each with content, duration, and order

### **Quizzes**
- 3 quizzes with 5 questions each
- Multiple choice format
- Explanations included

---

##  **Configuration Files**

### **Backend `.env`**
```env
PORT=3000
NODE_ENV=development
FIREBASE_DATABASE_URL=https://learninghub-xxxxx.firebaseio.com
```

### **Flutter `google-services.json`**
Place in: `android/app/google-services.json`

### **Backend `firebase-service-account.json`**
Place in: `backend/firebase-service-account.json`

---

##  **Test Your Setup**

### **Test Backend Connection**
```bash
cd backend
npm run dev
# Visit: http://localhost:3000/api/courses
```

### **Test Flutter Connection**
```dart
// In your Flutter app
Future<void> testFirestore() async {
  final courses = await FirebaseFirestore.instance
      .collection('courses')
      .get();
  
  print('Courses found: ${courses.docs.length}');
}
```

---

##  **Security Rules (Development)**

Current rules allow all read/write (for development):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

** Change to production rules before deploying!**

---

##  **Next Steps**

1.  Firestore is ready
2.  Sample data loaded
3.  Credentials configured
4. ⏭ Run your Flutter app
5. ⏭ Test data synchronization
6. ⏭ Build and deploy!

---

##  **Troubleshooting**

### **Error: firebase-service-account.json not found**
- Download from Firebase Console > Project Settings > Service Accounts
- Place in `backend/` folder

### **Error: Permission denied**
- Check Firestore security rules
- Make sure test mode is enabled

### **Error: Module not found**
- Run `npm install` in backend folder
- Make sure firebase-admin is installed

---

##  **Success!**

Your Firestore database is now:
-  Created and configured
-  Populated with sample data
-  Ready for your app to use
-  Syncing with SQLite

**Your app can now work both offline (SQLite) and online (Firestore)!** 

---

##  **Full Documentation**

For detailed setup instructions, see:
- `FIREBASE_SETUP_GUIDE.md` - Complete guide with all collections and fields
- `backend/seed-firestore.js` - Seeder script source code

---

**Setup Time**: 5 minutes ⏱  
**Status**:  Ready to use  
**Next**: Run your app and test sync!
