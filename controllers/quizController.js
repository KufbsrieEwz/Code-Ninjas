// controllers/quizController.js
const Quiz = require('../models/Quiz');

// Create a new quiz
exports.createQuiz = async (req, res) => {
  try {
    const {
      title,
      description,
      timePerQuestion,
      questions
    } = req.body;

    const newQuiz = new Quiz({
      title,
      description,
      createdBy: req.user.id, // Assuming you have authentication middleware
      timePerQuestion,
      questions
    });

    const quiz = await newQuiz.save();
    res.json(quiz);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get all quizzes
exports.getQuizzes = async (req, res) => {
  try {
    const quizzes = await Quiz.find().sort({ createdAt: -1 });
    res.json(quizzes);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get quiz by ID
exports.getQuizById = async (req, res) => {
  try {
    const quiz = await Quiz.findById(req.params.id);

    if (!quiz) {
      return res.status(404).json({ msg: 'Quiz not found' });
    }

    res.json(quiz);
  } catch (err) {
    console.error(err.message);
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ msg: 'Quiz not found' });
    }
    res.status(500).send('Server Error');
  }
};

// Update quiz
exports.updateQuiz = async (req, res) => {
  try {
    const {
      title,
      description,
      timePerQuestion,
      questions
    } = req.body;

    const quiz = await Quiz.findById(req.params.id);

    if (!quiz) {
      return res.status(404).json({ msg: 'Quiz not found' });
    }

    // Check quiz belongs to admin
    if (quiz.createdBy.toString() !== req.user.id) {
      return res.status(401).json({ msg: 'Not authorized' });
    }

    quiz.title = title || quiz.title;
    quiz.description = description || quiz.description;
    quiz.timePerQuestion = timePerQuestion || quiz.timePerQuestion;
    quiz.questions = questions || quiz.questions;

    await quiz.save();
    res.json(quiz);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Delete quiz
exports.deleteQuiz = async (req, res) => {
  try {
    const quiz = await Quiz.findById(req.params.id);

    if (!quiz) {
      return res.status(404).json({ msg: 'Quiz not found' });
    }

    // Check quiz belongs to admin
    if (quiz.createdBy.toString() !== req.user.id) {
      return res.status(401).json({ msg: 'Not authorized' });
    }

    await quiz.remove();
    res.json({ msg: 'Quiz removed' });
  } catch (err) {
    console.error(err.message);
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ msg: 'Quiz not found' });
    }
    res.status(500).send('Server Error');
  }
};

// Start a quiz session
exports.startQuizSession = async (req, res) => {
  try {
    const quiz = await Quiz.findById(req.params.id);

    if (!quiz) {
      return res.status(404).json({ msg: 'Quiz not found' });
    }

    // Create a new session
    const session = {
      startTime: Date.now(),
      participants: []
    };

    quiz.sessions.push(session);
    quiz.isActive = true;
    await quiz.save();

    res.json(quiz);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// End a quiz session
exports.endQuizSession = async (req, res) => {
  try {
    const quiz = await Quiz.findById(req.params.id);

    if (!quiz) {
      return res.status(404).json({ msg: 'Quiz not found' });
    }

    const sessionIndex = quiz.sessions.findIndex(
      session => session._id.toString() === req.params.sessionId
    );

    if (sessionIndex === -1) {
      return res.status(404).json({ msg: 'Session not found' });
    }

    quiz.sessions[sessionIndex].endTime = Date.now();
    quiz.isActive = false;
    await quiz.save();

    res.json(quiz);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Join a quiz session
exports.joinQuizSession = async (req, res) => {
  try {
    const quiz = await Quiz.findById(req.params.id);

    if (!quiz) {
      return res.status(404).json({ msg: 'Quiz not found' });
    }

    if (!quiz.isActive) {
      return res.status(400).json({ msg: 'This quiz is not currently active' });
    }

    const activeSession = quiz.sessions[quiz.sessions.length - 1];
    
    // Check if user is already a participant
    const participantIndex = activeSession.participants.findIndex(
      p => p.userId.toString() === req.user.id
    );

    if (participantIndex !== -1) {
      return res.status(400).json({ msg: 'Already joined this session' });
    }

    activeSession.participants.push({
      userId: req.user.id,
      score: 0,
      answers: []
    });

    await quiz.save();
    res.json(activeSession);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Submit answer for a question
exports.submitAnswer = async (req, res) => {
  try {
    const { answerId, timeToAnswer } = req.body;
    
    const quiz = await Quiz.findById(req.params.id);

    if (!quiz) {
      return res.status(404).json({ msg: 'Quiz not found' });
    }

    if (!quiz.isActive) {
      return res.status(400).json({ msg: 'This quiz is not currently active' });
    }

    const activeSession = quiz.sessions[quiz.sessions.length - 1];
    const questionId = req.params.questionId;
    
    // Find question in quiz
    const question = quiz.questions.find(q => q._id.toString() === questionId);
    
    if (!question) {
      return res.status(404).json({ msg: 'Question not found' });
    }
    
    // Find selected answer
    const answer = question.answers.find(a => a._id.toString() === answerId);
    
    if (!answer) {
      return res.status(404).json({ msg: 'Answer not found' });
    }
    
    // Find user in participants
    const participantIndex = activeSession.participants.findIndex(
      p => p.userId.toString() === req.user.id
    );
    
    if (participantIndex === -1) {
      return res.status(400).json({ msg: 'Not joined this quiz session' });
    }
    
    // Check if already answered this question
    const alreadyAnswered = activeSession.participants[participantIndex].answers.some(
      a => a.questionId.toString() === questionId
    );
    
    if (alreadyAnswered) {
      return res.status(400).json({ msg: 'Already answered this question' });
    }
    
    // Calculate score based on time and correctness
    const timeLimit = question.timeLimit || quiz.timePerQuestion;
    let score = 0;
    
    if (answer.isCorrect && timeToAnswer <= timeLimit) {
      // Score is higher the faster they answer (up to 1000 points)
      score = Math.round(1000 * (1 - (timeToAnswer / timeLimit)));
      if (score < 0) score = 0;
    }
    
    // Add answer to participant's list
    activeSession.participants[participantIndex].answers.push({
      questionId: question._id,
      answerId: answer._id,
      timeToAnswer,
      isCorrect: answer.isCorrect
    });
    
    // Update participant's total score
    activeSession.participants[participantIndex].score += score;
    
    await quiz.save();
    
    res.json({
      isCorrect: answer.isCorrect,
      score,
      totalScore: activeSession.participants[participantIndex].score
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get session results
exports.getSessionResults = async (req, res) => {
  try {
    const quiz = await Quiz.findById(req.params.id)
      .populate('sessions.participants.userId', 'username nickname avatarUrl');
      
    if (!quiz) {
      return res.status(404).json({ msg: 'Quiz not found' });
    }
    
    const session = quiz.sessions.find(
      s => s._id.toString() === req.params.sessionId
    );
    
    if (!session) {
      return res.status(404).json({ msg: 'Session not found' });
    }
    
    // Sort participants by score
    const results = session.participants
      .sort((a, b) => b.score - a.score)
      .map((p, index) => ({
        rank: index + 1,
        userId: p.userId,
        score: p.score,
        answeredQuestions: p.answers.length
      }));
      
    res.json(results);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};