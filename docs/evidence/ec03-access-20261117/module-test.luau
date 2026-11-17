assert(game.PlaceId==0,'isolated place only')
local Trail=require(game.ServerScriptService.Server.World.MineAccessTrail)
local root=Instance.new('Folder');root.Name='MineAccessTest';root.Parent=workspace
local V=Vector3.new
local function ground(p)return V(p.X,100,p.Z),true end
local function clear()return true end
local m=assert(Trail.build(root,V(0,100,0),V(0,100,40),ground,clear))
assert(#m:GetChildren()==10)
for _,p in ipairs(m:GetChildren())do
 assert(p.Anchored and not p.CanCollide and not p.CanTouch and not p.CanQuery)
 assert(math.abs(p.Size.X-6)<.001 and math.abs(p.Size.Y-.06)<.001 and math.abs(p.Position.Y-100.035)<.001)
end
local checks=10
for _,case in ipairs({
 {V(0,100,2),ground,clear,'Distance'},
 {V(0,100,161),ground,clear,'Distance'},
 {V(0,100,40),function(p)return p,false end,clear,'Ground'},
 {V(0,100,40),function(p)return V(p.X,100+p.X,p.Z),true end,clear,'CrossSlope'},
 {V(0,100,40),function(p)return V(p.X,100+p.Z,p.Z),true end,clear,'Slope'},
 {V(0,100,40),ground,function(p)return p.Z<20 end,'Occupied'},
})do
 local before=#root:GetChildren()
 local model,reason=Trail.build(root,V(0,100,0),case[1],case[2],case[3])
 assert(not model and reason==case[4],tostring(reason));assert(#root:GetChildren()==before)
 checks+=1
end
root:Destroy()
return {ok=true,checks=checks,note='module geometry and rejection; actual placement separate'}
