// test/db-test.js

const mongoose = require('mongoose');
const connectDB = require('../config/db');
const User = require('../models/user');
const Quiz = require('../models/quiz');
const bcrypt = require('bcryptjs');

const runTest = async () => {
  console.log('Starting database test...');
  
  // Connect to database
  await connectDB();
  console.log('✅ Database connected');
  
  try {
    // Clear existing test data
    console.log('Cleaning up test data...');
    await User.deleteMany({ username: { $in: ['testadmin', 'testuser'] } });
    await Quiz.deleteMany({ title: { $regex: /^Test Quiz/ } });
    
    // Create test admin user
    console.log('Creating test admin user...');
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash('password123', salt);
    
    const admin = new User({
      username: 'testadmin',
      password: hashedPassword,
      firstName: 'Test',
      lastName: 'Admin',
      role: 'admin',
      nickname: 'TestAdmin'
    });
    
    await admin.save();
    console.log(`✅ Admin user created with ID: ${admin._id}`);
    
    // Create test regular user
    console.log('Creating test regular user...');
    const user = new User({
      username: 'testuser',
      password: hashedPassword,
      firstName: 'Test',
      lastName: 'User',
      role: 'user',
      nickname: 'TestUser'
    });
    
    await user.save();
    console.log(`✅ Regular user created with ID: ${user._id}`);
    
    // Create test quiz
    console.log('Creating test quiz...');
    const quiz = new Quiz({
      title: 'Test Quiz 1',
      description: 'A test quiz with sample questions',
      createdBy: admin._id,
      timePerQuestion: 20,
      questions: [
        {
          questionText: 'What is 2+2?',
          mediaType: 'none',
          answers: [
            { answerText: '3', isCorrect: false },
            { answerText: '4', isCorrect: true },
            { answerText: '5', isCorrect: false },
            { answerText: '22', isCorrect: false }
          ]
        },
        {
          questionText: 'Who created JavaScript?',
          mediaType: 'none',
          answers: [
            { answerText: 'Bill Gates', isCorrect: false },
            { answerText: 'Steve Jobs', isCorrect: false },
            { answerText: 'Brendan Eich', isCorrect: true },
            { answerText: 'Tim Berners-Lee', isCorrect: false }
          ]
        }
      ]
    });
    
    await quiz.save();
    console.log(`✅ Quiz created with ID: ${quiz._id}`);
    
    // Start a quiz session
    console.log('Starting quiz session...');
    quiz.isActive = true;
    quiz.sessions.push({
      startTime: new Date(),
      participants: []
    });
    
    await quiz.save();
    const sessionId = quiz.sessions[0]._id;
    console.log(`✅ Quiz session started with ID: ${sessionId}`);
    
    // Add user as participant
    console.log('Adding user as participant...');
    const session = quiz.sessions[0];
    session.participants.push({
      userId: user._id,
      score: 0,
      answers: []
    });
    
    await quiz.save();
    console.log('✅ User added as participant');
    
    // Simulate user answering questions
    console.log('Simulating user answering questions...');
    
    // Answer first question (correctly)
    const correctAnswer = quiz.questions[0].answers.find(a => a.isCorrect);
    session.participants[0].answers.push({
      questionId: quiz.questions[0]._id,
      answerId: correctAnswer._id,
      timeToAnswer: 5, // 5 seconds to answer
      isCorrect: true
    });
    
    // Calculate score (faster = more points, max 1000)
    const timeLimit = quiz.timePerQuestion;
    const timeToAnswer = 5;
    const score = Math.round(1000 * (1 - (timeToAnswer / timeLimit)));
    session.participants[0].score += score;
    
    await quiz.save();
    console.log(`✅ User answered question 1 correctly, score: ${score}`);
    
    // Answer second question (incorrectly)
    const incorrectAnswer = quiz.questions[1].answers.find(a => !a.isCorrect);
    session.participants[0].answers.push({
      questionId: quiz.questions[1]._id,
      answerId: incorrectAnswer._id,
      timeToAnswer: 10, // 10 seconds to answer
      isCorrect: false
    });
    
    await quiz.save();
    console.log('✅ User answered question 2 incorrectly, no points added');
    
    // End quiz session
    console.log('Ending quiz session...');
    session.endTime = new Date();
    quiz.isActive = false;
    await quiz.save();
    console.log('✅ Quiz session ended');
    
    // Update user's quiz history
    console.log("Updating user's quiz history...");
    user.quizHistory.push({
      quizId: quiz._id,
      sessionId: session._id,
      score: session.participants[0].score,
      rank: 1, // Only participant, so rank 1
      completedAt: new Date()
    });
    
    user.totalScore = session.participants[0].score;
    user.averageScore = session.participants[0].score; // First quiz, so average = total
    
    await user.save();
    console.log("✅ User's quiz history updated");
    
    // Fetch and verify data
    console.log('\nVerifying data...');
    
    // Verify quiz with populated user data
    const verifyQuiz = await Quiz.findById(quiz._id)
      .populate('createdBy', 'username role')
      .populate('sessions.participants.userId', 'username nickname');
      
    console.log('\nQuiz verification:');
    console.log(`Title: ${verifyQuiz.title}`);
    console.log(`Created by: ${verifyQuiz.createdBy.username} (${verifyQuiz.createdBy.role})`);
    console.log(`Questions: ${verifyQuiz.questions.length}`);
    console.log(`Active: ${verifyQuiz.isActive}`);
    console.log(`Sessions: ${verifyQuiz.sessions.length}`);
    
    const verifySession = verifyQuiz.sessions[0];
    console.log('\nSession verification:');
    console.log(`Start time: ${verifySession.startTime}`);
    console.log(`End time: ${verifySession.endTime}`);
    console.log(`Participants: ${verifySession.participants.length}`);
    
    const verifyParticipant = verifySession.participants[0];
    console.log('\nParticipant verification:');
    console.log(`Username: ${verifyParticipant.userId.username}`);
    console.log(`Nickname: ${verifyParticipant.userId.nickname}`);
    console.log(`Score: ${verifyParticipant.score}`);
    console.log(`Answers: ${verifyParticipant.answers.length}`);
    
    // Verify user quiz history
    const verifyUser = await User.findById(user._id);
    console.log('\nUser verification:');
    console.log(`Username: ${verifyUser.username}`);
    console.log(`Quiz history entries: ${verifyUser.quizHistory.length}`);
    console.log(`Total score: ${verifyUser.totalScore}`);
    console.log(`Average score: ${verifyUser.averageScore}`);
    
    console.log('\n✅ All tests completed successfully!');
    
  } catch (err) {
    console.error('❌ Test failed with error:', err);
  } finally {
    // Disconnect from MongoDB
    await mongoose.disconnect();
    console.log('Database disconnected');
  }
};

// Run the test
runTest();