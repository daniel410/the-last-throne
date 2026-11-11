-- Native engine fetch/masking fixture. Separate from published-client/cold-cache QA.
local source=game.StarterPlayer.StarterPlayerScripts.Client.EquipmentAssetLoading.Source
source=source:gsub('local RunService = game:GetService%("RunService"%)', [[
local qaBefore,qaRender
local RunService={PreSimulation={Connect=function(_,fn)qaBefore=fn end},BindToRenderStep=function(_,_,_,fn)qaRender=fn end}
local realProvider=ContentProvider
local qaFetches,qaFailures=0,0
ContentProvider={PreloadAsync=function(_,inputs,callback)
 task.wait(.2)
 realProvider:PreloadAsync(inputs,function(id,status)
  qaFetches+=1
  if status~=Enum.AssetFetchStatus.Success then qaFailures+=1 end
  callback(id,status)
 end)
end}
]])
source=source:gsub('\nreturn Assets%s*$', [[
function Assets.qaStep()qaBefore();qaRender()end
function Assets.qaPending()local n=0;for _,s in pairs(pending)do if not s.ready then n+=1 end end;return n,qaFetches,qaFailures end
return Assets]])
local module=Instance.new('ModuleScript');module.Name='EquipmentAssetLoadingQA';module.Source=source;module.Parent=game.StarterPlayer.StarterPlayerScripts.Client
local folder=Instance.new('Folder');folder.Name='EquipmentLoadingQA'
local parts,models={},0
for _,name in ipairs({'FourFamilyWeaponModels','FourFamilyShieldModels','FourFamilyArmorModels'})do
 for _,template in ipairs(game.ServerStorage[name]:GetChildren())do
  local model=template:Clone();models+=1
  model:SetAttribute('TLTArmorAppearance',name=='FourFamilyArmorModels')
  for _,part in ipairs(model:GetDescendants())do
   if part:IsA('MeshPart')then
    part.Anchored=true
    part:SetAttribute('TLTPlayerWeaponPart',name~='FourFamilyArmorModels')
    part.LocalTransparencyModifier=.35
    table.insert(parts,part)
   end
  end
  model.Parent=folder
 end
end
folder.Parent=workspace
local checks=0
local function check(value,message)checks+=1;assert(value,message)end
local ok,result=xpcall(function()
 local assets=require(module);assets.start();assets.start();assets.qaStep()
 for _,part in ipairs(parts)do check(part.LocalTransparencyModifier==1,'Pending mesh exposed: '..part:GetFullName())end
 local deadline=os.clock()+55
 local pending,fetches,failures=assets.qaPending()
 while pending>0 and os.clock()<deadline do
  task.wait(.1);assets.qaStep();pending,fetches,failures=assets.qaPending()
 end
 check(pending==0,'Native asset fetch timed out')
 check(failures==0,'Native asset fetch failed')
 check(fetches>=#parts*2,'Expected mesh and explicit texture callbacks')
 for _,part in ipairs(parts)do check(math.abs(part.LocalTransparencyModifier-.35)<.0001,'Existing visibility not restored')end
 return {models=models,meshParts=#parts,fetchCallbacks=fetches,fetchFailures=failures}
end,debug.traceback)
folder:Destroy();module:Destroy()
print('EQUIPMENT_ASSET_LOADING_NATIVE '..game.HttpService:JSONEncode({pass=ok,checks=checks,result=result}))
assert(ok,result)
