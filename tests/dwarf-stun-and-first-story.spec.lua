local C=dofile('src/shared/K0Config.luau')
local A=dofile('src/shared/AdvancedSkills.luau')
local B=dofile('src/shared/DeepwoodEncounterBalance.luau')
local Story=dofile('src/shared/DeepwoodContent.luau')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
check(C.Skills.dwarf[3].stunDuration==5,'Ground Slam base stun is five seconds')
local related=0
for _,d in ipairs(A.skills.dwarf)do if d.root==3 then related=related+1;check(d.stunDuration==5,'Ground Slam path retains five second stun')else check(d.stunDuration==nil,'other attack families are unchanged')end end
for _,d in ipairs(A.common.dwarf)do if d.root==3 then related=related+1;check(d.stunDuration==5,'pre-advancement ground path stuns')else check(d.stunDuration==nil,'other common skills do not gain unrelated stun')end end
check(related==9,'nine descendants plus Ground Slam receive stun')
for _,g in ipairs(Story.byId['DW-01'].goals)do if #g.enemies>0 then
 local waves=B.encounterWaves(Story.byId['DW-01'],g);local total,xp,gold=0,0,0
 for i,batch in ipairs(waves)do
  local seen={};for _,unit in ipairs(batch)do seen[unit.kind]=true;total=total+1;local x,y=B.rewards(unit);xp=xp+x;gold=gold+y end
  if i%4==1 or i%4==3 then check(seen.Goblin and not seen.Slime,'first and third group are Goblins')
  elseif i%4==2 then check(seen.Slime and not seen.Goblin,'second group is Slimes')
  else check(seen.Goblin and seen.Slime,'fourth group mixes Goblins and Slimes')end
  check(#batch<=B.packSize(Story.byId['DW-01'],g),'variety never increases the live cap')
 end
 local base=B.expand(g.enemies);local bx,bg=0,0;for _,u in ipairs(base)do local x,y=B.rewards(u);bx=bx+x;bg=bg+y end
 check(total==#base and xp==bx and gold==bg,'first story preserves total population and XP/Gold')
end end
print('Dwarf stun/first story: '..n..' checks passed')
