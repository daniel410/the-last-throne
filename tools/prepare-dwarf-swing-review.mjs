// Native motion-only fixture. No Python, Rojo game build, or combat startup.
import fs from 'node:fs';
import crypto from 'node:crypto';
import {execFileSync} from 'node:child_process';
const baseline=process.env.TLT_SWING_BASELINE;
const out=process.argv[2]??'/private/tmp/tlt-melee-blender-qa';
fs.mkdirSync(out,{recursive:true});
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const item=(cls,name,props='',children='')=>`<Item class="${cls}"><Properties><string name="Name">${name}</string>${props}</Properties>${children}</Item>`;
const inputs={};
const assets=[['assets/shared/td-refined-player-weapons','TDRefinedPlayerWeaponModels'],['assets/shared/td-player-weapons','TDPlayerWeaponModels'],['assets/shared/td-player-weapons/shield','TDKnightShieldModels']];
let models='';
for(const [folder,name] of assets){
 const manifest=JSON.parse(fs.readFileSync(folder+'/manifest.json','utf8'));
 const path=folder+'/runtime.rbxmx',bytes=fs.readFileSync(path);
 if(hash(bytes)!==manifest.files.runtime.sha256)throw new Error('Asset provenance mismatch: '+path);
 let xml=bytes.toString();
 if(/class="(?:Script|LocalScript|ModuleScript)"/.test(xml))throw new Error('Executable asset fixture rejected');
 xml=xml.slice(xml.indexOf('<Item'),xml.lastIndexOf('</roblox>')).trim();
 const refs=new Map([...xml.matchAll(/referent="([^"]+)"/g)].map(m=>[m[1],name+'_'+m[1]]));
 xml=xml.replace(/referent="([^"]+)"/g,(_,v)=>`referent="${refs.get(v)}"`).replace(/(<Ref\b[^>]*>)([^<]+)(<\/Ref>)/g,(_,a,v,b)=>a+(refs.get(v)??v)+b);
 models+=xml;inputs[path]=hash(bytes);inputs[folder+'/manifest.json']=hash(fs.readFileSync(folder+'/manifest.json'));
}
fs.writeFileSync(out+'/tlt-k0-qa-empty.rbxlx','<roblox version="4">'+item('Players','Players','<bool name="CharacterAutoLoads">false</bool>')+item('ServerStorage','ServerStorage','',models)+'</roblox>');
const escape=s=>s.replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;');
const groups={};
for(const [parent,folder] of [['shared','src/shared'],['cosmetics','src/server/Cosmetics'],['client','src/client']]){
 groups[parent]='';
 for(const file of fs.readdirSync(folder).filter(n=>n.endsWith('.luau')&&!n.includes('.client.')&&!n.includes('.server.'))){
  const path=folder+'/'+file,bytes=baseline && ['K0DwarfDiagonalClip.luau','K0MeleeMotion.luau'].includes(file)?execFileSync('git',['show',baseline+':'+path]):fs.readFileSync(path);inputs[path]=hash(bytes);
  groups[parent]+=item('ModuleScript',file.slice(0,-5),'<ProtectedString name="Source">'+escape(bytes.toString())+'</ProtectedString>');
 }
}
fs.writeFileSync(out+'/tlt-k0-qa-empty.rbxlx','<roblox version="4">'+item('Players','Players','<bool name="CharacterAutoLoads">false</bool>')+item('ServerStorage','ServerStorage','',models)+item('ReplicatedStorage','ReplicatedStorage','',item('Folder','Shared','',groups.shared))+item('ServerScriptService','ServerScriptService','',item('Folder','Server','',item('Folder','Cosmetics','',groups.cosmetics)))+item('StarterPlayer','StarterPlayer','',item('StarterPlayerScripts','StarterPlayerScripts','',item('LocalScript','Client','<bool name="Disabled">true</bool>',groups.client)))+'</roblox>');
let code='assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,"Private empty fixture required")\n';
const testPaths=process.argv.slice(3);
for(const path of testPaths){const bytes=fs.readFileSync(path);inputs[path]=hash(bytes);code+='\n'+bytes.toString()+'\n';}
fs.writeFileSync(out+'/source-probe.luau',code);
fs.writeFileSync(out+'/source-manifest.json',JSON.stringify(inputs,null,2)+'\n');
console.log(out);
