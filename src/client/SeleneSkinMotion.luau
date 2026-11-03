-- Presentation only: preserve the intact TD surface with native Bone transforms.
local Motion={}
local REQUIRED={'Root','Pelvis','Spine','Head','UpperL','ForearmL','HandL','UpperR','ForearmR','HandR','Lantern','LegL','FootL','LegR','FootR'}
function Motion.bind(model,root)
 local bones,basis={},{}
 for _,b in model:GetDescendants()do if b:IsA('Bone')then
  bones[b.Name]=b;basis[b.Name]=root.CFrame:ToObjectSpace(b.WorldCFrame).Rotation
 end end
 for _,name in REQUIRED do if not bones[name]then return end end
 local visual=assert(model:FindFirstChild('VisualRoot'))
 local height=model:GetScale()
 local palm=Vector3.new(-.36,.38,-.03)*height
 local handRest=visual.CFrame:ToObjectSpace(bones.HandL.WorldCFrame)
 return {bones=bones,basis=basis,visual=visual,height=height,palm=handRest:PointToObjectSpace(palm)}
end
function Motion.step(s,phase,weight,cast,now)
 for _,b in s.bones do b.Transform=CFrame.identity end
 -- Blender +Z up/-Y front -> Roblox +Y up/-Z front. Conjugate each
 -- character-space rotation into that bone's own rest axes.
 local function rotate(name,x,y,z)
  local basis=s.basis[name]
  s.bones[name].Transform=basis:Inverse()*CFrame.Angles(-x,0,0)*CFrame.Angles(0,0,y or 0)*CFrame.Angles(0,z or 0,0)*basis
 end
 local function move(name,v)
  local b=s.bones[name]
  b.Transform=CFrame.new(s.basis[name]:VectorToObjectSpace(v*s.height))*b.Transform
 end
 local wave=math.sin(phase)
 rotate('Spine',-.02*cast,.012*wave*weight,0)
 move('Spine',Vector3.new(0,.0015*math.sin(now*2.1)*(1-weight),0))
 rotate('Head',.035*cast,0,.02*math.sin(now*.7)*(1-weight))
 for _,side in {'L','R'}do
  local swing=math.sin(phase+(side=='L'and 0 or math.pi))
  move('Leg'..side,Vector3.new(0,math.max(0,swing)*.022*weight,-swing*.045*weight))
  rotate('Foot'..side,-math.max(0,swing)*.08*weight,0,0)
 end
 rotate('UpperL',-.12*wave*weight-.42*cast,0,-.08*cast)
 rotate('ForearmL',-.27*cast,0,0);rotate('HandL',.08*cast,0,0)
 rotate('UpperR',.055*wave*weight-.045*cast,0,0)
 rotate('Lantern',.025*wave*weight,0,0)
end
function Motion.hand(s)
 return s.bones.HandL.TransformedWorldCFrame*CFrame.new(s.palm)
end
function Motion.reset(s)
 for _,b in s.bones do if b.Parent then b.Transform=CFrame.identity end end
end
return Motion
