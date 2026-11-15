-- Server-confirmed support, counter windows and elemental afflictions only.
-- These local silhouettes never change movement, targeting, health or damage.
local M={}
local Snapshot=require(script.Parent.EnemyPatternDefinition)
local rows=setmetatable({},{__mode='k'})
local byId=setmetatable({},{__mode='v'})
local phases=setmetatable({},{__mode='k'})
local gold=Color3.fromRGB(255,207,104)
local purple=Color3.fromRGB(188,135,255)
local statuses={
 {key='Web',label='Webbed',color=Color3.fromRGB(234,228,255)},
 {key='Chill',label='Chilled',color=Color3.fromRGB(137,230,255)},
 {key='Burn',label='Burning',color=Color3.fromRGB(255,131,49)},
 {key='Venom',label='Poisoned',color=Color3.fromRGB(153,224,83)},
 {key='Weakness',label='Weakened',color=purple},
 {key='Soul',label='Soul Mark',color=Color3.fromRGB(133,245,218)},
}
local function live(model)
 if not model or not model:IsDescendantOf(workspace)then return false end
 local h=model:FindFirstChildOfClass('Humanoid')
 return h and h.Health>0 and model:GetAttribute('K0EnemyState')~='Dead'
end
local function expires(model,name,current)
 local value=model:GetAttribute(name)
 return type(value)=='number'and value>current
end
local function visible(root)
 local camera=workspace.CurrentCamera
 return not camera or (camera.CFrame.Position-root.Position).Magnitude<100
end
local function makePart(parent,name,color,shape)
 local p=Instance.new(shape=='wedge'and 'WedgePart'or 'Part')
 p.Name=name;p.Anchored=true;p.Massless=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
 p.Material=Enum.Material.Neon;p.Color=color;p.Transparency=.27
 if shape=='ball'then p.Shape=Enum.PartType.Ball end
 p.Parent=parent;return p
end
local function removeGroup(row,key)
 local group=row[key]
 if group then group:Destroy();row[key]=nil end
end
local function clearVisual(row)
 for _,key in ipairs({'label','motifs','tether'})do removeGroup(row,key)end
 row.visualKey=nil
end
local function remove(model)
 local row=rows[model]
 if row then clearVisual(row);rows[model]=nil end
end
local function state(model,current,row)
 local names,active,seen={},{},{}
 local function add(name)if not seen[name]and #names<3 then seen[name]=true;table.insert(names,name)end end
 local support=model:GetAttribute('K0SupportKind')
 local sequence=model:GetAttribute('K0SupportSeq')
 local casting=(support=='Ward'or support=='Rally')and expires(model,'K0SupportUntil',current)
 if row and row.cancelledSequence==sequence then casting=false end
 if casting then add(support);active.Casting=support end
 if expires(model,'K0WardUntil',current)and (model:GetAttribute('K0WardAmount')or 0)>0 then add('Ward');active.Ward=true end
 if expires(model,'K0RallyUntil',current)then add('Rally');active.Rally=true end
 if expires(model,'K0ExposedUntil',current)or model:GetAttribute('K0EnemyState')=='Exposed'then
  add('Exposed');active.Exposed=true
  local side=model:GetAttribute('K0ExposedSide')
  if not side and expires(model,'K0ExposedUntil',current)then side=row and row.weaknessSide end
  if type(side)=='string'then
   side=string.lower(side);active.ExposedSide=side
   if side=='rear'then add('Rear')elseif side=='flank'then add('Flank')end
  end
 end
 local count=0
 for _,s in ipairs(statuses)do
  if expires(model,'K0Enemy'..s.key..'Until',current)then
   active[s.key]=true
   if count<3 then add(s.label);count+=1 end
  end
 end
 if #names==0 and row and current<(row.phaseUntil or 0)then add(row.phaseCue);active.Phase=true end
 return table.concat(names,' · '),active
end
function M.observe(model,current,force)
 if not live(model)then remove(model);return end
 local root=model:FindFirstChild('HumanoidRootPart');if not root then return end
 local id=model:GetAttribute('K0EnemyId');if id then byId[id]=model end
 local row=rows[model]
 local d=model:GetAttribute('StoryBoss')and Snapshot.get(model)
 local phaseChange=d and d.phase and d.phaseName and phases[model]~=d.phase
 local text=state(model,current,row)
 if not row and text==''and not force and not phaseChange then return end
 if not row then
  local count=0;for _ in pairs(rows)do count+=1 end
  if count>=96 then return end
  row={root=root};rows[model]=row
 end
 if phaseChange then
  phases[model]=d.phase;row.phaseCue='Phase '..d.phase..' · '..d.phaseName;row.phaseUntil=current+2.4
 end
 if force then row.watchUntil=current+.75 end
end
function M.cancel(model,sequence)
 local row=rows[model];if not row then return end
 if row.channel and row.channel.sequence~=sequence then return end
 row.cancelledSequence=sequence;row.channel=nil
 removeGroup(row,'tether')
 removeGroup(row,'label');removeGroup(row,'motifs');row.visualKey=nil
