-- Isolated edit-mode engine geometry; no real touch input or published client.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local fixture only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local G=require(game.ReplicatedStorage.Shared.HeroProgression)
local P=require(game.ReplicatedStorage.Shared.SkillStatPreview)
local Stats=require(client.HeroStatsView)
local Theme=require(client.TDInventoryTheme)
local Menu=require(client.MobileActionMenu)
local report={kind='MOBILE_MENU_STATS_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local screen=Instance.new('ScreenGui');screen.Name='MobileStatsQA';screen.Parent=game.CoreGui
local body=Instance.new('ScrollingFrame');body.BackgroundTransparency=1;body.Parent=screen
local ok,err=xpcall(function()
 for _,size in ipairs({Vector2.new(280,550),Vector2.new(390,650),Vector2.new(700,170)}) do
  body.Size=UDim2.fromOffset(size.X,size.Y);task.wait()
  for _,classId in ipairs({'knight','elf','dwarf','mage'}) do
   local g=G.new(20);local hero={heroId='qa',baseClassId=classId,progression=g}
   local snapshot={ready=true,atHub=true,items={},stats={power=7,health=30,armor=2}}
   local draft={STR=4,DEX=0,INT=0,VIT=0}
   local after=G.copy(g);after.stats.STR+=4
   for _,section in ipairs({'Combat','Points','Gear','Skills'}) do
    body:ClearAllChildren()
    local state={mobile=true,section=section,gearExpanded=true}
    local height=Stats.render(body,hero,snapshot,P.derived(classId,after,snapshot.stats),draft,{requestId='same-save'},function()end,function()end,function()end,function()end,state)
    task.wait()
    local names={Combat='CombatStats',Points='StatAllocation',Gear='HeroEquipment',Skills='PreviewTitle'}
    check(body:FindFirstChild(names[section])~=nil,'selected content exists '..section)
    for id,name in pairs(names) do if id~=section then check(not body:FindFirstChild(name),'other section absent '..name) end end
    check(body:FindFirstChild('RetrySave')~=nil,'same-save retry available in every section')
    for _,id in ipairs({'Combat','Points','Gear','Skills'}) do
     local b=body['Section'..id]
     check(b.Size.Y.Offset>=44 and b.Size.X.Offset>=44,'section touch target')
     check(b:GetAttribute('Selected')==(id==section),'selected section feedback')
    end
    for _,child in ipairs(body:GetChildren()) do
     if child:IsA('GuiObject') then
      check(child.Position.Y.Offset+child.Size.Y.Offset<=height,'content inside vertical canvas '..child.Name)
      check(child.AbsolutePosition.X+child.AbsoluteSize.X<=body.AbsolutePosition.X+body.AbsoluteSize.X,'no horizontal overflow '..child.Name)
     end
    end
    if section=='Points' then
     check(not body.StatAllocation.ApplyPoints.Active,'pending save blocks duplicate confirmation')
     check(body.StatAllocation.STR.Minus.Size.X.Offset>=44,'minus touch width')
    elseif section=='Combat' then
     check(body.CombatStats.physicalPower.Draft~=nil,'draft stays separate from saved total')
    end
   end
  end
 end
 body:ClearAllChildren()
 local scaled=Instance.new('Frame');scaled.Parent=body
 local scale=Instance.new('UIScale');scale.Scale=.62;scale.Parent=scaled
 local menu=Theme.frame(scaled,'Actions',UDim2.fromOffset(0,248),UDim2.fromOffset(168,238))
 local buttons={}
 for i,id in ipairs({'Hero','Bag','Journal','Settings','BackToLobby'}) do
  buttons[i]=Theme.button(menu,id,id,UDim2.fromOffset(10,i*40),UDim2.fromOffset(148,36))
 end
 local trigger=Theme.button(scaled,'Trigger','MENU',UDim2.fromOffset(130,0),UDim2.fromOffset(40,40))
 local layout=Menu.bind(body,menu,buttons,trigger)
 for _,size in ipairs({Vector2.new(280,550),Vector2.new(750,250),Vector2.new(390,650),Vector2.new(1160,700)}) do
  body.Size=UDim2.fromOffset(size.X,size.Y);task.wait();layout();task.wait()
  if size.X<600 or size.Y<400 then
   check(menu.Parent==body,'mobile menu escapes minimap scale')
   check(trigger.Parent==body and trigger.AbsoluteSize.Y>=44,'menu toggle escapes minimap scale')
   check(menu.AbsolutePosition.Y+menu.AbsoluteSize.Y<=body.AbsolutePosition.Y+body.AbsoluteSize.Y,'menu fits height')
   for _,b in ipairs(buttons) do
    check(b.AbsoluteSize.Y>=52,'effective touch height after minimap scale')
    check(b.Position.Y.Offset+b.Size.Y.Offset<=menu.Size.Y.Offset,'action fits menu')
    check(not b.Caption.Text:find('%[[HBJ]%]'),'mobile hides keyboard hints')
   end
  else check(menu.Parent==scaled and menu.Size==UDim2.fromOffset(168,238),'desktop restores menu parent and size') end
 end
end,debug.traceback)
screen:Destroy()
if not ok then table.insert(report.failures,tostring(err))end
report.pass=ok;return report
