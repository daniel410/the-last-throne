-- Show every region in the selected epic, including optional adventure areas.
local Content=game and require(script.Parent.CampaignContent) or dofile('src/shared/CampaignContent.luau')
local Progress=game and require(script.Parent.DeepwoodProgress)or dofile('src/shared/DeepwoodProgress.luau')
local Bounds=game and require(script.Parent.CampaignBounds)or dofile('src/shared/CampaignBounds.luau')
local Scope={}
function Scope.range(epic)
	return (epic-1)*7+1,math.min(epic*7,Content.mainCount)
end
function Scope.ids(epic)
	local ids={}
	for id in pairs(Content.zones) do if Scope.epicFor(id)==epic then ids[id]=true end end
	return ids
end
-- Only boundary mouths are added; adjacent epic regions stay in their own atlas.
function Scope.connections(epic)
 local result={}
 for _,edge in ipairs(Content.overlandLinks)do
  local a,b=Bounds.ends(edge)
  local first,last=Content.zones[edge[1]].epic,Content.zones[edge[2]].epic
  if first==epic or last==epic then
   local forward=first==epic
   table.insert(result,{edge=edge,origin=forward and edge[1]or edge[2],
    destination=forward and edge[2]or edge[1],epic=forward and last or first,
    start=forward and a or b,finish=forward and b or a})
  end
 end
 return result
end
function Scope.epicFor(id)
	for i,spec in ipairs(Content.epics) do
		if id and id:sub(1,3)==spec.hub:sub(1,3) then return i end
	end
	return 1
end
-- main is a contiguous frontier; migrated saves may have later regions cleared.
function Scope.progress(journal,epic)
 local first,last=Scope.range(epic);local count=0
 for i=first,last do if journal and journal.clears and journal.clears[Content.mainChapters[i].id]then count=count+1 end end
 return count,last-first+1
end
function Scope.status(journal,id)
 if journal and journal.clears and journal.clears[id]then return 'Complete'end
 if not journal or type(journal.clears)~='table'then return 'Locked'end
 local chapter=Content.byId[id]
 return journal and chapter and Progress.eligible(journal,chapter)and 'Current'or 'Locked'
end
return Scope
