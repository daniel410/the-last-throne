local RS=game:GetService('ReplicatedStorage')
local Content=require(RS.Shared.CampaignContent)
local Text=require(RS.Shared.K0Text)
local Theme=require(script.Parent.TDInventoryTheme)
local Notice={}
function Notice.create(parent,player)
 local frame=Theme.frame(parent,'StoryRegionNotice',UDim2.new(.5,0,.24,0),UDim2.new(1,-32,0,76))
 frame.AnchorPoint=Vector2.new(.5,0);frame.Visible=false;frame.Active=false;frame.ZIndex=8
 local size=Instance.new('UISizeConstraint');size.MaxSize=Vector2.new(420,76);size.Parent=frame
 local title=Theme.label(frame,'Heading',Text.StoryRegionEntering,UDim2.fromOffset(12,5),UDim2.new(1,-24,0,22),12,Theme.color.gold)
 title.Font=Enum.Font.GothamBold;title.TextXAlignment=Enum.TextXAlignment.Center;title.ZIndex=9
 local name=Theme.label(frame,'RegionName','',UDim2.fromOffset(12,27),UDim2.new(1,-24,0,40),22,Theme.color.text)
 name.Font=Enum.Font.GothamBlack;name.TextXAlignment=Enum.TextXAlignment.Center;name.TextScaled=true;name.TextStrokeTransparency=.25;name.ZIndex=9
 local limit=Instance.new('UITextSizeConstraint');limit.MinTextSize=12;limit.MaxTextSize=22;limit.Parent=name
 local last,token=nil,0
 local function refresh()
  local id=player:GetAttribute('TLTStoryRegion')
  local active=player:GetAttribute('K0SessionPhase')=='Tutorial' and player:GetAttribute('TLTRoute')~='Training'
  if not active or not Content.zones[id] then last=nil;token+=1;frame.Visible=false;return end
  if id==last then return end
  last=id;token+=1;local own=token
  name.Text=Content.zones[id].name;frame.Visible=true
  task.delay(3.5,function()if own==token and frame.Parent then frame.Visible=false end end)
 end
 local connections={}
 for _,attribute in ipairs({'TLTStoryRegion','K0SessionPhase','TLTRoute'})do table.insert(connections,player:GetAttributeChangedSignal(attribute):Connect(refresh))end
 frame.Destroying:Connect(function()for _,connection in ipairs(connections)do connection:Disconnect()end end)
 refresh()
 return frame
end
return Notice
