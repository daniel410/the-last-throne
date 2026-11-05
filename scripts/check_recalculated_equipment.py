"""Compare proposed kits against actual pure growth/difficulty functions, not combat execution."""
import json
import hashlib
import math
import subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
p=json.loads((ROOT/'assets/balance/equipment-recalculated-2026-11-05.json').read_text())
code='''
local G=dofile('src/shared/HeroProgression.luau')
local D=dofile('src/shared/Difficulty.luau')
local C=dofile('src/shared/ItemCatalog.luau')
for _,class in ipairs({'knight','elf','dwarf','mage'})do assert(C.items[class..'_weapon_forged'].stats.power==24)end
for _,level in ipairs({10,20,40,60,80})do
 for _,class in ipairs({'knight','elf','dwarf','mage'})do
  for _,build in ipairs({'unallocated','balanced','fullVIT','fullINT'})do
   local g=G.new(level);local points=4*(level-1)
   if build=='balanced'then g.stats.VIT=math.floor(points/4);g.stats.INT=math.floor(points/4);g.stats.STR=points-g.stats.VIT-g.stats.INT
   elseif build=='fullVIT'then g.stats.VIT=points elseif build=='fullINT'then g.stats.INT=points end
   local d=G.derived(class,g)
   print(table.concat({'hero',class,level,build,d.health,d.mana,d.armor},'|'))
  end
 end
 for _,mode in ipairs(D.order)do
  if level>=D.modes[mode].level then
   for party=1,4 do
    local _,normal,effective=D.stats('Orc',10,party,false,mode,D.version)
    local _,boss=D.stats('KingOgre',10,party,true,mode,D.version)
    print(table.concat({'enemy',level,mode,party,normal,boss,effective},'|'))
   end
  end
 end
end
'''
r=subprocess.run(['lua','-'],input=code,text=True,capture_output=True,cwd=ROOT,check=True)
heroes={};enemies=[]
for line in r.stdout.splitlines():
 a=line.split('|')
 if a[0]=='hero': heroes[(a[1],int(a[2]),a[3])]=dict(zip(('health','maxMana','armor'),map(float,a[4:])))
 else: enemies.append({'level':int(a[1]),'mode':a[2],'humans':int(a[3]),'normalHit':float(a[4]),'bossHit':float(a[5]),'enemyLevel':int(a[6])})
rows=[]
for grade,required in p['requiredLevels'].items():
 for level in ({required,80} if grade=='Unique' else {required}):
  for cls in ('knight','elf','dwarf','mage'):
   kit=[i for i in p['items'] if i['rarity']==grade and i['classId']==cls]
   assert len(kit)==(8 if cls=='knight' else 7)
   assert len([i for i in kit if i['slot']=='accessory'])==2
   for stage in (0,9):
    for build in ('unallocated','balanced','fullVIT','fullINT'):
     hero=heroes[(cls,level,build)]
     def total(previous):
      out=dict.fromkeys(('power','armor','health','maxMana'),0)
      for i in kit:
       src=i['previous'] if previous else i
       data=src['statsAtEnhancement9'] if stage else src['stats']
       for k,v in data.items():out[k]+=v
      return out
     for enemy in (e for e in enemies if e['level']==level):
      entry={**enemy,'rarity':grade,'classId':cls,'enhancement':stage,'build':build,'hero':hero}
      for label,gear in [('previous',total(True)),('recalculated',total(False))]:
       # Sets/procs excluded to isolate the raw-stat change; old Unique is Lv10 reference.
       entry[label]={'gear':gear,'maxHealth':hero['health']+gear['health'],
        'hypotheticalMaxMana':hero['maxMana']+gear['maxMana'] if hero['maxMana']>0 else 0,
        'normalDamageAfterFlatArmor':max(1,enemy['normalHit']-hero['armor']-gear['armor']),
        'bossDamageAfterFlatArmor':max(1,enemy['bossHit']-hero['armor']-gear['armor'])}
       assert all(math.isfinite(v) and v>0 for k,v in entry[label].items() if k in ('maxHealth','normalDamageAfterFlatArmor','bossDamageAfterFlatArmor'))
      rows.append(entry)
assert len(rows)==1664,len(rows)
# Runtime MP remains unsupported; no claim that hypotheticalMaxMana is applied by the game.
report={'date':'2026-11-05','kind':'synthetic-inputs-actual-pure-growth-and-difficulty-not-live-combat',
 'runtimeSourceHashes':{name:hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in ('src/shared/HeroProgression.luau','src/shared/Difficulty.luau','src/shared/ItemCatalog.luau','src/server/Combat/CombatService.luau')},
 'balancePlanHash':hashlib.sha256((ROOT/'assets/balance/equipment-recalculated-2026-11-05.json').read_bytes()).hexdigest(),
 'runtimeRulesVersion':3,'authoredEnemyLevel':10,'ai':'AI not simulated; human count 1..4 only',
 'excluded':['set bonuses','proc effects','block','dodge','animation timing','AI','magic archer MP branch','DataStore'],
 'fullINTMage60Mana':heroes[('mage',60,'fullINT')]['maxMana'],
 'minimumDamageRowsBefore':sum(i['previous']['normalDamageAfterFlatArmor']==1 for i in rows),
 'minimumDamageRowsAfter':sum(i['recalculated']['normalDamageAfterFlatArmor']==1 for i in rows),
 'fixtures':rows}
fixture_rows=report.pop('fixtures')
text=json.dumps(report,ensure_ascii=False,indent=2)[:-2]+',\n  \"fixtures\": [\n'+',\n'.join(json.dumps(row,ensure_ascii=False,separators=(',',':')) for row in fixture_rows)+'\n]}\n'
(ROOT/'docs/evidence/equipment-recalculation-fixtures-20261105.json').write_text(text)
print('PASS: 1664 legal-level human-party fixtures, actual pure Growth/Difficulty v3; minimum normal damage before/after:',report['minimumDamageRowsBefore'],report['minimumDamageRowsAfter'])
