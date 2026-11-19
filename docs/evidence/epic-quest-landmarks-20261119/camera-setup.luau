assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, 'isolated local place only')
local World=game.ServerScriptService.Server.World
local Shared=game.ReplicatedStorage.Shared
local content=require(Shared.CampaignContent)
local bounds=require(Shared.CampaignBounds)
local existingWorld
for epic=1,5 do existingWorld=require(World.CampaignWorld).create(epic,existingWorld) end
local V=Vector3.new
local targets={
    {'DW-02',1,'Deepwood'},
    {'GW-06',2,'Gloamwood'},
    {'FV-04',1,'FrozenVale'},
    {'EC-05',1,'EmberCaldera'},
    {'HG-04',1,'HauntedGraveyard'},
}
local shots={}
for _,target in ipairs(targets) do
    local id,index,theme=table.unpack(target)
    local chapter=content.byId[id]
    local goal=chapter.expansionGoals[index]
    local activity=goal.activity
    local at=V(table.unpack(activity.finish.position))
    local area
    for _,a in ipairs(content.zones[chapter.zone].expansionAreas) do
        if a.id==goal.area then area=a;break end
    end
    local from=V(table.unpack(activity.steps[math.max(1,#activity.steps-1)].position))
    if id=='GW-06' then from=V(table.unpack(chapter.goals[1].position)) end
    local delta=V(from.X-at.X,0,from.Z-at.Z)
    if delta.Magnitude<1 then delta=V(table.unpack(area.entry))-at end
    local front=V(delta.X,0,delta.Z).Unit
    local right=V(-front.Z,0,front.X)
    print('QUEST_SITE',id,at,from,front,area.center[1],area.center[2],area.center[3])
    local function shot(suffix,offset,height)
        local eye=at+offset
        eye=V(eye.X,(bounds.surface(eye.X,eye.Z) or at.Y)+height,eye.Z)
        table.insert(shots,{id=id..suffix,theme=theme,aim={at.X,at.Y+1.8,at.Z},origin={eye.X,eye.Y,eye.Z}})
    end
    shot('-approach',front*27,9)
    shot('-side',front*12+right*18,8)
end
local cameraPlan=game.HttpService:JSONEncode(shots)
