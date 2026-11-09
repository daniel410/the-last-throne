-- Existing side quest reports bring people and everyday life back, without new rewards.
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local Visual=require(script.Parent.NPCVisual)
local R={};local V=Vector3.new
local messages={['DW-Q2']='A PROPER CAMP MEAL\nLiora: More than warm water this time!',
 ['FV-Q1']='WELCOME BACK, NELL\nA name, a badge, and friends waiting.',
 ['EC-Q1']='JORI · BACK ON THE CREW\nKetta kept this place for you.'}
function R.create(parent,at,id)
 local name='ReturnStory_'..id;local previous=parent:FindFirstChild(name);if previous then return previous end
 local c=C.byId[id];local m=Instance.new('Model');m.Name=name;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 m:SetAttribute('ExpansionEvent',id..':'..c.quest.turnIn);m:SetAttribute('ExpansionChapter',id);m:SetAttribute('ExpansionMin',3);m:SetAttribute('ExpansionMax',3)
 local function part(name,size,offset,color,material)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.Position=at+offset;p.Color=color;p.Material=material or Enum.Material.Wood
  p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Parent=m;return p
 end
 local wood=Color3.fromRGB(112,81,49);local gold=Color3.fromRGB(232,198,111)
 local sign
 if id=='DW-Q2'then
  part('CampMealTable',V(10,.5,5),V(0,2,0),wood)
  for _,x in ipairs({-3,3})do part('TableSupport',V(.6,2,.6),V(x,1,0),wood)end
  for i=-1,1 do
   part('ReturnedFood',V(1.6,.5,1.4),V(i*3,2.6,0),gold)
   part('SharedMealBench',V(8,.4,1.5),V(0,1,i*4),wood)
  end
  Visual.actor(m,'Liora',at+V(-6,0,0));sign=part('MealSign',V(5,3,.3),V(0,3,-5),wood)
 else
  sign=part('NamedReturnBoard',V(7,5,.4),V(0,3,0),wood)
  part(id=='FV-Q1'and 'ReturnedBadge'or 'ReturnedWorkMark',V(1.4,1.4,.2),V(0,3,-.4),gold,Enum.Material.Metal)
  Visual.actor(m,id=='FV-Q1'and 'Nell'or 'Miner Jori',at+V(-5,0,2))
 end
 local gui=Instance.new('BillboardGui');gui.Name='ReturnStoryCaption';gui.Size=UDim2.fromOffset(270,68);gui.StudsOffset=V(0,4,0);gui.MaxDistance=40;gui.Enabled=false;gui.Parent=sign
 local text=Instance.new('TextLabel');text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.TextWrapped=true;text.Font=Enum.Font.GothamBold;text.TextSize=13;text.TextColor3=gold;text.TextStrokeTransparency=.2;text.Text=messages[id];text.AutoLocalize=false;text.Parent=gui
 for _,p in ipairs(m:GetDescendants())do if p:IsA('BasePart')then p:SetAttribute('ExpansionTransparency',p.Transparency);p.Transparency=1;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false elseif p:IsA('BillboardGui')then p.Enabled=false end end
 m.Parent=parent;return m
end
function R.lobby(lobby)
 local folder=lobby.folder:FindFirstChild('SideStoryHomecomings')or Instance.new('Folder');folder.Name='SideStoryHomecomings';folder.Parent=lobby.folder
 for _,row in ipairs({{'DW-Q2',-42,-35},{'FV-Q1',-42,15},{'EC-Q1',42,15}})do R.create(folder,lobby.origin+V(row[2],0,row[3]),row[1])end
end
return R
