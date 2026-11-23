 if sessionOnly and game.PlaceId == 0 and profile and not profile.heroes['qa-gw-knight'] then
  profile, errorCode = state.store:transact(player.UserId, function(current)
   local seeded = assert(Rules.addHero(current, 'qa-gw-knight', 'knight', Catalog))
   local hero = seeded.heroes['qa-gw-knight']
   hero.level = 80
   hero.progression = Growth.new(80)
   local C = require(ReplicatedStorage.Shared.CampaignContent)
   local P = require(ReplicatedStorage.Shared.DeepwoodProgress)
   local target = C.byId['GW-07']
   local progress = P.new()
   for _, chapter in ipairs(C.mainChapters) do
    if chapter.number >= target.number then break end
    progress.main = chapter.number
    progress.clears[chapter.id] = true
    progress.coins += chapter.journalCoins or chapter.reward.coins
    for _, goal in ipairs(chapter.goals) do
     if not goal.expansion and not goal.pacing and not goal.optional then
      progress.flags[chapter.id .. ':' .. goal.id] = true
     end
    end
   end
   progress.choice = 'shared'
   progress.flags['GW-07:nest'] = true
   progress.flags['GW-07:queen'] = true
   progress = assert(P.enableExpansion(progress))
   progress = assert(P.apply(progress, 'GW-07', 'ridge_patrol'))
   assert(P.validate(progress) and P.available(progress, target, P.goal(target, 'exit')))
   hero.deepwood = progress
   hero.expeditions = {version = 1, clears = {}, cacheProgress = {}}
   require(ReplicatedStorage.Shared.AdventureRules).upgradeHero(hero)
   assert(Rules.validate(seeded, Catalog))
   return seeded
  end)
 end
