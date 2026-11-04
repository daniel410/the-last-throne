local M={}
function M.new(load)
 local implementation
 local api={}
 function api.start(...)
  if implementation then return end
  implementation=load();implementation.start(...)
 end
 setmetatable(api,{__index=function(_,name)
  return function(...)
   if implementation then return implementation[name](...)end
   if name=='canUseInventoryItem'then return false,'WaitForLobby'end
   return false
  end
 end})
 return api
end
return M
