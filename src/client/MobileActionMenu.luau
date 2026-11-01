-- Keep touch menus outside the minimap's HUD scale and inside safe GUI bounds.
local UIS=game:GetService('UserInputService')
local Navigation=require(game.ReplicatedStorage.Shared.NavigationText)
local M={}
function M.bind(host,menu,entries,trigger)
 local originalParent,originalSize,originalPosition=menu.Parent,menu.Size,menu.Position
 local triggerOriginal=trigger and {parent=trigger.Parent,size=trigger.Size,position=trigger.Position}
 local originals={}
 for i,button in ipairs(entries) do
  originals[i]={position=button.Position,size=button.Size,text=button.Caption.Text}
 end
 local function layout()
  local size=host.AbsoluteSize
  if size.X<=0 or size.Y<=0 then return end
  local mobile=size.X<600 or size.Y<400 or (UIS.TouchEnabled and size.X<1000)
  menu:SetAttribute('MobileLayout',mobile)
  if mobile then
   local width=math.min(368,size.X-24)
   local height=16+math.ceil(#entries/2)*60
   if trigger then trigger.Parent=host;trigger.Size=UDim2.fromOffset(48,48);trigger.Position=UDim2.new(1,-60,0,4) end
   menu.Parent=host;menu.Size=UDim2.fromOffset(width,height)
   menu.Position=UDim2.new(1,-width-12,0,math.max(8,math.min(60,size.Y-height-8)))
   local w=(width-28)/2
   for i,button in ipairs(entries) do
    button.Position=UDim2.fromOffset(10+((i-1)%2)*(w+8),8+math.floor((i-1)/2)*60)
    button.Size=UDim2.fromOffset(w,52)
    button.Caption.Text=button.Name=='Hero' and Navigation.mobileHero or button.Name=='Bag' and Navigation.mobileBag or button.Name=='Journal' and Navigation.mobileJournal or originals[i].text
   end
  else
   if trigger then trigger.Parent=triggerOriginal.parent;trigger.Size=triggerOriginal.size;trigger.Position=triggerOriginal.position end
   menu.Parent=originalParent;menu.Size=originalSize;menu.Position=originalPosition
   for i,button in ipairs(entries) do
    button.Position=originals[i].position;button.Size=originals[i].size;button.Caption.Text=originals[i].text
   end
  end
 end
 local connection=host:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout)
 local inputConnection=UIS:GetPropertyChangedSignal('TouchEnabled'):Connect(layout)
 host.Destroying:Connect(function() connection:Disconnect();inputConnection:Disconnect() end)
 layout()
 return layout
end
return M
