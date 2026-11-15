assert(game.PlaceId==0,'Unpublished local QA only')
local S=game.ServerScriptService.Server
local I,H=require(S.Inventory.InventoryService),require(S.Lobby.HeroSessionService)
local C,P=require(game.ReplicatedStorage.Shared.CampaignContent),require(game.ReplicatedStorage.Shared.DeepwoodProgress)
local G=require(game.ReplicatedStorage.Shared.HeroProgression)
local q=Instance.new('BindableFunction');q.Name='ModeProgressQA'
q.OnInvoke=function(action)
 local player=game.Players:GetPlayers()[1];local hero=H.getActiveHero(player)
 if not hero then return 'HeroNotReady'end
 local run=I.expedition(player,hero.heroId)
 if action=='complete_first_quest' then
  assert(run and run.missionId=='DW-01','first quest admission required')
  local c=C.byId['DW-01']
  for _,g in ipairs(c.goals)do if P.required(I.storyState(player,hero.heroId),g)then
   for _,step in ipairs(g.activity and g.activity.steps or {false})do
    local choice=step and step.choices and(step.solution or step.choices[1].id)or g.choice and 'shared'or nil
    assert(not I.storyEvent(player,hero.heroId,c.id,g.id,choice,step and step.id or nil,run.runId),'QA story save failed')
   end
  end end
 end
 local data=I.snapshot(player);local stored=data.heroes and data.heroes[hero.heroId]
 local profile=I.expeditionHero(player)
 local journals={}
 for _,mode in ipairs({'Easy','Hard','Insane','Hell'})do
  local j=profile.expeditions.modeJournals[mode];journals[mode]={main=j.main,firstQuestComplete=j.clears['DW-01']==true}
 end
 local fine=0;for _,item in pairs(data.items or {})do if item.definitionId=='knight_weapon_fine'then fine=fine+item.quantity end end
 return game.HttpService:JSONEncode({phase=player:GetAttribute('K0SessionPhase'),run=I.expedition(player,hero.heroId),journals=journals,
  wallet=data.wallet,totalXP=G.totalXP(profile.progression),fineWeapons=fine,journal=I.storyState(player,hero.heroId)})
end
q.Parent=game.ServerStorage
