# 🔧 Notification Database Schema Fix

## ❌ Problems Found

### 1. Database Schema Mismatch
```
E/SQLiteLog: table notifications has no column named action_data
E/SQLiteLog: table notifications has no column named updated_at
```

**Cause:** NotificationModel has `action_data` and `updated_at` fields but database schema was missing them.

### 2. Backend 500 Error
```
Error fetching user notifications: DioException [bad response]: status code 500
```

**Cause:** Firestore query requires composite index for `user_id` + `created_at` ordering.

---

## ✅ Solutions Applied

### Fix 1: Updated Database Schema

**Files Modified:**
1. `lib/core/constants/app_constants.dart` - Bumped DB version from 6 to 7
2. `lib/services/database_helper.dart` - Added missing columns

**Changes:**

#### Before:
```sql
CREATE TABLE notifications (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL,
  is_read INTEGER DEFAULT 0,
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id)
)
```

#### After:
```sql
CREATE TABLE notifications (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL,
  is_read INTEGER DEFAULT 0,
  action_data TEXT,              -- ✅ ADDED
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,      -- ✅ ADDED
  FOREIGN KEY (user_id) REFERENCES users (id)
)
```

### Fix 2: Firestore Index (Backend)

The backend query needs a composite index in Firestore:

**Query:**
```javascript
db.collection('notifications')
  .where('user_id', '==', userId)
  .orderBy('created_at', 'desc')
```

**Required Index:**
- Collection: `notifications`
- Fields: `user_id` (Ascending), `created_at` (Descending)

---

## 🚀 How to Apply Fixes

### Step 1: Restart Flutter App

The database will automatically upgrade when you restart:

```bash
# Stop the app (Ctrl+C in terminal)
# Then restart
flutter run
```

**What happens:**
- App detects DB version changed (6 → 7)
- Drops all tables
- Recreates with new schema including `action_data` and `updated_at`
- Re-seeds data automatically

### Step 2: Create Firestore Index

#### Option A: Via Firebase Console (Recommended)

1. Open Firebase Console: https://console.firebase.google.com
2. Select your project
3. Go to **Firestore Database**
4. Click **Indexes** tab
5. Click **Create Index**
6. Configure:
   - **Collection ID:** `notifications`
   - **Fields to index:**
     - Field: `user_id`, Order: `Ascending`
     - Field: `created_at`, Order: `Descending`
   - **Query scope:** `Collection`
7. Click **Create**
8. Wait 2-5 minutes for index to build

#### Option B: Via Error Link

When you try to fetch notifications, Firestore will give you a direct link to create the index. Check backend logs for:

```
The query requires an index. You can create it here: https://console.firebase.google.com/...
```

Click that link and it will auto-configure the index for you.

#### Option C: Via Firebase CLI

Create `firestore.indexes.json`:
```json
{
  "indexes": [
    {
      "collectionGroup": "notifications",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "user_id",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "created_at",
          "order": "DESCENDING"
        }
      ]
    }
  ]
}
```

Deploy:
```bash
firebase deploy --only firestore:indexes
```

---

## 🧪 Testing

### Test 1: Database Schema Fixed

1. **Restart app:** `flutter run`
2. **Login as admin:** admin@learninghub.com / admin123
3. **Send broadcast:** Admin Dashboard → Manage Notifications → Send Broadcast
4. **Expected:** ✅ No database errors, broadcast sends successfully

### Test 2: User Notifications Work

1. **Logout**
2. **Login as user:** john@example.com / user123
3. **Go to:** Profile → Notifications
4. **Pull to refresh**
5. **Expected:** 
   - ✅ No 500 errors
   - ✅ Notifications appear
   - ✅ Can mark as read

### Test 3: Enrollment Notifications

1. **As user, go to:** Courses
2. **Select course** (not enrolled)
3. **Click:** "Enroll Now"
4. **Go to:** Notifications
5. **Expected:** ✅ "Enrolled Successfully!" notification appears

---

## 🔍 Verification

### Check Database Schema

After restarting app, verify schema in SQLite:

```bash
# Find the database file
find ~/Library/Developer/CoreSimulator -name "learning_hub.db" 2>/dev/null | head -1

# Or for Android emulator
adb shell "run-as com.example.learninghub ls /data/data/com.example.learninghub/databases/"
```

### Check Backend Logs

Monitor backend terminal for errors:
```bash
cd backend
npm start
```

Look for:
- ✅ "Broadcast sent to X users"
- ❌ "The query requires an index" (if index not created yet)

---

## 📊 What Each Fix Does

### Database Schema Update
- **action_data column:** Stores JSON data for notification actions (e.g., deep links)
- **updated_at column:** Tracks when notification was last modified
- **Version bump:** Forces database recreation with new schema

### Firestore Index
- **Enables efficient queries:** Allows filtering by user_id AND sorting by created_at
- **Prevents 500 errors:** Without index, Firestore rejects the query
- **Improves performance:** Faster notification fetching

---

## 🐛 Troubleshooting

### Issue: "Database locked" error
**Solution:** 
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Still getting "no column" error
**Solution:** 
1. Uninstall app from device/emulator
2. Run `flutter run` again
3. Database will be created fresh

### Issue: Backend still returns 500
**Solution:** 
1. Check Firestore index is created and status is "Enabled"
2. Wait 2-5 minutes after creating index
3. Restart backend server: `npm start`

### Issue: No notifications appearing
**Solution:**
1. Verify backend is running on port 3000
2. Check API base URL is `http://10.0.2.2:3000` (for Android emulator)
3. Send a test broadcast from admin panel
4. Check backend logs for errors

---

## ✅ Success Criteria

After applying both fixes:

- ✅ No "no column named action_data" errors
- ✅ No "no column named updated_at" errors
- ✅ Admin can send broadcasts successfully
- ✅ Users can fetch notifications without 500 errors
- ✅ Enrollment notifications work
- ✅ Mark as read works
- ✅ Delete notifications works

---

## 📝 Files Modified

### Flutter App
1. `lib/core/constants/app_constants.dart` - DB version 6 → 7
2. `lib/services/database_helper.dart` - Added columns to notifications table

### Backend
No code changes needed - just create Firestore index

---

## 🎯 Summary

### What Was Broken
1. Database schema missing `action_data` and `updated_at` columns
2. Firestore query failing due to missing composite index

### What's Fixed
1. ✅ Database schema updated with all required columns
2. ✅ Database version bumped to force recreation
3. ✅ Instructions provided for creating Firestore index

### Next Steps
1. **Restart Flutter app** - Database will auto-upgrade
2. **Create Firestore index** - Via Firebase Console
3. **Test notifications** - Should work end-to-end

---

**Fixed**: December 17, 2025  
**Status**: ✅ Ready to test after index creation  
**Impact**: Critical - Enables full notification functionality
