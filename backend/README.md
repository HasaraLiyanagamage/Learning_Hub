# Learning Hub Backend API

A RESTful API backend for the Smart Learning Hub mobile application built with Node.js, Express, and Firebase Firestore.

##  Features

-  RESTful API endpoints
-  Firebase Firestore integration
-  CRUD operations for all resources
-  Data synchronization support
-  Broadcast notifications
-  User progress tracking
-  Quiz results management
-  CORS enabled
-  Security headers (Helmet)
-  Request logging (Morgan)
-  Response compression

##  Prerequisites

- Node.js (v18 or higher)
- npm or yarn
- Firebase project with Firestore enabled
- Firebase Admin SDK service account key

##  Installation

### 1. Clone and Navigate

```bash
cd backend
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Firebase Setup

#### Option A: Using Service Account File (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** > **Service Accounts**
4. Click **Generate New Private Key**
5. Save the downloaded JSON file as `firebase-service-account.json` in the `backend` folder

#### Option B: Using Environment Variables

Set the following environment variables in your `.env` file:
```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your-client-email
FIREBASE_CLIENT_ID=your-client-id
FIREBASE_CLIENT_CERT_URL=your-cert-url
FIREBASE_DATABASE_URL=https://your-project-id.firebaseio.com
```

### 4. Environment Configuration

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```env
PORT=3000
NODE_ENV=development
FIREBASE_DATABASE_URL=https://your-project-id.firebaseio.com
```

### 5. Start the Server

**Development mode (with auto-reload):**
```bash
npm run dev
```

**Production mode:**
```bash
npm start
```

The server will start on `http://localhost:3000`

##  API Endpoints

### Health Check
```
GET /health
```

### Courses
```
GET    /api/courses              - Get all courses
GET    /api/courses/:id          - Get single course
POST   /api/courses              - Create new course
PUT    /api/courses/:id          - Update course
DELETE /api/courses/:id          - Delete course
GET    /api/courses/search/:query - Search courses
```

### Lessons
```
GET    /api/lessons              - Get all lessons (optional ?courseId=)
GET    /api/lessons/:id          - Get single lesson
POST   /api/lessons              - Create new lesson
PUT    /api/lessons/:id          - Update lesson
DELETE /api/lessons/:id          - Delete lesson
```

### Quizzes
```
GET    /api/quizzes              - Get all quizzes
GET    /api/quizzes/:id          - Get single quiz
POST   /api/quizzes              - Create new quiz
PUT    /api/quizzes/:id          - Update quiz
DELETE /api/quizzes/:id          - Delete quiz
```

### Users
```
GET    /api/users                - Get all users
GET    /api/users/:id            - Get single user
POST   /api/users                - Create new user
PUT    /api/users/:id            - Update user
DELETE /api/users/:id            - Delete user
```

### Quiz Results & Progress
```
POST   /api/quiz-results         - Submit quiz result
GET    /api/quiz-results/user/:userId - Get user's quiz results
POST   /api/user-progress/progress    - Update user progress
GET    /api/user-progress/progress/user/:userId - Get user progress
```

### Notifications
```
GET    /api/notifications        - Get all notifications
GET    /api/notifications/user/:userId - Get user notifications
POST   /api/notifications        - Create notification
POST   /api/notifications/broadcast    - Send broadcast to all users
PUT    /api/notifications/:id/read     - Mark as read
DELETE /api/notifications/:id    - Delete notification
```

##  Request/Response Examples

### Create Course
```bash
POST /api/courses
Content-Type: application/json

{
  "title": "Introduction to Flutter",
  "description": "Learn Flutter basics",
  "instructor": "John Doe",
  "duration": "10 hours",
  "level": "Beginner",
  "rating": 4.5,
  "enrolled_count": 0,
  "lessons_count": 10
}
```

**Response:**
```json
{
  "success": true,
  "message": "Course created successfully",
  "data": {
    "id": "abc123",
    "title": "Introduction to Flutter",
    "description": "Learn Flutter basics",
    "created_at": "2025-12-16T02:00:00.000Z",
    "updated_at": "2025-12-16T02:00:00.000Z"
  }
}
```

### Submit Quiz Result
```bash
POST /api/quiz-results
Content-Type: application/json

{
  "user_id": 1,
  "quiz_id": 1,
  "score": 85,
  "total_questions": 10,
  "correct_answers": 8,
  "time_taken": 300
}
```

### Send Broadcast Notification
```bash
POST /api/notifications/broadcast
Content-Type: application/json

{
  "title": "New Course Available!",
  "message": "Check out our latest Flutter course",
  "type": "announcement"
}
```

##  Firestore Collections

The API uses the following Firestore collections:

- `courses` - Course information
- `lessons` - Lesson content
- `quizzes` - Quiz metadata
- `quiz_results` - User quiz scores
- `users` - User accounts
- `user_progress` - Learning progress
- `notifications` - User notifications

##  Security

- Helmet.js for security headers
- CORS enabled for cross-origin requests
- Password fields excluded from API responses
- Input validation recommended (add express-validator)

##  Testing

Test the API using:

**cURL:**
```bash
curl http://localhost:3000/health
```

**Postman:**
Import the endpoints and test each route.

**Browser:**
Navigate to `http://localhost:3000/` for API documentation.

##  Project Structure

```
backend/
 config/
    firebase.js          # Firebase configuration
 routes/
    courses.js           # Course endpoints
    lessons.js           # Lesson endpoints
    quizzes.js           # Quiz endpoints
    users.js             # User endpoints
    progress.js          # Progress & quiz results
    notifications.js     # Notification endpoints
 .env.example             # Environment template
 .gitignore              # Git ignore rules
 package.json            # Dependencies
 server.js               # Main server file
 README.md               # This file
```

##  Deployment

### Deploy to Heroku

```bash
# Login to Heroku
heroku login

# Create app
heroku create learninghub-api

# Set environment variables
heroku config:set NODE_ENV=production
heroku config:set FIREBASE_DATABASE_URL=your-url

# Deploy
git push heroku main
```

### Deploy to Google Cloud Run

```bash
# Build container
gcloud builds submit --tag gcr.io/PROJECT-ID/learninghub-api

# Deploy
gcloud run deploy learninghub-api \
  --image gcr.io/PROJECT-ID/learninghub-api \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

##  Troubleshooting

### Firebase Connection Issues

1. Verify `firebase-service-account.json` is in the backend folder
2. Check Firebase project ID matches
3. Ensure Firestore is enabled in Firebase Console

### Port Already in Use

```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Or use a different port
PORT=8080 npm start
```

### Module Not Found

```bash
# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

##  License

MIT License

##  Support

For issues or questions:
- Create an issue in the GitHub repository
- Contact: support@learninghub.com

##  Success!

Your Learning Hub Backend API is now ready to serve your mobile app!

**Test it:**
```bash
curl http://localhost:3000/health
```

**Expected Response:**
```json
{
  "status": "OK",
  "message": "Learning Hub API is running",
  "timestamp": "2025-12-16T02:00:00.000Z",
  "version": "1.0.0"
}
```
