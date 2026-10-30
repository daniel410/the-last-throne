-- Authored episode activities. Stable goal IDs and first-clear rewards stay in Content.
-- Spatial substeps are independently saved; these are trial pacing/English drafts.
local A={}
local function step(id,title,x,z,text,kind,choices)
 return {id=id,title=title,offset={x,z},text=text,kind=kind or 'clue',choices=choices}
end
local function answer(id,title,text) return {id=id,title=title,text=text} end
A.goals={
 ['DW-01:supplies']={mode='investigate',steps={
  step('manifest','Read the torn supply manifest',-45,32,'The manifest lists food and medicine. Every crate is still heavy. This was not a raid for supplies.','ledger'),
  step('bindings','Inspect the cut prisoner bindings',35,-35,'The ropes were cut from outside. Several captives escaped, but others were dragged toward the clearing.','bindings'),
  step('resin','Compare the violet resin on the wheel',60,25,'Violet resin covers the axle. The same stain marks the larger footprints leading east.','resin')}},
 ['DW-01:tracks']={mode='trail',steps={
  step('drag_marks','Follow the broken branches',-50,48,'A person was dragged here. The tracks turn away from the untouched food.','tracks'),
  step('heavy_prints','Find the heavy footprints',-5,-30,'The deep prints belong to something much heavier than a goblin.','tracks'),
  step('scout_sign','Find the scout\'s trail mark',35,20,'A royal scout carved this mark while fleeing. The clearing lies ahead.','tracks')}},
 ['DW-01:trail_exit']={mode='travel',steps={step('approach','Reach the overlook above the clearing',0,0,'Smoke rises from a broken cart. Someone below is calling for help.','arrival')}},
 ['DW-02:survivors']={mode='escort',actor='Wounded Scout',steps={
  step('shelter','Guide the survivors behind the ruined wall',-60,35,'Scout: Stay close. We cannot cross the open road alone.','arrival'),
  step('crossing','Lead them around the fallen cart',10,-45,'Survivor: They took our people, not our food. One of the prisoners was an elven courier.','arrival'),
  step('safety','Bring the survivors to the lantern shelter',60,25,'The survivors are safe. Clear the road before the next evacuation group leaves.','arrival')}},
 ['DW-02:testimony']={mode='investigate',steps={
  step('crest','Match the torn royal crest',-45,25,'The crest belonged to the missing supply captain. His escort was alive when they were taken.','ledger'),
  step('ritual','Examine the ritual stain',30,-35,'The scout describes a shaman ordering the raiders by violet signals.','resin'),
  step('witness','Hear the scout\'s full account',55,20,'Scout: Find Erin at the elder tree. She knows these marks, though she may not trust the crown.','actor')}},
 ['DW-02:clearing_exit']={mode='trail',steps={step('road','Follow the evacuation lanterns',-40,25,'The repaired lanterns mark a safe passage.','arrival'),step('outpost','Reach the outpost road',25,-15,'The elder tree rises beyond the pass. Bring the survivors\' testimony to its wardens.','arrival')}},
 ['DW-03:report']={mode='dialogue',actor='Outpost Warden',steps={
  step('account','Explain what happened on the road',0,0,'Warden: We will send a recovery party. What needs our attention first?','actor',{
   answer('survivors','Care for the wounded','Warden: The healers will prepare beds. Your survivors will have a place here.'),answer('road','Secure the evacuation road','Warden: I will place lantern guards on the road. The next families will have an escort.')}),
  step('missing','Report the missing prisoners',0,0,'The warden records each missing name. A messenger brings your evidence to Erin.','actor')}},
 ['DW-03:erin']={mode='dialogue',actor='Erin',steps={
  step('trust','Hear Erin\'s concern',0,0,'Erin: The crown asks us to surrender another relic, yet our forest is withering. Why should I trust this mission?','actor',{
   answer('truth','We will investigate before taking anything','Erin: Then follow the evidence with me. A promise matters only when it costs something.'),answer('people','The missing people come first','Erin: On that, we agree. Bring them home and we can discuss the crown.')}),
  step('signal','Ask about the violet signal',0,0,'Erin: The watchtower once guarded a spirit spring. Its light is violet now. Someone is drawing power through the old wards.','actor'),
  step('agreement','Agree on the investigation',0,0,'Erin: Free the spirit, examine the links, and return with proof. We act together, but we do not yet know who built the network.','actor')}},
 ['DW-03:watchtower_order']={mode='investigate',steps={step('map','Study the watchtower route',-35,25,'The old patrol map reveals two spirit links flanking the tower.','ledger'),step('ward','Learn the wardens\' rune warning',35,-20,'A carved warning reads: leaf catches rain; rain feeds root. Remember the order.','rune'),step('departure','Meet Erin at the departure lantern',55,30,'Erin: I will keep the outpost route open. The missing spirit is counting on you.','actor')}},
 ['DW-04:spirit']={mode='escort',actor='Freed Forest Spirit',spirit=true,steps={step('cage','Guide the spirit out of the broken cage',-45,20,'The spirit flickers, reaching for the spring beyond the tower.','arrival'),step('spring','Lead it around the corrupted stones',0,40,'The water brightens as the spirit approaches. The tower\'s drains fall silent.','arrival'),step('release','Return the spirit to the spring',50,15,'Spirit: These roots were meant to protect us. The corruption has turned their purpose against the forest.','arrival')}},
 ['DW-04:link_record']={mode='sequence',clue='Leaf catches rain. Rain feeds root. Wake the seals in that order.',steps={step('leaf','Wake the LEAF seal',-35,25,'The leaf seal lights the first conduit.','rune'),step('rain','Wake the RAIN seal',35,25,'The rain seal reveals a route toward the occupied ruins.','rune'),step('root','Wake the ROOT seal',0,-35,'The record shows prisoners being transferred through the ruins. The spirit spring is no longer feeding the ritual.','rune')}},
 ['DW-04:shortcut']={mode='mechanism',steps={step('counterweight','Release the gate counterweight',-30,20,'The counterweight rises.','lever'),step('lantern','Relight the return-route lantern',30,-10,'The outpost route is marked again. Report what the spirit revealed when you return.','lantern')}},
 ['DW-05:prisoners']={mode='escort',actor='Freed Prisoner',steps={step('cage','Lead the prisoners past the broken cages',-55,35,'Prisoner: The captain is still inside. They take a new group to the altar every night.','arrival'),step('cover','Move through the ruined cover',-10,-40,'The prisoners crouch while the barracks patrol passes.','arrival'),step('refuge','Bring them to the scout shelter',55,25,'The prisoners mark the barracks ritual on your map. End it before confronting the Warlord.','arrival')}},
 ['DW-05:transfer']={mode='investigate',steps={step('names','Recover the prisoner register',-45,30,'The register includes elves, humans, dwarves, and goblins. The raiders are feeding the same ritual with every people.','ledger'),step('orders','Read the sealed transfer orders',35,-30,'The Warlord answered to King Shaman. The orders point toward the corrupted rootwood.','ledger'),step('route','Compare the altar transport route',55,25,'A route passes a ruined goblin settlement before reaching the altar. The survivors there may know why.','tracks')}},
 ['DW-06:refugees']={mode='dialogue',actor='Goblin Refugee',goblin=true,steps={step('listen','Hear the refugee\'s story',0,0,'Refugee: Their shaman burned our homes too. Do you see enemies here, or people who need a road out?','actor',{
  answer('shelter','Offer the outpost as a refuge','Refugee: Tell your wardens we come without weapons. We will show you the buried root lines.'),answer('testimony','Ask how the village was destroyed','Refugee: Violet roots strangled the well. Follow them underground; this network is older than the shaman.')}),step('erin_response','Hear Erin reconsider',0,0,'Erin: I mistook a people for an army. We will make a way for these families after the devices are stopped.','actor'),step('map','Learn the buried conduit route',0,0,'The refugees mark three root devices. Beyond them lies the old seal network.','actor')}},
 ['DW-06:ancient_network']={mode='sequence',clue='The mural shows shelter, water, living roots, then the watchful star.',steps={step('shelter','Restore the SHELTER glyph',-45,20,'The first glyph depicts families sheltered beneath branches.','rune'),step('water','Restore the WATER glyph',20,35,'The second glyph feeds water toward the roots.','rune'),step('roots','Restore the ROOTS glyph',45,-20,'The roots connect to a network that predates the raiders.','rune'),step('star','Restore the STAR glyph',-15,-35,'The network is part of an ancient regional seal. Its original purpose was protection; the altar is misusing it.','rune')}},
 ['DW-06:altar_path']={mode='trail',steps={step('safe_root','Follow the quiet conduit',-50,30,'The corruption recedes along the disabled conduit.','arrival'),step('overlook','Reach the altar overlook',10,-35,'Prisoners and violet devices surround the altar. Two outer links feed its barrier.','arrival'),step('approach','Reach the sheltered altar approach',50,20,'You can see a rescue path beside the outer devices. The captives may help, but you can prevail without them.','arrival')}},
 ['DW-07:rescue_captives']={mode='escort',actor='Altar Captive',steps={step('cage','Lead the captives out of the altar cage',-35,25,'The captives break the binding on an enslaved ogre as they escape.','arrival'),step('cover','Guide them behind the stone cover',20,35,'The freed ogre watches the shaman. It will wait for an opening.','arrival'),step('safety','Reach the safe return path',45,-10,'The captives are safe. Their ally will create a brief opening during the final phase.','arrival')}},
 ['DW-07:core_record']={mode='investigate',steps={step('purpose','Read the regional protection record',-35,20,'The Seal Core regulates the regional seal and connects it to the distant throne.','ledger'),step('cost','Read the damaged energy account',25,-25,'The account records life drawn from the forest to maintain the damaged protection. The throne\'s survival has a cost.','ledger'),step('replacement','Find the replacement-conduit diagram',40,25,'A replacement loop can hold the regional seal while the core is separated. Stabilize it before removing anything.','rune')}},
 ['DW-07:stabilize']={mode='sequence',clue='The diagram routes flow from spring to roots, through shelter, and back to the spring.',steps={step('spring','Open the SPRING intake',-40,25,'Clean power enters the replacement loop.','rune'),step('roots','Link the ROOT conduit',30,30,'The forest roots take part of the load.','rune'),step('shelter','Anchor the SHELTER ward',35,-25,'The regional ward holds without the central core.','rune'),step('return','Close the RETURN loop',-25,-30,'The replacement loop is stable. The core can now be separated without dropping the local seal.','rune')}},
 ['DW-07:separate']={mode='mechanism',steps={step('clamp','Release the outer core clamp',-30,20,'The core dims as the outer clamp opens.','lever'),step('isolate','Isolate the transfer conduit',30,-20,'The local seal remains steady. The transfer conduit is safely isolated.','rune'),step('secure','Secure the core and its record',0,25,'The core is secured for transport. Return to Erin to decide how the remaining restoration power will be shared.','relic')}},
}
local introductions={
 ['DW-01']='A whistle cuts through the trees. The raiders move to block the supply road.',
 ['DW-02']='A survivor calls from the wreck. Raiders are closing around the broken cart.',
 ['DW-04']='The watchtower drains a captive spirit through two violet links.',
 ['DW-05']='The occupied ruins hold prisoners from several peoples. Stop the patrol before the alarm spreads.',
 ['DW-06']='The roots pulse against their own rhythm. The refugees point toward the devices poisoning their well.',
 ['DW-07']='The altar draws power from its outer devices. Find cover and break the links.',
}
function A.install(content)
 for _,c in ipairs(content.chapters) do if not c.side then for _,g in ipairs(c.goals) do
  local activity=A.goals[c.id..':'..g.id]
  if #g.enemies>0 then activity={mode='battle',intro=introductions[c.id],waves=(g.id=='supply_guards' or g.id=='escape_guards' or g.id=='barracks') and 2 or 1} end
  if activity then
   g.activity=activity
   for _,s in ipairs(activity.steps or {}) do s.position={g.position[1]+s.offset[1],g.position[2],g.position[3]+s.offset[2]} end
  end
 end end end
end
return A
