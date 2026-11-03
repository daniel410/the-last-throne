-- Isolated local rendered review. No live saves, Players or Place publication.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Isolated Selene visual QA')
local Run=game:GetService('RunService');Run:Run();task.wait(2)
local folder=Instance.new('Folder');folder.Name='SeleneRepairReview';folder.Parent=workspace
local ground=Instance.new('Part');ground.Size=Vector3.new(30,1,25);ground.CFrame=CFrame.new(10000,49.5,0);ground.Anchored=true;ground.Parent=folder
local model=require(game.ServerScriptService.Server.World.SeleneVisual).create(folder,Vector3.new(10000,50,0),'Selene',{label=false})
local description=Instance.new('HumanoidDescription')
local recipient=game.Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15)
description:Destroy();recipient.Name='SupportRecipient';recipient.Parent=folder
recipient:PivotTo(CFrame.new(10005,53,0));recipient.HumanoidRootPart.Anchored=true
local view=assert(require(game.StarterPlayer.StarterPlayerScripts.Client.SelenePresentation).bind(model,function()return recipient end))
workspace:SetAttribute('SeleneRepairClip','Idle');workspace:SetAttribute('SeleneRepairPhase',.25)
local previous
local connection=Run.Heartbeat:Connect(function()
 local clip=workspace:GetAttribute('SeleneRepairClip')or'Idle'
 local support=clip=='Heal'or clip=='Protect'or clip=='Cleanse'
 local speed=clip=='Walk'and 10 or 0
 model:SetAttribute('SeleneMoveSpeed',speed);view.speed=speed
 view.phase=(workspace:GetAttribute('SeleneRepairPhase')or .25)*math.pi*2
 model:SetAttribute('SupportAt',support and 100 or nil)
 if clip~=previous then
  view:destroy()
  if support then view:play(100,clip,12,recipient)end
  previous=clip;view.seen=100
 end
 view:update(0,100+.625)
end)
game.ContentProvider:PreloadAsync(folder:GetDescendants())
print('SELENE_REPAIR_PREVIEW_READY')
workspace:SetAttribute('SeleneRepairReady',true)
local finish
finish=workspace:GetAttributeChangedSignal('SeleneRepairFinish'):Connect(function()
 if workspace:GetAttribute('SeleneRepairFinish')then
  finish:Disconnect();connection:Disconnect();view:destroy();folder:Destroy()
 end
end)
return 'SELENE_REPAIR_PREVIEW_READY'
