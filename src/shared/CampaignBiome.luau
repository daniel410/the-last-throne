-- Derive visual regions from the same translated footprints as campaign travel.
local Content=game and require(game:GetService('ReplicatedStorage').Shared.CampaignContent)or dofile('src/shared/CampaignContent.luau')
local Biome={}
local footprints={}
for id,zone in pairs(Content.zones)do
 local theme=Content.epics[zone.epic].region:gsub(' ','')
 local function add(area)
  footprints[#footprints+1]={id=id,theme=theme,center=area.center,size=area.size}
 end
 add(zone)
 for _,area in ipairs(zone.expansionAreas or {})do add(area);add(area.connector)end
end
table.sort(footprints,function(a,b)return a.id<b.id end)
function Biome.at(x,z)
 if type(x)~='number'or type(z)~='number'or x~=x or z~=z or math.abs(x)>1e7 or math.abs(z)>1e7 then return nil end
 local closest,distance
 for _,area in ipairs(footprints)do
  local dx=math.max(0,math.abs(x-area.center[1])-area.size[1]/2)
  local dz=math.max(0,math.abs(z-area.center[3])-area.size[2]/2)
  local d=dx*dx+dz*dz
  if not distance or d<distance then closest,distance=area,d end
 end
 -- In connecting roads, change mood at the nearest region's actual shoulder.
 return closest and closest.theme,closest and closest.id
end
return Biome
