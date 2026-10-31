#!/usr/bin/env python3
"""Private before/after motion inspection, independent of game builds/publishing."""
from pathlib import Path
import xml.etree.ElementTree as ET
import subprocess,json,hashlib
ROOT=Path(__file__).resolve().parents[3]
OUT=Path('/private/tmp/tlt-melee-comparison-v3.rbxlx')
tree=ET.Element('roblox',{'version':'4'})
def item(parent,cls,name):
 n=ET.SubElement(parent,'Item',{'class':cls});p=ET.SubElement(n,'Properties');ET.SubElement(p,'string',{'name':'Name'}).text=name;return n
def prop(n,kind,name,value):ET.SubElement(n.find('Properties'),kind,{'name':name}).text=str(value)
def source(parent,cls,name,text):
 n=item(parent,cls,name);prop(n,'ProtectedString','Source',text);return n
storage=item(tree,'ServerStorage','ServerStorage')
for number,(path,name) in enumerate([('assets/shared/td-player-weapons/runtime.rbxmx','TDPlayerWeaponModels'),('assets/shared/td-player-weapons/shield/runtime.rbxmx','TDKnightShieldModels')]):
 n=ET.parse(ROOT/path).getroot().find('Item');n.find('./Properties/string[@name="Name"]').text=name
 refs={i.get('referent'):f'INSPECT_{number}_{i.get("referent")}' for i in n.iter('Item') if i.get('referent')}
 for i in n.iter('Item'):
  if i.get('referent'):i.set('referent',refs[i.get('referent')])
 for ref in n.iter('Ref'):
  if ref.text in refs:ref.text=refs[ref.text]
 storage.append(n)
rep=item(tree,'ReplicatedStorage','ReplicatedStorage');shared=item(rep,'Folder','Shared')
# Config is pinned to the already accepted combat balance, even if another task
# is editing story content in the shared checkout.
for name in ['K0Config','AdvancedSkills']:
 text=subprocess.check_output(['git','show',f'4d24560:src/shared/{name}.luau'],cwd=ROOT,text=True)
 source(shared,'ModuleScript',name,text)
server=item(tree,'ServerScriptService','ServerScriptService');cosmetics=item(server,'Folder','Cosmetics')
for name in ['WeaponAppearance','WoodenStaffBuilder']:
 text=subprocess.check_output(['git','show',f'4d24560:src/server/Cosmetics/{name}.luau'],cwd=ROOT,text=True);source(cosmetics,'ModuleScript',name,text)
players=item(tree,'Players','Players');prop(players,'bool','CharacterAutoLoads','false')
starter=item(tree,'StarterPlayer','StarterPlayer');scripts=item(starter,'StarterPlayerScripts','StarterPlayerScripts')
for version in ['Baseline','Candidate']:
 folder=item(scripts,'Folder',version)
 for name in ['K0SwordVisual','K0MeleeMotion']:
  text=(ROOT/f'src/client/{name}.luau').read_text() if version=='Candidate' else subprocess.check_output(['git','show',f'4d24560:src/client/{name}.luau'],cwd=ROOT,text=True)
  source(folder,'ModuleScript',name,text)
