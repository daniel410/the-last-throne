-- North-up cartography projected from authoritative campaign coordinates.
local Shared=game:GetService('ReplicatedStorage').Shared
local Content=require(Shared.CampaignContent)
local Progress=require(Shared.DeepwoodProgress)
local Access=require(Shared.CampaignAccess)
local Text=require(Shared.K0Text).Map
local Theme=require(script.Parent.TDInventoryTheme)
local Art=require(script.Parent.DeepwoodCartography)
local Survey=require(Shared.CampaignCartography)
local Bounds=require(Shared.CampaignBounds)
local Canvas={}
function Canvas.create(parent,zoneId,compact,onSelect)
 local minX,minZ,maxX,maxZ=math.huge,math.huge,-math.huge,-math.huge
 local ids={};for id in pairs(Content.zones) do if not zoneId or id==zoneId or type(zoneId)=='table' and zoneId[id] then table.insert(ids,id) end end;table.sort(ids)
 for _,id in ipairs(ids) do local z=Content.zones[id]
  minX=math.min(minX,z.center[1]-z.size[1]/2);maxX=math.max(maxX,z.center[1]+z.size[1]/2)
  minZ=math.min(minZ,z.center[3]-z.size[2]/2);maxZ=math.max(maxZ,z.center[3]+z.size[2]/2)
 end
 if compact then
  local size=math.max(maxX-minX,maxZ-minZ);local cx,cz=(minX+maxX)/2,(minZ+maxZ)/2
  minX,maxX=cx-size/2,cx+size/2;minZ,maxZ=cz-size/2,cz+size/2
 else
  local px,pz=(maxX-minX)*.075,(maxZ-minZ)*.075;minX-=px;maxX+=px;minZ-=pz;maxZ+=pz
 end
 local width,height=maxX-minX,maxZ-minZ
 local function point(x,z) return Vector2.new((x-minX)/width,(z-minZ)/height) end
 local function label(name,text,p,size,font,color,layer)
  local t=Theme.label(parent,name,text,UDim2.fromScale(p.X,p.Y),size,font,color)
  t.AnchorPoint=Vector2.new(.5,.5);t.TextXAlignment=Enum.TextXAlignment.Center;t.TextStrokeTransparency=.35;t.TextStrokeColor3=Color3.fromRGB(5,17,20);t.ZIndex=layer or 8;return t
 end
 local roads={};local rows={};local lastJournal,lastSize
 local function line(name,a,b,color,thickness,layer,edge,zone,worldWidth)
  if compact then
   local delta=b-a;local offset=a-Vector2.new(.5,.5);local aa=delta:Dot(delta)
   if aa<.0000001 then return end
   local bb=2*offset:Dot(delta);local cc=offset:Dot(offset)-.475*.475
   local discriminant=bb*bb-4*aa*cc
   if discriminant<0 then return end
   local first=math.max(0,(-bb-math.sqrt(discriminant))/(2*aa))
   local last=math.min(1,(-bb+math.sqrt(discriminant))/(2*aa))
   if first>=last then return end
   b=a+delta*last;a=a+delta*first
  end
  local f=Art.shape(parent,name,(a.X+b.X)/2,(a.Y+b.Y)/2,0,0,color,layer,.5)
  table.insert(roads,{part=f,a=a,b=b,thickness=thickness,edge=edge,zone=zone,worldWidth=worldWidth});return f
 end
 for _,id in ipairs(ids) do Art.region(parent,id,Content.zones[id],point,width,height,compact,line) end
 local included={};for _,id in ipairs(ids)do included[id]=true end
 if type(zoneId)~='string' then for _,edge in ipairs(Access.edges) do
  if included[edge[1]] and included[edge[2]] and Content.zones[edge[1]].epic==Content.zones[edge[2]].epic then
  local a,b=Bounds.ends(edge);local first,second=point(a[1],a[3]),point(b[1],b[3])
  line('TrailShoulder',first,second,Color3.fromRGB(8,19,22),10,2,nil,nil,96)
  line('ConnectingTrail',first,second,Color3.fromRGB(86,106,83),7,2,nil,nil,80)
  line('Road',first,second,Theme.color.gold,2.5,4,edge)
 end end end
 local function selectRegion(id)
  for key,row in pairs(rows) do row.outline.Transparency=key==id and .05 or .7 end
  if onSelect then onSelect(id) end
 end
 for _,id in ipairs(ids) do
  local z=Content.zones[id];local survey=Survey.zones[id];local a=point(z.center[1]-z.size[1]/2,z.center[3]-z.size[2]/2)
  local size=Vector2.new(z.size[1]/width,z.size[2]/height);local center=point(z.center[1],z.center[3]);local cells={}
  for zz=1,12 do for x=1,12 do
   local origin=a+Vector2.new((x-.5)/12*size.X,(zz-.5)/12*size.Y)
   local cell=Art.shape(parent,'FogCell',origin.X,origin.Y,size.X/11.7,size.Y/11.7,Color3.fromRGB(12,24,31),6,.5)
   cells[(zz-1)*12+x]=cell
   if compact then cell.Visible=(origin-Vector2.new(.5,.5)).Magnitude<.44 end
  end end
  local caption=label('Place',z.name,center+Vector2.new(0,size.Y*.20),UDim2.fromOffset(156,34),12,Theme.color.text)
  caption.Font=Enum.Font.GothamBold;caption.Visible=not compact;caption.TextStrokeTransparency=1
  caption.BackgroundColor3=Color3.fromRGB(12,26,28);caption.BackgroundTransparency=.16
  local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(0,5);corner.Parent=caption
  -- Selection outlines the nameplate, never the glyphs (UIStroke defaults to Contextual).
  local outline=Instance.new('UIStroke');outline.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;outline.Thickness=1;outline.Color=Theme.color.gold;outline.Transparency=.7;outline.Parent=caption
  local status=label('RegionStatus','',center+Vector2.new(0,size.Y*.20),UDim2.fromOffset(160,16),9,Theme.color.muted)
  status.Position+=UDim2.fromOffset(0,27);status.Visible=not compact
  local chapter=Content.byId[id];local number=chapter and not chapter.side and chapter.number
  local badge=label('StoryOrder',number and string.format(Text.Main,number) or Text.Side,center-Vector2.new(0,size.Y*.37),UDim2.fromOffset(100,16),9,Theme.color.gold)
  badge.Visible=not compact
  local landmark=label('Landmark',survey.landmark,center-Vector2.new(0,size.Y*.27),UDim2.fromOffset(140,26),10,Theme.color.silver,7);landmark.Visible=not compact;landmark.TextWrapped=true
  local checkpoint=label('Checkpoint','◇',point(survey.spawn[1],survey.spawn[2]),UDim2.fromOffset(18,18),17,Theme.color.silver,10);checkpoint.Visible=false
  local hit
  if not compact then
   hit=Instance.new('TextButton');hit.Name='SelectRegion';hit.Text='';hit.BackgroundTransparency=1;hit.Position=caption.Position;hit.AnchorPoint=Vector2.new(.5,.5);hit.Size=UDim2.fromOffset(164,48);hit.ZIndex=9;hit.AutoLocalize=false;hit.Parent=parent
   hit.Activated:Connect(function() selectRegion(id) end)
  end
  rows[id]={cells=cells,name=caption,status=status,badge=badge,center=center,checkpoint=checkpoint,zone=caption,outline=outline,hit=hit,landmark=landmark}
 end
 local objective=label('Objective','◆',Vector2.zero,UDim2.fromOffset(26,26),23,Theme.color.gold,12);objective.Visible=false
 local pin=label('You','▲',Vector2.zero,UDim2.fromOffset(30,30),26,Color3.fromRGB(87,241,255),13);pin.TextStrokeTransparency=0;pin.Visible=false
 local function located(marker,position)
  local p=point(position.X,position.Z)
  if compact then
   local offset=p-Vector2.new(.5,.5)
   if offset.Magnitude>.39 then p=Vector2.new(.5,.5)+offset.Unit*.39 end
  end
  marker.Position=UDim2.fromScale(p.X,p.Y);marker.Visible=p.X>=0 and p.X<=1 and p.Y>=0 and p.Y<=1
 end
 local party=require(script.Parent.PartyMapMarkers).create(parent,point,compact)
 local function update(current,root,target,members)
  party.update(members)
  local journal=current and current.journal
  if journal~=lastJournal then
   lastJournal=journal
   for id,row in pairs(rows) do
    local cells=journal and journal.explored and journal.explored[id] or {};local allowed=Access.allowed(journal,id);local count=0
    for index,cell in ipairs(row.cells) do
     local explored=Progress.hasCell(cells,index);if explored then count+=1 end
     cell.BackgroundColor3=explored and Color3.fromRGB(70,110,75) or Color3.fromRGB(12,24,31)
     cell.BackgroundTransparency=explored and 1 or allowed and .97 or .93
    end
    row.name.TextColor3=allowed and Theme.color.text or Theme.color.muted
    row.status.Text=not allowed and Text.Locked or count==0 and Text.Available or string.format(Text.Explored,math.floor(count/144*100))
    row.status.TextColor3=allowed and Theme.color.green or Theme.color.muted
    local z=Content.zones[id];local sp=Survey.zones[id].spawn
    local cx=math.clamp(math.floor((sp[1]-z.center[1]+z.size[1]/2)/z.size[1]*12),0,11)
    local cz=math.clamp(math.floor((sp[2]-z.center[3]+z.size[2]/2)/z.size[2]*12),0,11)
    row.checkpoint.Visible=Progress.hasCell(cells,cz*12+cx+1)
    row.name:SetAttribute('ExploredPercent',math.floor(count/144*100));row.name:SetAttribute('Accessible',allowed==true)
   end
   for _,r in ipairs(roads) do
    if r.edge then r.part.BackgroundColor3=Access.allowed(journal,r.edge[1]) and Access.allowed(journal,r.edge[2]) and Theme.color.gold or Color3.fromRGB(100,115,112)
    elseif r.zone then r.part.Visible=Access.allowed(journal,r.zone)==true end
   end
  end
  if parent.AbsoluteSize~=lastSize then
   lastSize=parent.AbsoluteSize
   for _,r in ipairs(roads) do
    local delta=Vector2.new((r.b.X-r.a.X)*lastSize.X,(r.b.Y-r.a.Y)*lastSize.Y)
    local thickness=r.worldWidth and math.max(r.thickness,r.worldWidth/width*lastSize.X) or r.thickness
    r.part.Size=UDim2.fromScale(delta.Magnitude/math.max(1,lastSize.X),thickness/math.max(1,lastSize.Y));r.part.Rotation=math.deg(math.atan2(delta.Y,delta.X))
   end
  end
  if root then located(pin,root.Position);pin.Rotation=math.deg(math.atan2(root.CFrame.LookVector.X,-root.CFrame.LookVector.Z)) else pin.Visible=false end
  if target then located(objective,target) else objective.Visible=false end
 end
 return {party=party,pin=pin,objective=objective,rows=rows,aspect=width/height,update=update,project=point,select=selectRegion}
end
return Canvas
