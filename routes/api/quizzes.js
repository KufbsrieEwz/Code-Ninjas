// routes/api/quizzes.js
const express = require('express');
const router = express.Router();
const auth = require('../../middleware/auth');
const quizController = require('../../controllers/quizController');

// @route   GET api/quizzes
// @desc    Get all quizzes
// @access  Private
router.get('/', auth, quizController.getQuizzes);

// @route   GET api/quizzes/:id
// @desc    Get quiz by ID
// @access  Private
router.get('/:id', auth, quizController.getQuizById);

// @route   POST api/quizzes
// @desc    Create a quiz
// @access  Private (Admin only)
router.post('/', auth, quizController.createQuiz);

// @route   PUT api/quizzes/:id
// @desc    Update a quiz
// @access  Private (Admin only)
router.put('/:id', auth, quizController.updateQuiz);

// @route   DELETE api/quizzes/:id
// @desc    Delete a quiz
// @access  Private (Admin only)
router.delete('/:id', auth, quizController.deleteQuiz);

// @route   POST api/quizzes/:id/sessions
// @desc    Start a quiz session
// @access  Private (Admin only)
router.post('/:id/sessions', auth, quizController.startQuizSession);

// @route   POST api/quizzes/:id/sessions/:sessionId/end
// @desc    End a quiz session
// @access  Private (Admin only)
router.post('/:id/sessions/:sessionId/end', auth, quizController.endQuizSession);

// @route   POST api/quizzes/:id/join
// @desc    Join a quiz session
// @access  Private
router.post('/:id/join', auth, quizController.joinQuizSession);

// @route   POST api/quizzes/:id/questions/:questionId/answer
// @desc    Submit answer for a question
// @access  Private
router.post('/:id/questions/:questionId/answer', auth, quizController.submitAnswer);

// @route   GET api/quizzes/:id/sessions/:sessionId/results
// @desc    Get session results
// @access  Private
router.get('/:id/sessions/:sessionId/results', auth, quizController.getSessionResults);

module.exports = router;