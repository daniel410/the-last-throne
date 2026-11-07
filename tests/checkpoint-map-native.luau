-- Native TD controls with the production footer layout; no full gameplay/device claim.
return function(mapSource,themeSource,artSource,iconSource)
 local checks=0;local function check(v,m)checks+=1;assert(v,m)end
 local screen=Instance.new('ScreenGui');screen.Name='CheckpointMapQA';screen.IgnoreGuiInset=true;screen.Parent=game:GetService('CoreGui')
 local ok,result=xpcall(function()
  local art=assert(loadstring(artSource))();local icons=assert(loadstring(iconSource))()
  themeSource=themeSource:gsub('local Art = require%(Shared.TDUI.StatusWindowArtAssets%)','local Art = fixtureArt')
  themeSource=themeSource:gsub('local Icons = require%(Shared.TDUI.UIIconAssets%)','local Icons = fixtureIcons')
  local fn=assert(loadstring(themeSource));setfenv(fn,setmetatable({fixtureArt=art,fixtureIcons=icons},{__index=getfenv()}));local Theme=fn()
  local a=assert(mapSource:find(' layout=function()',1,true));local b=assert(mapSource:find('  local available=area.AbsoluteSize',a,true))
  local layoutSource=mapSource:sub(a,b-1)..' end\nreturn layout'
  for _,size in ipairs({{1366,768},{844,390},{667,375},{390,844},{320,568}})do
   local outer=Instance.new('Frame');outer.Size=UDim2.fromOffset(size[1],size[2]);outer.Parent=screen
   local panel=Theme.frame(outer,'WorldMap',UDim2.new(),UDim2.fromOffset(300,300))
   local function label(name)return Theme.label(panel,name,'Checkpoint',UDim2.new(),UDim2.fromOffset(100,30),12)end
   local function frame(name)local f=Instance.new('Frame');f.Name=name;f.Parent=panel;return f end
   local env={gui=outer,panel=panel,title=label('Title'),progress=label('Progress'),detail=label('RegionDetail'),legend=label('Legend'),hint=label('MapHint'),journey=frame('Journey'),epicTabs=frame('EpicCategories'),compass=label('Compass'),area=frame('Atlas')}
   env.Theme=Theme;env.Text={NavigationOn='Navigation Trail: ON',NavigationOff='Navigation Trail: OFF',Map={TrailOn='TRAIL: ON',TrailOff='TRAIL: OFF'}}
   env.Content={epics={{region='Deepwood'},{region='Frozen Vale'},{region='Ember Caldera'},{region='Gloamwood'},{region='Haunted Graveyard'}}};env.epic=1;env.epicButtons={}
   env.player={GetAttribute=function()return true end};env.categoriesOpen=false
   env.epicPicker=Theme.button(panel,'SelectEpic','',UDim2.new(),UDim2.fromOffset(150,44))
   env.close=Theme.button(panel,'Close','X',UDim2.new(),UDim2.fromOffset(44,44))
   env.epicTabs:Destroy();env.epicTabs=Instance.new('ScrollingFrame');env.epicTabs.Name='EpicCategories';env.epicTabs.Parent=panel
   label('Subtitle')
   for _,name in ipairs({'navigation','minus','plus','fit','you'})do env[name]=Theme.button(panel,name,'+',UDim2.new(),UDim2.fromOffset(44,40))end
   env.travel=Theme.button(panel,'TravelCheckpoint','TRAVEL · ERYN',UDim2.new(),UDim2.fromOffset(200,40),true);env.travel.Caption.TextSize=11
   setmetatable(env,{__index=getfenv()});task.wait(.03)
   local run=assert(loadstring('local layout\n'..layoutSource));setfenv(run,env);run()();task.wait(.03)
   local button=env.travel;local bottom=button.AbsolutePosition.Y+button.AbsoluteSize.Y
   check(button.AbsoluteSize.Y>=44 and button.AbsoluteSize.X>=200,'touch target fits '..size[1]..'x'..size[2])
   check(env.area.AbsolutePosition.Y+env.area.AbsoluteSize.Y<=button.AbsolutePosition.Y+1,'native atlas leaves space for travel')
   check(bottom<=env.navigation.AbsolutePosition.Y or env.navigation.AbsolutePosition.Y+env.navigation.AbsoluteSize.Y<=button.AbsolutePosition.Y,'native navigation does not overlap travel')
   check(button.Caption.TextFits,'destination text fits the native button')
   check(button.TDButtonArt.Image==(art.overrides and art.overrides.shellUpgrade and art.overrides.shellUpgrade.image or art.image) and panel:FindFirstChild('TDPanelArt')~=nil,'approved TD frame/button art is retained')
   outer:Destroy()
  end
  return 'Checkpoint map native: '..checks..' checks passed'
 end,debug.traceback)
 screen:Destroy();assert(ok,result);return result
end
