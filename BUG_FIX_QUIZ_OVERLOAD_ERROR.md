#  Bug Fix: Quiz Model Overload Error

## Issue Fixed

**Error**: Type overload/casting error when loading quizzes in the Manage Quizzes screen.

**Symptom**: App crashes or shows error when trying to display quiz cards with duration, passing score, or total questions.

**Root Cause**: SQLite returns numeric values as `dynamic` type, which could be either `int` or `double`. The `QuizModel.fromMap()` method was directly casting these values as `int` without proper type checking, causing type cast errors.

---

##  Fix Applied

**File**: `lib/models/quiz_model.dart`

### **Updated QuizModel.fromMap() Method**

**Before** :
```dart
factory QuizModel.fromMap(Map<String, dynamic> map) {
  return QuizModel(
    id: map['id'],
    courseId: map['course_id'],
    title: map['title'],
    description: map['description'],
    duration: map['duration'],              //  Direct cast - can fail
    passingScore: map['passing_score'],     //  Direct cast - can fail
    totalQuestions: map['total_questions'], //  Direct cast - can fail
    createdAt: map['created_at'],
    updatedAt: map['updated_at'],
  );
}
```

**After** :
```dart
factory QuizModel.fromMap(Map<String, dynamic> map) {
  return QuizModel(
    id: map['id'] as int?,
    courseId: map['course_id'] as int? ?? 0,
    title: map['title'] as String? ?? '',
    description: map['description'] as String? ?? '',
    //  Safe type conversion with fallback
    duration: (map['duration'] is int) 
        ? map['duration'] as int 
        : (map['duration'] as num?)?.toInt() ?? 0,
    //  Safe type conversion with fallback
    passingScore: (map['passing_score'] is int) 
        ? map['passing_score'] as int 
        : (map['passing_score'] as num?)?.toInt() ?? 60,
    //  Safe type conversion with fallback
    totalQuestions: (map['total_questions'] is int) 
        ? map['total_questions'] as int 
        : (map['total_questions'] as num?)?.toInt() ?? 0,
    createdAt: map['created_at'] as String? ?? '',
    updatedAt: map['updated_at'] as String? ?? '',
  );
}
```

---

##  Why This Happened

### **SQLite Type System**:

SQLite has a dynamic type system:
- INTEGER columns can return `int` or `double`
- Numeric operations can produce different types
- Dart requires explicit type handling

### **The Problem**:

```dart
// SQLite might return:
map['duration'] = 20 (int)
// OR
map['duration'] = 20.0 (double)

// Direct cast fails if type doesn't match:
duration: map['duration'],  //  Fails if it's a double
```

### **The Solution**:

```dart
// Check type first, then convert safely:
duration: (map['duration'] is int) 
    ? map['duration'] as int           // Already int, use directly
    : (map['duration'] as num?)?.toInt() ?? 0,  // Convert num to int
```

---

##  Result

**Status**:  **FIXED**

### **Before**:
-  Type cast errors when loading quizzes
-  App crashes on Manage Quizzes screen
-  Overload resolution errors
-  Inconsistent behavior

### **After**:
-  Safe type conversion
-  No cast errors
-  Quizzes load successfully
-  Consistent behavior
-  Graceful fallbacks

---

##  Testing

### **Test 1: View Quizzes**
```
1. Login as admin
2. Go to Manage Quizzes
3.  Quizzes display correctly
4.  Duration shows (e.g., "20 min")
5.  Passing score shows (e.g., "60% pass")
6.  Question count shows (e.g., "0 questions")
7.  No errors
```

### **Test 2: Create Quiz**
```
1. Click + button
2. Fill in quiz details:
   - Duration: 20 minutes
   - Passing Score: 60%
   - Total Questions: 10
3. Save quiz
4.  Quiz appears in list
5.  All values display correctly
6.  No type errors
```

### **Test 3: Edit Quiz**
```
1. Click "Edit" on a quiz
2. Modify values
3. Save changes
4.  Updated values display correctly
5.  No casting errors
```

---

##  Type Safety Improvements

### **Safe Conversion Pattern**:

```dart
// For integer fields from database:
fieldName: (map['field_name'] is int) 
    ? map['field_name'] as int 
    : (map['field_name'] as num?)?.toInt() ?? defaultValue
```

