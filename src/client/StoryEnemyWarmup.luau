local ContentProvider=game:GetService('ContentProvider')
local HttpService=game:GetService('HttpService')
local Warmup={}
local attribute='TLTStoryEnemyWarmup'
local batchSize=12

function Warmup.start(player)
 local latest,running
 local meshes,textures={},{}
 local function update()
  latest=player:GetAttribute(attribute)
  if running or not latest then return end
  running=true
  task.defer(function()
   while latest do
    local request=latest
    latest=nil
    local ok,assets=pcall(HttpService.JSONDecode,HttpService,request)
    if ok then
     local batch={}
     local function flush()
      pcall(function()ContentProvider:PreloadAsync(batch)end)
      for _,reference in ipairs(batch)do reference:Destroy()end
      table.clear(batch)
     end
     for _,uri in ipairs(assets.meshes)do
      if player:GetAttribute(attribute)~=request then break end
      if not meshes[uri]then
       -- A raw ID is fetched as the wrong asset type. Use a typed mesh reference.
       meshes[uri]=true
       local mesh=Instance.new('SpecialMesh');mesh.MeshType=Enum.MeshType.FileMesh;mesh.MeshId=uri
       table.insert(batch,mesh)
       if #batch==batchSize then flush()end
      end
     end
     for _,uri in ipairs(assets.textures)do
      if player:GetAttribute(attribute)~=request then break end
      if not textures[uri]then
       textures[uri]=true
       local decal=Instance.new('Decal');decal.Texture=uri
       table.insert(batch,decal)
       if #batch==batchSize then flush()end
      end
     end
     if #batch>0 then flush()end
    end
   end
   running=false
  end)
 end
 player:GetAttributeChangedSignal(attribute):Connect(update)
 update()
end

return Warmup
