const express = require('express');
const router = express.Router();
const { db } = require('../config/firebase');

// Get all quizzes
router.get('/', async (req, res) => {
  try {
    const snapshot = await db.collection('quizzes').get();
    const quizzes = [];
    
    snapshot.forEach(doc => {
      quizzes.push({
        id: doc.id,
        ...doc.data()
      });
    });

    res.json({
      success: true,
      count: quizzes.length,
      data: quizzes
    });
  } catch (error) {
    console.error('Error fetching quizzes:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch quizzes',
      message: error.message
    });
  }
});

// Get single quiz by ID
router.get('/:id', async (req, res) => {
  try {
    const doc = await db.collection('quizzes').doc(req.params.id).get();
    
    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Quiz not found'
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
    console.error('Error fetching quiz:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch quiz',
      message: error.message
    });
  }
});

// Create new quiz
router.post('/', async (req, res) => {
  try {
    const quizData = {
      ...req.body,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    const docRef = await db.collection('quizzes').add(quizData);
    
    res.status(201).json({
      success: true,
      message: 'Quiz created successfully',
      data: {
        id: docRef.id,
        ...quizData
      }
    });
  } catch (error) {
    console.error('Error creating quiz:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create quiz',
      message: error.message
    });
  }
});

// Update quiz
router.put('/:id', async (req, res) => {
  try {
    const quizData = {
      ...req.body,
      updated_at: new Date().toISOString()
    };

    await db.collection('quizzes').doc(req.params.id).update(quizData);
    
    res.json({
      success: true,
      message: 'Quiz updated successfully',
      data: {
        id: req.params.id,
        ...quizData
      }
    });
  } catch (error) {
    console.error('Error updating quiz:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update quiz',
      message: error.message
    });
  }
});

// Delete quiz
router.delete('/:id', async (req, res) => {
  try {
    await db.collection('quizzes').doc(req.params.id).delete();
    
    res.json({
      success: true,
      message: 'Quiz deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting quiz:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete quiz',
      message: error.message
    });
  }
});

module.exports = router;
