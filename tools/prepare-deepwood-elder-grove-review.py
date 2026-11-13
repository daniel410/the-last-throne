"""수입된 실제 MeshPart를 검수 좌표로 정규화한다. 게임 소스에는 자동 연결하지 않는다."""
from pathlib import Path
import argparse,json
root=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,default=Path('/tmp/tlt-elder-grove-review.luau'));args=p.parse_args()
manifest=json.loads((root/'assets/models/deepwood-elder-grove-v1/geometry.json').read_text())
code='''-- Local review only. Run after an authorized import into ServerStorage.DeepwoodElderGroveImport.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Local player-free review required')
local source=assert(game.ServerStorage:FindFirstChild('DeepwoodElderGroveImport'),'Import the real GLB first; no primitive fallback')
assert(source:IsA('Model'),'Imported Model required')
assert(not workspace:FindFirstChild('DeepwoodElderGroveCandidate'),'Preserve the existing candidate')
local data=game.HttpService:JSONDecode(MANIFEST_JSON)
local V=Vector3.new
local function vec(p)return V(p[1],p[3],-p[2])end
local names={};for name in pairs(data.meshes)do names[#names+1]=name end
table.sort(names,function(a,b)return #a>#b end)
local function component(name)
 for _,key in ipairs(names)do
  if name==key or(name:sub(1,#key)==key and name:sub(#key+1,#key+1):match('[._]'))then return key end
 end
end
local parts={};local seen={};local textures=0
for _,p in ipairs(source:GetDescendants())do
 assert(not p:IsA('LuaSourceContainer'),'Executable content rejected')
 if p:IsA('BasePart')then
  assert(p:IsA('MeshPart')and p.MeshId~='','Only real imported MeshParts are accepted')
  local key=assert(component(p.Name),'Unrecognized mesh '..p.Name)
  assert(not seen[key],'Duplicate imported component '..key);seen[key]=true
  local appearance=p:FindFirstChildOfClass('SurfaceAppearance')
  assert(p.TextureID~=''or(appearance and appearance.ColorMap~=''),'Missing imported atlas '..key)
  textures+=1;parts[#parts+1]={part=p,key=key}
 end
end
assert(#parts==#names,'Incomplete imported scene')
local lo=V(math.huge,math.huge,math.huge);local hi=-lo
for _,g in pairs(data.meshes)do
 local a,b=vec(g.min),vec(g.max)
 lo=V(math.min(lo.X,a.X,b.X),math.min(lo.Y,a.Y,b.Y),math.min(lo.Z,a.Z,b.Z))
 hi=V(math.max(hi.X,a.X,b.X),math.max(hi.Y,a.Y,b.Y),math.max(hi.Z,a.Z,b.Z))
end
local importedCF,importedSize=source:GetBoundingBox();local expected=hi-lo
assert((importedSize-expected).Magnitude<expected.Magnitude*.015,'Import scale/orientation mismatch')
local delta=importedCF.Position-(lo+hi)/2
local origin=V(table.unpack(data.originRoblox))
local model=Instance.new('Model');model.Name='DeepwoodElderGroveCandidate'
model:SetAttribute('PrototypeOnly',true);model:SetAttribute('BlenderSource','deepwood-elder-grove-v1')
model:SetAttribute('ImportedMeshCount',#parts);model:SetAttribute('GroveVersion',data.version)
local solidCount=0
for _,row in ipairs(parts)do
 local p=row.part:Clone();p.Name=row.key;p.Anchored=true;p.CanTouch=false
 p.CFrame=CFrame.new(origin-delta)*p.CFrame
 local solid=row.key=='ElderTrunk'or row.key:match('^ElderRoot%d+$')or row.key=='Gateway'or row.key=='RootOutpost'or row.key=='MapTable'or row.key=='SupplyProps'or row.key=='SupplyCart'
 p.CanCollide=solid and true or false;p.CanQuery=p.CanCollide
 if p.CanCollide then
  local ok,why=pcall(function()p.CollisionFidelity=Enum.CollisionFidelity.PreciseConvexDecomposition end)
  assert(ok,'Author collision fidelity in the authorized import: '..tostring(why));solidCount+=1
 end
 p.CastShadow=not(row.key=='GroveGround'or row.key=='CourtGround'or row.key=='CourtPavers'or row.key=='GroundCover'or row.key=='Wildflowers')
 p:SetAttribute('TLTDecorative',true);p:SetAttribute('TLTSceneryDistance',row.key:match('^Elder')and 700 or 420)
 p:SetAttribute('GroveComponent',row.key)
 local chunk=Instance.new('Model');chunk.Name=row.key;chunk.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 p.Parent=chunk;chunk.Parent=model
end
model.WorldPivot=CFrame.new(origin);model.Parent=workspace
workspace.CurrentCamera.CFrame=CFrame.lookAt(origin+V(205,235,335),origin+V(8,40,58))
return {candidate=model:GetFullName(),meshCount=#parts,textured= textures,solidMeshes=solidCount,origin=data.originRoblox,warning='Review candidate only; old scenery, foliage collision, route alignment and production integration still require validation'}
'''
code=code.replace('MANIFEST_JSON',json.dumps(json.dumps(manifest,separators=(',',':'))))
args.output.write_text(code);print(args.output)
