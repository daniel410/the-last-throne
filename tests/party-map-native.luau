-- Actual TD-backed map markers on atlas/minimap canvases, with server snapshot fixtures.
return function(markerSource,projectionSource,stateSource,themeSource,artSource,iconSource)
 local checks=0;local function check(v,m)checks+=1;assert(v,m)end
 local screen=Instance.new('ScreenGui');screen.Name='PartyMapQA';screen.Parent=game:GetService('CoreGui')
 local ok,result=xpcall(function()
  local art=assert(loadstring(artSource))();local icons=assert(loadstring(iconSource))()
  themeSource=themeSource:gsub('local Art = require%(Shared.TDUI.StatusWindowArtAssets%)','local Art = fixtureArt'):gsub('local Icons = require%(Shared.TDUI.UIIconAssets%)','local Icons = fixtureIcons')
  local fn=assert(loadstring(themeSource));setfenv(fn,setmetatable({fixtureArt=art,fixtureIcons=icons},{__index=getfenv()}));local Theme=fn()
  local projection=assert(loadstring(projectionSource))()
  markerSource=markerSource:gsub("local Projection=require%(game:GetService%('ReplicatedStorage'%).Shared.PartyMapProjection%)",'local Projection=fixtureProjection'):gsub('local Theme=require%(script.Parent.TDInventoryTheme%)','local Theme=fixtureTheme')
  fn=assert(loadstring(markerSource));setfenv(fn,setmetatable({fixtureProjection=projection,fixtureTheme=Theme},{__index=getfenv()}));local markers=fn()
  local members={{userId=2,slot=2,name='Archer',position={.7,0,.6}},{userId=3,slot=3,name='Dwarf',position={10,0,.5}},{userId=4,slot=4,name='Mage',position={.4,0,.5},downed=true}}
  for _,compact in ipairs({false,true})do
   local frame=Instance.new('Frame');frame.Size=compact and UDim2.fromOffset(152,152)or UDim2.fromOffset(680,500);frame.Parent=screen
   local display=markers.create(frame,function(x,z)return Vector2.new(x,z)end,compact)
   display.update(members);task.wait(.03)
   check(#frame:GetChildren()==3,'both map sizes show all three allies')
   check(display.nodes[2].number.Text=='2'and display.nodes[2].name.Text=='Archer','number and name identify the same ally')
   check(display.nodes[2].name.Visible==not compact,'minimap stays compact; full map names allies')
   check(display.nodes[3].arrow.Visible and math.abs(display.nodes[3].arrow.Rotation)<.001,'distant ally has an eastward edge indicator')
   check(display.nodes[4].number.Text=='+'and display.nodes[4].root.BackgroundColor3~=display.nodes[2].root.BackgroundColor3,'downed ally uses a separate symbol and color')
   display.update({members[1]});check(#frame:GetChildren()==1,'departed/respawning allies remove labels and pins')
   display.update({});check(#frame:GetChildren()==0,'empty/stale snapshot removes every marker')
   frame:Destroy()
  end
  local now=1;fn=assert(loadstring(stateSource));setfenv(fn,setmetatable({os={clock=function()return now end}},{__index=getfenv()}));local state=fn()
  state.set({heroId='h',mode='Tutorial'},nil);state.setParty({heroId='h',members=members});check(#state.party()==3,'fresh same-hero server snapshot is visible')
  now=3.1;check(#state.party()==0,'position stops being shown after a two-second timeout')
  state.setParty({heroId='other',members=members});check(#state.party()==0,'hero switch cannot reuse stale party markers')
  state.setParty({heroId='h',members=members});state.set({heroId='h',mode='Lobby'},nil);check(#state.party()==0,'lobby mode clears map markers immediately')
  state.set({heroId='h',mode='Tutorial',training=true},nil);check(#state.party()==0,'training never shows expedition allies')
  return 'Party map native: '..checks..' checks passed'
 end,debug.traceback)
 screen:Destroy();assert(ok,result);return result
end
