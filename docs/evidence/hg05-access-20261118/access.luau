-- Isolated candidate fix; run after hg05-terraces setup, before physics audit.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local root=assert(_G.Terraces)
local palette=require(game.ServerScriptService.Server.World.EpicEnvironmentKit).palette.HauntedGraveyard
for _,x in ipairs({150,270,390})do
 assert(_G.TerraceSafe(Vector3.new(x,188,-17468),26),'Ramp reservation overlap')
 local ramp=Instance.new('WedgePart')
 ramp.Name='BurialProcessionalRamp';ramp.Size=Vector3.new(16,18.05,48)
 ramp.Anchored=true;ramp.Material=Enum.Material.Slate;ramp.Color=palette.trim
 ramp.CFrame=CFrame.new(x,197.025,-17468)*CFrame.Angles(0,math.pi,0)
 ramp:SetAttribute('AssetOrigin','Derived:EpicEnvironmentKit.palette.HauntedGraveyard')
 ramp:SetAttribute('EpicDetailSolid',true);ramp.Parent=root
end
return true
