const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
    res.send('Hello World!');
});

app.get('/check', (res, req) => {
    const randomNumber = Math.floor(Math.random() * 100 + 1);
    res.json({ random: randomNumber });
});

app.listen(port, () => {
    console.log(`Example app listening at http://localhost:${port}`);
});

