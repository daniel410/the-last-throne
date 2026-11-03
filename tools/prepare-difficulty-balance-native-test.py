from pathlib import Path
import runpy
ns=runpy.run_path('tools/review-expedition-ui.py')
code=ns['code'].split('local existing=')[0]
code+='''
local B=req(tree.src.shared.DeepwoodEncounterBalance);local D=req(tree.src.shared.Difficulty)
local source=sources['src/server/Story/DeepwoodService.luau']
local body=assert(source:match('(local function applyBalance.-)\\nlocal spawnWave'),'runtime balance bridge missing')
local factory=assert(loadstring('return function(Balance)\\n'..body..'\\nreturn applyBalance end'))()
local apply=factory(B)
local model=Instance.new('Model');local checks,units=0,0
local ok,result=xpcall(function()
 for kind in pairs(D.families)do for _,level in ipairs({5,12,30})do for _,players in ipairs({1,4})do
  for _,mode in ipairs(D.order)do for _,version in ipairs({1,2})do for index=1,2 do
   local spec={kind=kind,level=level,rewardCopies=B.isBoss(kind)and 1 or 6,rewardIndex=index}
   apply(model,spec,players,mode,version,index)
   local hp,damage,actualLevel,elite=B.unitStats(spec,players,mode,version,index)
   local xp,gold=B.rewards(spec,mode,version)
   for key,value in pairs({StoryHealth=hp,StoryDamage=damage,StoryLevel=actualLevel,StoryRewardXP=xp,StoryRewardGold=gold})do
    checks+=1;assert(model:GetAttribute(key)==value,key..' not wired from authoritative rules')
   end
   checks+=1;assert(model:GetAttribute('StoryElite')==elite,'elite adjustment not reflected')
   units+=1;if units%100==0 then task.wait()end
  end end end
 end end end
 return {checks=checks,units=units,versions={1,2},bridge='actual DeepwoodService applyBalance',scope='native model attributes; no live game, user account or Teleport'}
end,debug.traceback)
model:Destroy();signal:Destroy();assert(ok,result);return result
'''
Path('builds/difficulty-balance-native.luau').write_text(code)
print('Prepared builds/difficulty-balance-native.luau')
