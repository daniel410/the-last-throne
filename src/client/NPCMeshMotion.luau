-- Continuous lower-body skinning keeps approved held props rigid in the upper body.
-- Client presentation never changes the actor root, interaction or escort authority.
local View={}
function View.bind(model)
 local root=model.PrimaryPart
 if not root then return end
 local bones,basis,parts={},{},{}
 for _,p in model:GetDescendants()do
  if p:IsA('Bone')then
   bones[p.Name]=p;basis[p.Name]=root.CFrame:ToObjectSpace(p.WorldCFrame).Rotation
  elseif p:IsA('BasePart') and p~=root then
   local rest=p:GetAttribute('NPCMeshRest');if not rest then return end
   table.insert(parts,{part=p,rest=rest})
  end
 end
 for _,name in {'Body','LegL','FootL','LegR','FootR'}do if not bones[name]then return end end
 if #parts==0 then return end
 local r={root=root,model=model,bones=bones,parts=parts,cf=root.CFrame,previous=root.Position,weight=0,phase=0}
 local seed=0;for i=1,#model.Name do seed+=string.byte(model.Name,i)*i end
 local height=model:GetAttribute('NPCMeshHeight') or 6.2
 local function translate(name,offset)
  bones[name].Transform=CFrame.new(basis[name]:VectorToObjectSpace(offset))
 end
 function r:update(dt,now)
  if dt<=0 or not root.Parent then return end
  local teleported=(root.Position-self.previous).Magnitude>=8
  self.cf=teleported and root.CFrame or self.cf:Lerp(root.CFrame,1-math.exp(-16*math.min(dt,.1)))
  local delta=self.cf.Position-self.previous;self.previous=self.cf.Position
  local distance=Vector3.new(delta.X,0,delta.Z).Magnitude
  local speed=not teleported and distance/dt or 0
  if teleported then self.weight=0 else
   self.weight+=(math.clamp(speed/7,0,1)-self.weight)*(1-math.exp(-10*math.min(dt,.1)))
   self.phase+=distance/(height*.52)*math.pi*2
  end
  for _,p in self.parts do if p.part.Parent then p.part.CFrame=self.cf*p.rest end end
  for _,bone in self.bones do bone.Transform=CFrame.identity end
  local breath=(math.sin((now+seed%101)*1.8)+1)*height*.0008*(1-self.weight)
  translate('Body',Vector3.new(0,breath,0))
  for _,side in {'L','R'}do
   local wave=math.sin(self.phase+(side=='L' and 0 or math.pi))
   translate('Leg'..side,Vector3.new(0,math.max(0,wave)*height*.025,-wave*height*.045)*self.weight)
  end
 end
 function r:reset()
  self.previous=root.Position;self.cf=root.CFrame;self.weight=0
  for _,bone in self.bones do if bone.Parent then bone.Transform=CFrame.identity end end
  for _,p in self.parts do if p.part.Parent and root.Parent then p.part.CFrame=root.CFrame*p.rest end end
 end
 return r
end
return View
