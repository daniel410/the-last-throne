"""Prepare a disposable Studio entry fixture from an existing build. Never publish it.
Only the Studio session profile seed and local loading-role selection differ.
"""
import argparse
from pathlib import Path
import xml.etree.ElementTree as E
parser=argparse.ArgumentParser()
parser.add_argument('--artifact',type=Path,required=True)
parser.add_argument('--output',type=Path,required=True)
args=parser.parse_args()
assert args.output.resolve()!=args.artifact.resolve(),'Never overwrite a build'
root=E.parse(args.artifact)
def name(i):return i.findtext('./Properties/string[@name="Name"]')
def find(n):return next(i for i in root.iter('Item') if name(i)==n)
def source(n):return find(n).find('./Properties/string[@name="Source"]')
seed='''
 if sessionOnly and game.PlaceId==0 and profile then
  profile,errorCode=store:transact(player.UserId,function(current)
   local p=assert(Rules.addHero(current,'qa-knight','knight',Catalog))
   local h=p.heroes['qa-knight'];h.level=80;h.progression=Growth.new(80)
   local C=require(ReplicatedStorage.Shared.CampaignContent)
   local P=require(ReplicatedStorage.Shared.DeepwoodProgress)
   h.deepwood=P.new();h.deepwood.main=C.mainCount;h.deepwood.choice='shared'
   for _,c in ipairs(C.mainChapters)do
    h.deepwood.clears[c.id]=true;h.deepwood.coins+=c.reward.coins
    for _,g in ipairs(c.goals)do h.deepwood.flags[c.id..':'..g.id]=true end
   end
   assert(Rules.validate(p,Catalog),'QA fixture profile invalid')
   return p
  end)
 end
'''
s=source('InventoryService');assert 'local profile, errorCode = store:open(player.UserId)' in s.text;s.text=s.text.replace('local profile, errorCode = store:open(player.UserId)','local profile, errorCode = store:open(player.UserId)'+seed)
# Local test loader exercises the exact production arrival script after local
# admission. Only role resolution is replaced because the test has no teleport.
loader=source('ArrivalLoading').text
start=loader.index('local role = ');end=loader.index('local ok, arriving',start)
loader=loader[:start]+"local role = 'Battle'\n"+loader[end:]
# It lives beside the production ReplicatedFirst dependencies and runs on demand.
first=find('ReplicatedFirst')
item=E.SubElement(first,'Item',{'class':'LocalScript','referent':'QAEntryLoader'})
props=E.SubElement(item,'Properties');E.SubElement(props,'string',{'name':'Name'}).text='QAEntryLoader'
E.SubElement(props,'bool',{'name':'Disabled'}).text='true';E.SubElement(props,'string',{'name':'Source'}).text=loader
root.write(args.output,encoding='utf-8',xml_declaration=True)
print(args.output)
