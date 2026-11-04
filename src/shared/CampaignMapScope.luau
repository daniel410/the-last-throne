-- Scope the detailed adventure map to one epic's seven main story regions.
local Content=game and require(script.Parent.CampaignContent) or dofile('src/shared/CampaignContent.luau')
local Scope={}
function Scope.range(epic)
	return (epic-1)*7+1,math.min(epic*7,Content.mainCount)
end
function Scope.ids(epic)
	local ids={}
	local first,last=Scope.range(epic)
	for i=first,last do ids[Content.mainChapters[i].id]=true end
	return ids
end
function Scope.epicFor(id)
	for i,spec in ipairs(Content.epics) do
		if id and id:sub(1,3)==spec.hub:sub(1,3) then return i end
	end
	return 1
end
return Scope
