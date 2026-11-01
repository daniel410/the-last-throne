-- Generated catalog of the Blender-authored NPC head assets.
local assets=script.Parent.NPCHeadAssets
local data={version=4,hairSurface="rbxassetid://100424123930098",characters={}}
for _,id in ipairs({"aldric","mira","rowan","tessa","oren","nia","eryn","liora","tobin","pip","fen","freya","haldor","nessa","ivo","ylva","brann","dagna","orik","ketta","suri","maeve","finn","tali","wispkeeper","lumi","garrick","elowen","rook"}) do data.characters[id]=require(assert(assets:FindFirstChild(id),'Missing NPC head asset: '..id)) end
return data
