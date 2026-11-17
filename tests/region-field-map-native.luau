-- Local engine fixture: invoke the callbacks connected to real controls, without synthetic OS input.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local client=game.StarterPlayer.StarterPlayerScripts.Client
local shared=game.ReplicatedStorage.Shared
local C=require(shared.CampaignContent)
local Survey=require(shared.CampaignCartography)
local Progress=require(shared.DeepwoodProgress)
local State=require(client.DeepwoodMapState)
local screen=Instance.new("ScreenGui")
screen.IgnoreGuiInset=true
screen.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
screen.Parent=game.CoreGui
local host=Instance.new("Frame")
host.Size=UDim2.fromOffset(800,550)
host.Parent=screen
local checks=0
local function check(ok,message) checks+=1;assert(ok,message) end
local bindings=setmetatable({},{__mode="k"})
local source=client.RegionFieldMap.Source:gsub("([%w_]+)%.Activated:Connect%(", "bind(%1,")
local createModule=assert(loadstring(source))
setfenv(createModule,setmetatable({script=client.RegionFieldMap,bind=function(button,callback)
 bindings[button]=callback
 return button.Activated:Connect(callback)
end},{__index=getfenv()}))
local function click(button)
 check(button.Visible and bindings[button],"visible control has a production callback")
 bindings[button]()
 task.wait()
end
local p=Progress.new()
local state={heroId="a",expedition={runId="first"},journal=p}
State.set(state,nil)
local returned
local field=createModule().create(host,function(id)returned=id end,State)
local panel=field.panel
for id,z in pairs(C.zones) do
 field.open(id,p)
 local map=panel.Chart.Survey
 local sites=panel.FieldGuide.Locations
 check(panel.Title.Text==z.name,id.." name")
 check(map:FindFirstChild("Relief")~=nil,id.." actual surveyed plate")
 check(not sites:FindFirstChild("LocationArt") and not map:FindFirstChild("LandmarkPortrait"),id.." field map uses only surveyed geography")
 local anchorX,anchorZ=table.unpack(Survey.zones[id].signature.anchor)
 local x0,z0,x1,z1=require(shared.CampaignAreas).surveyExtent(C.zones[id])
 local relief=map.Relief
 local u=relief.Position.X.Scale + (anchorX-x0)/(x1-x0)*relief.Size.X.Scale
 local v=relief.Position.Y.Scale + (anchorZ-z0)/(z1-z0)*relief.Size.Y.Scale
 check(math.abs(map.SitePin1.Position.X.Scale-u)<1e-5 and math.abs(map.SitePin1.Position.Y.Scale-v)<1e-5,id.." numbered pin aligns with surveyed pixels")
 check(sites.Site1.Title.Text==Survey.zones[id].signature.title,id.." signature")
 for i,area in ipairs(z.expansionAreas or {}) do
  check(sites["Site"..(i+1)].Title.Text==area.name and map["SitePin"..(i+1)]~=nil,id.." story site")
 end
end
field.open("DW-01",p);task.wait(.2)
local chart=panel.Chart
local list=panel.FieldGuide.Locations
click(chart.Survey.SitePin2)
check(list.Site2.Note.Visible and not list.Site1.Note.Visible,"map pin selects and reveals the matching field entry")
click(list.Site2.Pin)
check(State.waypoint and State.waypoint.zone=="DW-01","input places a personal pin")
local zone=C.zones["DW-01"]
local objective=Vector3.new(table.unpack(zone.center))
State.targetTitle="Quest under test"
field.update(p,nil,objective)
check(chart.Survey.Waypoint.Visible and chart.Survey.Objective.Visible and chart.TrackedObjective.Text:find(State.targetTitle,1,true),"pin coexists with live quest")
local minimapFrame=Instance.new("Frame");minimapFrame.Parent=screen
local mini=require(client.DeepwoodMapCanvas).create(minimapFrame,"DW-01",true)
mini.update(state,nil,objective,nil,State.waypoint)
check(mini.waypoint.Visible and mini.objective.Visible and not minimapFrame:FindFirstChild("LandmarkPortrait"),"round minimap shows both markers without 3D models")
click(list.Site2.Pin)
check(State.waypoint==nil,"same site clears pin")
click(list.Site2.Pin)
State.set({heroId="a",expedition={runId="second"},journal=p},nil)
check(State.waypoint==nil,"new expedition clears the previous pin")
local road
for _,row in ipairs(list:GetChildren()) do
 if row:IsA("TextButton") and row.Kind.Text=="ROAD"then road=row;break end
end
local n=tonumber(road.Name:match("%d+"))
click(chart.Survey["SitePin"..n]);click(road.ViewArea)
check(panel.Title.Text~=zone.name and panel.FieldGuide.Access.Text:find("Complete",1,true),"browse adjacent locked area and read its prerequisite")
click(panel.Back)
check(not panel.Visible and returned~=nil,"back returns to the epic")
for _,size in ipairs({Vector2.new(320,500),Vector2.new(643,221),Vector2.new(800,550)})do
 host.Size=UDim2.fromOffset(size.X,size.Y);field.open("HG-03",p);task.wait(.1)
 local guide=panel.FieldGuide
 check(chart.AbsoluteSize.Y>64 and guide.Locations.AbsoluteSize.Y>=44,"usable map and scrolling list")
 check(chart.AbsolutePosition.X+chart.AbsoluteSize.X<=guide.AbsolutePosition.X+1 or chart.AbsolutePosition.Y+chart.AbsoluteSize.Y<=guide.AbsolutePosition.Y+1,"chart and guide never overlap")
 check(panel.Back.Caption.TextFits and panel.Title.TextFits,"header fits")
end
field.close();State.set(nil,nil);screen:Destroy()
do
local plateSource=client.AtlasPlate.Source:gsub("local assets = game:GetService%(\"AssetService\"%)", "local assets = {CreateEditableImage = function() return nil end}")
local fn=assert(loadstring(plateSource));setfenv(fn,setmetatable({script=client.AtlasPlate},{__index=getfenv()}))
local plates=fn();local parent=Instance.new("Frame")
local detail=plates.draw(parent,"GW-05",true)
local overview=plates.draw(parent,"GW-05",false)
assert(detail:IsA("Frame") and #detail:GetChildren()>0)
assert(overview:IsA("Frame") and #overview:GetChildren()>0 and #overview:GetChildren()<#detail:GetChildren())
assert(#client.AtlasPlates:GetChildren()==44)
parent:Destroy();print("ATLAS_FALLBACK_PASS",3)
end

print("REGION_FIELD_MAP_PASS "..checks)
