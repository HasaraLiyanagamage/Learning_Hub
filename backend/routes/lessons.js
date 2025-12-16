const express = require('express');
const router = express.Router();
const { db } = require('../config/firebase');

// Get all lessons (with optional courseId filter)
router.get('/', async (req, res) => {
  try {
    const { courseId } = req.query;
    let query = db.collection('lessons');
    
    if (courseId) {
      query = query.where('course_id', '==', parseInt(courseId));
    }
    
    const snapshot = await query.get();
    const lessons = [];
    
    snapshot.forEach(doc => {
      lessons.push({
        id: doc.id,
        ...doc.data()
      });
    });

    res.json({
      success: true,
      count: lessons.length,
      data: lessons
    });
  } catch (error) {
    console.error('Error fetching lessons:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch lessons',
      message: error.message
    });
  }
});

// Get single lesson by ID
router.get('/:id', async (req, res) => {
  try {
    const doc = await db.collection('lessons').doc(req.params.id).get();
    
    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Lesson not found'
      });
    }

    res.json({
      success: true,
      data: {
        id: doc.id,
        ...doc.data()
      }
    });
  } catch (error) {
    console.error('Error fetching lesson:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch lesson',
      message: error.message
    });
  }
});

// Create new lesson
router.post('/', async (req, res) => {
  try {
    const lessonData = {
      ...req.body,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    const docRef = await db.collection('lessons').add(lessonData);
    
    res.status(201).json({
      success: true,
      message: 'Lesson created successfully',
      data: {
        id: docRef.id,
        ...lessonData
      }
    });
  } catch (error) {
    console.error('Error creating lesson:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create lesson',
      message: error.message
    });
  }
});

// Update lesson
router.put('/:id', async (req, res) => {
  try {
    const lessonData = {
      ...req.body,
      updated_at: new Date().toISOString()
    };

    await db.collection('lessons').doc(req.params.id).update(lessonData);
    
    res.json({
      success: true,
      message: 'Lesson updated successfully',
      data: {
        id: req.params.id,
        ...lessonData
      }
    });
  } catch (error) {
    console.error('Error updating lesson:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update lesson',
      message: error.message
    });
  }
});

// Delete lesson
router.delete('/:id', async (req, res) => {
  try {
    await db.collection('lessons').doc(req.params.id).delete();
    
    res.json({
      success: true,
      message: 'Lesson deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting lesson:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete lesson',
      message: error.message
    });
  }
});

module.exports = router;
