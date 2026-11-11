-- Isolated engine verification: actual scenery and personal snapshot projection.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0, 'Use an empty local TLT artifact')
local checks=0
local function check(ok,message) checks+=1;assert(ok,message) end
local server=game.ServerScriptService.Server
local client=game.StarterPlayer.StarterPlayerScripts.Client
for _,root in ipairs({server,client,game.ReplicatedStorage.Shared}) do
 for _,m in ipairs(root:GetDescendants()) do
  if m:IsA('LuaSourceContainer') then check(loadstring(m.Source,m:GetFullName())~=nil,'Luau syntax: '..m:GetFullName()) end
 end
end
local world=require(server.World.LobbyWorld)
local lobby=world.create()
check(world.create().folder==lobby.folder,'repeat world creation reuses the same lobby')
check(lobby.folder.Ground.Size==Vector3.new(300,4,300),'expanded floor is 300 by 300 studs')
check(lobby.bounds.size.X==300 and lobby.bounds.size.Z==300,'server lobby bounds cover the expanded floor')
local throne=lobby.folder.DawnspireThrone
check(throne:GetAttribute('ThroneSource')=='TDLobbyRoyalChair','royal chair comes from the TD lobby source')
check(throne.RoyalThroneSeat.Size==Vector3.new(12,2,8),'TD seat proportions are preserved')
check(throne.RoyalThroneBack.Size==Vector3.new(11,21,2),'TD tall back proportions are preserved')
check(throne.RoyalThroneCushion.Material==Enum.Material.Fabric and throne.RoyalThroneCushion.Color==Color3.fromRGB(37,62,109),'TD blue fabric is preserved')
check(throne.RoyalThroneSeat.Material==Enum.Material.Metal and throne.RoyalThroneSeat.Color==Color3.fromRGB(240,175,50),'TD final gold body is preserved')
check(throne:FindFirstChild('CrystalSpire')==nil and throne:FindFirstChild('ThroneChairPointedCrown')~=nil,'old crystal chair is replaced by TD pointed crown')
check(throne.ModelStreamingMode==Enum.ModelStreamingMode.Atomic,'throne streams as a single model')
check(throne:FindFirstChild('Crownheart',true)==nil,'shared throne has no restored heart')
local parts=0
for _,p in ipairs(lobby.folder:GetDescendants()) do
 if p:IsA('BasePart') then
  parts+=1;check(p.Anchored and not p.CanTouch,'static scenery has no touch gameplay')
 end
end
check(parts<600,'bounded lobby scenery budget')
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={lobby.folder};params.RespectCanCollide=true
local function ground(at)
 local hit=workspace:Raycast(at+Vector3.new(0,8,0),Vector3.new(0,-16,0),params)
 check(hit~=nil,'walk route has ground')
 return hit.Position
end
for _, direction in ipairs({Vector3.new(1,0,0),Vector3.new(-1,0,0),Vector3.new(0,0,1),Vector3.new(0,0,-1)}) do
 ground(lobby.origin+direction*130)
 local wall=workspace:Raycast(lobby.origin+direction*140+Vector3.new(0,3,0),direction*15,params)
 check(wall and wall.Instance:GetAttribute('SafetyBoundary')==true,'expanded perimeter remains closed')
end
local routes=0
local function walk(a,b)
 local last=ground(a)
 local samples=math.max(1,math.ceil((b-a).Magnitude/.75))
 for i=1,samples do
  local next=ground(a:Lerp(b,i/samples))
  check(math.abs(next.Y-last.Y)<.6,'walk route has no jump or abrupt drop')
  check(workspace:Raycast(last+Vector3.new(0,2.5,0),next-last,params)==nil,'walk route has no body obstruction')
  last=next;routes+=1
 end
