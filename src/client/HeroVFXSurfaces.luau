-- Filled, transient client geometry. Never participates in physics or hit tests.
local Input=game:GetService('UserInputService')
local S={}
local count=0
function S.count()return count end
function S.release(r)count=math.max(0,count-#r.faces)end
local function part(r,name,size,cf,color,alpha,shape,material,grow,rise)
 if count>=(Input.TouchEnabled and 80 or 160)then return end
 local p=Instance.new(shape=='wedge'and'WedgePart'or'Part')
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or r.color;p.Transparency=alpha or .3
 if shape=='ball'then p.Shape=Enum.PartType.Ball elseif shape=='disc'then p.Shape=Enum.PartType.Cylinder end
 p.Material=material or Enum.Material.Neon;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
 p.Parent=r.model;table.insert(r.faces,{part=p,cf=cf,size=size,alpha=p.Transparency,grow=grow,rise=rise});count+=1
 return p
end
function S.triangle(r,name,a,b,c,color,alpha)
 local ab,ac,bc=b-a,c-a,c-b
 local aa,bb,cc=ab:Dot(ab),ac:Dot(ac),bc:Dot(bc)
 if aa>bb and aa>cc then c,a=a,c elseif bb>aa and bb>cc then a,b=b,a end
 ab,ac,bc=b-a,c-a,c-b
 local normal=ac:Cross(ab);if normal.Magnitude<.001 or bc.Magnitude<.001 then return end
 local right=normal.Unit;local back=bc.Unit;local up=back:Cross(right)
 local height=math.abs(ab:Dot(up));if height<.01 then return end
 for _,v in ipairs({{b,right,back,math.abs(ab:Dot(back))},{c,-right,-back,math.abs(ac:Dot(back))}})do
  if v[4]>.01 then part(r,name,Vector3.new(.055,height,v[4]),CFrame.fromMatrix((a+v[1])*.5,v[2],up,v[3]),color,alpha,'wedge')end
 end
end
function S.ribbon(r,name,path,normal,width,alpha)
 local prevL,prevR
 for i=0,8 do
  local t=i/8;local at=path(t)
  local direction=path(math.min(1,t+.01))-path(math.max(0,t-.01))
  local side=normal:Cross(direction);side=side.Magnitude>.001 and side.Unit or Vector3.xAxis
  local half=width*(.025+.5*math.sin(t*math.pi)^.6)
  local left,right=at+side*half,at-side*half
  if prevL then S.triangle(r,name,prevL,prevR,left,nil,alpha);S.triangle(r,name,prevR,right,left,nil,alpha)end
  prevL,prevR=left,right
 end
end
function S.volume(r,name,at,size,color,alpha,shape,material,grow,rise)
 return part(r,name,size,CFrame.new(at),color,alpha,shape or'ball',material,grow,rise)
end
function S.disc(r,name,at,radius,color,alpha)
 return part(r,name,Vector3.new(.06,radius*2,radius*2),CFrame.new(at)*CFrame.Angles(0,0,math.pi/2),color,alpha,'disc',nil,true)
end
function S.step(r,u,fade)
 for _,v in ipairs(r.faces)do
  v.part.Transparency=v.alpha+(1-v.alpha)*fade
  if v.grow then v.part.Size=v.size*(.72+u*.65)end
  if v.rise then v.part.CFrame=v.cf+Vector3.yAxis*u*v.rise end
 end
end
return S
