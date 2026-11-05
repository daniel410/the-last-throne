// Offline export only. Run with a pinned patch-gg/pixelfx checkout; no npm install.
import { resolve, join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { execFileSync } from 'node:child_process';
import { mkdirSync, writeFileSync, copyFileSync, readFileSync, existsSync } from 'node:fs';
import { createHash } from 'node:crypto';
const checkout=resolve(process.argv[2] ?? '/tmp/tlt-pixelfx-review-20261104');
const pin='a84159688af3ca37a4be05a0d422b94451b2e24e';
if(execFileSync('git',['-C',checkout,'rev-parse','HEAD'],{encoding:'utf8'}).trim()!==pin)throw Error('PixelFX source pin mismatch');
const {loadEffect,renderFrames}=await import(pathToFileURL(join(checkout,'tools/lib/fxlib.mjs')));
const {encodePNG}=await import(pathToFileURL(join(checkout,'tools/lib/png.mjs')));
const out=resolve('assets/effects/pixelfx-v1');mkdirSync(out,{recursive:true});
const oldManifest=join(out,'source-manifest.json');
const old=existsSync(oldManifest)?JSON.parse(readFileSync(oldManifest,'utf8')):null;
const gold=['#423019','#806036','#bb9550','#ffd785','#ffe5ac','#fff0cb','#ffffff'];
// Only effect pixels are exported. No stock actor sprites or UI are included.
// Playback windows remove long charge-up sections so existing hit timing remains authoritative.
const specs=[
 ['steel','melee/sword-slash',0,.52,{palette:gold}],
 ['shield','impacts/shield-block',0,.65,{}],
 ['axe','impacts/crit-hit',0,.65,{}],
 ['arrow','impacts/hit-spark',0,.5,{palette:['#194c30','#318f57','#68ce80','#adf6a1','#f7ffe0','#ffffff']}],
 ['gun','impacts/bullet-impact',0,.7,{}],
 ['arcane','arcane/mana-burst',.35,1.45,{}],
 ['water','water/splash',.15,1.35,{}],
 ['gravity','explosions/implosion',0,1.5,{palette:['#190e30','#372059','#6434a1','#a875e1','#ddbbff','#ffffff']}],
 ['wind','nature/tornado',.2,1.2,{}],
 ['fire','explosions/small-explosion',0,.85,{}],
 ['frost','ice/snowflake-burst',.4,1.8,{}],
 ['lightning','lightning/zap-hit',0,.65,{}],
 ['earth','impacts/ground-slam',.15,1.35,{}],
 ['bomb','explosions/small-explosion',0,1.2,{}],
 ['holy','holy/sunburst',.25,1.4,{palette:gold}],
 ['nature','nature/leaf-storm',0,1.2,{}],
 ['heal','holy/heal-aoe',.35,1.7,{palette:gold}],
 ['ward','impacts/parry',0,.7,{palette:gold}],
 ['cleanse','ice/snowflake-burst',.4,1.4,{palette:['#29445e','#527f9c','#91c4d5','#c4efff','#effcff','#ffffff']}],
 ['enemy','impacts/hit-spark',0,.5,{palette:['#49161b','#923023','#d75a30','#ff9d51','#ffe1ad','#ffffff']}],
];
const manifest={source:'https://github.com/patch-gg/pixelfx',commit:pin,license:'MIT',cell:128,columns:4,rows:4,frames:16,padding:4,samples:[]};
for(const [key,id,start,end,extra]of specs){
 const fx=await loadEffect(id),options={light:.35,...extra};
 const r=renderFrames(fx,{actor:false,options});
 const selected=Array.from({length:16},(_,i)=>r.frames[Math.min(r.n-1,Math.round((start+(end-start)*i/15)*r.fps))]);
 let x0=r.w,y0=r.h,x1=0,y1=0;
 for(const f of selected)for(let y=0;y<r.h;y++)for(let x=0;x<r.w;x++)if(f.clear[(y*r.w+x)*4+3]>8){x0=Math.min(x0,x);y0=Math.min(y0,y);x1=Math.max(x1,x);y1=Math.max(y1,y)}
 if(x1<=x0||y1<=y0)throw Error(`Empty export: ${key}`);
 const w=x1-x0+1,h=y1-y0+1,k=Math.min(120/w,120/h),dw=Math.max(1,Math.floor(w*k)),dh=Math.max(1,Math.floor(h*k));
 const atlas=new Uint8Array(512*512*4);
 selected.forEach((f,index)=>{
  const ox=(index%4)*128+Math.floor((128-dw)/2),oy=Math.floor(index/4)*128+Math.floor((128-dh)/2);
  for(let y=0;y<dh;y++)for(let x=0;x<dw;x++){
   const s=((y0+Math.min(h-1,Math.floor(y/k)))*r.w+x0+Math.min(w-1,Math.floor(x/k)))*4,d=((oy+y)*512+ox+x)*4;
   atlas.set(f.clear.subarray(s,s+4),d);
  }
 });
 const png=encodePNG(512,512,atlas);writeFileSync(join(out,`${key}.png`),png);
 const hash=createHash('sha256').update(png).digest('hex');
 const previous=old?.samples.find(s=>s.key===key&&s.sha256===hash);
 manifest.samples.push({key,source:id,sourceWindow:[start,end],options,sourceBounds:[x0,y0,w,h],file:`${key}.png`,sha256:hash,frames:16,columns:4,cell:128,robloxAssetId:previous?.robloxAssetId??null});
 console.log(`${key}: ${id} -> 512x512 RGBA, 16 frames`);
}
copyFileSync(join(checkout,'LICENSE'),join(out,'LICENSE.pixelfx.txt'));
if(old?.upload)manifest.upload=old.upload;
writeFileSync(join(out,'source-manifest.json'),JSON.stringify(manifest,null,2)+'\n');
