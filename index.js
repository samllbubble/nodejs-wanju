const port = process.env.PORT || process.env.SERVER_PORT || 3000;
const { spawn } = require('child_process');
const fs = require('fs');

const startScriptPath = './start.sh';
fs.chmodSync(startScriptPath, 0o755);

const startScript = spawn(startScriptPath);
startScript.stdout.on('data', (data) => {
  console.log(`${data}`);
});
startScript.stderr.on('data', (data) => {
  console.error(`${data}`);
});
startScript.on('error', (error) => {
  console.error(`boot error: ${error}`);
  process.exit(1);
});

console.log(`server is listening on port : ${port}`);
