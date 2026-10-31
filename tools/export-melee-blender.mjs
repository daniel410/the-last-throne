// Convert Blender MCP's evaluated F-curves into Roblox presentation data.
// Blender remains the editable source; this script does not author motion.
import fs from 'node:fs';
import crypto from 'node:crypto';
const path='assets/animations/melee-blender-v1/curves.json';
const raw=fs.readFileSync(path),data=JSON.parse(raw);
const literal=x=>Array.isArray(x)?'{'+x.map(literal).join(',')+'}':x&&typeof x==='object'?'{'+Object.entries(x).map(([k,v])=>'['+JSON.stringify(k)+']='+literal(v)).join(',')+'}':JSON.stringify(x);
const runtime={sourceSha256:crypto.createHash('sha256').update(raw).digest('hex'),channels:data.channels,rest:data.rest,guard:data.guard,clips:{knight:[],dwarf:[]},skills:{}};
for(const clip of data.clips){
 for(const axes of Object.values(clip.curves))for(const keys of axes){
  if(keys.length<2||keys.some((k,i)=>k.length!==3||k.some(v=>!Number.isFinite(v))||(i&&k[0]<=keys[i-1][0])))throw new Error('Invalid Blender keys');
 }
 const {golden,...definition}=clip;
 if(clip.skillId) runtime.skills[clip.skillId]=definition;
 else runtime.clips[clip.classId].push(definition);
}
fs.writeFileSync('src/client/K0MeleeClips.luau','-- Exported from Blender Armature F-curves through MCP; edit the .blend source.\n-- Source: assets/animations/melee-blender-v1/curves.json\nreturn '+literal(runtime)+'\n');
// The fixture contains fcurve.evaluate results, independently of the exported
// handle-to-Hermite conversion used by the runtime.
const testPath='tests/k0-melee-blender-native.luau';
let test=fs.readFileSync(testPath,'utf8');
const start=test.indexOf('local fixtures='),end=test.indexOf('\nlocal report=',start);
if(start<0||end<0)throw new Error('Blender native fixture markers are missing');
const fixtures=data.clips.map(c=>({classId:c.classId,combo:c.combo,...(c.skillId?{skillId:c.skillId}:{}),samples:c.golden}));
test=test.slice(0,start)+'local fixtures='+literal(fixtures)+test.slice(end);
fs.writeFileSync(testPath,test);
console.log(JSON.stringify({clips:data.clips.length,sourceSha256:runtime.sourceSha256}));
