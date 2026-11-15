local T=dofile('src/shared/EnemyCombatTactics.luau')
local P=dofile('src/shared/EnemyPatterns.luau')
local n=0
local function check(v,m)n=n+1;assert(v,m)end
local radial,tangent,intent=T.movement('Shaman',4,'Easy',.2,0)
check(radial<0 and intent=='Retreat','pressed caster withdraws')
radial,tangent,intent=T.movement('IceElf',21,'Hard',.2,0)
check(radial==0 and tangent~=0 and intent=='Flank','artillery maintains firing band')
radial,tangent=T.movement('Goblin',12,'Hard',.2,0)
check(radial>0 and tangent~=0,'dagger approaches on a flank')
radial,tangent=T.movement('Ogre',12,'Hard',.2,0)
check(radial>0 and math.abs(tangent)<.2,'heavy club commits directly')
check(T.movement('Ogre',6,'Easy',0,0)>0,'no dead zone beyond melee reach')
local _,easy=T.movement('Goblin',4,'Easy',.2,0)
local _,hell=T.movement('Goblin',4,'Hell',.2,0)
check(math.abs(hell)>math.abs(easy),'higher mode uses stronger flanking')
for kind,profile in pairs(P.profiles)do
 for _,mode in ipairs({'Easy','Hard','Insane','Hell'})do
  local history={}
  for turn=1,12 do
   local a=T.choose(profile,kind,4,history,turn*20,mode,.4)
   check(a~=nil,'close action '..kind)
   check(a.windup>=1 and a.recovery>=.8,'readable action '..kind)
   local old=a.id
   P.commit(history,a,turn*20)
   local nextAttack=T.choose(profile,kind,4,history,turn*20,mode,.4)
   check(not nextAttack or nextAttack.id~=old,'cooldown prevents same action spam')
  end
 end
end
for _,kind in ipairs({'Goblin','Orc','Ogre','IceWolf','IceBear'})do
 check(T.choose(P.get(kind),kind,12,{},0,'Hell',1)==nil,'melee cannot select distant hit')
end
local a=T.choose(P.get('Goblin'),'Goblin',4,{last='Goblin.1',ready={['Goblin.2']=100}},50,'Easy',1)
check(a and a.id=='Goblin.1','available basic remains usable while follow-up cools down')
print('enemy-combat-tactics: '..n..' checks PASS')
