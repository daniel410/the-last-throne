"""Recompute shop prices against authoritative authored income, not play-time telemetry."""
import argparse,hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--baseline',default='7279201286ded3f9ffc1e15891ccc2921f1c4f00');args=p.parse_args()
old=subprocess.check_output(['git','show',args.baseline+':src/shared/EconomyCatalog.luau'],cwd=ROOT,text=True)
assert ']==]' not in old
bridge="local Old=assert(load([==["+old+"]==]))()\n"+r'''
local I=dofile('src/shared/ItemCatalog.luau');local C=dofile('src/shared/EconomyCatalog.luau');local P=dofile('src/shared/EquipmentPricing.luau')
local Campaign=dofile('src/shared/CampaignContent.luau');local S=dofile('src/shared/EncounterSummary.luau');local D=dofile('src/shared/Difficulty.luau')
for _,offer in ipairs(C.goldOffers)do assert(offer.amount==offer.price*P.goldPerDiamond,'Exchange basis changed')end
local function row(...)local v={};for i=1,select('#',...)do v[i]=tostring(select(i,...))end;print(table.concat(v,'\t'))end
row('rules',D.version,P.goldPerDiamond)
for _,c in ipairs(Campaign.mainChapters)do
 for _,mode in ipairs(D.order)do
  local s=S.mission(c,mode,1,D.version);local repeatReward=D.completion(c,mode,D.version)
  row('mission',c.id,c.epic,mode,c.reward.coins,s.gold,repeatReward.gold,s.count)
 end
end
for _,offer in ipairs(C.offers)do
 local d=I.items[offer.definitionId];local before=Old.offer(offer.id)
 row('offer',offer.id,d.id,d.name,d.family or 'accessory',d.slot or 'consumable',offer.currency,offer.price,before and before.price or 0,C.sell[d.id] or 0,d.category)
end
for _,offer in ipairs(Old.offers)do if not C.offer(offer.id)then row('removed',offer.id,offer.definitionId,I.items[offer.definitionId].family or '')end end
for _,id in ipairs(I.tierEquipment)do local d=I.items[id];row('gear',id,d.family,d.slot,d.classId or 'all',d.rarity,d.level,C.sell[id],Old.sell[id])end
'''
raw=subprocess.check_output(['lua','-e',bridge],cwd=ROOT,text=True)
report={'baselineCommit':args.baseline,'scope':'Static authored finite encounters and completion budgets; not minimum route, live wallet, play time, drop income, side quests, daily login, consumable use or multiplayer telemetry. First fixed rewards remain unchanged across modes; kill/repeat values use pinned current rules.','missions':[],'offers':[],'removed':[],'gear':[]}
for line in raw.splitlines():
 r=line.split('\t')
 if r[0]=='rules':report.update(rewardRules=int(r[1]),goldPerDiamond=int(r[2]))
 elif r[0]=='mission':report['missions'].append(dict(id=r[1],epic=int(r[2]),mode=r[3],firstFixedGold=int(r[4]),finiteKillGold=int(r[5]),repeatFixedGold=int(r[6]),finiteEnemies=int(r[7])))
 elif r[0]=='offer':report['offers'].append(dict(id=r[1],definitionId=r[2],name=r[3],family=r[4],slot=r[5],currency=r[6],price=int(float(r[7])),oldPrice=int(float(r[8])),resaleGold=int(r[9]),category=r[10]))
 elif r[0]=='removed':report['removed'].append(dict(id=r[1],definitionId=r[2],family=r[3]))
 elif r[0]=='gear':report['gear'].append(dict(id=r[1],family=r[2],slot=r[3],classId=r[4],rarity=r[5],level=int(r[6]),resaleGold=int(r[7]),oldResaleGold=int(r[8])))
