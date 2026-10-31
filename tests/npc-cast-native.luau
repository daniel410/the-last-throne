-- Engine verification of visible cast, safe authored anchors and existing world integration.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Isolated local fixture required')
local report={kind='NPC_CAST_NATIVE',checks=0,characters=0,parts=0,failures={}}
local function check(v,m) report.checks+=1;assert(v,m) end
local ok,err=xpcall(function()
 local World=game.ServerScriptService.Server.World
 local C=require(game.ReplicatedStorage.Shared.NPCCatalog)
 local Cast=require(World.NPCCast);local V=require(World.NPCVisual)
 local folder=Instance.new('Folder');folder.Name='CastQA';folder.Parent=workspace
 local templates=Cast.templates();check(#templates:GetChildren()==30,'all thirty identities are engine models')
 for _,c in ipairs(C.characters) do
  local model=templates:FindFirstChild(c.id);check(model~=nil,'template exists: '..c.id)
  check(model:GetAttribute('NPCId')==c.id and model.PrimaryPart~=nil,'stable NPC identity and movement root')
  check(not model:FindFirstChildOfClass('Humanoid'),'static cast does not consume AI actors')
  if c.id=='selene' then check(model:GetAttribute('TDSourceModel')=='nun','Selene template uses original TD nun')
  else
   check(model.FaceRig.Head:FindFirstChildOfClass('SpecialMesh').MeshType==Enum.MeshType.Sphere and model.FaceRig:FindFirstChild('Nose') and model.FaceRig:FindFirstChild('Smile'),'smooth sculpted face with nose and smile')
   check(model.Torso.Shape==Enum.PartType.Block,'rectangular body')
  end
  local limbs=0
  for _,v in ipairs(model:GetDescendants()) do
   check(not v:IsA('LuaSourceContainer'),'art contains no scripts')
   if v:IsA('BasePart') then
    report.parts+=1;check(v.Anchored and not v.CanCollide and not v.CanTouch and not v.CanQuery,'art does not obstruct combat or travel')
    if c.id~='selene' and (v.Name:find('Arm') or v.Name:find('Leg') or v.Name=='Hand' or v.Name=='Boot') then limbs+=1;check(v.Shape==Enum.PartType.Block,'limb is cuboid') end
    if c.id=='selene' and v:IsA('MeshPart') then
     local original=game.ServerStorage.TDSeleneModels.nun:FindFirstChild(v.Name,true)
     check(original and original.MeshId==v.MeshId and original.TextureID==v.TextureID,'Selene template retains TD mesh and texture')
    end
   end
  end
  if c.id~='selene' then check(limbs==12,'full segmented block limbs') end;report.characters+=1
 end
 local bad=pcall(function() Cast.region(folder,'frozen-vale',{}) end)
 check(not bad and #folder:GetChildren()==0,'missing region anchors fail before creating partial NPCs')
 local preview=Cast.preview(folder,Vector3.new(2000,100,0));check(#preview:GetChildren()==6,'all region kits instantiate')
 local scout=V.actor(folder,'Wounded Scout',Vector3.new(0,50,0));scout:PivotTo(CFrame.new(10,50,20))
 check((scout.PrimaryPart.Position-Vector3.new(10,50,20)).Magnitude<.01,'escort root follows existing pivot contract')
 check(scout.PrimaryPart.NPCLabel.TextLabel.Text=='Wounded Scout','quest alias label preserved')
 local selene=require(World.SeleneVisual).create(folder,Vector3.new(20,50,20),'SeleneCamp')
 check(selene.Name=='SeleneCamp' and selene:GetAttribute('NPCId')=='selene','camp/follower identity unchanged')
 check(selene:GetAttribute('TDSourceModel')=='nun','camp uses original TD model')
 local lobby=require(World.LobbyWorld).create();local merchant=require(World.WeaponMerchant).create(lobby)
 local facilities=require(World.LobbyLandmarks).create(lobby);local _,storagePrompt=require(World.StorageChest).create(lobby)
 local residents=require(World.LobbyResidents).create(lobby,facilities,storagePrompt)
 check(residents.selene.model:GetAttribute('TDSourceModel')=='nun' and residents.selene.prompt.Parent==residents.selene.model.PrimaryPart,'lobby uses TD model with working prompt anchor')
 check(merchant.npc:GetAttribute('NPCId')=='aldric' and merchant.prompt.ObjectText=='Aldric · Blacksmith','smith replaces old placeholder and retains trade prompt')
 check(residents.mira.prompt.ActionText=='Browse weapons','merchant uses existing weapon shop')
 check(storagePrompt.ObjectText=='Oren · Account Storage' and facilities.training.prompt.ObjectText=='Rowan · Hero Trainer','storage/training facility identity')
 local deepwood=require(World.DeepwoodWorld).create();local count=0;local pip=false;local eryn=false
 for _,v in ipairs(deepwood.folder:GetDescendants()) do if v:IsA('Model') and v:GetAttribute('TLTNPC') then
  count+=1;pip=pip or v:GetAttribute('NPCId')=='pip';eryn=eryn or v:GetAttribute('NPCId')=='eryn'
  check(not v:GetAttribute('EnemyKind'),'friendly actors are not combat enemies')
 end end
 check(count>10 and pip and eryn,'Deepwood quest, refugee, survivor and camp art is connected')
 report.deepwoodActors=count
 folder:Destroy()
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err)) end
report.pass=#report.failures==0
print('NPC_CAST_NATIVE '..game:GetService('HttpService'):JSONEncode(report))
assert(report.pass,'NPC cast native verification failed')
return report
