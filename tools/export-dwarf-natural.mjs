// Export only the new diagonal clip and replace its independent Blender sample fixture.
import fs from 'node:fs';
const clip=JSON.parse(fs.readFileSync('assets/animations/dwarf-natural-v2/clip.json','utf8'));
const literal=x=>Array.isArray(x)?'{'+x.map(literal).join(',')+'}':x&&typeof x==='object'?'{'+Object.entries(x).map(([k,v])=>'['+JSON.stringify(k)+']='+literal(v)).join(',')+'}':JSON.stringify(x);
const {golden,...runtime}=clip;
runtime.r6Curves=JSON.parse(fs.readFileSync('assets/animations/dwarf-diagonal-v1/clip.json','utf8')).curves;
// The rigid R6 arm has no elbow/wrist. Lift its anticipation earlier while
// preserving the accepted contact, follow-through and hand socket curves.
const anticipation=runtime.r6Curves.right[0];anticipation[1][1]=95;
for(let i=1;i<anticipation.length-1;i++){
 const left=anticipation[i][0]-anticipation[i-1][0],right=anticipation[i+1][0]-anticipation[i][0];
 const a=(anticipation[i][1]-anticipation[i-1][1])/left,b=(anticipation[i+1][1]-anticipation[i][1])/right;
 anticipation[i][2]=a*b>0?3*(left+right)/((2*right+left)/a+(right+2*left)/b):0;
}
fs.writeFileSync('src/client/K0DwarfDiagonalClip.luau','-- Exported from Blender Dwarf_NaturalCut_v2. See dwarf-natural-v2/clip.json.\nreturn '+literal(runtime)+'\n');
const file='tests/k0-melee-blender-native.luau';let source=fs.readFileSync(file,'utf8');
const marker='{["classId"]="dwarf",["combo"]=1,["samples"]=';
const start=source.indexOf(marker);if(start<0)throw Error('Missing dwarf basic fixture');
let end=start,depth=0;
for(;end<source.length;end++){if(source[end]==='{')depth++;if(source[end]==='}'&&--depth===0){end++;break;}}
if(depth!==0)throw Error('Invalid fixture boundary');
source=source.slice(0,start)+literal({classId:'dwarf',combo:1,samples:golden})+source.slice(end);
fs.writeFileSync(file,source);
console.log('Exported diagonal clip and '+golden.length+' independently evaluated Blender samples');
