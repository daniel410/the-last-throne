"""Replace superseded dwarf reference rows with independently evaluated Blender rows."""
import json
import pathlib
import re
import sys
root=pathlib.Path(__file__).resolve().parents[1]
profile=sys.argv[1]if len(sys.argv)>1 else 'dwarf'
gold=json.loads((root/('assets/animations/mixamo-'+profile+'-v1/blender-golden.json')).read_text())
mapping={None:'basic','dwarf.common.overhead':'overhead','dwarf.common.ground':'ground'}
path=root/'tests/k0-melee-blender-native.luau';source=path.read_text()
def lua(x):
    if isinstance(x,dict):return '{'+','.join('['+json.dumps(k)+']='+lua(v)for k,v in x.items())+'}'
    if isinstance(x,list):return '{'+','.join(map(lua,x))+'}'
    return json.dumps(x)
offset=0;updated=0
while True:
    start=source.find('{["classId"]="'+profile+'",["combo"]=',offset)
    if start<0:break
    depth=0;end=start
    for end in range(start,len(source)):
        if source[end]=='{':depth+=1
        if source[end]=='}':
            depth-=1
            if depth==0:break
    end+=1
    row=source[start:end];match=re.search(r'\["skillId"\]="([^"]+)"',row)
    skill=match[1]if match else None
    combo=int(re.search(r'\["combo"\]=(\d+)',row)[1])
    if (profile=='dwarf'and skill in mapping)or(profile=='knight'and not skill):
        replacement={'classId':profile,'combo':combo}
        if skill:replacement['skillId']=skill
        replacement['samples']=gold[mapping[skill]if profile=='dwarf'else {1:'forehand',2:'backhand',3:'overhead'}[combo]]
        text=lua(replacement);source=source[:start]+text+source[end:];end=start+len(text);updated+=1
    offset=end
assert updated==3,updated
path.write_text(source)
print('Updated three '+profile+' Blender reference rows')
