-- Apply after terraces setup, access and asymmetry scripts in an isolated QA scene.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local root=assert(_G.Terraces)
local pylons=assert(root:FindFirstChild('TwinShieldPylons'))
local memorial=assert(root:FindFirstChild('KeeperMemorialCluster')):Clone()
memorial.Name='RoyalKeeperMemorial'
local cf,size=memorial:GetBoundingBox()
memorial:PivotTo(memorial:GetPivot()+(Vector3.new(270,206.05+size.Y/2,-17530)-cf.Position))
memorial:SetAttribute('AssetOrigin','Derived:KeeperMemorialCluster; replaces decorative TwinShieldPylons only')
memorial.Parent=root
pylons:Destroy()
root:SetAttribute('PrototypeVersion',3)
return {parts=#root:GetDescendants(),memorialCenter=tostring(select(1,memorial:GetBoundingBox()).Position)}
