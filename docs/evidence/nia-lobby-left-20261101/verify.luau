local w=workspace:WaitForChild('DawnspireLobbyPrototype');local r=w:WaitForChild('DawnspireResidents');local n=r:WaitForChild('Nia');local o=r:WaitForChild('Oren');local at=n:GetPivot().Position;local ot=o:GetPivot().Position;local checks=0
local function check(v,m)assert(v,m);checks+=1 end
check((at-Vector3.new(-18,96,537)).Magnitude<.01,'Nia left position')
check(at.X==-ot.X and at.Z==ot.Z,'opposite Oren')
local p=n:FindFirstChildWhichIsA('ProximityPrompt',true);check(p and p.ActionText=='Talk' and p.KeyboardKeyCode==Enum.KeyCode.F,'dialogue retained')
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={w};params.RespectCanCollide=true
for x=0,-18,-3 do local start=Vector3.new(x,100,540);check(workspace:Raycast(start,Vector3.new(0,-12,0),params)~=nil,'approach floor');check(workspace:Raycast(start,Vector3.new(-3,0,0),params)==nil,'approach clear')end
return {checks=checks,nia=tostring(at),oren=tostring(ot),coverage='Studio Play positions, existing prompt and approach raycasts; not player dialogue acceptance'}
