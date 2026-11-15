"""Existing build -> disposable Studio-only GW-01 approach fixture; never publish."""
from pathlib import Path
import argparse, hashlib, json
import xml.etree.ElementTree as E
p=argparse.ArgumentParser();p.add_argument('--artifact',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--record',type=Path,required=True);a=p.parse_args()
assert a.artifact.resolve()!=a.output.resolve()
tree=E.parse(a.artifact)
originalSources={i.attrib.get('referent'):i.findtext('./Properties/string[@name="Source"]')for i in tree.iter('Item')if i.find('./Properties/string[@name="Source"]')is not None}
def name(i):return i.findtext('./Properties/string[@name="Name"]')
item=next(i for i in tree.iter('Item')if name(i)=='InventoryService')
source=item.find('./Properties/string[@name="Source"]')
needle='local profile, errorCode = store:open(player.UserId)'
seed='''
 if sessionOnly and game.PlaceId==0 and profile then
  profile,errorCode=store:transact(player.UserId,function(current)
   local p=assert(Rules.addHero(current,'qa-gw-knight','knight',Catalog))
   local h=p.heroes['qa-gw-knight'];h.level=80;h.progression=Growth.new(80)
   local C=require(ReplicatedStorage.Shared.CampaignContent)
   local P=require(ReplicatedStorage.Shared.DeepwoodProgress)
   local s=P.new()
   for _,c in ipairs(C.mainChapters)do if c.epic==1 then
    s.main=c.number;s.clears[c.id]=true;s.coins+=(c.journalCoins or c.reward.coins)
    for _,g in ipairs(c.goals)do if not g.expansion and not g.pacing then s.flags[c.id..':'..g.id]=true end end
   end end
   s.choice='shared';assert(P.validate(s),'prefix valid')
   s=assert(P.enableExpansion(s))
   for _,id in ipairs({'maeve','trail'})do
    local g=P.goal(C.byId['GW-01'],id)
    for _,step in ipairs(g.activity and g.activity.steps or {false})do s=assert(P.apply(s,'GW-01',id,nil,step and step.id or nil))end
   end
   h.deepwood=s;h.expeditions={version=1,clears={},cacheProgress={}}
   require(ReplicatedStorage.Shared.AdventureRules).upgradeHero(h)
   assert(Rules.validate(p,Catalog),'QA profile valid')
   return p
  end)
 end
'''
assert source.text.count(needle)==1
source.text=source.text.replace(needle,needle+seed)
changed=[i for i in tree.iter('Item')if i.find('./Properties/string[@name="Source"]')is not None and originalSources.get(i.attrib.get('referent'))!=i.findtext('./Properties/string[@name="Source"]')]
assert len(changed)==1 and name(changed[0])=='InventoryService'
tree.write(a.output,encoding='utf-8',xml_declaration=True)
a.record.write_text(json.dumps({'artifact':str(a.artifact),'artifactSHA256':hashlib.sha256(a.artifact.read_bytes()).hexdigest(),'fixture':str(a.output),'fixtureSHA256':hashlib.sha256(a.output.read_bytes()).hexdigest(),'onlyModifiedSource':'Server.Inventory.InventoryService','purpose':'Studio session hero seed; Easy GW-01 exp_1 pending; no production source changes','seed':seed},indent=2)+'\n')
print(a.output)
