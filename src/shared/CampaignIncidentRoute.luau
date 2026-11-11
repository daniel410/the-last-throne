-- Connector-aware walking guidance, shared by escort motion and client arrows.
local C=game and require(script.Parent.CampaignContent)or dofile('src/shared/CampaignContent.luau')
local A=game and require(script.Parent.CampaignAreas)or dofile('src/shared/CampaignAreas.luau')
local M={}
local function progress(a,p)
 local f,t=a.connector.rampStart,a.connector.rampEnd
 local dx,dz=t[1]-f[1],t[3]-f[3]
 return ((p[1]-f[1])*dx+(p[3]-f[3])*dz)/math.max(.001,dx*dx+dz*dz)
end
local function route(origin,target)
 -- The mouth overlaps the main rectangle. Once both points are on that
 -- rectangle, do not pull the hero back into an incident connector.
 for _,z in pairs(C.zones)do if A.contains(z,origin[1],origin[3],.05)and A.contains(z,target[1],target[3],.05)then return {origin,target}end end
 local from,to
 for _,z in pairs(C.zones)do for _,a in ipairs(z.expansionAreas or {})do
  if A.contains(a,target[1],target[3])then to=a end
  if A.contains(a,origin[1],origin[3])then from=a end
 end end
 if from and from==to then return {origin,target}end
 local result={origin}
 local function add(p)result[#result+1]=p end
 if from then add(from.connector.rampEnd);add(from.connector.rampStart);add(from.entry)
 elseif not to then
  for _,z in pairs(C.zones)do for _,a in ipairs(z.expansionAreas or {})do
   if A.contains(a.connector,origin[1],origin[3])then
    if progress(a,origin)>0 then add(a.connector.rampStart)end
    if progress(a,origin)>progress(a,a.entry)+.001 then add(a.entry)end
    from=a;break
   end
  end;if from then break end end
 end
 if to then
  if not A.contains(to.connector,origin[1],origin[3])then add(to.entry);add(to.connector.rampStart)
  elseif progress(to,origin)<0 then add(to.connector.rampStart)end
  add(to.connector.rampEnd)
 end
 add(target);return result
end
function M.route(origin,target)
 local points=route(origin,target);local result={origin}
 for i=2,#points do local a,b=result[#result],points[i]
  if (a[1]-b[1])^2+(a[3]-b[3])^2>.0001 then result[#result+1]=b end
 end
 -- Keep the existing arrival chevron when the target is directly underfoot.
 if #result==1 then result[2]=target end
 return result
end
return M
