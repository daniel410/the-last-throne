-- Material/paint only: never changes collision, authoritative floor size or height.
local Shared=game.ReplicatedStorage.Shared
local Biome=require(Shared.CampaignBiome)
local K=require(script.Parent.EpicEnvironmentKit)
local Finish={version=6}
local V=Vector3.new
local routes={WornCurvedRoute='secondary',JourneyWalkingTrail='main',RegionalReturnTrail='returning',ReturnLoop='returning',ExpansionWalkingLine='main'}
local materials={Deepwood=Enum.Material.Grass,Gloamwood=Enum.Material.Grass,FrozenVale=Enum.Material.Snow,EmberCaldera=Enum.Material.Basalt,HauntedGraveyard=Enum.Material.Slate}
local groundNames={Ground=true,ForestGround=true,SnowGround=true,BasaltGround=true,JourneyGround=true,JourneyPass=true}
function Finish.apply(world)
 local painted=0
 for _,p in ipairs(world.folder:GetDescendants())do if p:IsA('BasePart')then
  local theme=Biome.at(p.Position.X,p.Position.Z);local palette=K.palette[theme]
  if palette then
   local role=routes[p.Name]
   if role and not p.CanCollide then
    local returning=role=='returning';local secondary=role=='secondary'
    p.Color=palette.ground:Lerp(palette.trim,returning and .12 or secondary and .18 or .30)
    p.Material=materials[theme]
    p.Transparency=returning and .55 or secondary and .35 or .12
    -- HG-03: Lumi's maintenance passage has a modest secondary slate walk.
    -- Inspect authored ancestry, never infer a chapter from biome coordinates.
    local site=p.Parent
    while site and site~=world.folder and site.Name~='HG-03'do site=site.Parent end
    local servicePassage=site and site.Name=='HG-03' and secondary
    local width=servicePassage and 6 or (returning and 7 or secondary and 9 or 14)
    p.Size=V(math.min(p.Size.X,width),p.Size.Y,p.Size.Z)
    p.CastShadow=false;p:SetAttribute('CampaignSurfaceVersion',Finish.version);painted+=1
   elseif p.Name=='CourtFlagstone'or p.Name=='RegionalPathInlay'or p.Name=='MeetingCourtTile'or p.Name=='WornTrailPaver'or p.Name=='WornMeetingCourt'or p.Name=='MeetingCourtStone'then
    p.Color=palette.ground:Lerp(palette.trim,.16);p.Material=materials[theme]
    p.Transparency=.35;p.CastShadow=false;p:SetAttribute('CampaignSurfaceVersion',Finish.version)
   elseif groundNames[p.Name]and p.CanCollide then
    p.Color=palette.ground;p.Material=materials[theme]
    p:SetAttribute('CampaignSurfaceVersion',Finish.version)
   end
  end
 end end
 require(script.Parent.OverlandSurfaceTransition).apply(world)
 require(script.Parent.CampaignSurfaceUnderlays).apply(world)
 world.folder:SetAttribute('CampaignFinishedPaths',painted)
end
return Finish
