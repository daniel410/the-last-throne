-- A small supplies counter behind Mira; interaction remains on the resident.
local A=require(script.Parent.LobbyArchitecture)
local C=A.color
local Spec=require(game.ReplicatedStorage.Shared.LobbyFacilities).itemShop
local M={}
function M.create(lobby)
 local model=Instance.new('Model');model.Name='DawnspireItemShop';model.Parent=lobby.folder
 local make=A.builder(model,lobby.origin+Spec.offset)
 make('Counter',Vector3.new(10,3,2),Vector3.new(0,1.5,0),C.wood,Enum.Material.WoodPlanks,true)
 make('CounterTop',Vector3.new(11,.35,2.5),Vector3.new(0,3.15,0),C.dark,Enum.Material.Slate)
 for _,x in ipairs({-5,5}) do make('Post',Vector3.new(.7,10,.7),Vector3.new(x,5,0),C.wood,Enum.Material.Wood) end
 make('Canopy',Vector3.new(12,.5,5),Vector3.new(0,10,0),C.blue,Enum.Material.Fabric)
 local sign=make('Sign',Vector3.new(10,2,.4),Vector3.new(0,7.5,-.8),C.blue,Enum.Material.Wood)
 A.sign(sign,Spec)
 for i,color in ipairs({Color3.fromRGB(211,67,67),Color3.fromRGB(75,145,230),Color3.fromRGB(211,67,67)}) do
  local bottle=make('Potion'..i,Vector3.new(.65,1,.65),Vector3.new(-1.5+i*1.5,3.8,.15),color,Enum.Material.Glass);bottle.Shape=Enum.PartType.Ball
  make('BottleNeck'..i,Vector3.new(.25,.35,.25),Vector3.new(-1.5+i*1.5,4.45,.15),C.gold,Enum.Material.Wood)
 end
 return model
end
return M
