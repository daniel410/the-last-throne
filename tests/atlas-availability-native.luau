-- Engine instances and pixel buffers, isolated from the user's scene and assets.
-- The runner may provide candidate sources without editing any game modules.
local client=game.StarterPlayer.StarterPlayerScripts.Client
local plateSource=ATLAS_PLATE_SOURCE or client.AtlasPlate.Source
local canvasSource=ATLAS_CANVAS_SOURCE or client.DeepwoodMapCanvas.Source
local assets=game:GetService('AssetService')
local encoding=game:GetService('EncodingService')
local realPlates=client.AtlasPlates
local checks=0
local function check(ok,message)checks+=1;assert(ok,message)end
local function plate(folder,service,content)
 local fn=assert(loadstring(plateSource))
 local owner={FindFirstChild=function(_,name)return name=='AtlasPlates' and folder end,AtlasPlates=folder}
 setfenv(fn,setmetatable({script={Parent=owner},Content=content or Content,game={GetService=function(_,name)
  return name=='AssetService' and (service or assets) or encoding
 end}},{__index=getfenv()}))
 return fn()
end
local function canvas(p)
 local fn=assert(loadstring(canvasSource))
 setfenv(fn,setmetatable({script=client.DeepwoodMapCanvas,require=function(module)
  if module==client.AtlasPlate then return p end
  return require(module)
 end},{__index=getfenv()}))
 return fn()
end
local host=Instance.new('Frame')
local partial=Instance.new('Folder')
local ok,err=xpcall(function()
 -- Menu construction must complete before image siblings have replicated.
 local p=plate(nil)
 local view=canvas(p).create(host,'DW-01',false)
 view.present(500,false);view.update({journal=require(game.ReplicatedStorage.Shared.DeepwoodProgress).new()})
 check(view.rows['DW-01'] and host:FindFirstChild('SurveyGround_DW-01'),'missing folder retains map geography and region')
 host:ClearAllChildren()
 p=plate(partial)
 check(p.draw(host,'DW-01',true)==nil,'missing individual plate is recoverable')
 local entry=Instance.new('StringValue');entry.Name='Relief_DW-01';entry.Parent=partial
 check(p.draw(host,'DW-01',true)==nil,'empty replicated value is recoverable')
 entry.Value='not base64'
 check(p.draw(host,'DW-01',true)==nil,'bad encoded value is recoverable')
 for _,raw in ipairs({buffer.create(4),buffer.create(772)})do
  entry.Value=buffer.tostring(encoding:Base64Encode(encoding:CompressBuffer(raw,Enum.CompressionAlgorithm.Zstd)))
  check(p.draw(host,'DW-01',true)==nil,'truncated or invalid dimensions are recoverable')
 end
 entry.Value=realPlates['Relief_DW-01'].Value
 local recovered=p.draw(host,'DW-01',true)
 check(recovered and recovered.Name=='Relief','late valid data restores the surveyed image on reopening')
 host:ClearAllChildren()
 for _,service in ipairs({
  {CreateEditableImage=function()return nil end},
  {CreateEditableImage=function()error('image API denied')end},
 })do
  local fallback=plate(realPlates,service).draw(host,'EC-03',true)
  check(fallback:IsA('Frame') and #fallback:GetChildren()>0,'creation failure draws the same terrain pixels')
  host:ClearAllChildren()
 end
 local destroyed=0
 local broken={CreateEditableImage=function()return {
  WritePixelsBuffer=function()error('pixel upload failed')end,
  Destroy=function()destroyed+=1 end,
 }end}
 local fallback=plate(realPlates,broken).draw(host,'EC-03',true)
 check(fallback:IsA('Frame') and #fallback:GetChildren()>0 and destroyed==1,'pixel failure cleans image and preserves terrain')
 host:ClearAllChildren()
 local binding={fromObject=function()error('content binding failed')end}
 fallback=plate(realPlates,nil,binding).draw(host,'EC-03',true)
 check(fallback:IsA('Frame') and #fallback:GetChildren()>0,'content binding failure preserves terrain')
 host:ClearAllChildren()
 -- Every stored source still decodes and draws; this is not a visual-quality test.
 p=plate(realPlates)
 local count=0
 for _,entry in ipairs(realPlates:GetChildren())do
  local drawn=p.draw(host,entry.Name:sub(8),true)
  check(drawn and drawn.Name=='Relief',entry.Name..' remains available')
  drawn:Destroy();count+=1;task.wait()
 end
 check(count==44,'all 44 region sources checked')
end,debug.traceback)
host:Destroy();partial:Destroy()
assert(ok,err)
return {checks=checks,pass=true}
