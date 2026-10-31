// Materialize only the pinned Git input, checking each LFS object's bytes.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {execFileSync,spawnSync} from 'node:child_process';
const commit='6a2ed6c6f307278527c5bdadaf82ef0a9ee23e96',version='0.42.2';
const repo=process.cwd(),evidence='docs/evidence/elf-bow-refinement';
const git=(...args)=>execFileSync('git',args,{maxBuffer:32*1024*1024});
const hash=data=>crypto.createHash('sha256').update(data).digest('hex');
if(git('show',commit+':VERSION').toString().trim()!==version)throw Error('Pinned version mismatch');
const projects=['default.project.json','battle.project.json'];
const inputs=new Set(['src','VERSION',...projects]);
function collect(v){if(v&&typeof v==='object'){if(v.$path&&!v.$path.startsWith('src/'))inputs.add(v.$path);for(const item of Object.values(v))collect(item);}}
for(const project of projects)collect(JSON.parse(git('show',commit+':'+project)));
const files=git('ls-tree','-r','--name-only',commit,'--',...inputs).toString().trim().split('\n');
const stage=fs.mkdtempSync('/private/tmp/tlt-0422-pinned-'),materialized=[];
for(const file of files){
 let data=git('show',commit+':'+file);
 if(data.toString().startsWith('version https://git-lfs.github.com/spec/v1\n')){
  const pointer=data.toString(),oid=pointer.match(/oid sha256:(\w+)/)[1],size=Number(pointer.match(/size (\d+)/)[1]);
  data=fs.readFileSync(file);if(hash(data)!==oid||data.length!==size)throw Error('Pinned LFS mismatch: '+file);
  materialized.push(file);
 }
 const target=path.join(stage,file);fs.mkdirSync(path.dirname(target),{recursive:true});fs.writeFileSync(target,data);
}
const output=path.join(repo,'builds',version);fs.mkdirSync(output,{recursive:false});
const report={version,source_commit:commit,tool:execFileSync('rojo',['--version']).toString().trim(),stage,lfs_materialized:materialized,artifacts:[],published:false,release_tag:null};
try{
 for(const [i,role] of ['Lobby','Battle'].entries()){
  const target=path.join(output,`TheLastThrone-${role}-${version}.rbxlx`);
  const command=['build',projects[i],'--output',target];const result=spawnSync('rojo',command,{cwd:stage,encoding:'utf8'});
  fs.writeFileSync(evidence+'/'+role.toLowerCase()+'-build.log',result.stdout+result.stderr);
  if(result.status!==0)throw Error(result.stderr);
  const data=fs.readFileSync(target);report.artifacts.push({role,path:path.relative(repo,target),bytes:data.length,sha256:hash(data),command:['rojo',...command],result:'success'});
 }
 report.status='local-build-success-unpublished';
}finally{report.status??='failed';fs.writeFileSync(evidence+'/build.json',JSON.stringify(report,null,2)+'\n');}
console.log(JSON.stringify(report,null,2));
