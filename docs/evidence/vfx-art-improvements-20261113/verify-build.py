"""커밋 원문과 실제 빌드 내 VFX 모듈15개의 일치 및 검사 집계를 검증한다."""
from pathlib import Path
import argparse,subprocess,json,xml.etree.ElementTree as ET,hashlib,re
p=argparse.ArgumentParser();p.add_argument('--source',required=True);p.add_argument('--version',required=True);p.add_argument('--native',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
root=Path(__file__).resolve().parents[3]
commit=subprocess.check_output(['git','rev-parse',a.source],cwd=root).decode().strip()
build=root/'builds'/a.version/f'TheLastThrone-{a.version}.rbxlx';nodes={}
def walk(node,path):
 for it in node.findall('Item'):
  name=it.find("Properties/string[@name='Name']");key=path+'/'+(name.text or '')
  source=it.find("Properties/*[@name='Source']")
  if source is not None:nodes[key]=source.text or ''
  walk(it,key)
walk(ET.parse(build).getroot(),'')
paths=['src/shared/CombatVFXPalette.luau','src/shared/EnemySpellProfiles.luau']
paths+=['src/client/'+name+'.luau'for name in ['SkillVFXProfiles','HeroVFX','HeroVFXSurfaces','AdvancedSkillVisual','K0HitEffects','K0MageFocus','EnemyPatternEffects','EnemySpellVFX','EnemySpellArt','SelenePresentation','CuratedVFX','PixelFX','DeepwoodNavigation']]
checked=[]
for path in paths:
 section,relative=path.split('/',2)[1:];prefix={'client':'/StarterPlayer/StarterPlayerScripts/Client','shared':'/ReplicatedStorage/Shared'}[section]
 data=subprocess.check_output(['git','show',commit+':'+path],cwd=root).decode();assert nodes.get(prefix+'/'+relative.removesuffix('.luau'))==data,path
 checked.append({'file':path,'sha256':hashlib.sha256(data.encode()).hexdigest()})
results=[]
for line in a.native.read_text().splitlines():
 if '{'not in line:continue
 row=json.loads(line[line.index('{'):]);assert not row.get('failures');assert row.get('pass',True);results.append(row)
assert len(results)==17,len(results)
record={'sourceCommit':commit,'version':a.version,'buildSha256':hashlib.sha256(build.read_bytes()).hexdigest(),'matchingProductionModules':checked,'nativeSuites':len(results),'nativeChecks':sum(r['checks']for r in results),'cpuChecks':sum(map(int,re.findall(r'CPU: (\d+) checks',Path(__file__).with_name('cpu.log').read_text()))),'navigation':'See nav.log','publishedClient':'not tested','realDevice':'not tested','userArtAcceptance':'pending'}
a.output.write_text(json.dumps(record,indent=2)+'\n');print('Matched modules:',len(checked),'native checks:',record['nativeChecks'])
