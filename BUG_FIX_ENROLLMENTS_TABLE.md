# 🐛 Bug Fix: Enrollments Table Missing Columns

## Issue Fixed

**Error**: 
```
E/SQLiteLog: (1) table enrollments has no column named progress in 
"INSERT INTO enrollments (id, user_id, course_id, enrolled_at, completed_at, progress, status) 
VALUES (NULL, ?, ?, ?, NULL, ?, ?)"
```

**Root Cause**: The `enrollments` table schema was missing the `progress` and `status` columns, but the `EnrollmentModel` was trying to insert these fields.

---

## ✅ Fixes Applied

### **Files Modified**:

1. **`lib/services/database_helper.dart`**
   - Added `progress` column to enrollments table
   - Added `status` column to enrollments table
   - Updated database version from 4 to 5

2. **`lib/core/constants/app_constants.dart`**
   - Incremented `dbVersion` from 4 to 5

---

## 🔧 Technical Changes

### **Fix 1: Database Schema Update**

**Before** ❌:
```sql
CREATE TABLE enrollments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  course_id INTEGER NOT NULL,
  enrolled_at TEXT NOT NULL,
  completed_at TEXT,
  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (course_id) REFERENCES courses (id),
  UNIQUE(user_id, course_id)
)
```

**After** ✅:
```sql
CREATE TABLE enrollments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  course_id INTEGER NOT NULL,
  enrolled_at TEXT NOT NULL,
  completed_at TEXT,
  progress INTEGER DEFAULT 0,          -- ✅ ADDED
  status TEXT DEFAULT 'active',        -- ✅ ADDED
  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (course_id) REFERENCES courses (id),
  UNIQUE(user_id, course_id)
)
```

---

### **Fix 2: Database Version Update**

**File**: `lib/core/constants/app_constants.dart`

**Before**:
```dart
static const int dbVersion = 4;
```

**After**:
```dart
static const int dbVersion = 5;  // ✅ Incremented
```

---

### **Fix 3: Migration Handler Update**

**File**: `lib/services/database_helper.dart`

**Before**:
```dart
if (oldVersion < 4) {
  // Drop and recreate tables
}
```

**After**:
```dart
if (oldVersion < 5) {  // ✅ Updated condition
  // Drop and recreate tables
}
```

---

## 📊 Enrollments Table Schema

### **Complete Schema**:

| Column | Type | Constraints | Default | Description |
|--------|------|-------------|---------|-------------|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | - | Unique enrollment ID |
| `user_id` | INTEGER | NOT NULL, FOREIGN KEY | - | Reference to users table |
| `course_id` | INTEGER | NOT NULL, FOREIGN KEY | - | Reference to courses table |
| `enrolled_at` | TEXT | NOT NULL | - | ISO8601 timestamp of enrollment |
| `completed_at` | TEXT | NULL | NULL | ISO8601 timestamp of completion |
| `progress` | INTEGER | - | 0 | Progress percentage (0-100) |
| `status` | TEXT | - | 'active' | Enrollment status |

### **Constraints**:
- `UNIQUE(user_id, course_id)` - Prevents duplicate enrollments
- `FOREIGN KEY (user_id)` - References users table
- `FOREIGN KEY (course_id)` - References courses table

---

## 📝 EnrollmentModel Fields

### **Model Definition**:
```dart
class EnrollmentModel {
  final int? id;
  final int userId;
  final int courseId;
  final String enrolledAt;
  final String? completedAt;
  final int progress;        // ✅ Now matches DB schema
  final String status;       // ✅ Now matches DB schema
}
```

### **Status Values**:
- `'active'` - Currently enrolled and learning
- `'completed'` - Finished all course content
- `'dropped'` - User unenrolled from course

### **Progress Values**:
- Range: `0` to `100`
- Represents percentage of course completion
- Updated as user completes lessons

---

## 🔄 Database Migration Process

### **What Happens on App Restart**:

1. **App starts** → Opens database
2. **Version check**: Old version (4) < New version (5)
3. **Migration triggered**: `_upgradeDB()` called
4. **Tables dropped**: All existing tables deleted
5. **Tables recreated**: New schema with `progress` and `status` columns
6. **Migration complete**: Database now at version 5

### **Data Impact**:
⚠️ **WARNING**: This migration **drops all existing data**!

**Why?**: 
- Simplest migration strategy
- Ensures clean schema
- App is in development phase

**For Production**: Would use `ALTER TABLE` to preserve data:
```sql
ALTER TABLE enrollments ADD COLUMN progress INTEGER DEFAULT 0;
ALTER TABLE enrollments ADD COLUMN status TEXT DEFAULT 'active';
```

---

## 🧪 Testing

