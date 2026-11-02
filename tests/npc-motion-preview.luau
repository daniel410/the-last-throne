assert(game.PlaceId==0,'isolated gallery only')
local V=require(game.ServerScriptService.Server.World.NPCVisual)
local Motion=require(game.ReplicatedStorage.Shared.NPCMotion)
local f=Instance.new('Folder');f.Name='NPCMotionReview';f.Parent=workspace
local ids={'aldric','eryn','nia','lumi'}
local floor=Instance.new('Part');floor.Size=Vector3.new(60,.2,30);floor.Position=Vector3.new(0,-.1,0);floor.Anchored=true;floor.Color=Color3.fromRGB(65,74,79);floor.Parent=f
for i,id in ipairs(ids) do
 local m=V.create(f,id,Vector3.new((i-2.5)*7,0,0),{yaw=.2,label=true})
 local pose=Motion.pose(2,.9,1,m:GetScale(),m:GetAttribute('NPCMotionWidth'),m:GetAttribute('NPCMotionProp'),.15)
 for _,p in ipairs(m:GetDescendants()) do
  if p:IsA('BasePart') and p:GetAttribute('NPCMotionRest') then p.CFrame=m.PrimaryPart.CFrame*pose[p:GetAttribute('NPCMotionGroup')]*p:GetAttribute('NPCMotionRest') end
 end
end
workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(12,10,-26),Vector3.new(0,2.6,0))
game.Lighting.ClockTime=13;game.Lighting.Brightness=2;game.Lighting.Ambient=Color3.fromRGB(160,160,160)
game.ContentProvider:PreloadAsync(f:GetDescendants())
print('NPC_MOTION_GALLERY_READY')
task.wait(55)
f:Destroy()
