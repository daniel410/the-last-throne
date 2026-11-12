-- Incident objects use the same authored story contracts as the original goals.
local M={}
function M.create(parent,chapter,goal,step,at)
 local kit=require(script.Parent.StoryProps)
 local key=assert(kit.forStep(chapter,goal,step),'Missing incident art: '..chapter..':'..goal..':'..step.id)
 local themes={DW='Deepwood',GW='Gloamwood',FV='FrozenVale',EC='EmberCaldera',HG='HauntedGraveyard'}
 local m=kit.build(nil,key,at,{name=chapter..'_'..goal..'_'..step.id..'_Art',theme=themes[chapter:sub(1,2)],detail='incident'})
 m:SetAttribute('StoryObjective',chapter..':'..goal..':'..step.id);m:SetAttribute('StoryObjectTitle',step.title)
 m:SetAttribute('ExpansionStepEvent',chapter..':'..goal);m:SetAttribute('ExpansionStepChapter',chapter);m:SetAttribute('ExpansionStepIndex',tonumber(step.id:match('%d+')))
 for _,p in ipairs(m:GetDescendants())do if p:IsA('BasePart')then p:SetAttribute('ExpansionOriginalColor',p.Color)end end
 m.Parent=parent
 return m
end
return M
