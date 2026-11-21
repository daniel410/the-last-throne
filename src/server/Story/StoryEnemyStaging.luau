-- Prepare the run's upcoming waves without publishing them or starting AI.
local Staging={}
local retention=8

function Staging.destroy(models)
 for _,bucket in pairs(models) do
  for _,model in ipairs(bucket) do model:Destroy() end
 end
end

function Staging.create(template)
 local packs={}
 local queue={}
 local working=false
 local cache={}

 local function drain()
  while #queue>0 do
   local pack=table.remove(queue,1)
   local ok,reason=pcall(function()
    for _,spec in ipairs(pack.batch) do
     if packs[pack.key]~=pack or not pack.models then break end
     local kind=spec.kind
     local bucket=pack.models[kind]
     if not bucket then bucket={};pack.models[kind]=bucket end
     table.insert(bucket,template(kind):Clone())
     task.wait()
    end
   end)
   if not ok then warn('[Story] Could not stage enemy wave: '..tostring(reason)) end
  end
  working=false
 end

 function cache.keep(key)
  local pack=packs[key]
  if pack then pack.touched=os.clock() end
  return pack
 end

 function cache.request(key,firstWave)
  local old=cache.keep(key)
  if old then return old.batch end
  local batch=firstWave()
  if not batch then return nil end
  local pack={key=key,batch=batch,touched=os.clock(),models={}}
  packs[key]=pack
  table.insert(queue,pack)
  if not working then working=true;task.defer(drain) end
  return batch
 end

 function cache.claim(key)
  local pack=cache.keep(key)
  if not pack then return nil end
  local models=pack.models
  pack.models=nil
  return models
 end

 function cache.sweep()
  local cutoff=os.clock()-retention
  for key,pack in pairs(packs) do
   if pack.touched<cutoff then
    packs[key]=nil
    if pack.models then Staging.destroy(pack.models);pack.models=nil end
   end
  end
 end

 return cache
end

return Staging
