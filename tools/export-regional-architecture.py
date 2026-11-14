"""Blender MCP의 실제 기하 JSON을 런타임 템플릿과 스토리 대응표로 내보낸다."""
from pathlib import Path
import json,math,hashlib
root=Path(__file__).resolve().parents[1]
data=json.loads((root/'assets/models/regional-architecture-blender-v1/kit.json').read_text())
def literal(v):
 if isinstance(v,list):return '{'+','.join(map(literal,v))+'}'
 if isinstance(v,float):return format(v,'.9g')
 if isinstance(v,bool):return str(v).lower()
 return json.dumps(v,ensure_ascii=False,separators=(',',':'))
lines=['-- Generated from actual Blender MCP geometry; edit the authoring source.','return {']
for name,parts in data['models'].items():
 lines.append(' '+name+'={')
 for p in parts:
  assert len(p['cf'])==12 and all(x>0 for x in p['size'])
  lines.append('  '+literal([p[k]for k in ['name','shape','material','size','color','cf','solid']])+',')
 lines.append(' },')
lines.append('}')
(root/'src/server/World/RegionalArchitectureTemplates.luau').write_text('\n'.join(lines)+'\n')
rows=json.loads((root/'assets/concepts/2026-11-13-regional-epic-stories-v1/stories.json').read_text())
profiles={}
for r in rows:
 if r['zone']in profiles:profiles[r['zone']]['stories'].append(r['id']);continue
 profiles[r['zone']]=dict(title=r['title'],kind=r['kind'],epic=r['epic'],stories=[r['id']])
lines=['-- Story concepts share the same physical zone where the campaign does.','return {']
for id,p in profiles.items():
 lines.append(' ['+json.dumps(id)+']={title='+json.dumps(p['title'])+',kind='+json.dumps(p['kind'])+',epic='+str(p['epic'])+',stories='+literal(p['stories'])+'},')
lines.append('}')
(root/'src/server/World/RegionalConceptProfiles.luau').write_text('\n'.join(lines)+'\n')
print(json.dumps({'models':len(data['models']),'parts':sum(map(len,data['models'].values())),'zones':len(profiles),'stories':len(rows)}))
