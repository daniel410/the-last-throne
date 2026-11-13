"""수입 원본의 표식으로 방향/이동을 교정하고 편집용 고정 템플릿을 만든다."""
from pathlib import Path
import json
root=Path(__file__).resolve().parents[1];data=json.loads((root/'assets/models/deepwood-elder-grove-v1/geometry.json').read_text())
code='''assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local data=game.HttpService:JSONDecode(DATA)
local source=assert(game.ServerStorage:FindFirstChild('DeepwoodElderGroveImport'))
assert(not game.ServerStorage:FindFirstChild('DeepwoodElderGroveTemplate'),'Preserve prior template')
local V=Vector3.new
local function vec(t)return V(t[1],t[3],-t[2])end
local function expected(key)local d=data.meshes[key];return (vec(d.min)+vec(d.max))/2 end
local rows={};local byName={}
for _,p in ipairs(source:GetDescendants())do
 assert(not p:IsA('LuaSourceContainer'),'Executable asset content')
 if p:IsA('MeshPart')then
  local key=p.Name:gsub('%..*$','');assert(data.meshes[key],p.Name);assert(not byName[key],key)
  assert(p.MeshId~=''and p.TextureID~='','Imported mesh and atlas required')
  rows[#rows+1]={key=key,p=p};byName[key]=p
 end
end
assert(#rows==34,'Incomplete GLB')
local _,size=source:GetBoundingBox();local low,high=math.huge,-math.huge
for _,d in pairs(data.meshes)do low=math.min(low,d.min[3]);high=math.max(high,d.max[3])end
-- Source authoring units are explicitly studs, not real-world metres.
local scale=(high-low)/size.Y;assert(math.abs(scale-1)<.02,'Unexpected import scale')
local ae=byName.Gateway.Position-byName.ElderTrunk.Position;local ee=expected('Gateway')-expected('ElderTrunk')
local yaw=math.atan2(ee.X,ee.Z)-math.atan2(ae.X,ae.Z)
local transform=CFrame.new(expected('ElderTrunk'))*CFrame.Angles(0,yaw,0)*CFrame.new(-byName.ElderTrunk.Position)
local template=Instance.new('Model');template.Name='DeepwoodElderGroveTemplate';template.ModelStreamingMode=Enum.ModelStreamingMode.Nonatomic
local report={meshes=0,sourceModelId='110278314469184',textureId='',yawCorrection=yaw,scale=scale,centerError=0,solidMeshes=0,collisionErrors={}}
for _,row in ipairs(rows)do
 local key=row.key;local p=row.p:Clone();p.Name=key;p.CFrame=transform*p.CFrame;p.Anchored=true;p.CanTouch=false;p.Color=Color3.new(1,1,1)
 p.DoubleSided=true
 local solid=key=='ElderTrunk'or key:match('^ElderRoot%d+$')or key=='Gateway'or key=='RootOutpost'or key=='MapTable'or key=='SupplyProps'or key=='SupplyCart'
 p:SetAttribute('ElderGroveSolid',solid and true or false);p.CanCollide=solid and true or false;p.CanQuery=p.CanCollide
 if p.CanCollide then local ok,why=pcall(function()p.CollisionFidelity=Enum.CollisionFidelity.PreciseConvexDecomposition end);if not ok then report.collisionErrors[#report.collisionErrors+1]=tostring(why)end;report.solidMeshes+=1 end
 p.CastShadow=not(key=='GroveGround'or key=='CourtGround'or key=='CourtPavers'or key=='GroundCover'or key=='Wildflowers')
 p:SetAttribute('TLTDecorative',true);p:SetAttribute('TLTSceneryDistance',key:match('^Elder')and 700 or 420)
 p:SetAttribute('GroveComponent',key)
 for _,d in ipairs(p:GetDescendants())do if d:IsA('PackageLink')then d:Destroy()end end
 report.centerError=math.max(report.centerError,(p.Position-expected(key)).Magnitude);report.textureId=p.TextureID;report.meshes+=1;p.Parent=template
end
assert(report.centerError<.01,'Orientation or mirroring mismatch')
assert(#report.collisionErrors==0,'Collision authoring failed')
template:SetAttribute('BlenderSource','deepwood-elder-grove-v1');template:SetAttribute('GroveVersion',1);template:SetAttribute('SourceModelAssetId','110278314469184');template.WorldPivot=CFrame.identity;template.Parent=game.ServerStorage
local preview=template:Clone();preview.Name='DeepwoodElderGrovePreview';preview:PivotTo(CFrame.new(0,7,0));preview.Parent=workspace
workspace.CurrentCamera.CFrame=CFrame.lookAt(V(205,242,335),V(8,47,58))
game.ChangeHistoryService:SetWaypoint('Normalize Elder Grove import')
_G.ElderGroveImportReport=report
return report
'''.replace('DATA',json.dumps(json.dumps(data,separators=(',',':'))))
Path('/tmp/tlt-normalize-elder-grove.luau').write_text(code);print('/tmp/tlt-normalize-elder-grove.luau')
