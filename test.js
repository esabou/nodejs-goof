const express = require('express');
const router = express.Router();

// Vulnerable to Reflected XSS
// Example: /xss?input=<script>alert('xss')</script>
router.get('/xss', (req, res) => {
  const userInput = req.query.input || 'No input provided';
  res.send(`<h1>Search Results</h1><p>You searched for: ${userInput}</p>`);
});

module.exports = router;
