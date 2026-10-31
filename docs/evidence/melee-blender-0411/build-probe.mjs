// Native motion-only fixture. No Python, Rojo game build, or combat startup.
import fs from 'node:fs';
import crypto from 'node:crypto';
const out=process.argv[2]??'/private/tmp/tlt-melee-blender-qa';
fs.mkdirSync(out,{recursive:true});
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const item=(cls,name,props='',children='')=>`<Item class="${cls}"><Properties><string name="Name">${name}</string>${props}</Properties>${children}</Item>`;
const inputs={};
const assets=[['assets/shared/td-player-weapons','TDPlayerWeaponModels'],['assets/shared/td-player-weapons/shield','TDKnightShieldModels']];
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
let code=`assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,"Private empty fixture required")
local shared=Instance.new("Folder");shared.Name="Shared";shared.Parent=game.ReplicatedStorage
local server=Instance.new("Folder");server.Name="Server";server.Parent=game.ServerScriptService
local cosmetics=Instance.new("Folder");cosmetics.Name="Cosmetics";cosmetics.Parent=server
local client=Instance.new("LocalScript");client.Name="Client";client.Disabled=true;client.Parent=game.StarterPlayer.StarterPlayerScripts
`;
for(const [parent,folder,names]of [['shared','src/shared',['K0Config','AdvancedSkills']],['cosmetics','src/server/Cosmetics',['WeaponAppearance','WoodenStaffBuilder']],['client','src/client',['K0MeleeMotion','K0MeleeClips','K0SwordVisual']]])for(const name of names){
 const path=folder+'/'+name+'.luau',bytes=fs.readFileSync(path),source=bytes.toString();if(source.includes(']===]'))throw new Error('Unsafe source delimiter');inputs[path]=hash(bytes);
 code+=`do local m=Instance.new("ModuleScript");m.Name="${name}";m.Source=[===[${source}]===];m.Parent=${parent} end\n`;
}
const testPaths=['tests/k0-melee-curves-native.luau','tests/k0-melee-blender-native.luau','tests/k0-dwarf-motion-native.luau'];
for(const path of testPaths){const bytes=fs.readFileSync(path);inputs[path]=hash(bytes);code+='\n'+bytes.toString()+'\n';}
fs.writeFileSync(out+'/source-probe.luau',code);
fs.writeFileSync(out+'/source-manifest.json',JSON.stringify(inputs,null,2)+'\n');
console.log(JSON.stringify({place:out+'/tlt-k0-qa-empty.rbxlx',script:out+'/source-probe.luau',modules:7,tests:testPaths.length}));
