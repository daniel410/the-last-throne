-- Show every region in the selected epic, including optional adventure areas.
local Content=game and require(script.Parent.CampaignContent) or dofile('src/shared/CampaignContent.luau')
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
return Scope
