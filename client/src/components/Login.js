import React, { useState } from 'react';
import { login } from '../api/api';

function Login({ onLogin }) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const res = await login(username, password);
      const token = res.data.token;
      // Decode JWT to get role (or fetch profile after login)
      // For simplicity, fetch profile:
      const profileRes = await fetch('/api/users/me', { headers: { 'x-auth-token': token } });
      const profile = await profileRes.json();
      onLogin(token, profile.role);
    } catch (err) {
      setError('Invalid credentials', err);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <h2>Login</h2>
      {error && <div style={{color: 'red'}}>{error}</div>}
      <input value={username} onChange={e => setUsername(e.target.value)} placeholder="Username" required />
      <input type="password" value={password} onChange={e => setPassword(e.target.value)} placeholder="Password" required />
      <button type="submit">Login</button>
    </form>
  );
}

export default Login;