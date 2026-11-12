-- Story-specific, upload-free native model kit. All detail is decorative.
-- Legacy exports: assets/models/story-props-v1; authored quest geometry: StoryQuestGeometry.
local Geometry=require(script.Parent.StoryPropGeometry)
local QuestGeometry=require(script.Parent.StoryQuestGeometry)
local Assignments=require(script.Parent.StoryPropAssignments)
-- The roadside manifest belongs to fallen convoy cargo, not office furniture.
local convoyCargo={purpose='Convoy food and medicine crate dropped during the ambush, with its packing list secured beneath the delivery seal.',parts=table.clone(Geometry.SupplyCrate.parts)}
table.insert(convoyCargo.parts,{name='PackingList',size={1.25,.035,1.5},position={-.2,2.17,0},color={223,207,164},material='Fabric',rotation={0,0,0},shape='Block'})
for i=1,4 do
 table.insert(convoyCargo.parts,{name='PackingListLine',size={.75,.012,.045},position={-.25,2.195,-.5+i*.22},color={74,62,46},material='Fabric',rotation={0,0,0},shape='Block'})
end
local P={version=2}
local function theme(chapter)
 if chapter and chapter:match('^GW')then return 'Gloamwood'end
 if chapter and chapter:match('^HG')then return 'HauntedGraveyard'end
 if chapter and chapter:match('^FV') then return 'FrozenVale' end
 if chapter and chapter:match('^EC') then return 'EmberCaldera' end
 return 'Deepwood'
end
function P.build(parent,key,position,options)
 options=options or {};local spec=assert(key=='ConvoySupplyCrate' and convoyCargo or QuestGeometry[key] or Geometry[key],'Unknown story prop: '..tostring(key))
 local model=Instance.new('Model');model.Name=options.name or key
 model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 model:SetAttribute('StoryPropVersion',P.version);model:SetAttribute('StoryPropKey',key)
 model:SetAttribute('StoryPropTheme',options.theme or 'Deepwood');model:SetAttribute('StoryPurpose',spec.purpose)
 local origin=typeof(position)=='CFrame' and position or CFrame.new(position)
 local scale=options.scale or 1
 local counts,seen={},{}
 local limits={WoundHempCable=6,RatchetGear=6,RatchetTooth=4,GuidePulley=4,BoltedFlange=6,FlangeBolt=4,GaugeBezel=4,ValveHandwheel=8,CompassRim=4,HandwrittenLedgerRule=3}
 if options.detail=='incident'then for _,piece in ipairs(spec.parts)do counts[piece.name]=(counts[piece.name]or 0)+1 end end
 for _,s in ipairs(spec.parts) do
  seen[s.name]=(seen[s.name]or 0)+1
  local limit=options.detail=='incident'and limits[s.name]
  local keep=not limit or math.floor(seen[s.name]*limit/counts[s.name])>math.floor((seen[s.name]-1)*limit/counts[s.name])
  if keep then
  local p=Instance.new(s.shape=='Wedge' and 'WedgePart' or 'Part');p.Name=s.name
  p.Size=Vector3.new(table.unpack(s.size))*scale
  local at=Vector3.new(table.unpack(s.position))*scale
  local cf=CFrame.new(at)
  if s.look then cf=CFrame.lookAt(at,Vector3.new(table.unpack(s.look))*scale)
  else cf*=CFrame.Angles(table.unpack(s.rotation)) end
  p.CFrame=origin*cf;p.Color=Color3.fromRGB(table.unpack(s.color));p.Material=Enum.Material[s.material]
  if s.shape=='Cylinder' then p.Shape=Enum.PartType.Cylinder end
  if p.Material==Enum.Material.Glass then p.Transparency=.35 end
  if options.theme=='FrozenVale' and (s.material=='Slate' or s.name=='LanternHood') then p.Color=p.Color:Lerp(Color3.fromRGB(194,218,226),.42)
  elseif options.theme=='EmberCaldera' and s.material=='Metal' then p.Color=p.Color:Lerp(Color3.fromRGB(107,76,62),.28) end
  p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
  p.CastShadow=p.Size.Magnitude>1;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
  p:SetAttribute('TLTDecorative',true);p.Parent=model
  if s.name=='RelayBridge' or s.name=='BraceHandle' then p:SetAttribute('StoryHandleOriginalColor',p.Color) end
  if not model.PrimaryPart then model.PrimaryPart=p end
  end
 end
 model.WorldPivot=origin;model.Parent=parent;return model
end
function P.forStep(chapter,goal,step)
 if step.kind=='actor' then return nil end
 return Assignments.forStep(chapter,goal,step)
end
function P.activity(parent,chapter,goal,step,position)
 if goal:match('^exp_')then return require(script.Parent.CampaignIncidentProps).create(parent,chapter,goal,step,position)end
 local key=P.forStep(chapter,goal,step)
 if not key then return end
 local model=P.build(nil,key,position,{theme=theme(chapter),name=chapter..'_'..goal..'_'..step.id..'_Art'})
 model:SetAttribute('StoryObjective',chapter..':'..goal..':'..step.id)
 model:SetAttribute('StoryObjectTitle',step.title)
 if chapter:match('^EC') and step.kind=='lever' then model:SetAttribute('StoryVisualKey',chapter..':'..goal) end
 model.Parent=parent
 return model
end
function P.goal(parent,chapter,goal)
 -- Later epic objects without multi-step activities still need meaningful art.
 if goal.activity or #(goal.enemies or {})>0 then return end
 local key=Assignments.goals[chapter..':'..goal.id]
 if key then
  local model=P.build(nil,key,Vector3.new(table.unpack(goal.position)),{theme=theme(chapter),name=chapter..'_'..goal.id..'_Art'})
  model:SetAttribute('StoryObjective',chapter..':'..goal.id);model:SetAttribute('StoryObjectTitle',goal.title)
  model.Parent=parent
  return model
 end
end
return P
