-- TSV bridge for the JSON report; no game state or canonical asset writes.
local nativeDofile=dofile
local baseline=os.getenv('TLT_BALANCE_BASELINE')
if baseline then
 dofile=function(path)
  local name=path:match('([^/]+)$');local f=io.open(baseline..'/'..name,'r')
  if f then f:close();return nativeDofile(baseline..'/'..name)end
  return nativeDofile(path)
 end
end
local D=dofile('src/shared/Difficulty.luau');local B=dofile('src/shared/DeepwoodEncounterBalance.luau')
local C=dofile('src/shared/CampaignContent.luau');local Repeat=dofile('src/shared/AdventureRepeatRewards.luau')
-- Before-state adapter is identical to the old runtime's inline elite adjustment.
if not B.unitStats then function B.unitStats(spec,players,mode,version,index)
 local hp,damage,level=B.stats(spec.kind,spec.level,players,mode)
 if not B.isBoss(spec.kind)then
  if(mode=='Insane'or mode=='Hell')and index==1 then hp=math.floor(hp*1.15+.5)end
  if mode=='Hell'and index==2 then damage=math.floor(damage*1.1+.5)end
 end
 return hp,damage,level
end end
local S=nativeDofile('src/shared/EncounterSummary.luau')
-- Summary owns its loader, so route it to the adapted legacy Balance instance.
if baseline then
 local old=dofile;dofile=function(path)if path=='src/shared/DeepwoodEncounterBalance.luau'then return B end;return old(path)end
 S=nativeDofile('src/shared/EncounterSummary.luau')
end
local function completion(c,mode)
 if D.completion then return D.completion(c,mode)end
 local m=D.modes[mode];local base=Repeat[c.id]or {xp=math.floor(c.reward.xp*.25),gold=math.floor(c.reward.coins*.30)}
 return {xp=math.floor(base.xp*m.xp),gold=math.floor(base.gold*m.gold),ore=D.combat(c)and m.ore or 0,cores=D.combat(c)and m.cores or 0,cache=D.combat(c)and m.cache or 0}
end
print('mission\tmode\tplayers\tcount\tnormalLevelMin\tnormalLevelMax\tnormalHPMin\tnormalHPMax\tbossLevelMin\tbossLevelMax\tbossHPMin\tbossHPMax\thealthBudget\tkillXP\tkillGold\tcompletionXP\tcompletionGold\tore\tcores\tcache\ttotalRepeatXP\ttotalRepeatGold\trewardLevel\trewardBand\tgems\tstones')
for _,c in ipairs(C.chapters)do for _,mode in ipairs(D.order)do for _,players in ipairs({1,4})do
 local s=S.mission(c,mode,players);local r=completion(c,mode);local normal,boss=s.normal or {},s.boss or {}
 local row={c.id,mode,players,s.count,normal.levelMin or 0,normal.levelMax or 0,normal.hpMin or 0,normal.hpMax or 0,boss.levelMin or 0,boss.levelMax or 0,boss.hpMin or 0,boss.hpMax or 0,s.health,s.xp,s.gold,r.xp,r.gold,r.ore,r.cores,r.cache,s.xp+r.xp,s.gold+r.gold,r.rewardLevel or 0,r.rewardBand or 0,r.gems or 0,r.stones or 0}
 for i,v in ipairs(row)do row[i]=tostring(v)end;print(table.concat(row,'\t'))
end end end
