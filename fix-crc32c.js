const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, 'node_modules/@google-cloud/storage/build/cjs/src/crc32c.d.ts');
let content = fs.readFileSync(filePath, 'utf-8');

content = content.replace(/Int32Array<ArrayBuffer>/g, 'Int32Array');

fs.writeFileSync(filePath, content);

console.log('Fixed crc32c.d.ts type issues');