easy=[m for m in report['missions']if m['mode']=='Easy'];report['epics']=[]
for epic in range(1,6):
 ms=[m for m in easy if m['epic']==epic]
 report['epics'].append(dict(epic=epic,firstFixedGold=sum(m['firstFixedGold']for m in ms),finiteKillGold=sum(m['finiteKillGold']for m in ms),firstGrossGold=sum(m['firstFixedGold']+m['finiteKillGold']for m in ms),repeatGrossGold=sum(m['repeatFixedGold']+m['finiteKillGold']for m in ms)))
report['sets']=[]
for family in ['tempered','veteran','sentinel']:
 for cls in ['knight','elf','dwarf','mage']:
  selected=[g for g in report['gear']if g['family']==family and (g['slot']=='weapon'and g['classId']==cls or g['slot']=='offhand'and cls=='knight'or g['slot']=='body'and g['classId']==('mage'if cls=='mage'else'all')or g['slot']in ['head','hands','feet'])]
  assert len(selected)==(6 if cls=='knight'else 5)
  offers=[next(o for o in report['offers']if o['definitionId']==g['id']and o['currency']==('diamonds'if family=='sentinel'else'gold'))for g in selected]
  price=sum(o['price']for o in offers);old_price=sum(o['oldPrice']for o in offers)
  row=dict(family=family,classId=cls,currency=offers[0]['currency'],price=price,oldPrice=old_price,excludesAccessories=True,allPiecesPurchased=True)
  if row['currency']=='gold':
   row['grossThresholds']=[]
   for reserve in [0,200,400,800]:
    cumulative=0;threshold=None
    for m in easy:
     cumulative+=m['firstFixedGold']+m['finiteKillGold']
     if cumulative>=price+reserve:threshold=m['id'];break
    row['grossThresholds'].append(dict(reservedGold=reserve,chapter=threshold,ignoresLevelGatesAndDrops=True))
  else:row['firstClearStoryEquivalents']=(price+2)//3
  report['sets'].append(row)
report['checks']={}
assert len(report['removed'])==14 and all(r['family']=='traveler'for r in report['removed'])
assert all(o['family']!='traveler'for o in report['offers'])
assert all(o['price']==o['oldPrice']for o in report['offers']if o['category']!='Equipment')
for offer in report['offers']:
 if offer['category']=='Equipment':
  peers=[o for o in report['offers']if o['definitionId']==offer['definitionId']]
  assert len({o['price']*(50 if o['currency']=='diamonds'else 1)for o in peers})==1
  old_min=min(o['oldPrice']*(50 if o['currency']=='diamonds'else 1)for o in peers)
  assert offer['resaleGold']<old_min # Stock bought at historical prices cannot profit on resale.
report['checks'].update(removedTravelerOffers=14,remainingOffers=len(report['offers']),unchangedConsumableAndResetOffers=10,dualCurrencyParity=True,noHistoricalBuyCurrentResaleArbitrage=True)
inputs=['src/shared/EquipmentPricing.luau','src/shared/EconomyCatalog.luau','src/shared/EquipmentFamilies.luau','src/shared/CampaignContent.luau','src/shared/DeepwoodContent.luau','src/shared/QuestCompletionRewards.luau','src/shared/FrozenValeContent.luau','src/shared/EmberCalderaContent.luau','src/shared/LateEpicContent.luau','src/shared/AdventureRepeatRewards.luau','src/shared/Difficulty.luau','src/shared/DeepwoodEncounterBalance.luau','src/shared/EncounterSummary.luau','src/shared/RewardEconomy.luau','src/shared/CampaignStoryText.luau','src/shared/CampaignExpansion.luau','src/shared/CampaignStoryBeats.luau']
report['scriptSha256']=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
report['inputSha256']={name:hashlib.sha256((ROOT/name).read_bytes()).hexdigest()for name in inputs}
args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'checks':report['checks'],'epics':report['epics'],'sets':[{k:v for k,v in s.items()if k not in ['grossThresholds']}for s in report['sets']]},indent=2))
