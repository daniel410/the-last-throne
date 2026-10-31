-- FV stable story IDs / fixed first-clear budgets remain canonical.
-- Trial encounter pacing and en-US scenario wording follow the approved five-epic story.
local F={version=1,chapters={},zones={},edges={}}
local function goal(id,title,x,z,enemies,text,mode,actor)
 return {id=id,title=title,offset={x,z},requires={},enemies=enemies or {},text=text or '',activity=mode and {mode=mode,actor=actor} or nil}
end
local function enemy(kind,level,count)return {kind=kind,level=level,count=count or 1}end
local function story(id,title,number,center,reward,brief,outcome,goals)
 local c={id=id,zone=id,title=title,number=number+7,epic=2,side=false,minMain=number+6,reward={xp=reward[1],coins=reward[2]},goals=goals,
  quest={title=title,brief=brief,outcome=outcome,phases={}}}
 F.zones[id]={name=title,center=center,size={420,380},requiresMain=number+6,epic=2}
 for i,g in ipairs(goals)do
  if i>1 then g.requires={goals[i-1].id}end
  g.position={center[1]+g.offset[1],center[2],center[3]+g.offset[2]}
  if #g.enemies>0 then g.activity={mode='battle',intro='Protect the route. Watch the ice guardians\' attack warnings.'}
  elseif g.activity then
   g.activity.steps={{id='confirmed',title=g.title,text=g.text,kind=g.activity.mode=='travel' and 'arrival' or 'actor',position={table.unpack(g.position)}}}
  end
  table.insert(c.quest.phases,{title=g.title,goals={g.id}})
 end
 table.insert(F.chapters,c)
end
story('FV-01','Blizzard Gate',1,{-792,54,-4200},{187,280},'Find Freya, rescue the stranded travelers, and relight the shelter lanterns.','The travelers have a safe path to Ember Refuge.',{
 goal('pathfinder','Meet Freya at the snow trail',-110,95,nil,'Freya: The storm has trapped our neighbors. Follow me! We can bring everyone to shelter.','dialogue','Freya'),
 goal('snow_guards','Drive the wolves away from the travelers',-55,40,{enemy('IceWolf',12,3)}),
 goal('rescue','Help the stranded travelers',5,0,nil,'Everyone is ready to move. Light the lanterns so no one loses the way.'),
 goal('troll','Clear the lantern crossing',65,-45,{enemy('IceTroll',13)}),
 goal('lanterns','Relight the shelter lanterns',105,-100,nil,'A warm light shines through the snow. The refuge is just ahead!'),
})
story('FV-02','Ember Refuge',2,{-260,60,-4680},{51,120},'Bring the rescue news to Haldor and prepare a safe route through the ravine.','The refuge is ready. Freya has marked the road through Wolf Ravine.',{
 goal('welcome','Meet Haldor at the warm refuge',-90,60,nil,'Haldor: There is room for everyone. Thank you for bringing our friends home!','dialogue','Haldor'),
 goal('supplies','Deliver medicine to the shelter',0,0,nil,'Nessa: The supplies will keep everyone warm and well. Selene is helping the wounded.','dialogue','Nessa'),
 goal('route','Plan the ravine crossing with Freya',85,-65,nil,'Freya: The enemy woke the ice guardians to slow us down. Let us reconnect the shelter beacons.'),
})
story('FV-03','Wolf Ravine',3,{320,68,-5160},{185,360},'Keep the ravine clear and restore both shelter beacons.','Both beacons shine. The storm is coming from the fortress guardian.',{
 goal('wolves','Secure the ravine entrance',-100,90,{enemy('IceWolf',13,4)}),
 goal('west_beacon','Relight the western beacon',-65,10,nil,'The first beacon is lit. A second light will guide travelers across the ravine.'),
 goal('bear','Make room for the trapped caravan',45,-20,{enemy('IceBear',14),enemy('IceWolf',14,2)}),
 goal('east_beacon','Relight the eastern beacon',95,-90,nil,'Both beacons are working! The path to the glacier is open.'),
})
story('FV-04','Subglacial Archive',4,{850,76,-5640},{382,480},'Repair the glacier relays and find a way to calm the awakened guardians.','The relays carry a calming signal. Ylva can help you reach the fortress.',{
 goal('guards','Clear the frozen relay hall',-100,85,{enemy('IceGolem',15,2),enemy('IceTroll',14)}),
 goal('relay_west','Repair the western relay',-65,0,nil,'The relay glows blue. Its signal can help calm the guardians.'),
 goal('elf_guards','Stop the alarm at the archive',45,-10,{enemy('IceElf',15,2)}),
 goal('relay_east','Repair the eastern relay',95,-60,nil,'Both relays are ready. The guardians are confused by a false alarm from the fortress.'),
 goal('ylva','Ask Ylva how to help the guardians',100,-110,nil,'Ylva: They are frightened, not cruel. Restore the signal mirrors and we can help them rest.','dialogue','Ylva'),
})
story('FV-05','Silent Battlefield',5,{260,84,-6120},{403,540},'Open a safe crossing and recover the caravan route markers.','Ivo recognizes the route marks. The crystal convoy passed through the fortress.',{
 goal('crossing','Clear the snowbound crossing',-100,85,{enemy('IceWolf',16,3),enemy('IceGolem',16)}),
 goal('marker_west','Recover the first caravan marker',-50,10,nil,'This marker belongs to the crystal convoy. Its sled runners point toward the fortress.'),
 goal('patrol','Clear the fortress approach',45,-20,{enemy('IceElf',17,2),enemy('IceGolem',17)}),
 goal('courier','Show the route marks to Ivo',100,-85,nil,'Ivo: I saw those sleds! Help open the fortress road and I can show you where they went.','dialogue','Ivo'),
})
story('FV-06','Frost Citadel Gate',6,{-320,92,-6600},{500,680},'Release the two gate locks and calm King Ice Golem.','The great guardian is resting. The palace road is safe.',{
 goal('gate_guards','Secure the citadel courtyard',-110,90,{enemy('IceGolem',18,2),enemy('IceElf',18,2)}),
 goal('west_lock','Release the western ice lock',-70,0,nil,'The western lock is open. The guardian can hear the relay signal.'),
 goal('east_lock','Release the eastern ice lock',65,0,nil,'Both locks are open. Help the great guardian settle down.'),
 goal('king_golem','Calm King Ice Golem',30,-80,{enemy('KingIceGolem',19)}),
 goal('palace_road','Reach the palace road',-70,-120,nil,'The guardian lowers its arms and rests. Ylva waves you toward the palace.','travel'),
})
story('FV-07','Ice Mirror Palace',7,{-850,100,-7080},{450,900},'Stop the false alarm, calm the palace guardian, and reopen the northern road.','The storm has eased and the villages are reunited! The crystal convoy went to Ember Caldera. The safe route to that expedition is open.',{
 goal('hall','Clear the mirror hall',-100,90,{enemy('IceGolem',19,2),enemy('IceElf',19,2)}),
 goal('mirror_west','Restore the first signal mirror',-80,0,nil,'The first mirror sends a gentle blue signal across the valley.'),
 goal('mirror_east','Restore the second signal mirror',70,0,nil,'The second mirror reconnects the shelters. One guardian still hears the false alarm.'),
 goal('queen','Calm Queen Ice Elf',25,-65,{enemy('QueenIceElf',20)}),
 goal('mirror_crown','Restore the final signal mirror',-70,-90,nil,'The false alarm is gone. The guardian rests, and sunlight breaks through the blizzard!'),
 goal('reunion','Bring the good news to Ivo',0,-130,nil,'Ivo: The roads are open! The crystal convoy went to the dwarves\' volcano city. Our friends can help you reach Ember Caldera. At level 20, open STATS & SKILLS [H] to choose your first advancement.'),
})
-- Optional guardian challenges use no extra fixed story XP/Gold budget.
local function side(id,zone,title,kind,level,main,center,giver)
 F.zones[zone]={name=title,center=center,size={320,300},requiresMain=main,epic=2}
 local goals={goal('inspect','Inspect the abandoned supplies',-65,60,nil,'Travelers left supplies here. Clear a safe path to recover them.'),goal('guardian','Calm the guardian',0,0,{enemy(kind,level)}),goal('report','Secure the supplies and report to '..giver,75,-65,nil,'The guardian rests and the supplies can reach the refuge safely.')}
 local c={id=id,zone=zone,title=title,number=0,epic=2,side=true,minMain=main,reward={xp=0,coins=0},goals=goals,quest={title=title,giver=giver,brief='Find the missing supplies and calm the guardian blocking the safe route.',outcome='A safe supply route is restored.',turnIn='report',discoveryOnly=true,offerPosition={center[1]-65,center[2],center[3]+60}}}
 for i,g in ipairs(goals)do g.position={center[1]+g.offset[1],center[2],center[3]+g.offset[2]};if i>1 then g.requires={goals[i-1].id}end;if #g.enemies>0 then g.activity={mode='battle'}end end
 table.insert(F.chapters,c)
