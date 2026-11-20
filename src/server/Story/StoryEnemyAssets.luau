local HttpService=game:GetService('HttpService')
local Shared=game:GetService('ReplicatedStorage').Shared
local Content=require(Shared.CampaignContent)
local Balance=require(Shared.DeepwoodEncounterBalance)
local Rig=require(script.Parent.Parent.World.TrainingField)
local Sizing=require(script.Parent.Parent.World.StoryMonsterSizing)

local Assets={}
local templates,assetsByKind={},{}
local requests=setmetatable({},{__mode='k'})

function Assets.template(kind)
 if not templates[kind] then
  local scale,visual=Sizing.forStory(kind,Balance.isBoss(kind))
  templates[kind]=Rig.makeEnemy(nil,kind,0,0,scale,visual)
 end
 return templates[kind]
end

local maps={'ColorMapContent','NormalMapContent','MetalnessMapContent','RoughnessMapContent'}
local function forKind(kind)
 if assetsByKind[kind] then return assetsByKind[kind] end
 local meshes,textures={},{}
 for _,item in ipairs(Assets.template(kind):GetDescendants())do
  if item:IsA('MeshPart') then
   meshes[item.MeshId]=true;textures[item.TextureID]=true
  elseif item:IsA('SurfaceAppearance') then
   for _,property in ipairs(maps)do
    local uri=item[property].Uri
    if uri then textures[uri]=true end
   end
  end
 end
 meshes['']=nil;textures['']=nil
 local result={meshes=meshes,textures=textures}
 assetsByKind[kind]=result
 return result
end

function Assets.prepare(player,chapter,journal)
 local kinds,seen={},{}
 local goals=0
 if chapter then for _,goal in ipairs(chapter.goals)do
  if #goal.enemies>0 and (not journal or not journal.flags[chapter.id..':'..goal.id]
   and (not goal.pacing or journal.combatPacingVersion==1)
   and (not goal.expansion or journal.expansionVersion==1))then
   for _,unit in ipairs(goal.enemies)do
    if not seen[unit.kind]then
     seen[unit.kind]=true;table.insert(kinds,unit.kind)
    end
   end
   goals+=1
   if goals==2 then break end
  end
 end end
 local key=table.concat(kinds,',')
 if requests[player]==key then return end
 requests[player]=key
 if key=='' then player:SetAttribute('TLTStoryEnemyWarmup',nil);return end
 task.defer(function()
  if not player.Parent or requests[player]~=key then return end
  local meshes,textures,seenMeshes,seenTextures={},{},{},{}
  for _,kind in ipairs(kinds)do
   local ok,assets=pcall(forKind,kind)
   if ok then
    for uri in pairs(assets.meshes)do
     if not seenMeshes[uri]then seenMeshes[uri]=true;table.insert(meshes,uri)end
    end
    for uri in pairs(assets.textures)do
     if not seenTextures[uri]then seenTextures[uri]=true;table.insert(textures,uri)end
    end
   else warn('Story enemy warmup failed: '..kind..' · '..tostring(assets))end
  end
  player:SetAttribute('TLTStoryEnemyWarmup',HttpService:JSONEncode({meshes=meshes,textures=textures}))
 end)
end

function Assets.prepareArrival(player,chapterId,journal)
 Assets.prepare(player,Content.byId[chapterId],journal)
end

return Assets
