// proxy.js

const express = require('express');
const app = express();
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*'); // Allow all origins
  res.header('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type,Authorization');
  if (req.method === 'OPTIONS') return res.sendStatus(200);
  next();
});
app.use(express.json());

app.post('/openai', async (req, res) => {
  const apiKey = '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';
  try {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(req.body)
    });

    const text = await response.text();
    try {
      const data = JSON.parse(text);
      res.json(data);
    } catch (e) {
      console.error('OpenAI response was not JSON:', text);
      res.status(500).send(text);
    }
  } catch (err) {
    console.error('Proxy error:', err);
    res.status(500).send('Proxy error');
  }
});
app.listen(3000, () => console.log('Proxy running on http://localhost:3000'));