end
side('FV-Q2','FV-S1','Frostfang Supply Cave','IceTrollKing',16,10,{-310,68,-5300},'Freya')
side('FV-Q3','FV-S2','Blue Lake Return Route','KingIceBear',17,11,{1450,76,-5690},'Haldor')
side('FV-Q4','FV-S3','Ancient Glacier Watch','AncientGlacierKing',21,14,{-1470,100,-7130},'Ylva')
local tagGoals={goal('name_tag','Find the name tag in the snow',-100,120,nil,'This tag belongs to a traveler at Ember Refuge.'),goal('luggage',"Recover the traveler's luggage",-30,110,nil,'The lost luggage is safe. Bring it to Nessa at the refuge.'),goal('report','Return the luggage to Nessa',0,0,nil,'Nessa: Our friend has their belongings back. Thank you for looking after everyone!')}
for i,g in ipairs(tagGoals)do local z=F.zones[i==3 and 'FV-02' or 'FV-01'];g.position={z.center[1]+g.offset[1],z.center[2],z.center[3]+g.offset[2]};if i>1 then g.requires={tagGoals[i-1].id}end end
tagGoals[3].minMain=8
local first=tagGoals[1].position
table.insert(F.chapters,{id='FV-Q1',zone='FV-01',title='A Name in the Snow',number=0,epic=2,side=true,minMain=7,reward={xp=0,coins=0},goals=tagGoals,quest={title='A Name in the Snow',giver='Nessa',brief='Find a lost name tag and return the luggage to Nessa at Ember Refuge.',outcome='The traveler has their belongings back.',turnIn='report',discoveryOnly=true,offerPosition={table.unpack(first)}}})
F.edges={{'DW-07','FV-01'},{'FV-01','FV-02'},{'FV-02','FV-03'},{'FV-03','FV-04'},{'FV-04','FV-05'},{'FV-05','FV-06'},{'FV-06','FV-07'},{'FV-03','FV-S1'},{'FV-04','FV-S2'},{'FV-07','FV-S3'}}
return F
