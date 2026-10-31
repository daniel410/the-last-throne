-- Show only unlocks observed between server-confirmed account snapshots.
local RS=game:GetService('ReplicatedStorage')
local TweenService=game:GetService('TweenService')
local Http=game:GetService('HttpService')
local Advanced=require(RS.Shared.AdvancedSkills)
local Text=require(RS.Shared.K0Text)
local Theme=require(script.Parent.TDInventoryTheme)
local Notice={}
function Notice.create(parent)
 local gui=Instance.new('ScreenGui');gui.Name='SkillUnlockNotice';gui.ResetOnSpawn=false;gui.DisplayOrder=85;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=parent
 local frame=Theme.frame(gui,'Announcement',UDim2.new(.5,0,.24,0),UDim2.new(1,-32,0,132));frame.AnchorPoint=Vector2.new(.5,0);frame.Visible=false;frame.Active=false
 local size=Instance.new('UISizeConstraint');size.MaxSize=Vector2.new(440,132);size.Parent=frame
 local scale=Instance.new('UIScale');scale.Parent=frame
 local sparkle=Theme.label(frame,'Sparkle','✦',UDim2.fromOffset(16,31),UDim2.fromOffset(46,54),38,Theme.color.gold);sparkle.TextXAlignment=Enum.TextXAlignment.Center
 local heading=Theme.label(frame,'Heading',Text.SkillUnlockedTitle,UDim2.fromOffset(62,10),UDim2.new(1,-78,0,25),15,Theme.color.gold);heading.Font=Enum.Font.GothamBlack
 local name=Theme.label(frame,'SkillName','',UDim2.fromOffset(62,38),UDim2.new(1,-78,0,38),22,Theme.color.text);name.Font=Enum.Font.GothamBlack;name.TextScaled=true
 local limit=Instance.new('UITextSizeConstraint');limit.MinTextSize=12;limit.MaxTextSize=22;limit.Parent=name
 local hint=Theme.label(frame,'Hint','',UDim2.fromOffset(62,82),UDim2.new(1,-78,0,40),12,Theme.color.silver)
 local queue={};local shown=false;local token=0;local currentHero,lastRevision,lastGrowth,lastClass=nil,-1,nil,nil
 local function clear()
  table.clear(queue);shown=false;token+=1;frame.Visible=false
 end
 local showNext
 showNext=function()
  if shown or #queue==0 or not gui.Parent then return end
  local item=table.remove(queue,1);shown=true;token+=1;local own=token
  name.Text=item.name;hint.Text=item.ultimate and Text.UltimateUnlockedHint or Text.SkillUnlockedHint
  frame.Visible=true;scale.Scale=.78
  TweenService:Create(scale,TweenInfo.new(.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
  task.delay(3.5,function()if own~=token or not gui.Parent then return end;frame.Visible=false;shown=false;showNext()end)
 end
 local function receive(snapshot)
  if type(snapshot)~='table' or not snapshot.ready or type(snapshot.revision)~='number' or type(snapshot.heroId)~='string' then return end
  if snapshot.revision<lastRevision then return end
  local hero=type(snapshot.heroes)=='table' and snapshot.heroes[snapshot.heroId]
  local g=hero and hero.progression;local class=hero and hero.baseClassId
  if type(g)~='table' or type(g.level)~='number' or type(g.stage)~='number' or type(g.branch)~='string' or not Advanced.order[class] then return end
  if currentHero~=snapshot.heroId or lastClass~=class then clear();currentHero=snapshot.heroId;lastGrowth=nil;lastClass=class end
  if lastGrowth and snapshot.revision>lastRevision then
   for index=4,Advanced.maxIndex do
    local skill=Advanced.get(class,index)
    if skill and Advanced.unlocked(g,class,index) and not Advanced.unlocked(lastGrowth,class,index) then table.insert(queue,skill) end
   end
  end
  lastRevision=snapshot.revision;lastGrowth={level=g.level,stage=g.stage,branch=g.branch}
  showNext()
 end
 return {gui=gui,receive=receive}
end
function Notice.start(player)
 local view=Notice.create(player:WaitForChild('PlayerGui'))
 task.spawn(function()
  local remotes=RS:WaitForChild('Remotes');local request=remotes:WaitForChild('InventoryRequest')
  local connection=remotes:WaitForChild('InventoryState').OnClientEvent:Connect(view.receive)
  view.gui.Destroying:Connect(function()connection:Disconnect()end)
  request:FireServer({action='GetState',requestId=Http:GenerateGUID(false)})
 end)
 return view
end
return Notice