**This pattern**:
1.  Checks if value is already int
2.  If not, tries to convert from num
3.  Provides fallback default value
4.  Handles null safely

---

##  Fields Fixed

| Field | Type | Default | Conversion |
|-------|------|---------|------------|
| `id` | int? | null | Direct cast with null safety |
| `courseId` | int | 0 | Direct cast with fallback |
| `title` | String | '' | Direct cast with fallback |
| `description` | String | '' | Direct cast with fallback |
| **`duration`** | **int** | **0** | **Safe num→int conversion**  |
| **`passingScore`** | **int** | **60** | **Safe num→int conversion**  |
| **`totalQuestions`** | **int** | **0** | **Safe num→int conversion**  |
| `createdAt` | String | '' | Direct cast with fallback |
| `updatedAt` | String | '' | Direct cast with fallback |

---

##  How It Works Now

### **Database → Model Flow**:

```
SQLite Query
    ↓
Returns Map<String, dynamic>
    ↓
QuizModel.fromMap(map)
    ↓
Check each field type
    ↓
Convert safely if needed
    ↓
Return QuizModel with correct types
    ↓
Display in UI without errors
```

---

##  UI Display

### **Quiz Card Shows**:
-  **Duration**: `20 min` (from `duration: 1200` seconds)
-  **Passing Score**: `60% pass` (from `passingScore: 60`)
-  **Questions**: `0 questions` (from `totalQuestions: 0`)

### **Calculation in UI**:
```dart
_buildInfoChip(Icons.timer, '${quiz.duration ~/ 60} min')
// quiz.duration is now guaranteed to be int
// ~/ operator works correctly
```

---

##  Best Practices Applied

### **1. Type Safety**
```dart
// Always check type before casting
(map['field'] is int) ? ... : ...
```

### **2. Null Safety**
```dart
// Use null-aware operators
map['field'] as int? ?? defaultValue
```

### **3. Fallback Values**
```dart
// Provide sensible defaults
duration: ... ?? 0
passingScore: ... ?? 60
```

### **4. Defensive Programming**
```dart
// Handle all possible type scenarios
(map['field'] as num?)?.toInt() ?? 0
```

---

##  Related Models

This same pattern should be applied to other models with numeric fields:

### **Already Safe**:
-  `QuizQuestionModel` - has proper defaults
-  `QuizResultModel` - uses proper conversions

### **May Need Review**:
- `CourseModel` - check numeric fields
- `LessonModel` - check numeric fields
- `UserModel` - check numeric fields

---

##  Type Conversion Examples

### **Example 1: Integer Field**
```dart
// Database value could be: 20, 20.0, or null
duration: (map['duration'] is int) 
    ? map['duration'] as int      // Use if already int
    : (map['duration'] as num?)?.toInt() ?? 0  // Convert or default
```

### **Example 2: Boolean Field**
```dart
// SQLite stores as 0 or 1
passed: map['passed'] == 1  // Convert to bool
```

### **Example 3: String Field**
```dart
// Simple with fallback
title: map['title'] as String? ?? ''
```

---

##  Impact

### **User Experience**:
-  No crashes when viewing quizzes
-  Smooth navigation
-  Reliable data display

### **Developer Experience**:
-  Clear error handling
-  Type-safe code
-  Predictable behavior
-  Easy to debug

### **Code Quality**:
-  Robust type conversions
-  Null safety
-  Defensive programming
-  Maintainable code

---

##  Integration

This fix integrates with:

1. **Manage Quizzes Screen**
   - Displays quiz cards
   - Shows duration, passing score, questions

2. **Add/Edit Quiz Screen**
   - Creates/updates quizzes
   - Saves numeric values

3. **Quiz Detail Screen**
   - Shows quiz information
   - Uses quiz model data

4. **Take Quiz Screen**
   - Uses duration for timer
   - Uses passing score for grading

---

**Fixed**: 2025-12-16  
**Issue**: Type overload/casting error in QuizModel  
**Root Cause**: SQLite returning dynamic numeric types  
**Solution**: Safe type conversion with fallbacks  
**Impact**: Quizzes now load without type errors
