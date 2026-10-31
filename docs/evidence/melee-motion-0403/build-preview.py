#!/usr/bin/env python3
"""Isolated motion inspection scene, not a game build or publish artifact."""
from pathlib import Path
import xml.etree.ElementTree as ET
import json, hashlib
ROOT = Path(__file__).resolve().parents[3]
OUT = Path('/private/tmp/tlt-melee-preview.rbxlx')
xml = ET.parse(ROOT/'assets/shared/td-player-weapons/runtime.rbxmx')
tree = xml.getroot()
source = tree.find('Item')
source.find('./Properties/string[@name="Name"]').text = 'TDPlayerWeaponModels'
def item(parent, cls, name):
    node=ET.SubElement(parent,'Item',{'class':cls}); props=ET.SubElement(node,'Properties')
    ET.SubElement(props,'string',{'name':'Name'}).text=name
    return node
def prop(node,kind,name,value):
    ET.SubElement(node.find('Properties'),kind,{'name':name}).text=str(value)
def script(parent,cls,name,source):
    node=item(parent,cls,name); prop(node,'ProtectedString','Source',source); return node
storage=item(tree,'ServerStorage','ServerStorage'); tree.remove(source); storage.append(source)
rep=item(tree,'ReplicatedStorage','ReplicatedStorage'); shared=item(rep,'Folder','Shared')
inputs={}
for p in (ROOT/'src/shared').glob('*.luau'):
    script(shared,'ModuleScript',p.stem,p.read_text());inputs[str(p.relative_to(ROOT))]=hashlib.sha256(p.read_bytes()).hexdigest()
server=item(tree,'ServerScriptService','ServerScriptService'); cosmetics=item(server,'Folder','Cosmetics')
for name in ['WeaponAppearance','WoodenStaff']:
    p=ROOT/f'src/server/Cosmetics/{name}.luau'
    if p.exists():script(cosmetics,'ModuleScript',name,p.read_text())
players=item(tree,'Players','Players');prop(players,'bool','CharacterAutoLoads','false')
starter=item(tree,'StarterPlayer','StarterPlayer'); scripts=item(starter,'StarterPlayerScripts','StarterPlayerScripts');client=item(scripts,'Folder','Client')
for name in ['K0SwordVisual','K0MeleeMotion']:
    p=ROOT/f'src/client/{name}.luau';script(client,'ModuleScript',name,p.read_text());inputs[str(p.relative_to(ROOT))]=hashlib.sha256(p.read_bytes()).hexdigest()
