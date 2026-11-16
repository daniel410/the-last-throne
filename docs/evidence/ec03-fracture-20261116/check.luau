local W=game.ServerScriptService.Server.World
local m=require(W.RegionalArchitecture).build('BracedMineHead')
local rows=require(W.RegionalArchitectureTemplates).BracedMineHead
local children=m:GetChildren();local count=0;local variants={}
for i,r in ipairs(rows)do
 local p=children[i];assert(p.Name==r[1]);assert(p.Size==Vector3.new(table.unpack(r[4])));assert(p.CFrame==CFrame.new(table.unpack(r[6])))
 assert(p:GetAttribute('EpicDetailSolid')==r[7]);assert(p.Anchored and not p.CanCollide and not p.CanQuery and not p.CanTouch)
 if r[1]=='CoursedMasonry'then local mesh=assert(p:FindFirstChild('MineFractureSurface'));assert(p.Material==Enum.Material.Basalt);assert(p:GetAttribute('MineFractureVisual'));count+=1;variants[tostring(mesh.Scale)]=true end
end
assert(count==18);local n=0 for _ in variants do n+=1 end assert(n==5)
local parts=0 for _,p in m:GetDescendants()do if p:IsA('BasePart')then parts+=1 end end assert(parts==#rows+13)
m:Destroy();return game.HttpService:JSONEncode({fractureFaces=count,variants=n,baseParts=parts,templateParts=#rows,physicsPreserved=true})
