local plots={};local added=0;local old=0
for _,m in _G.PassWorld.folder:GetDescendants()do if m.Name=='QuietBurialPlot'then
 local a=m:GetAttribute('GroundPosition');local n=0
 for _,p in m:GetDescendants()do if p:IsA('BasePart')then
 if p.Name=='GardenWallCoping'or p.Name=='GardenReturnWall'or p.Name=='GardenReturnCoping'then
 assert(p.Anchored and not p.CanCollide and not p.CanQuery and not p.CanTouch)
 assert(Vector3.new(p.Position.X-a.X,0,p.Position.Z-a.Z).Magnitude+p.Size.Magnitude/2<34)
 n+=1
 elseif p.Name=='BurialGardenWall'then old+=1 end
 end end
 assert(n==15);added+=n;table.insert(plots,{at={a.X,a.Y,a.Z},added=n})
 end end
assert(#plots==4 and old==12)
_G.GardenPlots=plots
return {plots=plots,addedParts=added,retainedWalls=old}
