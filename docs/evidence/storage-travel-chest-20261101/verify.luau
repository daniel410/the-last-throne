local w=workspace:WaitForChild('DawnspireLobbyPrototype');local m=w:WaitForChild('DawnspireAccountStorage')
local n=0;local function check(v,s)assert(v,s);n+=1 end
local count,solid=0,0
for _,v in ipairs(m:GetDescendants())do
 check(not v:IsA('LuaSourceContainer'),'no embedded executable code')
 if v:IsA('BasePart')then count+=1;check(v.Anchored,'anchored');check(not v.CanTouch,'no touch events');if v.CanCollide then solid+=1;check(v.Name=='Chest' and v.CanQuery,'one collision body')else check(not v.CanQuery,'decorations do not obstruct queries')end end
end
check(count==153 and solid==1,'bounded part and collision count')
check(m:FindFirstChild('GoldBand')==nil,'gift ribbon removed')
for _,name in ipairs({'WoodPlank','IronRail','LeatherStrap','BuckleSide','CarryingGrip','LockHasp','Padlock','Keyhole','DiagonalTravelHarness'})do check(m:FindFirstChild(name)~=nil,name..' present')end
local p=m.Chest:FindFirstChild('OpenAccountStorage')
check(p and p.KeyboardKeyCode==Enum.KeyCode.F and p.MaxActivationDistance==12 and p.ActionText=='Open Storage','storage interaction contract')
check((m.Chest.Position-Vector3.new(12,97.4,536)).Magnitude<.01,'same storage origin')
local create=require(game.ServerScriptService.Server.World.StorageChest).create
local scratch=Instance.new('Folder');scratch.Name='TravelChestQA';scratch.Parent=workspace
for i=1,4 do local body,prompt=create({folder=scratch,origin=Vector3.new(0,-500,i*20)});check(body.Parent.PrimaryPart==body and prompt.Parent==body,'all hub callers retain return API')end
scratch:Destroy()
return {checks=n,parts=count,collisionBodies=solid,model=m.Name,coverage='Studio Play visual geometry and storage prompt/API; not persistent inventory transactions'}
