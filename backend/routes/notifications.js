const express = require('express');
const router = express.Router();
const { db } = require('../config/firebase');

// Get all notifications
router.get('/', async (req, res) => {
  try {
    const snapshot = await db.collection('notifications')
      .orderBy('created_at', 'desc')
      .get();
    
    const notifications = [];
    snapshot.forEach(doc => {
      notifications.push({
        id: doc.id,
        ...doc.data()
      });
    });

    res.json({
      success: true,
      count: notifications.length,
      data: notifications
    });
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch notifications',
      message: error.message
    });
  }
});

// Get notifications for a specific user
router.get('/user/:userId', async (req, res) => {
  try {
    const snapshot = await db.collection('notifications')
      .where('user_id', '==', parseInt(req.params.userId))
      .orderBy('created_at', 'desc')
      .get();
    
    const notifications = [];
    snapshot.forEach(doc => {
      notifications.push({
        id: doc.id,
        ...doc.data()
      });
    });

    res.json({
      success: true,
      count: notifications.length,
      data: notifications
    });
  } catch (error) {
    console.error('Error fetching user notifications:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch notifications',
      message: error.message
    });
  }
});

// Create notification
router.post('/', async (req, res) => {
  try {
    const notificationData = {
      ...req.body,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    const docRef = await db.collection('notifications').add(notificationData);
    
    res.status(201).json({
      success: true,
      message: 'Notification created successfully',
      data: {
        id: docRef.id,
        ...notificationData
      }
    });
  } catch (error) {
    console.error('Error creating notification:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create notification',
      message: error.message
    });
  }
});

// Send broadcast notification to all users
router.post('/broadcast', async (req, res) => {
  try {
    const { title, message, type } = req.body;
    
    // Get all users
    const usersSnapshot = await db.collection('users').get();
    const notifications = [];
    
    // Create notification for each user
    const batch = db.batch();
    usersSnapshot.forEach(doc => {
      const notificationRef = db.collection('notifications').doc();
      batch.set(notificationRef, {
        user_id: parseInt(doc.id),
        title,
        message,
        type: type || 'announcement',
        is_read: false,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      });
      notifications.push(notificationRef.id);
    });
    
    await batch.commit();
    
    res.status(201).json({
      success: true,
      message: `Broadcast sent to ${usersSnapshot.size} users`,
      data: {
        count: notifications.length,
        notification_ids: notifications
      }
    });
  } catch (error) {
    console.error('Error sending broadcast:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to send broadcast',
      message: error.message
    });
  }
});

// Mark notification as read
router.put('/:id/read', async (req, res) => {
  try {
    await db.collection('notifications').doc(req.params.id).update({
      is_read: true,
      updated_at: new Date().toISOString()
    });
    
    res.json({
      success: true,
      message: 'Notification marked as read'
    });
  } catch (error) {
    console.error('Error updating notification:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update notification',
      message: error.message
    });
  }
});

// Delete notification
router.delete('/:id', async (req, res) => {
  try {
    await db.collection('notifications').doc(req.params.id).delete();
    
    res.json({
      success: true,
      message: 'Notification deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting notification:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete notification',
      message: error.message
    });
  }
});

module.exports = router;
