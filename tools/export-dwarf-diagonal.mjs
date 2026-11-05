// Export only the new diagonal clip and replace its independent Blender sample fixture.
import fs from 'node:fs';
const clip=JSON.parse(fs.readFileSync('assets/animations/dwarf-diagonal-v1/clip.json','utf8'));
const literal=x=>Array.isArray(x)?'{'+x.map(literal).join(',')+'}':x&&typeof x==='object'?'{'+Object.entries(x).map(([k,v])=>'['+JSON.stringify(k)+']='+literal(v)).join(',')+'}':JSON.stringify(x);
const {golden,...runtime}=clip;
fs.writeFileSync('src/client/K0DwarfDiagonalClip.luau','-- Exported from Blender Dwarf_RightTemple_To_LeftKnee_v1. See dwarf-diagonal-v1/clip.json.\nreturn '+literal(runtime)+'\n');
const file='tests/k0-melee-blender-native.luau';let source=fs.readFileSync(file,'utf8');
const marker='{["classId"]="dwarf",["combo"]=1,["samples"]=';
const start=source.indexOf(marker);if(start<0)throw Error('Missing dwarf basic fixture');
let end=start,depth=0;
for(;end<source.length;end++){if(source[end]==='{')depth++;if(source[end]==='}'&&--depth===0){end++;break;}}
if(depth!==0)throw Error('Invalid fixture boundary');
source=source.slice(0,start)+literal({classId:'dwarf',combo:1,samples:golden})+source.slice(end);
fs.writeFileSync(file,source);
console.log('Exported diagonal clip and '+golden.length+' independently evaluated Blender samples');
