-- Local story evidence, not a new navigation route or progression state.
local K=require(script.Parent.EpicEnvironmentKit)
local M={version=2}
local V=Vector3.new
function M.build(parent,chapter,ground)
 local old=parent:FindFirstChild('ScoutsTrailEvidence');if old then old:Destroy()end
 if not chapter or chapter.id~='GW-01'then return end
 local goal
 for _,g in ipairs(chapter.goals)do if g.id=='exp_1'then goal=g;break end end
 if not goal or not goal.activity or #goal.activity.steps<3 then return end
 local steps=goal.activity.steps
 local origin=V(table.unpack(steps[1].position))
 local target=V(table.unpack(steps[3].position))
 local scout=V(target.X-origin.X,0,target.Z-origin.Z)
 if scout.Magnitude<1 then return end
 scout=scout.Unit
 local root=Instance.new('Model');root.Name='ScoutsTrailEvidence'
 root.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 root:SetAttribute('StoryZone','GW-01');root:SetAttribute('StoryGoal','exp_1')
 root:SetAttribute('EvidenceVersion',M.version);root:SetAttribute('SourceKind','NewNativePrimitives')
 local count=0
 local function mark(name,p,width,length,direction,color)
  local side=V(-direction.Z,0,direction.X)
  local at,ok=ground(p);if not ok then return end
  -- Probe all corners: never bridge a seam, step, void or slope with a flat mark.
  for _,x in ipairs({-1,1})do for _,z in ipairs({-1,1})do
   local hit,valid=ground(p+side*x*width/2+direction*z*length/2)
   if not valid or math.abs(hit.Y-at.Y)>.025 then return end
  end end
  local part=K.part(root,name,V(width,.025,length),CFrame.lookAt(at+V(0,.025,0),at+V(0,.025,0)+direction),color,Enum.Material.Ground)
  -- PartType.Ball does not render this extreme flattening reliably.
  local mesh=Instance.new('SpecialMesh');mesh.MeshType=Enum.MeshType.Sphere;mesh.Parent=part
  part.Transparency=.16;part.CastShadow=false
  part:SetAttribute('TLTSceneryDistance',150);count+=1
 end
 local north=V(0,0,-1)
 local mud=K.palette.Gloamwood.ground:Lerp(K.palette.Gloamwood.wood,.65)
 for i=-3,3 do
  for _,side in ipairs({-1,1})do
   mark('LoadedWheelRut',origin+V(side*2.7,0,i*3.2),.75,2.8,north,mud)
  end
 end
 local across=V(-scout.Z,0,scout.X)
 for i=1,10 do
  local p=origin+scout*(5+i*1.6)+across*(i%2==0 and .65 or -.65)
  local color=mud:Lerp(K.palette.Gloamwood.trim,.18)
  -- Rounded sole and smaller heel leave a readable instep gap.
  mark('ScoutSole',p+scout*.24,.65,.72,scout,color)
  mark('ScoutHeel',p-scout*.43,.46,.36,scout,color)
 end
 root:SetAttribute('MarkCount',count);root.Parent=parent
 return root
end
return M
