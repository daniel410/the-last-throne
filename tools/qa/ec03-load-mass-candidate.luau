-- Review-only EC-03 prototype. Never invoked by production world creation.
-- Reuses the three pinned TD VolcanoCliff meshes; preserves the X/Z footprint.
return function(mine)
 local pivot=mine:GetPivot()
 local report={meshes={},kind='EC03_LOAD_MASS_CANDIDATE',production=false}
 local index=0
 for _,rock in ipairs(mine:GetChildren())do if rock:GetAttribute('MineQuarryMass')then
  index+=1
  local factor=({1.25,1.4,1.5})[index]
  assert(factor,'unexpected quarry mass count')
  for _,p in ipairs(rock:GetDescendants())do if p:IsA('MeshPart')then
   local before=p.Size;local cf=p.CFrame
   local localPosition=pivot:PointToObjectSpace(p.Position)
   -- The source meshes are yaw-only; lifting half the added height anchors
   -- their buried bottom to the exact previous plane, with no floating skirt.
   assert(math.abs(cf.UpVector.Y-1)<.001,'yaw-only source required')
   p.Size=Vector3.new(before.X,before.Y*factor,before.Z)
   p.CFrame=cf+Vector3.new(0,(p.Size.Y-before.Y)/2,0)
   report.meshes[#report.meshes+1]={mesh=p.MeshId,factor=factor,
    before={before.X,before.Y,before.Z},after={p.Size.X,p.Size.Y,p.Size.Z},
    xzPreserved=p.Size.X==before.X and p.Size.Z==before.Z and p.Position.X==cf.X and p.Position.Z==cf.Z,
    bottomDelta=(p.Position.Y-p.Size.Y/2)-(cf.Y-before.Y/2)}
  end end
 end end
 assert(index==3 and #report.meshes==3,'exactly three pinned TD masses')
 for _,row in ipairs(report.meshes)do assert(row.xzPreserved and math.abs(row.bottomDelta)<.001)end
 return report
end
