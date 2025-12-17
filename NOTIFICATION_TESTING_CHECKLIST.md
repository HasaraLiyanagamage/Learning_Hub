# 🧪 Notification System - Testing Checklist

## ⚙️ Prerequisites

### Backend Server
- [ ] Backend server running on `http://localhost:3000`
- [ ] Firebase/Firestore configured and accessible
- [ ] Check backend logs are visible

### Flutter App
- [ ] App compiled and running
- [ ] At least 2 test users in database
- [ ] Admin account available (admin@learninghub.com / admin123)

---

## 📋 Test Cases

### ✅ Test 1: Admin Broadcast Notification

**Steps:**
1. [ ] Login as admin
2. [ ] Navigate to Admin Dashboard
3. [ ] Click "Manage Notifications"
4. [ ] Click "Send Broadcast" FAB button
5. [ ] Enter Title: "Test Broadcast"
6. [ ] Enter Message: "This is a test notification"
7. [ ] Click "Send"

**Expected Results:**
- [ ] Snackbar shows "Sending broadcast..."
- [ ] Snackbar shows "Broadcast sent to X users successfully!"
- [ ] Notification appears in admin's notification list
- [ ] Shows recipient count (e.g., "5 recipients")
- [ ] Backend logs show: `POST /notifications/broadcast`

**If Failed:**
- Check backend server is running
- Check network connectivity
- Check browser console for errors
- Verify Firestore permissions

---

### ✅ Test 2: User Receives Broadcast

**Steps:**
1. [ ] Logout from admin account
2. [ ] Login as regular user (john@example.com / user123)
3. [ ] Navigate to Profile → Notifications
4. [ ] Pull down to refresh

**Expected Results:**
- [ ] "Test Broadcast" notification appears
- [ ] Notification has unread indicator (colored border + dot)
- [ ] Notification shows correct timestamp
- [ ] Local push notification was shown
- [ ] Backend logs show: `GET /notifications/user/:userId`

**If Failed:**
- Check user ID is correct
- Check backend returned notifications
- Check sync logic in NotificationsScreen
- Verify local database has the notification

---

### ✅ Test 3: Mark Notification as Read

**Steps:**
1. [ ] From notifications screen (as user)
2. [ ] Tap on "Test Broadcast" notification

**Expected Results:**
- [ ] Unread indicator disappears
- [ ] Border color changes to normal
- [ ] Dot indicator removed
- [ ] Font weight changes from bold to normal

**If Failed:**
- Check markAsRead() is being called
- Check local database update
- Verify UI refresh after marking read

---

### ✅ Test 4: Enrollment Notification

**Steps:**
1. [ ] Login as user
2. [ ] Navigate to Courses
3. [ ] Select a course you're NOT enrolled in
4. [ ] Click "Enroll Now" button
5. [ ] Wait for confirmation
6. [ ] Navigate to Notifications

**Expected Results:**
- [ ] Snackbar shows "Successfully enrolled!"
- [ ] Notification appears: "Enrolled Successfully!"
- [ ] Message includes course title
- [ ] Notification type is "course" (school icon)
- [ ] Backend logs show: `POST /notifications`

**If Failed:**
- Check enrollInCourse() passes courseTitle
- Check API call in EnrollmentService
- Verify backend received the request
- Check Firestore has the notification

---

### ✅ Test 5: Multiple Broadcasts

**Steps:**
1. [ ] Login as admin
2. [ ] Send 3 different broadcasts:
   - "Broadcast 1" / "First message"
   - "Broadcast 2" / "Second message"
   - "Broadcast 3" / "Third message"
3. [ ] Logout and login as user
4. [ ] Open Notifications

**Expected Results:**
- [ ] All 3 broadcasts appear
- [ ] Sorted by newest first
- [ ] No duplicate entries
- [ ] Each has correct title and message
- [ ] All are unread initially

**If Failed:**
- Check deduplication logic
- Verify sorting order
- Check backend returned all notifications

---

### ✅ Test 6: Cross-Device Sync

**Steps:**
1. [ ] Admin sends broadcast on Device/Browser A
2. [ ] Open app on Device/Browser B (different user)
3. [ ] Navigate to Notifications
4. [ ] Pull to refresh

**Expected Results:**
- [ ] Broadcast appears on Device B
- [ ] Data synced via Firestore
- [ ] No manual intervention needed

**If Failed:**
- Check Firestore has the notification
- Verify user ID query is correct
- Check API endpoint returns data

---

### ✅ Test 7: Offline Mode

**Steps:**
1. [ ] Ensure some notifications exist
2. [ ] Turn off WiFi/Mobile Data
3. [ ] Open Notifications screen

**Expected Results:**
- [ ] Previously synced notifications appear
- [ ] No crash or error
- [ ] Shows cached data from SQLite
- [ ] UI indicates offline state (optional)

**Steps (continued):**
5. [ ] Turn on WiFi/Data
6. [ ] Pull to refresh

**Expected Results:**
- [ ] New notifications fetched
- [ ] Synced to local database
- [ ] UI updates with new data

