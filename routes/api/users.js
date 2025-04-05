// routes/api/users.js
const express = require('express');
const router = express.Router();
const auth = require('../../middleware/auth');
const userController = require('../../controllers/userController');

// @route   POST api/users
// @desc    Register a user (admin only)
// @access  Private
router.post('/', auth, userController.createUser);

// @route   POST api/users/login
// @desc    Login user & get token
// @access  Public
router.post('/login', userController.login);

// @route   GET api/users
// @desc    Get all users
// @access  Private (Admin only)
router.get('/', auth, userController.getUsers);

// @route   GET api/users/me
// @desc    Get current user's profile
// @access  Private
router.get('/me', auth, userController.getUserProfile);

// @route   PUT api/users/profile
// @desc    Update user profile
// @access  Private
router.put('/profile', auth, userController.updateProfile);

// @route   PUT api/users/quiz-history
// @desc    Update user quiz history
// @access  Private
router.put('/quiz-history', auth, userController.updateQuizHistory);

module.exports = router;