### **Test 1: Fresh Install**
```
1. Uninstall app completely
2. Reinstall and run
3. ✅ Database created with version 5
4. ✅ Enrollments table has progress and status columns
5. ✅ No errors on enrollment
```

### **Test 2: Upgrade from Version 4**
```
1. App already installed (version 4)
2. Hot restart or rebuild
3. ✅ Migration runs automatically
4. ✅ All tables dropped and recreated
5. ✅ Database now at version 5
6. ✅ Enrollments work without errors
```

### **Test 3: Enrollment Functionality**
```
1. Login as user
2. Browse courses
3. Click "Enroll Now"
4. ✅ Enrollment created successfully
5. ✅ progress = 0 (default)
6. ✅ status = 'active' (default)
7. ✅ No SQLite errors
```

### **Test 4: Progress Update**
```
1. Enroll in a course
2. Complete some lessons
3. ✅ Progress updates (e.g., 25%, 50%, 75%)
4. ✅ Status remains 'active'
5. Complete all lessons
6. ✅ Progress = 100
7. ✅ Status changes to 'completed'
```

---

## 🔍 How Enrollment Works Now

### **1. Enroll in Course**:
```dart
final enrollment = EnrollmentModel(
  userId: 2,
  courseId: 1,
  enrolledAt: DateTime.now().toIso8601String(),
  progress: 0,           // ✅ Default
  status: 'active',      // ✅ Default
);

await _db.insert('enrollments', enrollment.toMap());
```

**Database Entry**:
```
id: 1
user_id: 2
course_id: 1
enrolled_at: "2025-12-16T12:16:00.000Z"
completed_at: NULL
progress: 0
status: "active"
```

---

### **2. Update Progress**:
```dart
await _enrollmentService.updateEnrollmentProgress(enrollmentId, 50);
```

**Database Update**:
```
progress: 50  (was 0)
status: "active"  (unchanged)
```

---

### **3. Complete Course**:
```dart
await _enrollmentService.completeEnrollment(enrollmentId);
```

**Database Update**:
```
progress: 100
status: "completed"
completed_at: "2025-12-16T12:30:00.000Z"
```

---

## 📋 Related Services

### **EnrollmentService Methods**:

| Method | Purpose | Updates |
|--------|---------|---------|
| `enrollInCourse()` | Create enrollment | Sets progress=0, status='active' |
| `updateEnrollmentProgress()` | Update progress | Updates progress field |
| `completeEnrollment()` | Mark as complete | Sets progress=100, status='completed' |
| `unenrollFromCourse()` | Remove enrollment | Deletes record |

---

## 🎯 Result

**Status**: ✅ **FIXED**

### **Before**:
- ❌ SQLite error on enrollment
- ❌ Missing `progress` column
- ❌ Missing `status` column
- ❌ Enrollment failed silently
- ❌ No progress tracking

### **After**:
- ✅ No SQLite errors
- ✅ `progress` column added (INTEGER, default 0)
- ✅ `status` column added (TEXT, default 'active')
- ✅ Enrollments work perfectly
- ✅ Progress tracking enabled
- ✅ Status management enabled

---

## 💡 Best Practices Applied

1. **Schema-Model Alignment**: Database schema matches model definition
2. **Default Values**: Sensible defaults for new columns
3. **Version Control**: Proper database versioning
4. **Migration Strategy**: Clean migration with version check
5. **Data Types**: Appropriate types (INTEGER for progress, TEXT for status)
6. **Constraints**: Foreign keys and unique constraints maintained

---

## 🚀 Next Steps

### **To Apply This Fix**:

1. **Stop the app** completely
2. **Uninstall** from device/emulator (to clear old database)
3. **Run** `flutter clean`
4. **Run** `flutter pub get`
5. **Rebuild** and run the app
6. ✅ Database will be created with new schema
7. ✅ Enrollments will work without errors

### **Alternative (Keep Data)**:

If you want to keep existing data, manually migrate:
```dart
// In _upgradeDB method
if (oldVersion < 5) {
  await db.execute('ALTER TABLE enrollments ADD COLUMN progress INTEGER DEFAULT 0');
  await db.execute('ALTER TABLE enrollments ADD COLUMN status TEXT DEFAULT "active"');
}
```

---

## 📝 Database Versions History

| Version | Changes | Date |
|---------|---------|------|
| 1-3 | Initial schemas | Earlier |
| 4 | Previous stable version | Before |
| 5 | Added progress & status to enrollments | 2025-12-16 |

---

**Fixed**: 2025-12-16  
**Issue**: Missing columns in enrollments table  
**Solution**: Added progress and status columns, incremented DB version  
**Impact**: Requires app reinstall or database migration
