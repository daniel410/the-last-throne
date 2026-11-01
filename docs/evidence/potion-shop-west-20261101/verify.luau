local w=workspace:WaitForChild('DawnspireLobbyPrototype')
local shop=w:WaitForChild('DawnspireItemShop');local training=w:WaitForChild('DawnspireTrainingGround');local portal=w:WaitForChild('DawnspireExpeditionPortal')
local residents=w:WaitForChild('DawnspireResidents');local mira=residents:WaitForChild('Mira');local rowan=residents:WaitForChild('Rowan')
local checks=0;local function check(v,m)assert(v,m);checks+=1 end
check(math.abs(shop:GetScale()-1.2)<.001,'shop enlarged20percent')
check((shop.Canopy.Size-Vector3.new(14.4,.6,6)).Magnitude<.01,'scaled canopy')
check((shop.Counter.Position-Vector3.new(-47,97.8,516)).Magnitude<.01,'shop moved')
check((mira:GetPivot().Position-Vector3.new(-47,96,522)).Magnitude<.01,'Mira follows scale and position')
check((rowan:GetPivot().Position-Vector3.new(-37,96,566)).Magnitude<.01,'Rowan follows training')
check(training.TrainingSand.Position.Z==555,'training12studs forward')
local sc,ss=shop:GetBoundingBox();local tc,ts=training:GetBoundingBox();local pc,ps=portal:GetBoundingBox()
check(sc.Position.Z-ss.Z/2>pc.Position.Z+ps.Z/2,'shop clear of portal')
check(sc.Position.Z+ss.Z/2<tc.Position.Z-ts.Z/2,'shop clear of training')
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={w};params.RespectCanCollide=true
for x=0,-45,-5 do
 local p=Vector3.new(x,100,527);check(workspace:Raycast(p,Vector3.new(0,-12,0),params)~=nil,'shop route floor')
 check(workspace:Raycast(p,Vector3.new(-5,0,0),params)==nil,'shop route clear')
end
for z=536,566,5 do
 local p=Vector3.new(0,100,z);check(workspace:Raycast(p,Vector3.new(0,-12,0),params)~=nil,'training route floor')
 check(workspace:Raycast(p,Vector3.new(0,0,5),params)==nil,'training route clear')
end
for x=0,-45,-5 do
 local p=Vector3.new(x,100,568);check(workspace:Raycast(p,Vector3.new(0,-12,0),params)~=nil,'training approach floor')
 check(workspace:Raycast(p,Vector3.new(-5,0,0),params)==nil,'training approach clear')
end
check(shop.Sign.FacilitySign.Title.Text=='POTION SHOP','English sign retained')
check(mira:FindFirstChildWhichIsA('ProximityPrompt',true).MaxActivationDistance==10,'merchant prompt retained')
return {checks=checks,shopCenter=tostring(sc.Position),shopSize=tostring(ss),trainingCenter=tostring(tc.Position),portalCenter=tostring(pc.Position),coverage='Studio Play server geometry and route raycasts; not player walking or transactions'}
