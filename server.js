const express = require('express');
const connectDB = require('./config/db');
require('dotenv').config();
const cors = require('cors'); // <-- Add this line

// Initialize express app
const app = express();

// Enable CORS for all origins (for development)
app.use(cors()); // <-- Add this line

// Connect to database
connectDB();

// Init middleware
app.use(express.json({ extended: false }));

// Define routes
app.use('/api/users', require('./routes/api/users'));
app.use('/api/quizzes', require('./routes/api/quizzes'));

// Basic route for testing
app.get('/', (req, res) => res.send('API Running'));

// Set port
const PORT = process.env.PORT || 5000;

// Start server
app.listen(PORT, () => console.log(`Server started on port ${PORT}`));