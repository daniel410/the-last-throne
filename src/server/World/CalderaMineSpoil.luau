-- EC-03: cold excavated basalt beside the rescue passage, never a new objective.
-- Derived from the pinned TD VolcanoCliff; source assets remain untouched.
local Env=require(script.Parent.DeepwoodEnvironment)
local Areas=require(game.ReplicatedStorage.Shared.CampaignAreas)
local Content=require(game.ReplicatedStorage.Shared.CampaignContent)
local M={version=1};local V=Vector3.new
function M.build(root,center,size,pal,safe,ground)
 local used={};local count=0
 local function candidate(p)
  local radius=32
  if math.abs(p.X-center.X)+radius>size[1]/2 or math.abs(p.Z-center.Z)+radius>size[2]/2 then return end
  if not safe(p,radius)then return end
  for _,area in ipairs(Content.zones['EC-03'].expansionAreas or {})do
   if Areas.contains(area,p.X,p.Z,radius+8)or Areas.contains(area.connector,p.X,p.Z,radius+8)then return end
  end
  for _,q in ipairs(used)do if (p-q).Magnitude<85 then return end end
  local at,ok=ground(p);if not ok then return end
  for _,d in ipairs({V(26,0,0),V(-26,0,0),V(0,0,26),V(0,0,-26)})do
   local q,supported=ground(p+d);if not supported or math.abs(q.Y-at.Y)>1 then return end
  end
  return at
 end
 for band,offset in ipairs({{-.37,-.33},{.37,-.33},{-.37,.33},{.37,.33}})do
  local anchor=center+V(offset[1]*size[1],0,offset[2]*size[2]);local at
  for ring=0,18 do
   for k=0,(ring==0 and 0 or 23)do
    local angle=k*math.pi/12;at=candidate(anchor+V(math.cos(angle)*ring*20,0,math.sin(angle)*ring*20))
    if at then break end
   end
   if at then break end
  end
  if at then
   local group=Instance.new('Model');group.Name='ColdBasaltSpoil';group.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
   group.WorldPivot=CFrame.new(at)
   group:SetAttribute('MineSpoilBand',band);group:SetAttribute('GroundPosition',at)
   group:SetAttribute('SourceKind','DerivedPinnedTD:VolcanoCliff');group.Parent=root
   -- A large fractured piece, a lower shoulder and a small toe: unequal massing.
   for i,spec in ipairs({{V(-7,0,-3),22},{V(9,0,5),13},{V(2,0,15),8}})do
    local foot=ground(at+spec[1]);local rock=Env.asset(group,'VolcanoCliff',foot,spec[2])
    local cf=rock:GetBoundingBox()
    rock:PivotTo(CFrame.new(cf.Position)*CFrame.Angles(0,band*.87+i*.61,0)*CFrame.Angles(0,0,math.pi/2)*cf:ToObjectSpace(rock:GetPivot()))
    -- Keep world-up bounds: route relocation and grounding use their bottom.
    rock.PrimaryPart=nil;rock.WorldPivot=CFrame.new(foot)
    local bounds,extent=rock:GetBoundingBox()
    rock:PivotTo(rock:GetPivot()+V(0,foot.Y-(bounds.Y-extent.Y/2)-.25,0))
    rock:SetAttribute('MineSpoilHeight',spec[2]);rock:SetAttribute('GroundPosition',foot)
    for _,p in ipairs(rock:GetDescendants())do if p:IsA('MeshPart')then
     p:SetAttribute('TDOriginalTexture',p.TextureID);p.TextureID='';p.Material=Enum.Material.Basalt
     p.Color=pal.rock:Lerp(pal.trim,(i-1)*.09)
    end end
   end
   used[#used+1]=at;count+=1
  end
  task.wait()
 end
 root:SetAttribute('MineSpoilVersion',M.version);root:SetAttribute('MineSpoilGroups',count)
 return root
end
return M