end
walk(lobby.origin+Vector3.new(0,0,24),lobby.origin+require(game.ReplicatedStorage.Shared.DawnspireDesign).throneOffset+Vector3.new(0,0,8))
local facilities=require(server.World.LobbyLandmarks).create(lobby)
facilities.forge=require(server.World.WeaponMerchant).create(lobby)
local _, storagePrompt=require(server.World.StorageChest).create(lobby)
require(server.World.LobbyResidents).create(lobby,facilities,storagePrompt)
require(server.World.ItemShop).create(lobby)
for _,f in pairs(facilities) do
 check(f.prompt.KeyboardKeyCode==Enum.KeyCode.F and f.prompt.GamepadKeyCode==Enum.KeyCode.ButtonX,'facility inputs preserved')
 local target=(f.anchor or f.counter).Position+Vector3.new(0,0,7)
 walk(lobby.origin+Vector3.new(0,0,24),Vector3.new(0,lobby.origin.Y,target.Z))
 walk(Vector3.new(0,lobby.origin.Y,target.Z),Vector3.new(target.X,lobby.origin.Y,target.Z))
end
-- Execute the actual personal scene and its expansion/atmosphere integration.
local M=require(client.DawnspireHomecoming)
local snap={heroId='finished',heroes={finished={deepwood={clears={['HG-07']=true}}},new={deepwood={clears={}}}}}
M.update(snap)
check(throne:FindFirstChild('DawnspireHomecoming')~=nil,'final clear restores the existing throne')
local scene=throne.DawnspireHomecoming
check(scene.Crownheart.Position==throne:GetAttribute('HeartPosition'),'heart uses throne socket coordinates')
for _,p in ipairs(scene:GetDescendants()) do if p:IsA('BasePart') then check(not p.CanCollide and not p.CanQuery and not p.CanTouch,'personal restoration cannot change physics') end end
M.update(snap);check(throne.DawnspireHomecoming==scene,'repeat snapshots do not duplicate the heart')
snap.heroId='new';M.update(snap)
check(not throne:FindFirstChild('DawnspireHomecoming'),'unfinished hero does not inherit another hero restoration')
check(throne.ThroneStorySign.FacilitySign.Subtitle.Text==require(game.ReplicatedStorage.Shared.DawnspireDesign).text.missing,'unfinished hero sees missing-heart explanation')
snap.heroId='finished';M.update(snap)
M.update(nil);check(not throne:FindFirstChild('DawnspireHomecoming'),'deselection clears restoration')
M.update({heroId='bad',heroes={bad={deepwood={}}}})
check(not throne:FindFirstChild('DawnspireHomecoming'),'partial journal is handled safely')
-- Snapshot first, scenery later, then streaming removal/re-entry.
local old=lobby.folder;old.Parent=nil
M.update(snap)
old.Parent=workspace;task.wait(.2)
check(throne:FindFirstChild('DawnspireHomecoming')~=nil,'snapshot before streamed throne restores on arrival')
old:Destroy()
local replacement=world.create();task.wait(.2)
check(replacement.folder.DawnspireThrone:FindFirstChild('DawnspireHomecoming')~=nil,'streamed replacement reapplies latest snapshot')
M.update({heroId='new',heroes=snap.heroes})
check(not replacement.folder.DawnspireThrone:FindFirstChild('DawnspireHomecoming'),'hero change after streaming clears restoration')
M.update(snap)
local restoredFacilities=require(server.World.LobbyLandmarks).create(replacement)
require(server.World.WeaponMerchant).create(replacement)
local _, chestPrompt=require(server.World.StorageChest).create(replacement)
require(server.World.LobbyResidents).create(replacement,restoredFacilities,chestPrompt)
require(server.World.ItemShop).create(replacement)
workspace.CurrentCamera.CFrame=CFrame.lookAt(lobby.origin+Vector3.new(66,53,52),lobby.origin+Vector3.new(0,7,-45))
game.Lighting.ClockTime=10;game.Lighting.Brightness=2;game.Lighting.Ambient=Color3.fromRGB(90,90,100)
print('DAWNSPIRE_THRONE_NATIVE '..game.HttpService:JSONEncode({pass=true,checks=checks,routeSamples=routes,sceneryParts=parts,coverage='Native geometry and actual personal projection and expansion integration; no real client/device/Teleport acceptance'}))
if _G.TLTThroneReviewPause then task.wait(50) end
return {pass=true,checks=checks}
