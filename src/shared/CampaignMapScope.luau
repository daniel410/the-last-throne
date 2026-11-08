-- Show every region in the selected epic, including optional adventure areas.
local Content=game and require(script.Parent.CampaignContent) or dofile('src/shared/CampaignContent.luau')
local Progress=game and require(script.Parent.DeepwoodProgress)or dofile('src/shared/DeepwoodProgress.luau')
local Scope={}
function Scope.range(epic)
	return (epic-1)*7+1,math.min(epic*7,Content.mainCount)
end
function Scope.ids(epic)
	local ids={}
	for id in pairs(Content.zones) do if Scope.epicFor(id)==epic then ids[id]=true end end
	return ids
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
