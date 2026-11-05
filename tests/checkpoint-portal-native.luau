-- Run in Studio Edit with portal/environment source strings supplied by the driver.
return function(portalSource,environmentSource)
 local checks=0;local function check(v,m)checks+=1;assert(v,m)end
 local folder=Instance.new('Folder');folder.Name='CheckpointPortalQA';folder.Parent=game:GetService('ServerStorage')
 local ok,result=xpcall(function()
  local env=assert(loadstring(environmentSource,'DeepwoodEnvironmentQA'))()
  local rules={text={portal='Return to Eryn',use='Travel to checkpoint'},report=function(s)return s.ready and {id='DW-07:restoration',zone='DW-03'}or nil end}
  local content={byId={['DW-07']={goals={{id='separate',activity={steps={{position={0,0,0}}}}}}}}}
  portalSource=portalSource:gsub('local Rules=require%(Shared.CheckpointTravel%)','local Rules=fixtureRules')
  portalSource=portalSource:gsub('local Content=require%(Shared.CampaignContent%)','local Content=fixtureContent')
  portalSource=portalSource:gsub('local Env=require%(script.Parent.DeepwoodEnvironment%)','local Env=fixtureEnv')
  local fn=assert(loadstring(portalSource,'StoryCheckpointPortalQA'))
  setfenv(fn,setmetatable({fixtureRules=rules,fixtureContent=content,fixtureEnv=env},{__index=getfenv()}))
  local portal=fn();local world={folder=folder,spawns={['DW-03']=true}}
  portal.ensure(world,{},function()end);check(#folder:GetChildren()==0,'no return portal before saved completion')
  portal.ensure(world,{ready=true},function()end)
  local group=assert(folder:FindFirstChild('StoryCheckpointPortals'));local model=assert(group:FindFirstChild('ErynReturnPortal'))
  check(model:GetAttribute('TDEnvironmentSource')=='TDArrivalPortal','portal uses the pinned TD original')
  local mesh=0
  for _,item in ipairs(model:GetDescendants())do
   if item:IsA('MeshPart')then mesh+=1;check(item.MeshId~=''and not item.CanCollide and item.Anchored,'original portal meshes retain IDs and cannot block players')end
  end
  check(mesh>0,'real TD portal has rendered mesh geometry')
  local prompt=assert(model.TravelAnchor:FindFirstChildOfClass('ProximityPrompt'))
  check(prompt:GetAttribute('CheckpointTarget')=='DW-07:restoration'and prompt.Style==Enum.ProximityPromptStyle.Custom,'existing custom prompt receives the server route')
  check(prompt.ObjectText=='Return to Eryn'and prompt.MaxActivationDistance==14,'English destination and interaction distance')
  portal.ensure(world,{ready=true},function()end);check(#group:GetChildren()==1,'party updates do not duplicate portal models')
  return 'Checkpoint portal native: '..checks..' checks passed; '..mesh..' pinned meshes'
 end,debug.traceback)
 folder:Destroy();assert(ok,result);return result
end
