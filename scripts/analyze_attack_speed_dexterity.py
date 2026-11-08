"""Read-only arithmetic for the dated combat research; no runtime edits."""
from pathlib import Path
import hashlib,json,subprocess
root=Path(__file__).resolve().parents[1];base={'knight':[.42,.46,.62],'dwarf':[.42]}
growth=(root/'src/shared/HeroProgression.luau').read_text()
assert 'attackRate=1+math.min(1,g.stats.DEX*.005)' in growth
assert 'moveRate=1+math.min(.3,g.stats.DEX*.001)' in growth
config=(root/'src/shared/K0Config.luau').read_text()
for text in ['windup = 0.16, active = 0.10, recovery = 0.16',
 'windup = 0.18, active = 0.10, recovery = 0.18',
 'windup = 0.26, active = 0.12, recovery = 0.24',
 'windup = 0.16, active = 0.10, hitDelay = 0.06, recovery = 0.16']:
 assert text in config,'Refresh research assumptions after timing changes'
rows=[]
for dex in [0,20,40,50,80,100,150,200,250,300,316]:
 rate=1+min(1,dex*.005);move=1+min(.3,dex*.001)
 rows.append({'investedDEX':dex,'attackRate':rate,'attackBonusPercent':(rate-1)*100,'moveRate':move,'moveBonusPercent':(move-1)*100,
 'knightPeriods':[t/rate for t in base['knight']],'knightAveragePeriod':.5/rate,'knightAPS':2*rate,
 'dwarfPeriod':.42/rate,'dwarfAPS':rate/.42,'dwarfHitTime':.22/rate,'walkStudsPerSecond':16*move,'sprintStudsPerSecond':24*move,
 'attackMoveStudsPerSecond':6.4*move,'guardMoveStudsPerSecond':8*move,'nextDEXAttackBonus':min(1,(dex+1)*.005)-min(1,dex*.005),
 'nextDEXMoveBonus':min(.3,(dex+1)*.001)-min(.3,dex*.001)})
proposals=[]
for period in [.42,.60,.65,.70]:
 coeff=.75*period/.42
 proposals.append({'status':'unapproved research candidate','dwarfBasePeriod':period,'baseAPS':1/period,'maxDEXPeriod':period/2,
 'maxDEXAPS':2/period,'basicDPSRatioIfDamageUnchanged':.42/period,'damageCoefficientForSameIdealizedDPS':coeff})
paths=['src/shared/K0Config.luau','src/shared/HeroProgression.luau','src/server/Combat/K0Rules.luau','src/server/Combat/CombatService.luau','src/client/K0MeleeMotion.luau']
r={'date':'2026-11-08','sourceCommit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=root).decode().strip(),
 'method':'Static arithmetic from current source; not measured gameplay, transport, frame or enemy-armor simulation',
 'inputs':{p:hashlib.sha256((root/p).read_bytes()).hexdigest()for p in paths},'rows':rows,'unapprovedProposals':proposals,
 'oldDwarfSkillToBasicCompression':1.13/.42,'baselineBasicDPSAtEqualPower100':{'knight':(75+90+120)/1.5,'dwarf':75/.42},
 'wc3ArchivedGuideExamples':{'mountainKingLevel1Seconds':2.22/(1+.02*11),'paladinLevel1Seconds':2.2/(1+.02*13),
 'mountainKingPlus20AgilitySeconds':2.22/(1+.02*31),'relativeAttackRateGainFrom11To31Agility':(1+.02*31)/(1+.02*11)-1,
 'status':'Calculated from archived official guide, not a current Reforged client measurement'}}
assert abs(rows[0]['dwarfAPS']/rows[0]['knightAPS']-1-4/21)<1e-9
assert rows[-1]['attackRate']==2 and rows[-1]['moveRate']==1.3
assert rows[-1]['nextDEXAttackBonus']==0 and rows[-1]['nextDEXMoveBonus']==0
out=root/'docs/research/data/2026-11-08-attack-speed-dexterity.json';out.write_text(json.dumps(r,indent=2)+'\n')
for x in rows:
 if x['investedDEX']in [0,40,100,200,300,316]:print(x['investedDEX'],round(x['attackBonusPercent']),round(x['moveBonusPercent']),round(x['dwarfPeriod'],3),round(x['knightAveragePeriod'],3),round(x['walkStudsPerSecond'],2))
print('Computed research tables; no game source changed')
