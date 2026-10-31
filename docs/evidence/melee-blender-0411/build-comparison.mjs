// Recreate the same private avatar comparison without executing Python.
import fs from 'node:fs';
import cp from 'node:child_process';
const out=process.argv[2]??'/private/tmp/tlt-melee-blender-comparison.rbxlx';
const item=(cls,name,children='',props='')=>`<Item class="${cls}"><Properties><string name="Name">${name}</string>${props}</Properties>${children}</Item>`;
const script=(cls,name,source,children='')=>item(cls,name,children,`<ProtectedString name="Source"><![CDATA[${source.replaceAll(']]>',']]]]><![CDATA[>')}]]></ProtectedString>`);
const pinned=p=>cp.execFileSync('git',['show','4d24560:'+p],{encoding:'utf8'});
// The earlier fixture's Lua is retained as a comparison specification.
const spec=fs.readFileSync('docs/evidence/melee-motion-0404/build-comparison.py','utf8');
const stage=spec.match(/source\(server,'Script','InspectionStage',r'''([\s\S]*?)'''\)/)?.[1];
let inspect=spec.match(/source\(scripts,'LocalScript','Inspect',r'''([\s\S]*?)'''\)/)?.[1];
if(!stage||!inspect)throw new Error('Comparison specification is missing');
inspect=inspect.replaceAll('0.40.3 / REVISED','0.40.3 / BLENDER');
let modules='';
for(const version of ['Baseline','Candidate']){
 let children='';
 for(const name of ['K0MeleeMotion','K0SwordVisual',...(version==='Candidate'?['K0MeleeClips']:[])])children+=script('ModuleScript',name,version==='Baseline'?pinned('src/client/'+name+'.luau'):fs.readFileSync('src/client/'+name+'.luau','utf8'));
 modules+=item('Folder',version,children);
}
let assets='';
for(const [dir,prefix]of[['assets/shared/td-player-weapons','WEAPON'],['assets/shared/td-player-weapons/shield','SHIELD']]){
 let xml=fs.readFileSync(dir+'/runtime.rbxmx','utf8');xml=xml.slice(xml.indexOf('<Item'),xml.lastIndexOf('</roblox>')).trim();
 const refs=new Map([...xml.matchAll(/referent="([^"]+)"/g)].map(m=>[m[1],prefix+'_'+m[1]]));
 assets+=xml.replace(/referent="([^"]+)"/g,(_,v)=>`referent="${refs.get(v)}"`).replace(/(<Ref\b[^>]*>)([^<]+)(<\/Ref>)/g,(_,a,v,b)=>a+(refs.get(v)??v)+b);
}
const shared=['K0Config','AdvancedSkills'].map(n=>script('ModuleScript',n,pinned('src/shared/'+n+'.luau'))).join('');
const cosmetics=['WeaponAppearance','WoodenStaffBuilder'].map(n=>script('ModuleScript',n,pinned('src/server/Cosmetics/'+n+'.luau'))).join('');
const xml='<roblox version="4">'+item('ServerStorage','ServerStorage',assets)+item('Players','Players','','<bool name="CharacterAutoLoads">false</bool>')+item('ReplicatedStorage','ReplicatedStorage',item('Folder','Shared',shared))+item('ServerScriptService','ServerScriptService',item('Folder','Cosmetics',cosmetics)+script('Script','InspectionStage',stage))+item('StarterPlayer','StarterPlayer',item('StarterPlayerScripts','StarterPlayerScripts',script('LocalScript','Inspect',inspect,modules)))+'</roblox>';
fs.writeFileSync(out,xml);console.log(out);
