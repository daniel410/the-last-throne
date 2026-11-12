-- Presentation failures must not disable combat controls or hold client readiness.
local P={}
local effects={
 'K0BackgroundMusic','K0Telegraphs','K0SwordVisual','K0EnemyVisual',
 'K0HitEffects','K0PlayerHitFeedback','AdvancedSkillVisual','PixelFXController',
 'K0CombatAudio','DeepwoodAtmosphere',
}
function P.launch(name,callback,dependencies)
 local d=dependencies or {spawn=task.spawn,warn=warn}
 d.spawn(function()
  local ok,err=xpcall(callback,debug.traceback)
  if not ok then d.warn('Battle presentation failed: '..name..'\n'..tostring(err))end
 end)
end
function P.start(modules,dependencies)
 local d=dependencies or {spawn=task.spawn,warn=warn,load=require}
 for _,name in ipairs(effects)do
  P.launch(name,function()d.load(modules[name]).start()end,d)
 end
end
return P
