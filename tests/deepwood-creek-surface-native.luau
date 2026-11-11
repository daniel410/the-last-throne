-- Visual geometry matters even when a decorative part has no collision.
local Content=require(game.ReplicatedStorage.Shared.CampaignContent)
local Scenes=require(game.ServerScriptService.Server.World.CampaignIncidentScenes)
local root=Instance.new('Folder');root.Name='CreekSurfaceQA'
local count=0
local ok,err=pcall(function()
 for _,chapter in ipairs(Content.chapters)do if chapter.epic==1 then
  for _,goal in ipairs(chapter.expansionGoals or {})do
   for _,area in ipairs(Content.zones[chapter.zone].expansionAreas or {})do
    if area.id==goal.area and area.layout=='creek'then
     local scene=Instance.new('Model');scene.Parent=root
     Scenes.create(scene,chapter,goal,area)
     local water=assert(scene:FindFirstChild('CreekWater'),'missing creek')
     local top=water.Position.Y+water.Size.Y/2
     assert(top<=area.center[2]+.1,'creek conceals the hero and walking route')
     assert(top>=area.center[2],'creek surface is buried')
     assert(water.Size.X==8 and water.Size.Z>100,'creek footprint changed')
     assert(not water.CanCollide and not water.CanQuery and not water.CanTouch,'decorative creek blocks gameplay')
     local stones=0
     for _,part in ipairs(scene:GetChildren())do if part.Name=='CreekCrossingStone'then
      assert(part.Position.Y+part.Size.Y/2>top,'crossing stone submerged');stones+=1
     end end
     assert(stones==3,'crossing stones missing');count+=1
    end
   end
  end
 end end
 assert(count==3,'expected all three Deepwood creeks')
end)
root:Destroy()
assert(ok,err)
return {passed=true,creeks=count}
