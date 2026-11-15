assert(game.PlaceId==0,'Local QA only')
local S=game.ServerScriptService.Server
local H=require(S.Lobby.HeroSessionService)
local I=require(S.Inventory.InventoryService)
local D=require(S.Story.DeepwoodService)
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local R=require(game.ReplicatedStorage.Shared.CampaignCombatRoutes)
local request=Instance.new('BindableFunction');request.Name='HardRouteQARequest'
request.OnInvoke=function(action)
 local p=game.Players:GetPlayers()[1];local h=H.getActiveHero(p);local run=h and I.expedition(p,h.heroId)
 if action=='arrive' then
  local c=C.byId[run.missionId];local g=c.goals[1];local at=R.entry(c,g,run,1)
  require(S.Combat.CombatService).relocateForStoryGate(p,CFrame.new(at[1],at[2]+3.18,at[3]))
  task.wait(.8)
 elseif action=='defeat' then
  for _,m in ipairs(workspace.DeepwoodK0.Enemies:GetChildren())do
   local key=m:GetAttribute('DeepwoodEncounter');local human=m:FindFirstChildOfClass('Humanoid')
   if key and key:find(run.runId,1,true)and human and human.Health>0 then human.Health=0 end
  end
  task.wait(.8)
 end
 return game.HttpService:JSONEncode({phase=p:GetAttribute('K0SessionPhase'),run=run and {id=run.runId,mode=run.difficultyId,kills=run.kills},
  encounters=h and workspace:FindFirstChild('DeepwoodK0') and D.encounterState(p,h.heroId),position=tostring(p.Character:GetPivot().Position)})
end
request.Parent=game.ServerStorage