**If Failed:**
- Check try-catch in _loadNotifications()
- Verify local database has cached data
- Check error handling

---

### ✅ Test 8: Delete Notification

**Steps:**
1. [ ] Open Notifications screen
2. [ ] Swipe notification left
3. [ ] Confirm deletion

**Expected Results:**
- [ ] Notification removed from list
- [ ] Snackbar shows "Notification deleted"
- [ ] Deleted from local database
- [ ] Local push notification cancelled

**Note:** Currently only deletes locally, not from backend

---

### ✅ Test 9: Clear All Notifications

**Steps:**
1. [ ] Open Notifications screen with multiple notifications
2. [ ] Tap delete sweep icon (top right)
3. [ ] Confirm "Delete all notifications?"

**Expected Results:**
- [ ] All notifications removed
- [ ] Empty state shown
- [ ] All local push notifications cancelled
- [ ] Local database cleared

**Note:** Currently only clears locally, not from backend

---

### ✅ Test 10: Notification Types & Icons

**Steps:**
1. [ ] Create different notification types:
   - Broadcast (announcement)
   - Enrollment (course)
   - Achievement (course completion)
2. [ ] Check each notification

**Expected Results:**
- [ ] **Announcement**: Purple campaign icon
- [ ] **Course**: Purple school icon
- [ ] **Achievement**: Amber trophy icon
- [ ] Each has correct color scheme

---

### ✅ Test 11: Backend API Direct Test

**Using Postman/cURL:**

**Test Broadcast:**
```bash
curl -X POST http://localhost:3000/notifications/broadcast \
  -H "Content-Type: application/json" \
  -d '{
    "title": "API Test",
    "message": "Testing via API",
    "type": "announcement"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Broadcast sent to X users",
  "data": {
    "count": X,
    "notification_ids": [...]
  }
}
```

**Test Get User Notifications:**
```bash
curl http://localhost:3000/notifications/user/2
```

**Expected Response:**
```json
{
  "success": true,
  "count": X,
  "data": [...]
}
```

---

## 🐛 Common Issues & Solutions

### Issue 1: "Failed to send broadcast"
**Cause:** Backend server not running or not accessible  
**Solution:**
- Start backend: `cd backend && npm start`
- Check `http://localhost:3000/health`
- Verify firewall/network settings

### Issue 2: Notifications not appearing for users
**Cause:** Backend not creating notifications in Firestore  
**Solution:**
- Check backend logs for errors
- Verify Firestore credentials
- Check `users` collection exists
- Test API endpoint directly

### Issue 3: Duplicate notifications
**Cause:** Deduplication logic not working  
**Solution:**
- Check `where` clause in deduplication query
- Verify `created_at` timestamp format matches
- Clear local database and re-sync

### Issue 4: Push notifications not showing
**Cause:** Notification permissions not granted  
**Solution:**
- Check app notification permissions
- Verify NotificationService initialized
- Check Android/iOS notification settings

### Issue 5: Enrollment notification not sent
**Cause:** courseTitle not passed to enrollInCourse()  
**Solution:**
- Verify `courseTitle: widget.course.title` is passed
- Check EnrollmentService has courseTitle parameter
- Check API call is being made

---

## 📊 Success Criteria

### All Tests Pass When:
- [x] Admin can send broadcasts successfully
- [x] Users receive broadcasts on all devices
- [x] Enrollment notifications work
- [x] Notifications sync across devices
- [x] Offline mode works (cached data)
- [x] Push notifications appear
- [x] Mark as read works
- [x] Delete works locally
- [x] Backend API responds correctly
- [x] No crashes or errors

---

## 🎯 Performance Benchmarks

### Expected Performance:
- **Broadcast send time**: < 3 seconds for 100 users
- **Notification fetch time**: < 1 second
- **Sync to local DB**: < 500ms
- **UI refresh**: Instant (< 100ms)

### Monitor:
- Backend response times
- Database query times
- UI frame rate (should stay 60fps)
- Memory usage

---

## 📝 Test Results Template

```
Date: _______________
Tester: _______________
Device/Browser: _______________

Test 1: Admin Broadcast        [ PASS / FAIL ]
Test 2: User Receives          [ PASS / FAIL ]
Test 3: Mark as Read           [ PASS / FAIL ]
Test 4: Enrollment Notif       [ PASS / FAIL ]
Test 5: Multiple Broadcasts    [ PASS / FAIL ]
Test 6: Cross-Device Sync      [ PASS / FAIL ]
Test 7: Offline Mode           [ PASS / FAIL ]
Test 8: Delete Notification    [ PASS / FAIL ]
Test 9: Clear All              [ PASS / FAIL ]
Test 10: Notification Types    [ PASS / FAIL ]
Test 11: Backend API           [ PASS / FAIL ]

Overall Status: [ PASS / FAIL ]

Notes:
_________________________________
_________________________________
_________________________________
```

---

**Happy Testing! 🚀**

If all tests pass, the notification system is fully functional and ready for production use.
