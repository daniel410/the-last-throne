-- Bounded 2D cartography: no Workspace clones, camera or Viewport world.
local Content=require(game:GetService('ReplicatedStorage').Shared.DeepwoodContent)
local Progress=require(game:GetService('ReplicatedStorage').Shared.DeepwoodProgress)
local Access=require(game:GetService('ReplicatedStorage').Shared.DeepwoodAccess)
local Theme=require(script.Parent.TDInventoryTheme)
local Canvas={}
function Canvas.create(parent,zoneId,compact)
 local minX,minZ,maxX,maxZ=math.huge,math.huge,-math.huge,-math.huge
 for id,z in pairs(Content.zones) do if not zoneId or id==zoneId then
  minX=math.min(minX,z.center[1]-z.size[1]/2);maxX=math.max(maxX,z.center[1]+z.size[1]/2)
  minZ=math.min(minZ,z.center[3]-z.size[2]/2);maxZ=math.max(maxZ,z.center[3]+z.size[2]/2)
 end end
 if compact then local size=math.max(maxX-minX,maxZ-minZ);local cx,cz=(minX+maxX)/2,(minZ+maxZ)/2;minX,maxX=cx-size/2,cx+size/2;minZ,maxZ=cz-size/2,cz+size/2 end
 local width,height=maxX-minX,maxZ-minZ
 local function point(x,z) return Vector2.new((x-minX)/width,(z-minZ)/height) end
 local function rect(name,a,b,color,zindex)
  local f=Instance.new('Frame');f.Name=name;f.BorderSizePixel=0;f.BackgroundColor3=color;f.Position=UDim2.fromScale(a.X,a.Y);f.Size=UDim2.fromScale(b.X,b.Y);f.ZIndex=zindex or 1;f.Parent=parent;return f
 end
 local rows={};local roads={}
 if not zoneId then for _,edge in ipairs(Access.edges) do
  local a,b=Content.zones[edge[1]],Content.zones[edge[2]];local first,second=point(a.center[1],a.center[3]),point(b.center[1],b.center[3]);local delta=second-first
  -- Normalized square canvas keeps bridge bearings stable through resize.
  local f=rect('Road',first,Vector2.new(delta.Magnitude,.004),Color3.fromRGB(156,142,97));f.AnchorPoint=Vector2.new(0,.5);f.Rotation=math.deg(math.atan2(delta.Y,delta.X));table.insert(roads,{part=f,edge=edge,delta=delta})
 end end
 for id,z in pairs(Content.zones) do if not zoneId or id==zoneId then
  local a=point(z.center[1]-z.size[1]/2,z.center[3]-z.size[2]/2);local size=Vector2.new(z.size[1]/width,z.size[2]/height)
  local zone=rect('Region',a,size,Color3.fromRGB(44,78,51),2);local cells={}
  if compact then zone.BackgroundTransparency=1
  else local stroke=Instance.new('UIStroke');stroke.Color=Color3.fromRGB(72,90,91);stroke.Thickness=1;stroke.Parent=zone end
  if not compact then
   -- The authored broad trail and investigation paths, hidden by unexplored cells.
   local previous=point(z.center[1]-z.size[1]*.37,z.center[3]+z.size[2]*.34)
   for _,chapter in ipairs(Content.chapters) do if chapter.zone==id and not chapter.side then for _,goal in ipairs(chapter.goals) do if not goal.zone and not goal.optional then
    local nextPoint=point(goal.position[1],goal.position[3]);local delta=nextPoint-previous
    local path=rect('LocalTrail',previous,Vector2.new(delta.Magnitude,.002),Color3.fromRGB(167,151,104),2);path.AnchorPoint=Vector2.new(0,.5)
    table.insert(roads,{part=path,delta=delta,zone=id});previous=nextPoint
   end end end end
  end
  for zz=1,12 do for x=1,12 do
   local origin=a+Vector2.new((x-1)/12*size.X,(zz-1)/12*size.Y);local extent=Vector2.new(size.X/12+.0005,size.Y/12+.0005)
   local cell=rect('FogCell',origin,extent,Color3.fromRGB(7,16,26),3);cells[(zz-1)*12+x]=cell
   if compact then
    local inside=true;for _,corner in ipairs({origin,origin+extent,origin+Vector2.new(extent.X,0),origin+Vector2.new(0,extent.Y)}) do if (corner-Vector2.new(.5,.5)).Magnitude>.48 then inside=false end end
    cell.Visible=inside
   end
  end end
  local center=point(z.center[1],z.center[3])
  local name=Theme.label(parent,'Place','Unexplored',UDim2.fromScale(center.X,center.Y),UDim2.fromOffset(compact and 0 or 158,compact and 0 or 38),11,Theme.color.text);name.AnchorPoint=Vector2.new(.5,.5);name.TextXAlignment=Enum.TextXAlignment.Center;name.TextStrokeTransparency=.1;name.ZIndex=5;name.Visible=not compact
  local checkpoint=Theme.label(parent,'Checkpoint','◇',UDim2.fromScale(center.X-z.size[1]*.37/width,center.Y+z.size[2]*.34/height),UDim2.fromOffset(18,18),16,Theme.color.silver);checkpoint.AnchorPoint=Vector2.new(.5,.5);checkpoint.ZIndex=6;checkpoint.Visible=false
  rows[id]={cells=cells,name=name,checkpoint=checkpoint,zone=zone}
 end end
 local objective=Theme.label(parent,'Objective','◆',UDim2.new(),UDim2.fromOffset(20,20),18,Theme.color.gold);objective.AnchorPoint=Vector2.new(.5,.5);objective.ZIndex=8;objective.Visible=false
 local pin=Theme.label(parent,'You','▲',UDim2.new(),UDim2.fromOffset(26,26),24,Color3.fromRGB(87,241,255));pin.AnchorPoint=Vector2.new(.5,.5);pin.TextStrokeTransparency=0;pin.TextXAlignment=Enum.TextXAlignment.Center;pin.ZIndex=9;pin.Visible=false
 local function located(marker,position)
  local p=point(position.X,position.Z);marker.Position=UDim2.fromScale(math.clamp(p.X,.035,.965),math.clamp(p.Y,.035,.965));marker.Visible=p.X>=0 and p.X<=1 and p.Y>=0 and p.Y<=1
 end
 return {pin=pin,objective=objective,rows=rows,aspect=width/height,update=function(current,root,target)
  local journal=current and current.journal
  for id,row in pairs(rows) do
   local z=Content.zones[id];local cells=journal and journal.explored and journal.explored[id] or {};local allowed=journal and Access.allowed(journal,id)
   local visited=next(cells)~=nil
   for index,cell in ipairs(row.cells) do cell.BackgroundColor3=Progress.hasCell(cells,index) and Color3.fromRGB(70,110,75) or allowed and Color3.fromRGB(24,41,46) or Color3.fromRGB(7,16,26);cell.BackgroundTransparency=not compact and Progress.hasCell(cells,index) and 1 or 0 end
   row.name.Text=visited and z.name or allowed and 'Unexplored' or 'Locked';row.name.TextColor3=allowed and Theme.color.text or Theme.color.muted
   row.checkpoint.Visible=visited and Progress.hasCell(cells,(math.floor(.84*12))*12+math.floor(.13*12)+1)
  end
  for _,r in ipairs(roads) do
   local delta=Vector2.new(r.delta.X*parent.AbsoluteSize.X,r.delta.Y*parent.AbsoluteSize.Y);r.part.Size=UDim2.fromOffset(delta.Magnitude,3);r.part.Rotation=math.deg(math.atan2(delta.Y,delta.X))
   if r.zone then r.part.Visible=journal and (journal.explored or {})[r.zone]~=nil
   else r.part.Visible=journal and Access.allowed(journal,r.edge[1]) and Access.allowed(journal,r.edge[2]) and (journal.explored or {})[r.edge[1]]~=nil end end
  if root then located(pin,root.Position);pin.Rotation=math.deg(math.atan2(root.CFrame.LookVector.X,-root.CFrame.LookVector.Z)) else pin.Visible=false end
  if target then located(objective,target) else objective.Visible=false end
 end}
end
return Canvas
