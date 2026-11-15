local R=dofile('src/shared/EnemyAfflictionRules.luau')
local checks=0
local function check(value,message)checks=checks+1;assert(value,message)end
for _,element in ipairs({'fire','venom'})do
 for amount=0,1000 do
  local direct,plan=R.split(element,amount)
  local total=direct
  if plan then
   check(#plan.amounts==2,'two finite deferred ticks')
   for _,tick in ipairs(plan.amounts)do check(tick>=0 and tick==math.floor(tick),'integer tick budget');total=total+tick end
  end
  check(total==amount,'direct and deferred raw budget is conserved')
  check(direct>=0 and direct<=amount,'no additional direct damage')
 end
end
for _,element in ipairs({'frost','web','shadow','soul'})do
 local amount,plan=R.split(element,101)
 check(amount==101 and #plan.amounts==0,'control does not create extra damage')
 check(plan.rule.duration<=1.5,'short finite control window')
 check(not plan.rule.stun and not plan.rule.root,'control never prevents all actions')
end
for _,element in ipairs({'physical','arcane','unknown'})do
 local amount,plan=R.split(element,101)
 check(amount==101 and plan==nil,'unsupported element has no hidden effects')
end
for _,receipt in ipairs({{applied=0,result='Hit'}, {applied=10,result='Blocked'},
 {applied=10,result='Dodged'}, {applied=10,result='PerfectBlock'}, {applied=10,result='Hit',absorbed=2},
 {applied=0,result='Absorbed'}, {applied=0,result='Prevented'}})do
 check(not R.canApply(receipt),'defense/no health loss never applies a status')
end
check(R.canApply({applied=1,result='Hit',absorbed=0}),'confirmed health loss allows status')
check(R.movement(0)==.7 and R.movement(.1)==.7 and R.movement(2)==1,'movement floor is 70 percent')
check(R.outgoing(0)==.8 and R.outgoing(.1)==.8 and R.outgoing(2)==1,'weakness cap is 20 percent')
local original=R.get('fire');original.duration=100
check(R.get('fire').duration==1.35,'rule consumers cannot mutate the catalog')
check(select(1,R.split('fire',0/0))==0 and select(2,R.split('fire',math.huge))==nil,'nonfinite budget is rejected')
print('enemy-affliction-rules: '..checks..' checks PASS')
