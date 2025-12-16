const express = require('express');
const router = express.Router();
const { db, auth } = require('../config/firebase');

// Get all users
router.get('/', async (req, res) => {
  try {
    const snapshot = await db.collection('users').get();
    const users = [];
    
    snapshot.forEach(doc => {
      const userData = doc.data();
      // Don't send password in response
      delete userData.password;
      users.push({
        id: doc.id,
        ...userData
      });
    });

    res.json({
      success: true,
      count: users.length,
      data: users
    });
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch users',
      message: error.message
    });
  }
});

// Get single user by ID
router.get('/:id', async (req, res) => {
  try {
    const doc = await db.collection('users').doc(req.params.id).get();
    
    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    const userData = doc.data();
    delete userData.password;

    res.json({
      success: true,
      data: {
        id: doc.id,
        ...userData
      }
    });
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch user',
      message: error.message
    });
  }
});

// Create new user
router.post('/', async (req, res) => {
  try {
    const userData = {
      ...req.body,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    const docRef = await db.collection('users').add(userData);
    
    // Remove password from response
    delete userData.password;
    
    res.status(201).json({
      success: true,
      message: 'User created successfully',
      data: {
        id: docRef.id,
        ...userData
      }
    });
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create user',
      message: error.message
    });
  }
});

// Update user
router.put('/:id', async (req, res) => {
  try {
    const userData = {
      ...req.body,
      updated_at: new Date().toISOString()
    };

    await db.collection('users').doc(req.params.id).update(userData);
    
    delete userData.password;
    
    res.json({
      success: true,
      message: 'User updated successfully',
      data: {
        id: req.params.id,
        ...userData
      }
    });
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update user',
      message: error.message
    });
  }
});

// Delete user
router.delete('/:id', async (req, res) => {
  try {
    await db.collection('users').doc(req.params.id).delete();
    
    res.json({
      success: true,
      message: 'User deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete user',
      message: error.message
    });
  }
});

module.exports = router;
