-- TD LobbyHomeUI.navigationMetrics size rules, rechecked 2026-11-05.
-- Only dimensions are shared: RPG artwork, order and destinations stay local.
local S={}
function S.measure(w,h)
 local short,large=h<500,w>=1500 and h>=700
 local landscape=w>=548 and h<400
 local tile=math.clamp(math.floor(math.min(w*.112,h*.2)),92,190)
 if short then tile=math.clamp(math.floor((h-148)/2)-12,64,84) end
 if w<600 then tile=math.min(110,math.floor((w-48)/3));if short then tile=64 end end
 local width,height=tile,tile
 if large then width=math.floor(math.min(w*.115,228));height=math.floor(width*1.19) end
 width,height=math.max(64,math.floor(width*.78)),math.max(44,math.floor(height*.78))
 local gap,rowGap=large and 16 or 10,16
 if short and w<600 then rowGap=10 end
 if landscape then width,height,gap,rowGap=64,48,8,4 end
 return {width=width,height=height,gap=gap,rowGap=rowGap,large=large}
end
return S
