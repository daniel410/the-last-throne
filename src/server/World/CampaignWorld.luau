local W={}
function W.create()
 local world=require(script.Parent.DeepwoodWorld).create()
 require(script.Parent.FrozenValeWorld).create(world)
 require(script.Parent.EmberCalderaWorld).create(world)
 require(script.Parent.LateEpicWorld).create(world)
 require(script.Parent.DeepwoodActivityWorld).create(world)
 return world
end
return W
