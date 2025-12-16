const express = require('express');
const router = express.Router();
const { db } = require('../config/firebase');

// Get all courses
router.get('/', async (req, res) => {
  try {
    const snapshot = await db.collection('courses').get();
    const courses = [];
    
    snapshot.forEach(doc => {
      courses.push({
        id: doc.id,
        ...doc.data()
      });
    });

    res.json({
      success: true,
      count: courses.length,
      data: courses
    });
  } catch (error) {
    console.error('Error fetching courses:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch courses',
      message: error.message
    });
  }
});

// Get single course by ID
router.get('/:id', async (req, res) => {
  try {
    const doc = await db.collection('courses').doc(req.params.id).get();
    
    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Course not found'
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
    console.error('Error fetching course:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch course',
      message: error.message
    });
  }
});

// Create new course
router.post('/', async (req, res) => {
  try {
    const courseData = {
      ...req.body,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    const docRef = await db.collection('courses').add(courseData);
    
    res.status(201).json({
      success: true,
      message: 'Course created successfully',
      data: {
        id: docRef.id,
        ...courseData
      }
    });
  } catch (error) {
    console.error('Error creating course:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create course',
      message: error.message
    });
  }
});

// Update course
router.put('/:id', async (req, res) => {
  try {
    const courseData = {
      ...req.body,
      updated_at: new Date().toISOString()
    };

    await db.collection('courses').doc(req.params.id).update(courseData);
    
    res.json({
      success: true,
      message: 'Course updated successfully',
      data: {
        id: req.params.id,
        ...courseData
      }
    });
  } catch (error) {
    console.error('Error updating course:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update course',
      message: error.message
    });
  }
});

// Delete course
router.delete('/:id', async (req, res) => {
  try {
    await db.collection('courses').doc(req.params.id).delete();
    
    res.json({
      success: true,
      message: 'Course deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting course:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete course',
      message: error.message
    });
  }
});

// Search courses
router.get('/search/:query', async (req, res) => {
  try {
    const query = req.params.query.toLowerCase();
    const snapshot = await db.collection('courses').get();
    const courses = [];
    
    snapshot.forEach(doc => {
      const data = doc.data();
      if (data.title?.toLowerCase().includes(query) || 
          data.description?.toLowerCase().includes(query)) {
        courses.push({
          id: doc.id,
          ...data
        });
      }
    });

    res.json({
      success: true,
      count: courses.length,
      data: courses
    });
  } catch (error) {
    console.error('Error searching courses:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to search courses',
      message: error.message
    });
  }
});

module.exports = router;
