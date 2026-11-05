-- Pure account transactions. Credits are story entitlements, never heal charges.
local M={offers={{id='selene_story_1',stories=1,price=200},{id='selene_story_5',stories=5,price=1000},{id='selene_story_10',stories=10,price=2000}}}
local Content=game and require(game:GetService('ReplicatedStorage').Shared.CampaignContent) or dofile('src/shared/CampaignContent.luau')
local Adventure=game and require(game:GetService('ReplicatedStorage').Shared.AdventureRules)or dofile('src/shared/AdventureRules.luau')
local function target(h)
 local a=h.expeditions and h.expeditions.active
 local nextChapter=Adventure.continuation(a)
 if nextChapter then return nextChapter.number,'run:'..a.runId..':'..nextChapter.id,false end
 local c=a and Content.byId[a.missionId]
 if c and not c.side and type(a.runId)=='string' then return c.number,'run:'..a.runId..':'..a.missionId,a.completed==true end
 local n=((h.deepwood and h.deepwood.main) or 0)+1;return n,'main:'..n,false
end
local function int(v,max)return type(v)=='number' and v==v and v%1==0 and v>=0 and v<=max end
local function trialAvailable(p,heroId,story,completed)
 local h=p.heroes[heroId];local s=p.supportPasses
 return h and h.deepwood and h.deepwood.clears['DW-03']==true and story>=4 and story<=Content.mainCount
  and not completed and not (s and s.trials and s.trials[heroId]) or false
end
function M.valid(p)
 if type(p)~='table' then return false end
 local s=p.supportPasses;if s==nil then return true end
 if type(p.heroes)~='table' or type(s)~='table' or s.version~=1 or not int(s.credits,9999) or type(s.active)~='table' then return false end
 if s.trials~=nil then
  if type(s.trials)~='table' then return false end
  for id,used in pairs(s.trials)do if not p.heroes[id] or used~=true then return false end end
 end
 local n=0
 for heroId,c in pairs(s.active)do
  n=n+1
  if not p.heroes[heroId] or type(c)~='table' or not int(c.story,35) or c.story<1 or type(c.id)~='string' or #c.id>64 or type(c.ended)~='boolean' or type(c.scope)~='string' or #c.scope>100 or c.trial~=nil and type(c.trial)~='boolean' then return false end
  if c.trial and not (s.trials and s.trials[heroId]) then return false end
 end
 return n<=4
end
function M.offer(id)for _,o in ipairs(M.offers)do if o.id==id then return o end end end
function M.view(p,heroId)
 local h=p and p.heroes and p.heroes[heroId];if not h then return nil end
 local story,scope,completed=target(h)
 local s=p.supportPasses;local c=s and s.active[heroId]
 return {credits=s and s.credits or 0,story=story,active=c~=nil and not c.ended and not completed and c.story==story and c.scope==scope,scope=scope,completed=completed,contractId=c and c.id or nil,price=200,offers=M.offers,
  trialAvailable=trialAvailable(p,heroId,story,completed),trial=c and c.trial==true or false}
end
function M.apply(p,cmd,ctx,R,catalog)
 if not M.valid(p) or type(cmd)~='table' or type(cmd.requestId)~='string' or #cmd.requestId<1 or #cmd.requestId>64 or not cmd.requestId:match('^[%w_-]+$') then return nil,'InvalidRequest' end
 local fingerprint=table.concat({'support',cmd.action or '',cmd.heroId or '',cmd.offerId or '',tostring(cmd.revision),tostring(cmd.story),tostring(cmd.scope)},'|')
 local old=p.operations[cmd.requestId]
 if old then if old.fingerprint~=fingerprint then return nil,'RequestConflict' end;return R.copy(p),nil,true end
 local h=p.heroes[cmd.heroId];if not h then return nil,'HeroNotOwned' end
 local n=R.copy(p);n.supportPasses=n.supportPasses or {version=1,credits=0,active={}}
 local s=n.supportPasses;local story,scope,completed=target(h)
 if cmd.action=='Buy' then
  if not ctx.atLobby then return nil,'ShopLobbyOnly' end
  if cmd.revision~=p.revision then return nil,'Changed' end
  local offer=M.offer(cmd.offerId);if not offer then return nil,'InvalidRequest' end
  if s.credits+offer.stories>9999 then return nil,'SupportLimit' end
  -- Old accounts migrate via the existing server-owned economy adapter first.
  if not n.wallet or n.wallet.gold<offer.price then return nil,'NotEnoughGold' end
  n.wallet.gold=n.wallet.gold-offer.price;s.credits=s.credits+offer.stories
 elseif cmd.action=='Activate' then
  if not ctx.inAdventure or cmd.story~=story or cmd.scope and cmd.scope~=scope or not ctx.hasCampAccess then return nil,'Unavailable' end
  if not h.deepwood or not h.deepwood.flags['DW-03:report'] then return nil,'StoryLocked' end
  if completed or ctx.maxStories and story>ctx.maxStories then return nil,'SupportStoryComplete' end
  local c=s.active[cmd.heroId]
  if c and not c.ended and c.story==story and c.scope==scope then return R.copy(p),nil,true end
  local trial=trialAvailable(p,cmd.heroId,story,completed)
  if not trial and s.credits<1 then return nil,'SupportPassRequired' end
  n.heroes[cmd.heroId].deepwood.seleneFollowing=true
  if trial then s.trials=s.trials or {};s.trials[cmd.heroId]=true else s.credits=s.credits-1 end
  s.active[cmd.heroId]={id=cmd.requestId,story=story,scope=scope,ended=false,trial=trial}
 elseif cmd.action=='End' then
  if not ctx.serverEnd then return nil,'InvalidRequest' end
  local c=s.active[cmd.heroId]
  if not c or c.ended then return R.copy(p),nil,true end
  c.ended=true
 else return nil,'InvalidRequest' end
 n.revision=n.revision+1;n.operations[cmd.requestId]={fingerprint=fingerprint,revision=n.revision}
 table.insert(n.operationOrder,cmd.requestId);if #n.operationOrder>96 then n.operations[table.remove(n.operationOrder,1)]=nil end
 if not R.validate(n,catalog) then return nil,'Incompatible' end
 return n
end
return M
