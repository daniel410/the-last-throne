-- Pure presentation palette. Never changes server skill elements or outcomes.
local Catalog=require(script.Parent.PixelFXCatalog)
local P={}
P.colors=table.freeze({steel=Color3.fromRGB(163,210,244),axe=Color3.fromRGB(243,172,89),shield=Color3.fromRGB(102,211,255),holy=Color3.fromRGB(255,189,50),arrow=Color3.fromRGB(192,232,170),nature=Color3.fromRGB(93,219,135),arcane=Color3.fromRGB(181,139,255),gravity=Color3.fromRGB(144,83,226),wind=Color3.fromRGB(173,249,225),water=Color3.fromRGB(81,186,249),fire=Color3.fromRGB(255,112,45),earth=Color3.fromRGB(176,136,91),frost=Color3.fromRGB(142,231,255),lightning=Color3.fromRGB(90,164,255),gun=Color3.fromRGB(255,215,133),bomb=Color3.fromRGB(255,144,66)})
function P.get(key,classId)
 local displayKey=classId=='dwarf'and key=='steel'and'axe'or key
 return P.colors[displayKey]or P.colors.steel,key=='holy'and Color3.fromRGB(255,226,128)or Color3.fromRGB(248,248,229)
end
function P.resolve(classId,id)
 local row=Catalog.get(classId,id)
 local key=row and row.key or Catalog.basic[classId]
 if not key then return nil end
 local color,hot=P.get(key,classId)
 return color,hot,key,row
end
return table.freeze(P)
