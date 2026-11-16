-- Client presentation only. Curves keep their authored endpoints and instance budgets.
local Style={}
local function frame(p,tangent)
 local x=tangent.Magnitude>.00001 and tangent.Unit or Vector3.xAxis
 local up=math.abs(x.Y)>.95 and Vector3.zAxis or Vector3.yAxis
 local z=x:Cross(up).Unit
 return CFrame.fromMatrix(p,x,z:Cross(x),z)
end
Style.frame=frame
function Style.span(path,first,last,age)
 local p,q=path(first,age),path(last,age)
 local h=math.min(.002,(last-first)*.1)
 local function tangent(t)
  local a,b=math.max(0,t-h),math.min(1,t+h)
  return (path(b,age)-path(a,age))/math.max(.00001,b-a)
 end
 local a,b=tangent(first)*(last-first)/3,tangent(last)*(last-first)/3
 -- A sharp or nearly collapsed authored path must not grow a large loop.
 local limit=(q-p).Magnitude*.7
 return p,q,a,b,math.min(a.Magnitude,limit),math.min(b.Magnitude,limit)
end
function Style.pose(a,b,beam,p,q,ta,tb,c0,c1)
 a.WorldCFrame=frame(p,ta);b.WorldCFrame=frame(q,tb)
 beam.CurveSize0=c0;beam.CurveSize1=c1
end
function Style.ribbon(points,beams)
 if #beams<2 then return end
 for i,a in ipairs(points)do
  local p=a.Position
  local previous=i>1 and points[i-1].Position or p-(points[i+1].Position-p)
  local following=i<#points and points[i+1].Position or p+(p-previous)
  local tangent=(following-previous)/6
  a.CFrame=frame(p,tangent)
  if beams[i]then beams[i].CurveSize0=tangent.Magnitude end
  if beams[i-1]then beams[i-1].CurveSize1=tangent.Magnitude end
 end
end
function Style.trail(trail,kind)
 local spell=kind=='spell';local enemy=kind=='enemy'
 trail.WidthScale=NumberSequence.new({NumberSequenceKeypoint.new(0,spell and .7 or .82),NumberSequenceKeypoint.new(.12,1),NumberSequenceKeypoint.new(.5,.34),NumberSequenceKeypoint.new(1,0)})
 trail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,enemy and .5 or spell and .3 or .16),NumberSequenceKeypoint.new(.35,enemy and .76 or .55),NumberSequenceKeypoint.new(1,1)})
 trail.LightInfluence=0;trail.FaceCamera=true
end
function Style.particles(e,key,smoke)
 -- Keep emitter speed/lifetime/count unchanged; give the residue a material flow.
 if key=='water'then
  e.Orientation=Enum.ParticleOrientation.VelocityParallel;e.Drag=1.4;e.Acceleration=-Vector3.yAxis*10
 elseif key=='fire'or key=='bomb'then
  e.Drag=smoke and 2.6 or 3.2;e.Acceleration=Vector3.yAxis*(smoke and 3 or 6)
 elseif key=='frost'or key=='ice'then
  e.Orientation=Enum.ParticleOrientation.VelocityParallel;e.Drag=4.5;e.RotSpeed=NumberRange.new(-25,25)
 elseif key=='soul'or key=='nature'or key=='heal'or key=='holy'then
  e.EmissionDirection=Enum.NormalId.Top;e.SpreadAngle=Vector2.new(24,24);e.Drag=2.5;e.Acceleration=Vector3.yAxis*3
 elseif key=='earth'or key=='venom'then
  e.Drag=smoke and 3.5 or 2;e.Acceleration=-Vector3.yAxis*(smoke and .7 or 5)
 elseif key=='wind'then
  e.Orientation=Enum.ParticleOrientation.VelocityParallel;e.Drag=3;e.RotSpeed=NumberRange.new(-12,12)
 end
end
return Style
