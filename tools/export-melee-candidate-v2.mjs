// Convert the Blender MCP candidate into the existing rigid joint contract.
// This validates Blender key handles and independent evaluated samples before writing runtime data.
import fs from 'node:fs';
import crypto from 'node:crypto';
const baselinePath='assets/animations/melee-blender-v1/curves.json';
const rawPath='assets/animations/melee-blender-v1/melee-attacks-candidate-v2-raw.json';
const baseline=JSON.parse(fs.readFileSync(baselinePath));
const rawBytes=fs.readFileSync(rawPath),raw=JSON.parse(rawBytes);
if(raw.fps!==60) throw Error('Unexpected Blender frame rate');
const source=raw.actions.Knight_Forehand_Candidate_v2;
if(!source||source.classId!=='knight'||source.combo!==1||source.curves.length!==36) throw Error('Unexpected knight action');
const clip=baseline.clips.find(c=>c.classId==='knight'&&c.combo===1&&!c.skillId);
const bones={right:'RightShoulder',left:'LeftShoulder',elbow:'RightElbow',leftElbow:'LeftElbow',wrist:'RightWrist',neck:'Neck',torso:'Waist',rightHip:'RightHip',leftHip:'LeftHip',rightKnee:'RightKnee',leftKnee:'LeftKnee',weapon:'WeaponSocket'};
const axisMap=[[0,1],[2,1],[1,-1]],degrees=180/Math.PI;
const converted={},golden=source.curves[0].samples.map(([frame])=>({age:frame/raw.fps,angles:{}}));
for(const [channel,bone] of Object.entries(bones)) {
 converted[channel]=[];
 for(const [index,[axis,sign]] of axisMap.entries()) {
  const matches=source.curves.filter(c=>c.path===`pose.bones["${bone}"].rotation_euler`&&c.axis===axis);
  if(matches.length!==1) throw Error(`Missing or duplicate ${bone}/${axis}`);
  const curve=matches[0],original=clip.curves[channel][index];
  if(curve.keys.length!==original.length||curve.samples.length!==golden.length) throw Error(`Invalid key/sample count ${bone}/${axis}`);
  const keys=curve.keys.map((k,i)=>{
   const co=k.co,left=k.left,right=k.right;
   if([...co,...left,...right].some(v=>!Number.isFinite(v))||right[0]<=co[0]||left[0]>=co[0]) throw Error('Invalid handle');
   const rs=(right[1]-co[1])/(right[0]-co[0])*raw.fps*degrees*sign;
   const ls=(co[1]-left[1])/(co[0]-left[0])*raw.fps*degrees*sign;
   if(Math.abs(rs-ls)>.002) throw Error('Nonmatching tangents');
   if(i<curve.keys.length-1&&Math.abs((right[0]-co[0])/(curve.keys[i+1].co[0]-co[0])-1/3)>.00001) throw Error('Unexpected right handle');
   if(i>0&&Math.abs((co[0]-left[0])/(co[0]-curve.keys[i-1].co[0])-1/3)>.00001) throw Error('Unexpected left handle');
   let factor=1;
   if(i>0&&i<curve.keys.length-1&&axis===2&&channel==='right') factor=1.12;
   if(i>0&&i<curve.keys.length-1&&axis===2&&channel==='torso') factor=1.10;
   if(Math.abs(co[0]/raw.fps-original[i][0])>.000001||Math.abs(co[1]*degrees*sign-original[i][1]*factor)>.0001||Math.abs(rs-original[i][2]*factor)>.003) throw Error(`Baseline mismatch ${channel}/${axis}/${i}`);
   return [co[0]/raw.fps,co[1]*degrees*sign,rs];
  });
  for(const [i,[frame,value]] of curve.samples.entries()) {
   if(!Number.isFinite(frame)||!Number.isFinite(value)||Math.abs(frame/raw.fps-golden[i].age)>1e-8) throw Error('Invalid Blender sample');
   let segment=0;for(let n=0;n<keys.length-1;n++)if(frame/raw.fps>=keys[n][0])segment=n;
   const a=keys[segment],b=keys[segment+1],h=b[0]-a[0],u=Math.max(0,Math.min(1,(frame/raw.fps-a[0])/h));
   const v=(2*u**3-3*u**2+1)*a[1]+(u**3-2*u**2+u)*h*a[2]+(-2*u**3+3*u**2)*b[1]+(u**3-u**2)*h*b[2];
   if(Math.abs(v-value*degrees*sign)>.003) throw Error(`Blender sample mismatch ${channel}/${axis}/${frame}`);
   (golden[i].angles[channel]??=[])[index]=value*degrees*sign;
  }
  converted[channel].push(keys);
 }
}
clip.curves=converted;clip.golden=golden;clip.name='Knight_Forehand_Candidate_v2';
const literal=x=>Array.isArray(x)?'{'+x.map(literal).join(',')+'}':x&&typeof x==='object'?'{'+Object.entries(x).map(([k,v])=>'['+JSON.stringify(k)+']='+literal(v)).join(',')+'}':JSON.stringify(x);
const runtime={sourceSha256:crypto.createHash('sha256').update(rawBytes).digest('hex'),channels:baseline.channels,rest:baseline.rest,guard:baseline.guard,clips:{knight:[],dwarf:[]},skills:{}};
for(const c of baseline.clips){const {golden,...definition}=c;if(c.skillId)runtime.skills[c.skillId]=definition;else runtime.clips[c.classId].push(definition)}
fs.writeFileSync('src/client/K0MeleeClips.luau','-- Exported from Blender MCP candidate and unchanged baseline; do not edit curves by hand.\n-- Source: '+rawPath+' and '+baselinePath+'\nreturn '+literal(runtime)+'\n');
const testPath='tests/k0-melee-blender-native.luau';let test=fs.readFileSync(testPath,'utf8');const start=test.indexOf('local fixtures='),end=test.indexOf('\nlocal report=',start);
if(start<0||end<0)throw Error('Fixture markers missing');
const fixtures=baseline.clips.map(c=>({classId:c.classId,combo:c.combo,...(c.skillId?{skillId:c.skillId}:{}),samples:c.golden}));
fs.writeFileSync(testPath,test.slice(0,start)+'local fixtures='+literal(fixtures)+test.slice(end));
console.log(JSON.stringify({sourceSha256:runtime.sourceSha256,knightSamples:golden.length,clips:baseline.clips.length}));
