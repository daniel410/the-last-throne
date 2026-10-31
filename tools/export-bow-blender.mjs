// Convert the actual Blender MCP F-curves; this file does not author motion.
import fs from 'node:fs';
import crypto from 'node:crypto';
const raw=fs.readFileSync('assets/animations/elf-bow-v1/clip.json');
const data=JSON.parse(raw),{golden,...runtime}=data;
runtime.sourceSha256=crypto.createHash('sha256').update(raw).digest('hex');
const literal=v=>Array.isArray(v)?'{'+v.map(literal).join(',')+'}':v&&typeof v==='object'?'{'+Object.entries(v).map(([k,x])=>'['+JSON.stringify(k)+']='+literal(x)).join(',')+'}':JSON.stringify(v);
fs.writeFileSync('src/shared/ElfBowClip.luau','-- Exported from the editable Blender MCP bow source.\nreturn '+literal(runtime)+'\n');
fs.writeFileSync('tests/elf-bow-golden.luau','-- Independent Blender fcurve.evaluate samples.\nreturn '+literal(golden)+'\n');
console.log(JSON.stringify({sourceSha256:runtime.sourceSha256,samples:golden.length}));
