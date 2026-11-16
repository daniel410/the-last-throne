"""검토한 128개 아이콘 의미를 런타임 장식 표와 출처 목록으로 생성한다."""
import json,hashlib
from pathlib import Path
root=Path(__file__).resolve().parents[1]; prompts=json.loads((root/'assets/ui/hero-skill-icons-v2/prompts.json').read_text())['records']; icons={r['id']:r for r in json.loads((root/'assets/ui/hero-skill-icons-v2/manifest.json').read_text())['records']}
# 클래스별 아이콘 순서에 맞춘 수작업 의미 대응. 수량은 시각 장식이며 피해 횟수가 아니다.
cues={
'knight':'kite orbit shout counter sweep challenge orbit fracture guard rally drive point orbit fracture shout front oath sweep challenge dawn fracture kite guard drive guard orbit cross oath dawn point sweep guard'.split(),
'dwarf':'fracture axe fracture fracture returning dust fracture fracture leap drive cross ridge shatter pair tremor ridge muzzle lob blast muzzle shrapnel recoil fan bounce barrage pierce roll barrage barrage hook dust point'.split(),
'elf':'point feather fan mark glide pierce feather mark fan guard retreat pierce shatter cross rain fan leaf electric roots bloom electric roots leafguard glide rain pierce echo roots rain retreat pin rain'.split(),
'mage':'facet drops infall lance vapor rings dart ridge step stone ward vents lance molten ash vents crystal shard frostbreak shatter electric step electric ward storm crystal electric hail storm wind drops ward'.split()}
counts={'kite':1,'orbit':2,'shout':3,'counter':1,'sweep':1,'challenge':3,'fracture':3,'guard':1,'rally':2,'drive':2,'point':2,'front':3,'oath':1,'dawn':3,'cross':2,'axe':1,'returning':1,'dust':3,'leap':2,'ridge':3,'shatter':4,'pair':2,'tremor':3,'muzzle':3,'lob':1,'blast':4,'shrapnel':3,'recoil':2,'fan':5,'bounce':2,'barrage':3,'pierce':3,'roll':2,'hook':1,'feather':2,'mark':4,'glide':2,'retreat':2,'rain':4,'leaf':1,'electric':2,'roots':3,'bloom':5,'leafguard':1,'echo':3,'pin':2,'facet':1,'drops':3,'infall':3,'lance':1,'vapor':3,'rings':3,'dart':1,'step':2,'stone':1,'ward':3,'vents':3,'molten':3,'ash':4,'crystal':1,'shard':1,'frostbreak':3,'storm':3,'hail':4,'wind':2}
rows=[];lines=['-- Icon-derived, individually reviewed presentation cues. No gameplay values.','return table.freeze({']
for cls,seq in cues.items():
 rs=[r for r in prompts if r['classId']==cls];assert len(rs)==len(seq)==32
 for r,cue in zip(rs,seq):
  icon=icons[r['id']]; count=counts[cue]
  assert hashlib.sha256((root/'assets/ui/hero-skill-icons-v2'/r['file']).read_bytes()).hexdigest()==icon['sha256']
  # IDs, rather than translated names, identify the two ultimate slots.
  ultimate=r['id'] in ['knight.steel_knight.unyielding_front','knight.paladin.oath_of_dawn','dwarf.iron_axe.mountain_collapse','dwarf.gunner.siege_barrage','elf.marksman.grand_volley','elf.magic_archer.spirit_arrowfall','mage.pyro.caldera_s_judgment','mage.cryo.eternal_tempest']
  scale=1.45 if ultimate else .7 if cue=='dart' else 1.2 if 'glacial_spike' in r['id'] or 'heavy_draw' in r['id'] else 1
  lines.append(f' ["{r["id"]}"]=table.freeze({{cue="{cue}",count={count},scale={scale}}}),')
  rows.append({'id':r['id'],'classId':cls,'icon':str(Path('assets/ui/hero-skill-icons-v2')/r['file']),'iconSha256':icon['sha256'],'iconMotif':r['motif'],'cue':cue,'count':count,'scale':scale})
lines+=['})',''];(root/'src/client/SkillIconVFXProfiles.luau').write_text('\n'.join(lines))
out=root/'assets/effects/skill-icon-vfx-v1';out.mkdir(parents=True,exist_ok=True);(out/'manifest.json').write_text(json.dumps({'schemaVersion':1,'tasks':['TLT-033','TLT-057','TLT-059'],'records':rows},ensure_ascii=False,indent=2)+'\n')
