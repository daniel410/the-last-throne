-- `fixtures` comes from the GLB inverse bind matrices, independently of runtime code.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated unpublished fixture only')
local model=require(game.ServerScriptService.Server.World.SeleneVisual).create(workspace,Vector3.new(0,50,0),'SeleneBoneQA',{label=false})
local report={checks=0,vertices=0,faces=0}
local function check(v,label)report.checks+=1;assert(v,label)end
local ok,err=xpcall(function()
 local visual=model.VisualRoot
 for _,f in fixtures do
  local b=assert(model:FindFirstChild(f.name,true))
  local rest=visual.CFrame:ToObjectSpace(b.WorldCFrame);local expected=CFrame.new(unpack(f.cf))
  check((rest.Position-expected.Position*model:GetScale()).Magnitude<.001,'glTF Bone position '..f.name)
  local _,angle=(rest.Rotation:Inverse()*expected.Rotation):ToAxisAngle()
  check(math.abs(angle)<.001,'glTF Bone basis '..f.name)
 end
 for _,part in model:GetDescendants()do if part:IsA('MeshPart')then
  local mesh=game.AssetService:CreateEditableMeshAsync(Content.fromUri(part.MeshId))
  report.faces+=#mesh:GetFaces()
  for i,vertex in mesh:GetVertices()do
   local bones=mesh:GetVertexBones(vertex);local weights=mesh:GetVertexBoneWeights(vertex)
   local sum=0;for _,w in weights do sum+=w end
   check(#bones>0 and #bones<=4 and #weights==#bones,'weighted imported vertex')
   check(math.abs(sum-1)<.001,'normalized native weights')
   report.vertices+=1
   if i%500==0 then task.wait()end
  end
  mesh:Destroy()
 end end
 check(report.faces==2989,'all TD surface triangles preserved after import')
 check(report.vertices==3917,'pinned imported vertex count')
end,debug.traceback)
model:Destroy();report.pass=ok;report.error=not ok and err or nil
workspace:SetAttribute('SeleneBonesQAReport',game.HttpService:JSONEncode(report))
print('SELENE_BONES_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,err)
