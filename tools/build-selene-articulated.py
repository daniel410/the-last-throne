"""Recreate the local TD-derived six-piece appearance from audited Studio output."""
from pathlib import Path
import json,hashlib,xml.etree.ElementTree as E
root=Path(__file__).resolve().parents[1]
folder=root/'assets/shared/td-selene-articulated'
manifest=json.loads((folder/'segments.json').read_text())
assert hashlib.sha256((root/manifest['source']).read_bytes()).hexdigest()==manifest['sourceSha256']
doc=E.Element('roblox',version='4')
def item(parent,kind,name):
    node=E.SubElement(parent,'Item',{'class':kind});props=E.SubElement(node,'Properties');E.SubElement(props,'string',name='Name').text=name
    return node,props
container,_=item(doc,'Folder','SeleneArticulatedModels');model,_=item(container,'Model','nun')
names={'head and hood':'Head','torso and robe':'Body','left leg and foot':'LegL','right leg and foot':'LegR'}
foot=min(p['cf'][1]-p['size'][1]/2 for p in manifest['parts'])
for part in manifest['parts']:
    node,props=item(model,'MeshPart',names.get(part['name'],part['name']))
    for name,value in [('MeshId',part['mesh']),('TextureID',part['texture'])]:
        E.SubElement(E.SubElement(props,'Content',name=name),'url').text=value
    size=E.SubElement(props,'Vector3',name='size')
    for axis,value in zip('XYZ',part['size']):E.SubElement(size,axis).text=str(value)
    cf=part['cf'][:];cf[1]-=foot
    frame=E.SubElement(props,'CoordinateFrame',name='CFrame')
    for tag,value in zip(['X','Y','Z','R00','R01','R02','R10','R11','R12','R20','R21','R22'],cf):E.SubElement(frame,tag).text=str(value)
    E.SubElement(props,'Color3uint8',name='Color3uint8').text='16777215'
    initial=E.SubElement(props,'Vector3',name='InitialSize')
    for axis,value in zip('XYZ',part['size']):E.SubElement(initial,axis).text=str(value)
    E.SubElement(props,'bool',name='DoubleSided').text='true'
    E.SubElement(props,'token',name='Material').text='272'
    E.SubElement(props,'bool',name='Anchored').text='true'
    E.SubElement(props,'bool',name='CanCollide').text='false'
E.indent(doc);E.ElementTree(doc).write(folder/'runtime.rbxmx',encoding='utf-8',xml_declaration=True)
print(folder/'runtime.rbxmx')