script(server,'Script','MotionInspection',r'''
local Players=game:GetService('Players')
local Appearance=require(script.Parent.Cosmetics.WeaponAppearance)
workspace.Gravity=196.2
local floor=Instance.new('Part');floor.Size=Vector3.new(50,1,40);floor.Position=Vector3.new(0,-.5,0);floor.Anchored=true;floor.Color=Color3.fromRGB(48,58,68);floor.Material=Enum.Material.SmoothPlastic;floor.Parent=workspace
local light=game:GetService('Lighting');light.ClockTime=13;light.Brightness=3;light.Ambient=Color3.fromRGB(150,155,170)
for i,classId in ipairs({'knight','dwarf'}) do
 local d=Instance.new('HumanoidDescription')
 local c=Players:CreateHumanoidModelFromDescriptionAsync(d,Enum.HumanoidRigType.R15);d:Destroy()
 c.Name=classId=='knight' and 'Knight' or 'Dwarf';c.Parent=workspace;c:PivotTo(CFrame.new(i==1 and -4 or 4,3.1,0))
 c.HumanoidRootPart.Anchored=true;c.Humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
 for _,p in ipairs(c:GetDescendants()) do if p:IsA('BasePart') then p.Color=classId=='knight' and Color3.fromRGB(82,132,202) or Color3.fromRGB(179,115,58);p.CanCollide=false end end
 local m=Instance.new('Model');m.Name='InspectionWeapon';m.Parent=c
 assert(Appearance.attachInto(m,c,classId))
 c:SetAttribute('K0ClassId',classId);c:SetAttribute('K0State','Attack');c:SetAttribute('K0AttackKind','Basic');c:SetAttribute('K0AttackStartedAt',100);c:SetAttribute('K0Combo',1);c:SetAttribute('InspectionRig',true)
 local billboard=Instance.new('BillboardGui');billboard.Size=UDim2.fromOffset(200,40);billboard.StudsOffset=Vector3.new(0,3.6,0);billboard.AlwaysOnTop=true;billboard.Parent=c.Head
 local text=Instance.new('TextLabel');text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Text=c.Name;text.TextColor3=Color3.new(1,1,1);text.TextSize=24;text.Font=Enum.Font.GothamBold;text.Parent=billboard
end
''')
script(client,'LocalScript','Inspect',r'''
local Run=game:GetService('RunService')
local Input=game:GetService('UserInputService')
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local Visual=require(script.Parent.K0SwordVisual)
local camera=workspace.CurrentCamera
camera.CameraType=Enum.CameraType.Scriptable
camera.CFrame=CFrame.lookAt(Vector3.new(12,9,-21),Vector3.new(0,3,-1))
local gui=Instance.new('ScreenGui');gui.Name='MotionInspection';gui.Parent=game.Players.LocalPlayer:WaitForChild('PlayerGui')
local label=Instance.new('TextLabel');label.Size=UDim2.new(1,0,0,75);label.BackgroundColor3=Color3.fromRGB(17,23,30);label.BackgroundTransparency=.1;label.TextColor3=Color3.new(1,1,1);label.Font=Enum.Font.Gotham;label.TextSize=18;label.Parent=gui
local clock,playing,manual,combo=0,true,nil,1
Input.InputBegan:Connect(function(input,processed)
 if processed then return end
 if input.KeyCode==Enum.KeyCode.Space then playing=not playing;manual=nil
 elseif input.KeyCode==Enum.KeyCode.One then playing=false;manual='Load'
 elseif input.KeyCode==Enum.KeyCode.Two then playing=false;manual='Contact'
 elseif input.KeyCode==Enum.KeyCode.Three then playing=false;manual='Follow'
 elseif input.KeyCode==Enum.KeyCode.Four then playing=false;manual='Guard'
 elseif input.KeyCode==Enum.KeyCode.C then combo=combo%3+1 end
end)
Run.PreSimulation:Connect(function(dt)
 if playing then clock+=dt*.65 end
 local rigs={}
 for _,c in ipairs(workspace:GetChildren()) do if c:GetAttribute('InspectionRig') then table.insert(rigs,c) end end
 local cycle=math.floor(clock/.95)
 local cut=playing and cycle%3+1 or combo
 label.Text='MELEE MOTION INSPECTION • R15 • 0.65×\nSpace: play/pause   1: load   2: contact   3: follow   4: guard   C: sword cut '..cut
 for _,c in ipairs(rigs) do
  local cls=c:GetAttribute('K0ClassId');local n=cls=='knight' and cut or 1
  c:SetAttribute('K0Combo',n)
  local d=Config.BasicAttackProfiles[cls].attacks[n];local total=d.windup+d.active+d.recovery
  local age=clock%.95
  if manual=='Load' then age=d.windup*.45 elseif manual=='Contact' then age=d.windup+(d.hitDelay or 0) elseif manual=='Follow' then age=d.windup+d.active+d.recovery*.15 elseif manual=='Guard' then age=total end
  age=math.min(age,total)
  c:SetAttribute('K0AttackPhase',age<d.windup and 'Windup' or age<d.windup+d.active and 'Active' or 'Recovery')
  Visual.renderArms(c,dt,100+age);Visual.renderCharacter(c,dt,100+age)
 end
end)
''')
xml.write(OUT,encoding='utf-8',xml_declaration=True)
print(json.dumps({'fixture':str(OUT),'sha256':hashlib.sha256(OUT.read_bytes()).hexdigest(),'inputs':inputs}))
