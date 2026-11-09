-- Cosmetic scene stages are derived only from confirmed journals.
local M={}
function M.count(s,key,chapter)
 if not s then return 0 end
 if (s.clears or {})[chapter]or (s.flags or {})[key]then return 3 end
 return math.min(3,(s.activities or {})[key]or 0)
end
function M.visible(s,key,chapter,first,last)
 local n=M.count(s,key,chapter)
 return n>=first and n<=last
end
function M.requires(s,keys)
 if not keys or keys==''then return true end
 if not s then return false end
 for key in keys:gmatch('[^|]+')do
  local chapter=key:match('^([^:]+):')
  if not ((s.flags or {})[key]or chapter and (s.clears or {})[chapter])then return false end
 end
 return true
end
return M
