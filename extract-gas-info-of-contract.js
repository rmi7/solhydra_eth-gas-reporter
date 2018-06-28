const fs = require('fs');

const filepath = process.argv[2];
const contractname = process.argv[3];
const outputpath = process.argv[4];

const content = fs.readFileSync(filepath, 'utf8').split('\n');

const indexOfFirstLine = content.findIndex(line => line.startsWith('|                                     Gas'));
const indexOfFirstLineDeploy = content.findIndex(line => line.startsWith('|  Deployments'));
const startEndLine = content[indexOfFirstLine - 1];
const emptyLineBig = content[indexOfFirstLine + 1];
const emptyLine = content[indexOfFirstLine + 3];
const output = [
  startEndLine,
  content[indexOfFirstLine],
  emptyLineBig,
  content[indexOfFirstLine + 2],
  emptyLine,
  content[indexOfFirstLine + 4],
];

const linesOfContract = content.filter(line => line.startsWith(`|  ${contractname}`));

if (linesOfContract.length) {
  linesOfContract.forEach((line) => {
    if (!line.includes('%')) {
      output.push(emptyLine);
      output.push(line);
    } else {
      // it's a deploymennt line
      output.push(emptyLine);
      output.push(content[indexOfFirstLineDeploy]);
      output.push(emptyLineBig);
      output.push(line);
    }
  });
  output.push(startEndLine);

  fs.writeFileSync(outputpath, output.join('\n'));
}
