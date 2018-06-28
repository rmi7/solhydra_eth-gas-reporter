const fs = require('fs');

const filepath = process.argv[2];

const content = fs.readFileSync(filepath, 'utf8');

const contractNames = content
  .split('\n')
  .map(s => s.trim())
  .filter(s => s.startsWith('contract'))
  .map(s => s.match(/contract ([a-zA-z0-9_]+)/)[1]);

// last contract is the one deployed
console.log(contractNames.pop());
