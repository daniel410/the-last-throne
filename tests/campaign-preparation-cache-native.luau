assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated Edit QA only')
local root=game.ServerScriptService.Server.World
local P,W,D,A,R,S=require(root.CampaignPreparation),require(root.CampaignWorld),require(root.DeepwoodWorld),require(root.EpicWorldArt),require(root.RegionalConceptArt),require(root.CampaignSurfaceFinish)
local create,current,connect,finish,surface=W.create,D.current,A.connectOverland,R.finish,S.apply
local world=P.new('CampaignCacheQA');local fail=true
local ok,err=xpcall(function()
 W.create=function(_,stage)D.current=stage;if fail then error('initial region failure')end;return stage end
 A.connectOverland=function()end;R.finish=function()end;S.apply=function()end
 assert(not pcall(P.prepare,1,world)and D.current==nil,'failed stage cache must be released')
 fail=false;P.prepare(1,world)
 assert(D.current==world and world.folder.Parent==workspace,'successful cache must reference live world')
end,debug.traceback)
W.create=create;D.current=current;A.connectOverland=connect;R.finish=finish;S.apply=surface
world.folder:Destroy();assert(ok,err)
return {checks=2,pass=true}
