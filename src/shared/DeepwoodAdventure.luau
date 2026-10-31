-- Authored episode activities. Stable goal IDs and first-clear rewards stay in Content.
-- Spatial substeps are independently saved; these are trial pacing/English drafts.
local A={}
local function step(id,title,x,z,text,kind,choices)
 return {id=id,title=title,offset={x,z},text=text,kind=kind or 'clue',choices=choices}
end
local function answer(id,title,text) return {id=id,title=title,text=text} end
A.goals={
 ['DW-01:supplies']={mode='investigate',steps={
  step("manifest","Read the convoy packing list",-45,32,"The convoy was carrying food and medicine for the village. Let us bring the supplies back.",'ledger'),
  step("bindings","Find the loose travel ropes",35,-35,"Someone untied these ropes and escaped. Look for the survivors by the clearing.",'bindings'),
  step("resin","Find the convoy wheel marks",60,25,"The wheel marks lead to a broken cart. Eryn has marked the way!",'resin')}},
 ['DW-01:tracks']={mode='trail',steps={
  step("drag_marks","Follow the broken branches",-50,48,"The convoy came this way. Keep following the trail.",'tracks'),
  step("heavy_prints","Find the large footprints",-5,-30,"An ogre passed here. Watch for its big swings!",'tracks'),
  step("scout_sign","Find Eryn's trail mark",35,20,"Eryn: This way! I can hear people calling from the clearing.",'tracks')}},
 ['DW-01:trail_exit']={mode='travel',steps={step('approach','Reach the overlook above the clearing',0,0,'Smoke rises from a broken cart. Someone below is calling for help.','arrival')}},
 ['DW-02:survivors']={mode='escort',actor='Wounded Scout',steps={
  step("shelter","Guide the survivors behind the wall",-60,35,"Selene: I will care for the wounded. Let us get everyone to the shelter.",'arrival'),
  step("crossing","Lead everyone around the cart",10,-45,"Survivor: Thank you for coming! Some of our friends are still in the ruins.",'arrival'),
  step("safety","Reach the lantern shelter",60,25,"Everyone is safe at the shelter! Clear the road so they can reach camp.",'arrival')}},
 ['DW-02:testimony']={mode='investigate',steps={
  step("crest","Find the convoy captain's badge",-45,25,"This is the convoy captain's badge. The survivors saw the captain taken toward the ruins.",'ledger'),
  step("ritual","Find the raiders' portal sign",30,-35,"A purple portal sign marks the raiders' route. Eryn will help us follow it.",'resin'),
  step("witness","Ask for the safe camp route",55,20,"Selene: Follow the lanterns to the elder tree camp. I will meet you there with our friends.",'actor')}},
 ['DW-02:clearing_exit']={mode='trail',steps={step("road","Follow the safe-route lanterns",-40,25,"The lanterns show the safe route home.",'arrival'),step("outpost","Reach the elder tree camp road",25,-15,"The camp is ahead. Tell Selene that everyone is safe!",'arrival')}},
 ['DW-03:report']={mode='dialogue',actor='Selene',steps={
  step("account","Tell Selene the rescue news",0,0,"Selene: Everyone made it to camp! You helped us bring them home.",'actor',{
   answer('survivors','Help everyone settle in','Selene: Warm beds and medicine are ready. Everyone can rest now!'),answer('road','Check the safe road','Selene: The road is safe. The next group can reach us too!')}),
  step("missing","Welcome Selene as a friend",0,0,"Selene: I would like to help on your journey. You can invite me at this camp whenever you are ready. Selene is now available as a free companion.",'actor')}},
 ['DW-03:erin']={mode='dialogue',actor='Eryn',steps={
  step("trust","Meet Eryn at camp",0,0,"Eryn: You brought our friends home! Let us find the rest of the convoy together.",'actor',{
   answer('truth','Let us find the missing workers','Eryn: Together, we will bring them home!'),answer('people','Let us stop the monster portal','Eryn: Yes! Our friends will have a safe forest again.')}),
  step("signal","Plan the watchtower rescue",0,0,"Eryn: The raiders are building a monster portal. We can stop their devices and free our friends.",'actor'),
  step("agreement","Make a rescue plan together",0,0,"Eryn: We will bring our friends home and stop that portal!",'actor')}},
 ['DW-03:watchtower_order']={mode='investigate',steps={step("map","Find the watchtower on the map",-35,25,"Eryn marks a safe route to the watchtower.",'ledger'),step("ward","Prepare for the rescue",35,-20,"Eryn: Watch for the purple portal devices. Stop them to open the cage.",'rune'),step("departure","Set out with your friends",55,30,"The rescue plan is ready. Follow the lanterns toward the watchtower!",'actor')}},
 ['DW-04:spirit']={mode='escort',actor='Freed Forest Spirit',spirit=true,steps={step("cage","Open the forest friend's cage",-45,20,"The portal devices are off. The cage can open!",'arrival'),step("spring","Open the safe return path",0,40,"The path to the forest spring is open. Our friend can head home.",'arrival'),step("release","Guide the forest friend home",50,15,"The forest friend is free and follows the lanterns toward camp.",'arrival')}},
 ['DW-04:link_record']={mode='sequence',clue='Light the route markers in order: LEAF, RAIN, ROOT.',steps={step("leaf","Read the raiders' route map",-35,25,"The raiders marked the occupied ruins. The missing workers must be there.",'rune'),step("rain","Find the prison camp mark",35,25,"Eryn: More friends need our help. Let us take the safe route to the ruins.",'rune'),step("root","Mark the safe ruins approach",0,-35,"The route is marked. Let us bring the convoy workers home!",'rune')}},
 ['DW-04:shortcut']={mode='mechanism',steps={step("counterweight","Open the return gate",-30,20,"The gate is open. Our rescued friends have a shorter way home.",'lever'),step("lantern","Light the return-route lantern",30,-10,"The way back to camp is bright again!",'lantern')}},
 ['DW-05:prisoners']={mode='escort',actor='Freed Prisoner',steps={step("cage","Guide the workers out of the cages",-55,35,"Worker: The captain is still ahead. Thank you for helping us!",'arrival'),step("cover","Guide everyone behind cover",-10,-40,"The workers wait safely behind the wall while the patrol passes.",'arrival'),step("refuge","Reach the scout shelter",55,25,"Everyone reaches the shelter. Stop the signal device, then face the Warlord!",'arrival')}},
 ['DW-05:transfer']={mode='investigate',steps={step("names","Check the convoy worker list",-45,30,"The list helps us check who is safely home and who still needs help.",'ledger'),step("orders","Read King Shaman's orders",35,-30,"King Shaman ordered the convoy workers taken to the Black Root Altar.",'ledger'),step("route","Find the safe altar route",55,25,"The map passes a forest village. The families there may know a safe way through.",'tracks')}},
 ['DW-06:refugees']={mode='dialogue',actor='Goblin Refugee',goblin=true,steps={step("listen","Hear the village families",0,0,"Villager: We need a safe path too. Can you help us stop those portal devices?",'actor',{
  answer('shelter','Offer a safe place at camp','Villager: Thank you! We will show you where the portal devices are.'),answer('testimony','Ask how to help the village','Villager: Stop the three portal devices and light the safe-route signs.')}),step("erin_response","Plan the rescue with Eryn",0,0,"Eryn: Of course. Everyone deserves a safe way home!",'actor'),step("map","Find the three portal devices",0,0,"The families mark the devices on your map. We can clear the path together.",'actor')}},
 ['DW-06:ancient_network']={mode='sequence',clue='Light the safe-route signs: SHELTER, WATER, ROOTS, STAR.',steps={step("shelter","Light the SHELTER marker",-45,20,"A shelter sign lights the way for the families.",'rune'),step("water","Light the WATER marker",20,35,"The water sign points toward the safe stream crossing.",'rune'),step("roots","Light the ROOTS marker",45,-20,"The roots sign marks the bend in the path.",'rune'),step("star","Light the STAR marker",-15,-35,"All four signs are lit! The families can find their way home.",'rune')}},
 ['DW-06:altar_path']={mode='trail',steps={step("safe_root","Follow the quiet forest path",-50,30,"The portal devices are off. The path is safe again.",'arrival'),step("overlook","Reach the altar overlook",10,-35,"The monster portal is ahead. Two outer devices protect King Shaman.",'arrival'),step("approach","Reach the sheltered altar path",50,20,"We can rescue the remaining captives here. Their help is welcome, but you can win either way.",'arrival')}},
 ['DW-07:rescue_captives']={mode='escort',actor='Altar Captive',steps={step("cage","Guide the captives out",-35,25,"The captives are free! They open a path for a trapped ogre too.",'arrival'),step("cover","Guide everyone behind cover",20,35,"The friendly ogre waits for a chance to help you.",'arrival'),step("safety","Reach the safe return path",45,-10,"Everyone is safe! The freed ogre will help during the final battle.",'arrival')}},
 ['DW-07:core_record']={mode='investigate',steps={step("purpose","Find the delivery label",-35,20,"The label says Crownheart. The stolen crystal was carried through this camp!",'ledger'),step("cost","Read the northbound orders",25,-25,"Orders: Take the Crownheart north through Frozen Vale.",'ledger'),step("replacement","Share the clue with Eryn",40,25,"Eryn: We know where to look next! First, let us close this monster portal.",'rune')}},
 ['DW-07:stabilize']={mode='sequence',clue='Close the portal switches in order: SPRING, ROOTS, SHELTER, RETURN.',steps={step("spring","Turn off the SPRING switch",-40,25,"The first portal switch is off.",'rune'),step("roots","Turn off the ROOTS switch",30,30,"The second portal switch is off. The portal is shrinking!",'rune'),step("shelter","Turn off the SHELTER switch",35,-25,"Only one switch left. We can do it!",'rune'),step("return","Turn off the RETURN switch",-25,-30,"The monster portal closes. The forest is safe again!",'rune')}},
 ['DW-07:separate']={mode='mechanism',steps={step("clamp","Open the supply crate",-30,20,"The convoy's missing supplies are inside.",'lever'),step("isolate","Collect the food and medicine",30,-20,"The supplies can go back to the village.",'rune'),step("secure","Take the delivery orders",0,25,"You have the northern route. Return to Eryn and celebrate the rescue!",'relic')}},
}
local introductions={
 ['DW-01']='A whistle cuts through the trees. The raiders move to block the supply road.',
 ['DW-02']='A survivor calls from the wreck. Raiders are closing around the broken cart.',
 ['DW-04']='Two portal devices guard a trapped forest friend. Stop them and open the cage.',
 ['DW-05']='The occupied ruins hold prisoners from several peoples. Stop the patrol before the alarm spreads.',
 ['DW-06']='The village families need a safe path. Stop the three portal devices together.',
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
