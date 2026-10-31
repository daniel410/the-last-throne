-- NPC cast v1 follows the user's smooth-face/block-body direction. TD original stays archived.
local Visual=require(script.Parent.NPCVisual)
local V={}
function V.create(parent,position,name)
 local model=Visual.create(parent,'selene',position,{name=name or 'Selene'})
 model:SetAttribute('TDDesignLineage','priestess / nun')
 return model
end
return V
