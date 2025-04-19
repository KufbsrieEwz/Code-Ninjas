import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000/api';

export const login = (username, password) =>
  axios.post(`${API_URL}/users/login`, { username, password });

export const getUserProfile = (token) =>
  axios.get(`${API_URL}/users/me`, { headers: { 'x-auth-token': token } });

export const getQuizzes = (token) =>
  axios.get(`${API_URL}/quizzes`, { headers: { 'x-auth-token': token } });

// Add more API calls as needed...