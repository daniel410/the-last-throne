-- Widen real regional ground before allocating incident wings. Centers and stable
-- story anchors stay fixed; neighboring story gates always retain a clear gap.
local F={version=1}
local profiles={DW={1.55,1.55},GW={1.7,1.45},FV={1.6,1.55},EC={1.65,1.5},HG={1.6,1.5}}
function F.install(C)
 local ids={};for id in pairs(C.zones)do ids[#ids+1]=id end;table.sort(ids)
 for _,id in ipairs(ids)do local z=C.zones[id];z.originalSize={z.size[1],z.size[2]};z.originalCenter={table.unpack(z.center)}end
 for _,id in ipairs(ids)do
  local z=C.zones[id];local scale=profiles[id:sub(1,2)]
  for axis=1,2 do
   local coordinate=axis==1 and 1 or 3;local other=axis==1 and 2 or 1;local cross=axis==1 and 3 or 1
   for _,side in ipairs({-1,1})do
    local extra=z.originalSize[axis]*(scale[axis]-1)/2
    local edge=z.center[coordinate]+side*z.size[axis]/2
    for _,key in ipairs(ids)do if key~=id then local neighbor=C.zones[key]
     if side*(neighbor.center[coordinate]-z.center[coordinate])>0 and math.abs(z.center[cross]-neighbor.center[cross])<(z.size[other]+neighbor.size[other])/2+28 then
      extra=math.min(extra,side*(neighbor.center[coordinate]-side*neighbor.size[axis]/2-edge)-28)
     end
    end end
    extra=math.max(0,extra);z.center[coordinate]=z.center[coordinate]+side*extra/2;z.size[axis]=z.size[axis]+extra
   end
  end
  z.routeFootprintVersion=F.version
 end
end
return F
