-- Story-specific, upload-free native model kit. All detail is decorative.
-- Geometry source and Blender exports: assets/models/story-props-v1.
local Geometry=require(script.Parent.StoryPropGeometry)
local P={version=1}
local function theme(chapter)
 if chapter and chapter:match('^FV') then return 'FrozenVale' end
 if chapter and chapter:match('^EC') then return 'EmberCaldera' end
 return 'Deepwood'
end
function P.build(parent,key,position,options)
 options=options or {};local spec=assert(Geometry[key],'Unknown story prop: '..tostring(key))
 local model=Instance.new('Model');model.Name=options.name or key
 model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 model:SetAttribute('StoryPropVersion',P.version);model:SetAttribute('StoryPropKey',key)
 model:SetAttribute('StoryPropTheme',options.theme or 'Deepwood');model:SetAttribute('StoryPurpose',spec.purpose)
 local origin=typeof(position)=='CFrame' and position or CFrame.new(position)
 local scale=options.scale or 1
 for _,s in ipairs(spec.parts) do
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
  if not model.PrimaryPart then model.PrimaryPart=p end
 end
 model.WorldPivot=origin;model.Parent=parent;return model
end
function P.forStep(chapter,goal,step)
 local kind=step.kind;local title=string.lower(step.title or '')
 -- Resolve the actual story object before using the reusable activity type.
 if title:find('badge',1,true) then return 'ConvoyBadge' end
 if title:find('crate',1,true) or title:find('medicine',1,true) or title:find('supplies',1,true) then return 'SupplyCrate' end
 if kind=='lever' then
  if title:find('cool',1,true) or title:find('valve',1,true) or title:find('intake',1,true) then return 'CoolantValve' end
  return 'GateWinch'
 end
 if kind=='ledger' or (kind=='relic' and title:find('order',1,true)) then return 'LedgerDesk' end
 if kind=='rune' then return title:find('portal',1,true) and 'PortalAnchor' or 'SealWaystone' end
 if kind=='lantern' then return 'RouteLantern' end
 if kind=='relic' then return 'SupplyCrate' end
 if kind=='tracks' or kind=='arrival' or kind=='resin' then
  return title:find('portal',1,true) and 'PortalAnchor' or 'TrailEvidence'
 end
 if kind=='bindings' then return 'TravelBindings' end
 if kind=='actor' then return nil end
 return 'LedgerDesk'
end
function P.activity(parent,chapter,goal,step,position)
 local key=P.forStep(chapter,goal,step)
 if not key then return end
 local model=P.build(parent,key,position,{theme=theme(chapter),name=chapter..'_'..goal..'_'..step.id..'_Art'})
 if chapter:match('^EC') and step.kind=='lever' then model:SetAttribute('StoryVisualKey',chapter..':'..goal) end
 return model
end
function P.goal(parent,chapter,goal)
 -- Later epic objects without multi-step activities still need meaningful art.
 if goal.activity or #(goal.enemies or {})>0 then return end
 local title=string.lower(goal.title or '')
 local key
 if title:find('lantern',1,true) or title:find('beacon',1,true) then key='RouteLantern'
 elseif title:find('mirror',1,true) then key='SignalMirror'
 elseif title:find('relay',1,true) or title:find('marker',1,true) then key='SealWaystone'
 elseif title:find('lock',1,true) then key='GateWinch'
 elseif title:find('record',1,true) or title:find('order',1,true) or title:find('plan',1,true) or title:find('map',1,true) then key='LedgerDesk'
 elseif title:find('suppl',1,true) or title:find('kit',1,true) then key='SupplyCrate'
 elseif title:find('seal',1,true) or title:find('portal',1,true) or title:find('core',1,true) then key='PortalAnchor' end
 if key then return P.build(parent,key,Vector3.new(table.unpack(goal.position)),{theme=theme(chapter),name=chapter..'_'..goal.id..'_Art'}) end
end
return P
