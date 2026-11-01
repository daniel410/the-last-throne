local w=workspace:WaitForChild('DawnspireLobbyPrototype')
local r=w:WaitForChild('DawnspireResidents');local selene=r:WaitForChild('Selene');local spec=require(game.ReplicatedStorage.Shared.LobbyFacilities)
local at=w:GetAttribute('WorldOrigin')+(spec.portal.offset+spec.defense.offset)/2
local n=0;local function check(v,m)assert(v,m);n+=1 end
check((selene:GetPivot().Position-at).Magnitude<.01,'Selene between portals')
check(at.X==-4 and at.Z==482,'correct lobby midpoint')
local p=selene:FindFirstChildWhichIsA('ProximityPrompt',true)
check(p and p.ActionText=='Talk' and p.KeyboardKeyCode==Enum.KeyCode.F and p.MaxActivationDistance==10,'same dialogue prompt')
local count=0;for _,v in ipairs(r:GetChildren())do if v.Name=='Selene'then count+=1 end end;check(count==1,'single resident')
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={w};params.RespectCanCollide=true
for z=536,486,-5 do local start=Vector3.new(-4,100,z);check(workspace:Raycast(start,Vector3.new(0,-12,0),params)~=nil,'grounded approach');check(workspace:Raycast(start,Vector3.new(0,0,-5),params)==nil,'clear approach')end
return {checks=n,position=tostring(selene:GetPivot().Position),prompt=p.ObjectText,coverage='Studio Play position, retained prompt and approach raycasts; no player dialogue or companion acceptance'}
