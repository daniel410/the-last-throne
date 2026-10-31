-- Visual reuse is not identity: different rescued residents may share Tobin's art.
local Catalog=require(script.Parent.NPCCatalog)
local I={}
local aliases={Quartermaster='liora',['Outpost Storekeeper']='liora',['Quarry Foreman']='fen',
 ['Outpost Scout']='eryn',['Goblin Refugee']='pip',Herbalist='fen',['Outpost Quartermaster']='liora',['Scout Captain']='eryn'}
local art={['Supply Survivor']='tobin',['Wounded Scout']='tobin',['Freed Prisoner']='tobin',Villager='tobin',['Freed Forest Spirit']='wispkeeper'}
function I.resolve(name,spirit)
 for _,c in ipairs(Catalog.characters)do if c.name==name then return c.id,'npc:'..c.id,true end end
 if aliases[name] then return aliases[name],'npc:'..aliases[name],true end
 return art[name] or (spirit and 'wispkeeper') or 'tobin','role:'..name,false
end
return I
