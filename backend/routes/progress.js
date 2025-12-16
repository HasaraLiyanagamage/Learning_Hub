const express = require('express');
const router = express.Router();
const { db } = require('../config/firebase');

// Submit quiz result
router.post('/', async (req, res) => {
  try {
    const resultData = {
      ...req.body,
      sync_status: 1,
      created_at: new Date().toISOString(),
      last_updated: new Date().toISOString()
    };

    const docRef = await db.collection('quiz_results').add(resultData);
    
    res.status(201).json({
      success: true,
      message: 'Quiz result submitted successfully',
      data: {
        id: docRef.id,
        ...resultData
      }
    });
  } catch (error) {
    console.error('Error submitting quiz result:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to submit quiz result',
      message: error.message
    });
  }
});

// Get quiz results for a user
router.get('/user/:userId', async (req, res) => {
  try {
    const snapshot = await db.collection('quiz_results')
      .where('user_id', '==', parseInt(req.params.userId))
      .get();
    
    const results = [];
    snapshot.forEach(doc => {
      results.push({
        id: doc.id,
        ...doc.data()
      });
    });

    res.json({
      success: true,
      count: results.length,
      data: results
    });
  } catch (error) {
    console.error('Error fetching quiz results:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch quiz results',
      message: error.message
    });
  }
});

// Submit/Update user progress
router.post('/progress', async (req, res) => {
  try {
    const progressData = {
      ...req.body,
      sync_status: 1,
      last_updated: new Date().toISOString()
    };

    const docRef = await db.collection('user_progress').add(progressData);
    
    res.status(201).json({
      success: true,
      message: 'Progress updated successfully',
      data: {
        id: docRef.id,
        ...progressData
      }
    });
  } catch (error) {
    console.error('Error updating progress:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update progress',
      message: error.message
    });
  }
});

// Get user progress
router.get('/progress/user/:userId', async (req, res) => {
  try {
    const snapshot = await db.collection('user_progress')
      .where('user_id', '==', parseInt(req.params.userId))
      .get();
    
    const progress = [];
    snapshot.forEach(doc => {
      progress.push({
        id: doc.id,
        ...doc.data()
      });
    });

    res.json({
      success: true,
      count: progress.length,
      data: progress
    });
  } catch (error) {
    console.error('Error fetching progress:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch progress',
      message: error.message
    });
  }
});

module.exports = router;