end
function M.receive(message)
 local now=workspace:GetServerTimeNow()
 if message.kind=='support'then
  if not live(message.model)or not live(message.target)or (message.support~='Ward'and message.support~='Rally')then return end
  if type(message.untilTime)~='number'or message.untilTime<=now or (message.at and now-message.at>.75)then return end
  local latest=message.model:GetAttribute('K0SupportSeq')
  if type(latest)=='number'and latest>message.sequence then return end
  M.observe(message.model,now,true);M.observe(message.target,now,true)
  local row=rows[message.model];if not row then return end
  removeGroup(row,'tether')
  row.channel={target=message.target,sequence=message.sequence,support=message.support,untilTime=message.untilTime}
  row.cancelledSequence=nil
 elseif message.kind=='supportEnd'then
  M.cancel(message.model,message.sequence)
 elseif message.kind=='status'then
  M.observe(message.target,now,true)
 elseif message.kind=='weakness'then
  M.observe(message.model,now,true)
  local row=rows[message.model];if row then row.weaknessSide=message.side end
 end
end
local function label(row,model,text,active)
 if not row.label then
  local gui=Instance.new('BillboardGui');gui.Name='EnemyMechanicState';gui.Adornee=row.root
  gui.Size=UDim2.fromOffset(240,18);gui.MaxDistance=95;gui.AlwaysOnTop=false
  local height=model:GetAttribute('TdMonsterTargetHeight')or 5
  gui.StudsOffsetWorldSpace=Vector3.new(0,height-row.root.Size.Y*1.5+3.1+(model:GetAttribute('StoryBoss')and .9 or 0),0)
  local textLabel=Instance.new('TextLabel');textLabel.Name='Status';textLabel.Size=UDim2.fromScale(1,1)
  textLabel.BackgroundTransparency=1;textLabel.Font=Enum.Font.GothamBold;textLabel.TextSize=12;textLabel.TextStrokeColor3=Color3.fromRGB(24,18,30)
  textLabel.TextStrokeTransparency=.12;textLabel.AutoLocalize=false;textLabel.Parent=gui
  gui.Parent=row.root;row.label=gui
 end
 row.label.Status.Text=text
 row.label.Status.TextSize=active.Phase and 11 or 12
 row.label.Status.TextColor3=active.Exposed and gold or (active.Casting=='Rally'or active.Rally or active.Weakness)and purple or gold
end
local function motifs(row,active)
 local key=active.Casting or ''
 for _,name in ipairs({'Ward','Rally','Exposed','Web','Chill','Burn','Venom','Weakness','Soul'})do if active[name]then key..=name..':'end end
 if row.visualKey==key then return end
 removeGroup(row,'motifs');row.visualKey=key
 if key==''then return end
 local group=Instance.new('Folder');group.Name='EnemyMechanicMotifs';group.Parent=row.root;row.motifs=group
 if active.Casting then for i=1,3 do makePart(group,'Casting'..i,active.Casting=='Ward'and gold or purple,'wedge')end end
 if active.Ward then for i=1,4 do makePart(group,'Ward'..i,gold,'wedge')end end
 if active.Rally then for i=1,2 do makePart(group,'Rally'..i,purple,'wedge')end end
 if active.Exposed then for i=1,2 do makePart(group,'Exposed'..i,gold)end end
 for index,s in ipairs(statuses)do
  if active[s.key]then
   local count=s.key=='Web'and 4 or 3
   for i=1,count do
    local shape=(s.key=='Burn'or s.key=='Chill'or s.key=='Weakness')and 'wedge'or (s.key=='Venom'or s.key=='Soul')and 'ball'or nil
    local p=makePart(group,s.key..i,s.color,shape);p:SetAttribute('Mechanic',s.key);p:SetAttribute('Index',i)
    if index>=3 and index>5 then p.Transparency=.48 end
   end
  end
 end