source(server,'Script','InspectionStage',r'''
local Players=game:GetService('Players')
local Appearance=require(script.Parent.Cosmetics.WeaponAppearance)
local stage=Instance.new('Folder');stage.Name='InspectionStage';stage.Parent=workspace
local floor=Instance.new('Part');floor.Size=Vector3.new(70,1,50);floor.Position=Vector3.new(0,-.5,-3);floor.Anchored=true;floor.Color=Color3.fromRGB(51,60,68);floor.Material=Enum.Material.SmoothPlastic;floor.Parent=stage
local light=game:GetService('Lighting');light.ClockTime=13;light.Brightness=3;light.Ambient=Color3.fromRGB(150,155,170)
local function make(player)
 if workspace:GetAttribute('InspectionReady') then return end
 player:LoadCharacterAsync()
 local avatar=player.Character or player.CharacterAdded:Wait()
 local humanoid=avatar:WaitForChild('Humanoid')
 local applied=humanoid:GetAppliedDescription()
 local avatarSource=player.UserId>0 and 'Studio player applied description' or 'Studio local test avatar'
 avatar:Destroy()
 for i,entry in ipairs({{'Baseline','knight',-10},{'Candidate','knight',-3.5},{'Baseline','dwarf',3.5},{'Candidate','dwarf',10}}) do
  local c=Players:CreateHumanoidModelFromDescriptionAsync(applied,Enum.HumanoidRigType.R15)
  c.Name=entry[1]..'_'..entry[2];c.Parent=stage
  c:PivotTo(CFrame.new(entry[3],c.Humanoid.HipHeight+c.HumanoidRootPart.Size.Y/2,0))
  c.HumanoidRootPart.Anchored=true;c.Humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
  for _,p in ipairs(c:GetDescendants()) do if p:IsA('BasePart') then p.CanCollide=false end end
  local colors=c:FindFirstChildOfClass('BodyColors')
  if colors then
   colors.TorsoColor3=entry[2]=='knight' and Color3.fromRGB(175,180,190) or Color3.fromRGB(130,90,55)
   colors.LeftArmColor3=entry[2]=='knight' and Color3.fromRGB(55,110,215) or Color3.fromRGB(200,120,50);colors.RightArmColor3=colors.LeftArmColor3
  end
  local m=Instance.new('Model');m.Name='InspectionWeapon';m.Parent=c
  assert(Appearance.attachInto(m,c,entry[2]));if entry[2]=='knight' then assert(Appearance.attachShieldInto(m,c)) end
  c:SetAttribute('K0ClassId',entry[2]);c:SetAttribute('K0State','Attack');c:SetAttribute('K0AttackKind','Basic');c:SetAttribute('K0AttackStartedAt',100);c:SetAttribute('K0Combo',1);c:SetAttribute('InspectionVersion',entry[1])
  local b=Instance.new('BillboardGui');b.Size=UDim2.fromOffset(210,50);b.StudsOffset=Vector3.new(0,3.4,0);b.AlwaysOnTop=true;b.Parent=c.Head
  local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=entry[2]:upper()..'\n'..(entry[1]=='Baseline' and '0.40.3' or 'REVISED');t.TextColor3=entry[1]=='Baseline' and Color3.fromRGB(200,205,215) or Color3.fromRGB(130,240,180);t.TextSize=17;t.Font=Enum.Font.GothamBold;t.Parent=b
  local target=Instance.new('Part');target.Name='RangeMarker';target.Size=Vector3.new(.12,.03,1.5);target.CFrame=CFrame.new(entry[3],.02,-4.5);target.Anchored=true;target.CanCollide=false;target.Material=Enum.Material.Neon;target.Color=Color3.fromRGB(110,175,200);target.Parent=stage
 end
 applied:Destroy();workspace:SetAttribute('InspectionAvatarSource',avatarSource);workspace:SetAttribute('InspectionReady',true)
end
Players.PlayerAdded:Connect(make);for _,p in ipairs(Players:GetPlayers()) do task.spawn(make,p) end
''')
source(scripts,'LocalScript','Inspect',r'''
local Run=game:GetService('RunService');local Input=game:GetService('UserInputService')
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local visuals={Baseline=require(script.Baseline.K0SwordVisual),Candidate=require(script.Candidate.K0SwordVisual)}
local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable
local front=false
local function cameraPose() camera.CFrame=CFrame.lookAt(front and Vector3.new(0,9,-44) or Vector3.new(0,10,44),Vector3.new(0,3,-1.5)) end
cameraPose()
local gui=Instance.new('ScreenGui');gui.Name='MotionComparison';gui.Parent=game.Players.LocalPlayer:WaitForChild('PlayerGui')
local label=Instance.new('TextLabel');label.Size=UDim2.new(1,0,0,85);label.BackgroundColor3=Color3.fromRGB(17,23,30);label.BackgroundTransparency=.08;label.TextColor3=Color3.new(1,1,1);label.Font=Enum.Font.Gotham;label.TextSize=17;label.Parent=gui
local clock,playing,manual,combo,speed=0,true,nil,1,.65
Input.InputBegan:Connect(function(input,processed)
 if processed then return end
 local key=input.KeyCode
 if key==Enum.KeyCode.Space then playing=not playing;manual=nil
 elseif key==Enum.KeyCode.One then playing=false;manual='Load'
 elseif key==Enum.KeyCode.Two then playing=false;manual='Before'
 elseif key==Enum.KeyCode.Three then playing=false;manual='Contact'
 elseif key==Enum.KeyCode.Four then playing=false;manual='After'
 elseif key==Enum.KeyCode.Five then playing=false;manual='Ready'
 elseif key==Enum.KeyCode.C then combo=combo%3+1
 elseif key==Enum.KeyCode.V then front=not front;cameraPose()
 elseif key==Enum.KeyCode.F then speed=speed==1 and .65 or 1 end
end)
Run.PreSimulation:Connect(function(dt)
 if playing then clock+=dt*speed end
 label.Text='0.40.3 / REVISED • same accepted attack timing • '..speed..'x\nSpace: play/pause  1: load  2: before contact  3: contact  4: after contact  5: ready  C: cut '..combo..'  V: camera  F: speed'
 local starts={0,.32,.68};local cycle=math.floor(clock/1.2);local within=clock%1.2
 local n=within<.32 and 1 or within<.68 and 2 or 3
 local offset=starts[n]
 local stage=workspace:FindFirstChild('InspectionStage');if not stage then return end
 for _,c in ipairs(stage:GetChildren()) do if c:GetAttribute('InspectionVersion') then
  local cls=c:GetAttribute('K0ClassId');local index=cls=='knight' and (manual and combo or n) or 1
  local d=Config.BasicAttackProfiles[cls].attacks[index];local total=d.windup+d.active+d.recovery
  local started=100+cycle*1.2+offset;local age=within-offset
  if manual then
   started=200
   local impact=d.windup+(d.hitDelay or 0)
   age=manual=='Load' and d.windup*.45 or manual=='Before' and impact-.025 or manual=='Contact' and impact or manual=='After' and impact+.025 or total
  end
  c:SetAttribute('K0Combo',index);c:SetAttribute('K0AttackStartedAt',started);c:SetAttribute('K0State',age<=total and 'Attack' or 'Idle')
  c:SetAttribute('K0AttackPhase',age<d.windup and 'Windup' or age<d.windup+d.active and 'Active' or age<=total and 'Recovery' or 'None')
  local v=visuals[c:GetAttribute('InspectionVersion')];v.renderArms(c,dt,started+age);v.renderCharacter(c,dt,started+age)
 end end
end)
''')
inspect=next(n for n in scripts if n.findtext('./Properties/string[@name="Name"]')=='Inspect')
for folder in list(scripts):
 if folder.get('class')=='Folder':scripts.remove(folder);inspect.append(folder)
ET.ElementTree(tree).write(OUT,encoding='utf-8',xml_declaration=True)
print(json.dumps({'fixture':str(OUT),'sha256':hashlib.sha256(OUT.read_bytes()).hexdigest(),'baseline':'4d24560','candidate_sources':{name:hashlib.sha256((ROOT/f'src/client/{name}.luau').read_bytes()).hexdigest() for name in ['K0MeleeMotion','K0SwordVisual']}}))
