// models/Quiz.js
const mongoose = require('mongoose');

const AnswerSchema = new mongoose.Schema({
  answerText: {
    type: String,
    required: true
  },
  isCorrect: {
    type: Boolean,
    required: true
  }
});

const QuestionSchema = new mongoose.Schema({
  questionText: {
    type: String,
    required: true
  },
  mediaType: {
    type: String,
    enum: ['none', 'image', 'youtube'],
    default: 'none'
  },
  mediaUrl: String,
  timeLimit: Number,
  answers: [AnswerSchema]
});

const ParticipantAnswerSchema = new mongoose.Schema({
  questionId: mongoose.Schema.Types.ObjectId,
  answerId: mongoose.Schema.Types.ObjectId,
  timeToAnswer: Number,
  isCorrect: Boolean
});

const ParticipantSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  score: {
    type: Number,
    default: 0
  },
  answers: [ParticipantAnswerSchema]
});

const SessionSchema = new mongoose.Schema({
  startTime: {
    type: Date,
    default: Date.now
  },
  endTime: Date,
  participants: [ParticipantSchema]
});

const QuizSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  description: String,
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  timePerQuestion: {
    type: Number,
    default: 30  // Default of 30 seconds per question
  },
  questions: [QuestionSchema],
  isActive: {
    type: Boolean,
    default: false
  },
  sessions: [SessionSchema]
});

module.exports = mongoose.model('Quiz', QuizSchema);