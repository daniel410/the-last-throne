-- Run against each frozen product artifact; no player identity or live persistence claims.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Local unpublished artifact required')
local Run=game:GetService('RunService')
local report={kind='NPC_BOOTSTRAP_NATIVE',role=game.ServerStorage.ServerRole.Value,checks=0,failures={}}
local function check(v,m) report.checks+=1;assert(v,m) end
local ok,e=xpcall(function()
 Run:Run()
 local deadline=os.clock()+30
 repeat
  task.wait(.1)
  local templates=game.ServerStorage:FindFirstChild('NPCCastV1')
  local remotes=game.ReplicatedStorage:FindFirstChild('Remotes')
  if templates and #templates:GetChildren()==30 and remotes and remotes:FindFirstChild('NPCDialogue') then break end
 until os.clock()>=deadline
 check(game.ServerStorage:FindFirstChild('NPCCastV1') and #game.ServerStorage.NPCCastV1:GetChildren()==30,'runtime builds full private template library')
 check(game.ServerStorage.NPCCastV1.selene:GetAttribute('TDSourceModel')=='nun','template library uses TD Selene')
 check(game.ReplicatedStorage.Remotes:FindFirstChild('NPCDialogue')~=nil,'server initializes NPC dialogue remote')
 check(workspace:GetAttribute('TLTServerRole')==report.role,'role boot completed')
 local campaign=workspace:FindFirstChild('DeepwoodCampaign');check(campaign~=nil,'campaign created')
 local cast=0;for _,v in ipairs(campaign:GetDescendants()) do if v:IsA('Model') and v:GetAttribute('TLTNPC') then cast+=1 end end
 check(cast>=15,'authored quest NPCs use new visual system')
 local lobby=workspace:FindFirstChild('DawnspireLobbyPrototype')
 if report.role=='Lobby' then
  check(lobby~=nil and #lobby.DawnspireResidents:GetChildren()==6,'lobby has six service/resident characters')
  check(lobby.DawnspireWeaponMerchant.Aldric:GetAttribute('NPCId')=='aldric','forge uses new smith')
  local residents=lobby.DawnspireResidents
  check(residents.Mira.ActorRoot.NPCInteract.ActionText=='Browse weapons','Mira exposes real weapon service')
  check(residents.Selene.ActorRoot.NPCInteract.ActionText=='Talk' and residents.Nia.ActorRoot.NPCInteract.ActionText=='Talk','resident conversations available')
  check(residents.Selene:GetAttribute('TDSourceModel')=='nun' and residents.Selene:FindFirstChild('Body'):IsA('MeshPart'),'lobby loads original TD priest meshes')
  local cf,size=residents.Selene:GetBoundingBox()
  for _,part in ipairs(lobby.DawnspireWeaponMerchant:GetChildren()) do if part:IsA('BasePart') and part.Name=='CanopyPost' then
   local d=cf.Position-part.Position;local half=(size+part.Size)/2
   check(math.abs(d.X)>half.X or math.abs(d.Y)>half.Y or math.abs(d.Z)>half.Z,'TD Selene clears every forge post')
  end end
 else check(not lobby,'battle does not construct public lobby NPCs') end
 -- All source parses at plugin security, including the client UI path not run without a Player.
 for _,container in ipairs({game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client}) do
  for _,module in ipairs(container:GetDescendants()) do if module:IsA('ModuleScript') then
   local compiled,reason=loadstring(module.Source);check(compiled~=nil,module:GetFullName()..': '..tostring(reason))
  end end
 end
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(e)) end
if Run:IsRunning() then Run:Stop() end
report.pass=#report.failures==0
print('NPC_BOOTSTRAP_NATIVE '..game.HttpService:JSONEncode(report))
assert(report.pass,'NPC bootstrap failed')
