// models/User.js
const mongoose = require('mongoose');

const QuizHistorySchema = new mongoose.Schema({
  quizId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Quiz'
  },
  sessionId: {
    type: mongoose.Schema.Types.ObjectId
  },
  score: Number,
  rank: Number,
  completedAt: {
    type: Date,
    default: Date.now
  }
});

const UserSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
    unique: true
  },
  password: {
    type: String,
    required: true
  },
  role: {
    type: String,
    enum: ['admin', 'user'],
    default: 'user'
  },
  firstName: String,
  lastName: String,
  nickname: String,
  avatarUrl: String,
  createdAt: {
    type: Date,
    default: Date.now
  },
  quizHistory: [QuizHistorySchema],
  totalScore: {
    type: Number,
    default: 0
  },
  averageScore: {
    type: Number,
    default: 0
  }
});

module.exports = mongoose.model('User', UserSchema);