-- Authored 2D symbols, projected from campaign coordinates, without 3D clones.
local Art={}
local C={ink=Color3.fromRGB(12,26,29),cliff=Color3.fromRGB(60,73,65),rim=Color3.fromRGB(82,102,71),
 forest=Color3.fromRGB(45,76,57),leaf=Color3.fromRGB(66,103,67),light=Color3.fromRGB(102,131,79),
 corrupt=Color3.fromRGB(54,58,69),violet=Color3.fromRGB(131,110,150),water=Color3.fromRGB(68,132,144),
 wood=Color3.fromRGB(125,100,65),stone=Color3.fromRGB(164,165,133),gold=Color3.fromRGB(211,182,113)}
function Art.shape(parent,name,x,y,w,h,color,layer,round)
 local f=Instance.new('Frame');f.Name=name;f.BorderSizePixel=0;f.BackgroundColor3=color
 f.AnchorPoint=Vector2.new(.5,.5);f.Position=UDim2.fromScale(x,y);f.Size=UDim2.fromScale(w,h);f.ZIndex=layer;f.Parent=parent
 if round then local c=Instance.new('UICorner');c.CornerRadius=UDim.new(round,0);c.Parent=f end
 return f
end
function Art.region(parent,id,z,point,width,height,compact)
 local center=point(z.center[1],z.center[3]);local sx,sy=z.size[1]/width,z.size[2]/height
 local corrupt=id=='DW-06' or id=='DW-07' or id=='DW-S3'
 local ground=corrupt and C.corrupt or C.forest
 local function blob(name,x,y,w,h,color,layer)
  return Art.shape(parent,name,center.X+x*sx,center.Y+y*sy,w*sx,h*sy,color,layer,.5)
 end
 -- Scalloped contours replace the rectangular development boxes.
 blob('CliffShadow',0,.035,1.03,1.02,C.ink,2)
 blob('LimestoneContour',0,.012,1,1,C.cliff,2)
 blob('MossContour',0,0,.96,.96,corrupt and C.corrupt or C.rim,2)
 blob('ForestFloor',0,-.015,.90,.90,ground,2)
 for i=1,8 do local a=i*math.pi/4
  blob('CanopyContour',math.cos(a)*.28,math.sin(a)*.29,.42,.40,ground,2)
 end
 for i=1,compact and 10 or 24 do
  local a=i*2.39996;local r=.30+(i%3)*.035
  local x,y=math.cos(a)*r,math.sin(a)*r;local size=.08+(i%4)*.014
  blob('TreeShadow',x+.013,y+.018,size*1.15,size*1.2,C.ink,3)
  blob('TreeCanopy',x,y,size,size*1.08,corrupt and Color3.fromRGB(76,75,82) or (i%3==0 and C.light or C.leaf),3)
 end
 blob('BroadTrail',0,0,.78,.035,C.wood,3)
 if id=='DW-S2' then
  blob('QuarryPool',-.25,-.17,.30,.38,C.water,3)
  blob('Waterfall',-.38,-.25,.04,.30,Color3.fromRGB(149,194,188),4)
 elseif id=='DW-01' then blob('Marsh',-.27,.32,.14,.14,C.water,3) end
 if compact then return end
 -- Landmarks match the existing DeepwoodWorld scenery.
 local lx,ly=center.X,center.Y-sy*.17
 local function icon(name,x,y,w,h,color,round)
  return Art.shape(parent,name,lx+x*sx,ly+y*sy,w*sx,h*sy,color,5,round)
 end
 if id=='DW-03' then
  icon('ElderTreeShadow',0,.025,.35,.36,C.ink,.5);icon('ElderTreeTrunk',0,.07,.04,.24,C.wood)
  for i=1,5 do local a=i*math.pi*2/5;icon('ElderTreeCrown',math.cos(a)*.075,math.sin(a)*.07-.02,.20,.20,i%2==0 and C.light or C.leaf,.5) end
 elseif id=='DW-04' then
  icon('TowerShadow',.025,.035,.22,.25,C.ink);icon('Watchtower',0,0,.19,.22,C.stone)
  icon('TowerRoof',0,-.10,.23,.055,C.rim);icon('TowerDoor',0,.065,.045,.08,C.ink)
 elseif id=='DW-07' then
  icon('AltarRing',0,0,.32,.30,C.violet,.5);icon('AltarDais',0,0,.25,.23,C.ink,.5)
  for _,x in ipairs({-.14,.14}) do icon('Obelisk',x,-.07,.045,.20,C.stone) end
  local crystal=icon('Seal',0,-.03,.06,.10,C.violet);crystal.Rotation=25
 elseif id=='DW-05' then
  for i=1,3 do icon('RuinedPillar',(i-2)*.11,0,.06,.18,C.stone) end
  icon('RuinedLintel',0,-.09,.32,.05,C.rim)
 elseif id=='DW-06' then
  for i=1,4 do local root=icon('BlackRoot',(i-2.5)*.065,0,.028,.30,C.violet);root.Rotation=i*32 end
 elseif id=='DW-01' or id=='DW-02' then
  icon('CartBed',0,0,.19,.09,C.wood)
  for _,x in ipairs({-.08,.08}) do icon('CartWheel',x,.05,.04,.05,C.ink,.5) end
 elseif id=='DW-S1' or id=='DW-S3' then
  for i=1,3 do local tent=icon('CampTent',(i-2)*.14,0,.09,.12,id=='DW-S3' and C.violet or C.gold);tent.Rotation=45 end
 end
end
return Art
