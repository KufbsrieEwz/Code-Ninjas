// controllers/userController.js
const User = require('../models/user');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
require('dotenv').config();

// Create a new user (admin only)
exports.createUser = async (req, res) => {
  try {
    const { username, password, firstName, lastName, role } = req.body;

    // Check if user already exists
    let user = await User.findOne({ username });
    if (user) {
      return res.status(400).json({ msg: 'User already exists' });
    }

    // Create the user
    user = new User({
      username,
      password,
      firstName,
      lastName,
      role: role || 'user',
      nickname: firstName
    });

    // Hash the password
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(password, salt);

    await user.save();

    // Return user without password
    const userResponse = {
      _id: user._id,
      username: user.username,
      firstName: user.firstName,
      lastName: user.lastName,
      role: user.role,
      nickname: user.nickname
    };

    res.json(userResponse);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// User login
exports.login = async (req, res) => {
  try {
    const { username, password } = req.body;

    // Check if user exists
    let user = await User.findOne({ username });
    if (!user) {
      return res.status(400).json({ msg: 'Invalid credentials' });
    }

    // Verify password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: 'Invalid credentials' });
    }

    // Create JWT payload
    const payload = {
      user: {
        id: user._id,
        role: user.role
      }
    };

    // Sign and return JWT
    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: '12h' },
      (err, token) => {
        if (err) throw err;
        res.json({ token });
      }
    );
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get all users (admin only)
exports.getUsers = async (req, res) => {
  try {
    // Check if requesting user is admin
    if (req.user.role !== 'admin') {
      return res.status(403).json({ msg: 'Not authorized' });
    }

    const users = await User.find()
      .select('-password')
      .sort({ createdAt: -1 });
    res.json(users);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get user profile
exports.getUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    
    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }
    
    res.json(user);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Update user profile
exports.updateProfile = async (req, res) => {
  try {
    const { nickname, avatarUrl } = req.body;
    
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }
    
    // Update fields
    if (nickname) user.nickname = nickname;
    if (avatarUrl) user.avatarUrl = avatarUrl;
    
    await user.save();
    
    // Return updated user without password
    const updatedUser = await User.findById(req.user.id).select('-password');
    res.json(updatedUser);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Update user quiz history
exports.updateQuizHistory = async (req, res) => {
  try {
    const { quizId, sessionId, score, rank } = req.body;
    
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }
    
    // Add to quiz history
    user.quizHistory.push({
      quizId,
      sessionId,
      score,
      rank,
      completedAt: Date.now()
    });
    
    // Update total and average scores
    const totalScores = user.quizHistory.reduce((sum, quiz) => sum + quiz.score, 0);
    user.totalScore = totalScores;
    user.averageScore = totalScores / user.quizHistory.length;
    
    await user.save();
    
    res.json({
      quizHistory: user.quizHistory,
      totalScore: user.totalScore,
      averageScore: user.averageScore
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};