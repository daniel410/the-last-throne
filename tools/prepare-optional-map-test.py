"""Patch a disposable local Studio fixture; never overwrite or publish the input build."""
from pathlib import Path
import xml.etree.ElementTree as ET
import argparse
p=argparse.ArgumentParser();p.add_argument('--artifact',type=Path,required=True);p.add_argument('--output',type=Path,required=True);args=p.parse_args()
assert args.artifact.resolve()!=args.output.resolve()
paths=['src/shared/AdventureRules.luau','src/shared/CampaignMapScope.luau','src/shared/DeepwoodQuestLog.luau','src/client/DeepwoodJournal.luau','src/client/DeepwoodQuestBook.luau','src/client/DeepwoodMap.luau']
updates={Path(path).stem:Path(path).read_text()for path in paths};tree=ET.parse(args.artifact);seen=set()
for item in tree.getroot().iter('Item'):
 props=item.find('Properties')
 if props is None:continue
 name=props.find("string[@name='Name']")
 if name is not None and name.text in updates:
  node=next(x for x in props if x.attrib.get('name')=='Source');node.text=updates[name.text];seen.add(name.text)
assert seen==set(updates);tree.write(args.output,encoding='utf-8',xml_declaration=True)