end
local function pose(row,model,current,active)
 if not row.motifs then return end
 local root=row.root;local height=model:GetAttribute('TdMonsterTargetHeight')or 5
 local radius=math.clamp(height*.18,.65,1.8)
 for _,p in ipairs(row.motifs:GetChildren())do
  local kind=p:GetAttribute('Mechanic');local i=p:GetAttribute('Index')or tonumber(p.Name:match('(%d+)$'))or 1
  local angle=i*math.pi*2/3
  if p.Name:match('^Casting')then
   local yaw=current*1.7+i*math.pi*2/3
   p.Size=Vector3.new(.08,.22,.13);p.CFrame=root.CFrame*CFrame.new(math.cos(yaw)*radius*.65,.85,math.sin(yaw)*radius*.65)*CFrame.Angles(0,-yaw,math.rad(25))
  elseif p.Name:match('^Ward')then
   local yaw=(i-1)*math.pi*.5
   p.Size=Vector3.new(.13,.65,.45);p.CFrame=root.CFrame*CFrame.new(math.cos(yaw)*radius,.2,math.sin(yaw)*radius)*CFrame.Angles(0,-yaw,math.rad(12))
   p.Transparency=.3+.12*math.sin(current*2)^2
  elseif p.Name:match('^Rally')then
   p.Size=Vector3.new(.12,.42,.3);p.CFrame=root.CFrame*CFrame.new((i==1 and -1 or 1)*radius*.65,.8+(current*.6+i*.2)%.45,0)*CFrame.Angles(0,0,math.pi)
  elseif p.Name:match('^Exposed')then
   local side=i==1 and -1 or 1
   p.Size=Vector3.new(.08,.55,.12)
   local offset=active.ExposedSide=='rear'and Vector3.new(side*.3,.5,radius+.15)or Vector3.new(side*(radius+.15),.5,0)
   p.CFrame=root.CFrame*CFrame.new(offset)*CFrame.Angles(0,0,side*math.rad(18))
  elseif kind=='Web'then
   local a=(i-1)*math.pi*.5
   p.Size=Vector3.new(.035,.035,radius*1.5);p.CFrame=root.CFrame*CFrame.new(math.cos(a)*radius*.6,-root.Size.Y*.9,math.sin(a)*radius*.6)*CFrame.Angles(0,a+math.pi*.25,0)
  elseif kind=='Chill'then
   p.Size=Vector3.new(.13,.4,.22);p.Material=Enum.Material.Ice
   p.CFrame=root.CFrame*CFrame.new(math.cos(angle)*radius,-root.Size.Y*.65,math.sin(angle)*radius)*CFrame.Angles(0,-angle,math.rad(i*8-16))
  elseif kind=='Burn'then
   p.Size=Vector3.new(.1,.27,.17);p.CFrame=root.CFrame*CFrame.new(math.cos(angle)*radius*.75,-.3+(current*1.25+i*.27)%.9,math.sin(angle)*radius*.75)*CFrame.Angles(0,angle,math.rad(18))
  elseif kind=='Venom'then
   p.Size=Vector3.new(.13,.21,.13);p.CFrame=root.CFrame*CFrame.new(math.cos(angle)*radius*.7,.6-(current*.7+i*.31)%.9,math.sin(angle)*radius*.7)
  elseif kind=='Weakness'then
   p.Size=Vector3.new(.09,.22,.18);p.CFrame=root.CFrame*CFrame.new(math.cos(angle)*radius,.35,math.sin(angle)*radius)*CFrame.Angles(0,-angle,math.pi)
  elseif kind=='Soul'then
   local yaw=current*.9+angle
   p.Size=Vector3.new(.1,.25,.1);p.CFrame=root.CFrame*CFrame.new(math.cos(yaw)*radius,.1+(current*.35+i*.2)%.75,math.sin(yaw)*radius)
  end
 end
end
local function tether(row,model,current,active)
 local channel=row.channel
 if not channel and active.Casting then
  local target=byId[model:GetAttribute('K0SupportTargetId')]
  if target then channel={target=target,sequence=model:GetAttribute('K0SupportSeq'),support=active.Casting,untilTime=model:GetAttribute('K0SupportUntil')};row.channel=channel end
 end
 if not channel or channel.untilTime<=current or not live(channel.target)then removeGroup(row,'tether');row.channel=nil;return end
 if not active.Casting then
  removeGroup(row,'tether')
  if current>=(row.watchUntil or 0)then row.channel=nil end
  return
 end
 local target=channel.target:FindFirstChild('HumanoidRootPart');if not target then removeGroup(row,'tether');return end
 local from=row.root.Position+Vector3.yAxis*.6;local to=target.Position+Vector3.yAxis*.6
 if (to-from).Magnitude<.05 then removeGroup(row,'tether');return end
 if not row.tether then
  local group=Instance.new('Folder');group.Name='EnemySupportTether';group.Parent=row.root;row.tether=group
  for i=1,3 do makePart(group,'SupportLine'..i,channel.support=='Ward'and gold or purple)end
 end
 for i,p in ipairs(row.tether:GetChildren())do
  local first=from:Lerp(to,(i-1)/3)+Vector3.yAxis*math.sin((i-1)*math.pi/3)*.35
  local last=from:Lerp(to,i/3)+Vector3.yAxis*math.sin(i*math.pi/3)*.35
  p.Size=Vector3.new(.055,.055,math.max(.01,(last-first).Magnitude));p.CFrame=CFrame.lookAt((first+last)*.5,last)
  p.Transparency=.22+.12*math.sin(current*3+i)^2
 end
end
function M.render(current)
 for model,row in pairs(rows)do
  if not live(model)or not row.root.Parent then remove(model)
  else
   if row.channel and (row.channel.untilTime<=current or not live(row.channel.target))then row.channel=nil;removeGroup(row,'tether')end
   local text,active=state(model,current,row)
   if text==''and not row.channel and current>=(row.watchUntil or 0)then remove(model)
   elseif not visible(row.root)then clearVisual(row)
   else
    if text~=''then label(row,model,text,active)else removeGroup(row,'label')end
    motifs(row,active);pose(row,model,current,active);tether(row,model,current,active)
   end
  end
 end
end
function M.clear(model)remove(model)end
return M
