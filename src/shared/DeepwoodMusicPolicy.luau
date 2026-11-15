-- Verified TD originals; RPG playback permissions are checked separately.
local Policy={normalId=73105938035554,bossId=120016858360297,volume=.20,fade=1.5}
-- TD map-themes-v2 originals. Zero means upload/Experience permission is pending.
Policy.epicIds={Deepwood=0,FrozenVale=0,EmberCaldera=0,HauntedGraveyard=0,Gloamwood=0}
function Policy.normalFor(session)
 if session.loading or session.mode~='Tutorial' or session.route=='Training' or not session.alive then return Policy.normalId end
 local id=Policy.epicIds[session.region]
 return type(id)=='number' and id>0 and id or Policy.normalId
end
function Policy.bossKey(snapshot,session)
 if not snapshot or snapshot.training or session.loading or not session.alive or session.mode~='Tutorial' or session.route=='Training'
  or not session.heroId or snapshot.heroId~=session.heroId then return nil end
 local selected
 for key,e in pairs(snapshot.encounters or {}) do
  local p=e.position;local here=session.position
  if e.boss==true and e.active==true and (e.remaining or 0)>0 and p and here then
   local dx,dy,dz=here[1]-p[1],here[2]-p[2],here[3]-p[3]
   if dx*dx+dy*dy+dz*dz<=110*110 and (not selected or key<selected) then selected=key end
  end
 end
 return selected
end
return Policy
