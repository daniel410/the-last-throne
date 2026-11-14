assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local Shared=game.ReplicatedStorage.Shared
local source=client.ExpeditionView.Source
local fixture=Instance.new('Folder');fixture.Parent=workspace;fixture:SetAttribute('K0SessionPhase','Lobby')
local replacement="local player={UserId=1,GetAttribute=function()return 'Lobby'end,GetAttributeChangedSignal=function()return script.Fixture.Value:GetAttributeChangedSignal('K0SessionPhase')end}"
local count;source,count=source:gsub('local player=game.Players.LocalPlayer',function()return replacement end);assert(count==1,'local-player seam')
local module=Instance.new('ModuleScript');module.Name='DifficultyDiamondsUIFixture';module.Source=source;module.Parent=client
local ref=Instance.new('ObjectValue');ref.Name='Fixture';ref.Value=fixture;ref.Parent=module
local gui=Instance.new('ScreenGui');gui.Parent=game.CoreGui
local host=Instance.new('Frame');host.BackgroundTransparency=1;host.Parent=gui
local view=require(module).create(host,function()error('no network commands in UI fixture')end);view.panel.Visible=true
local report={checks=0};local function check(v,m)report.checks+=1;assert(v,m)end
local hero={level=80,deepwood={version=2,main=35,clears={}},expeditions={clears={}}}
local missions=require(Shared.ExpeditionPresentation).missions(hero)
for _,size in ipairs({Vector2.new(1280,720),Vector2.new(844,390),Vector2.new(667,375)})do
 host.Size=UDim2.fromOffset(size.X,size.Y);task.wait(.1)
 for _,mode in ipairs(require(Shared.Difficulty).order)do
  view.render({role='Lobby',hero={classId='knight'},selection={missionId='DW-01',difficultyId=mode},missions=missions,list={}})
  task.wait(.1)
  local line=view.panel.PartyList:FindFirstChild('DiamondReward')
  check(line and line.Text=='First '..mode..' clear: '..({Easy=3,Hard=5,Insane=7,Hell=10})[mode]..' Diamonds. Once per hero.','selected difficulty reward visible '..mode)
  check(line.TextBounds.Y<=line.AbsoluteSize.Y+1,'Diamond line fits '..size.X..' '..mode)
  check(line.TextBounds.X<=line.AbsoluteSize.X+1,'Diamond line width fits '..size.X)
 end
 view.render({role='Lobby',hero={classId='knight'},selection={missionId='DW-Q1',difficultyId='Easy'},missions=missions,list={}})
 check(not view.panel.PartyList:FindFirstChild('DiamondReward'),'side has no Diamond reward')
end
view.panel:Destroy();gui:Destroy();module:Destroy();fixture:Destroy()
print('DIFFICULTY_DIAMOND_UI_NATIVE '..game.HttpService:JSONEncode(report))
return report
