-- Stable EC chapter IDs and original first-clear reward budgets.
local E={version=1,chapters={},zones={},edges={}}
local function enemy(kind,level,count)return {kind=kind,level=level,count=count or 1}end
local function goal(id,title,x,z,enemies,text,mode,actor)
 return {id=id,title=title,offset={x,z},requires={},enemies=enemies or {},text=text or '',activity=mode and {mode=mode,actor=actor} or nil}
end
local function story(id,title,n,center,reward,brief,outcome,goals)
 local c={id=id,zone=id,title=title,number=n+14,epic=3,side=false,minMain=n+13,reward={xp=reward[1],coins=reward[2]},goals=goals,quest={title=title,brief=brief,outcome=outcome,phases={}}}
 E.zones[id]={name=title,center=center,size={440,400},requiresMain=n+13,epic=3}
 for i,g in ipairs(goals)do
  if i>1 then g.requires={goals[i-1].id}end
  g.position={center[1]+g.offset[1],center[2],center[3]+g.offset[2]}
  if #g.enemies>0 then g.activity={mode='battle',intro='Protect the repair crew. Watch the enemy attack warnings.'}
  elseif g.activity then g.activity.steps={{id='confirmed',title=g.title,text=g.text,kind=g.activity.mode=='travel' and 'arrival' or 'actor',position={table.unpack(g.position)}}}end
  table.insert(c.quest.phases,{title=g.title,goals={g.id}})
 end
 table.insert(E.chapters,c);return c
end
story('EC-01','Ash Gate',1,{-850,100,-8100},{316,420},'Help the stranded workers and repair the freight lift.','The lift is repaired. The safe road to Forge City is open.',{
 goal('ash_raiders','Clear the ash-covered approach',-110,90,{enemy('Imp',20,3),enemy('LavaSlime',20)}),
 goal('worker','Help the workers behind the broken cart',-50,30,nil,'The workers have a safe way out. Find the spare gear for the freight lift.'),
 goal('gear','Recover the lift gear',20,-10,{enemy('Imp',21,2)}),
 goal('lift','Repair the freight lift',85,-70,nil,'The lift is working! The crew can reach Forge City safely.'),
})
story('EC-02','Forge City',2,{-260,108,-8580},{92,160},'Meet Brann and help the city prepare a rescue team.','The rescue crew is ready. Head for the collapsed mine.',{
 goal('brann','Meet Brann at the workshop',-95,65,nil,'Brann: The monsters took our great furnace. I cannot fix this alone. Will you help us bring the miners home?','dialogue','Brann'),
 goal('tools','Collect spare tools from Ketta',0,15,nil,'Ketta: Take these spare tools. The repair crew is counting on us!','dialogue','Ketta'),
 goal('plan','Find the marked mine entrance',95,-75,nil,'Brann has marked a safe road. The cooling engineer will meet you by the canals.','travel'),
})
story('EC-03','Collapsed Resonance Mine',3,{320,116,-9060},{600,560},'Brace the mine supports, drive off the magma worms, and rescue the miners.','The miners are safe. The furnace cooling channels need repairs.',{
 goal('mine_guards','Clear the mine entrance',-110,90,{enemy('Imp',21,3),enemy('Golem',22)}),
 goal('supports','Brace the cracked mine supports',-60,25,nil,'The supports hold firm. The rescue team can move deeper into the mine.'),
 goal('worm','Stop the magma worm at the rescue tunnel',25,-15,{enemy('MagmaWorm',23),enemy('Imp',22,2)}),
 goal('miners','Bring the missing miners out of the tunnel',80,-65,nil,'Orik: Everyone is here! We will follow the marked road back to the city. Thank you!','dialogue','Orik'),
 goal('cooling_map','Find the cooling-channel map',105,-115,nil,'The map shows two damaged valves. Fixing them will cool the great furnace.'),
})
story('EC-04','Split Coolant Canals',4,{900,124,-9540},{657,680},'Help Dagna repair both valves and restore the cooling flow.','Coolant is flowing again. The repair plans point to the old design vault.',{
 goal('engineer','Meet Dagna by the cooling channel',-110,85,nil,'Dagna: Two valves are stuck. Clear the monsters and turn each wheel. Any hero can help!','dialogue','Dagna'),
 goal('canal_guards','Clear the broken pumping station',-60,35,{enemy('LavaSlime',23,3),enemy('VolcanoShaman',24)}),
 goal('west_valve','Open the western coolant valve',-70,-15,nil,'The western channel is flowing again.'),
 goal('east_guards','Secure the eastern valve',55,-20,{enemy('Golem',24),enemy('VolcanoShaman',24)}),
 goal('east_valve','Open the eastern coolant valve',85,-70,nil,'Both valves are open. The furnace temperature is falling!'),
 goal('plans','Recover the repair-crew plans',0,-120,nil,'These plans show a safer heat circuit. Brann\'s family stored the complete design in the vault.'),
})
story('EC-05','Ancestral Design Vault',5,{300,132,-10020},{630,720},'Recover the heat-circuit plans and work with Brann to prepare the testworks.','The crew has a safe repair plan. Test the circuit before restarting the city furnace.',{
 goal('vault_guards','Clear the workshop vault',-105,85,{enemy('Golem',25,2),enemy('VolcanoShaman',25)}),
 goal('blueprint','Recover the safe heat-circuit blueprint',-50,20,nil,'The complete blueprint shows how to power the city without overheating the furnace.'),
 goal('crew','Bring the plans to the repair table',25,-30,nil,'Brann: I should have asked for help sooner. Together, we can make this work.'),
 goal('test_order','Prepare the testworks repair kit',100,-95,nil,'The repair kit is ready. Test the cooling circuit before you restart the great furnace.'),
})
story('EC-06','Geothermal Heart Testworks',6,{-300,140,-10500},{745,900},'Defeat Magma Golem and prove that the cooling circuit can protect the city.','The test circuit is stable. The crew is ready to reclaim the great furnace.',{
 goal('outer_guards','Secure the testworks entrance',-110,85,{enemy('Golem',26,2),enemy('Imp',26,2)}),
 goal('intake','Connect the coolant intake',-75,0,nil,'The test coolant intake is connected.'),
 goal('magma_golem','Defeat Magma Golem',30,-45,{enemy('MagmaGolem',28)}),
 goal('trial','Run the protected heat-circuit test',85,-95,nil,'The circuit holds steady. Dagna confirms that the city can safely restart its workshops.'),
})
E.chapters[1].goals[4].travelTo='EC-02'
local rescue=E.chapters[3].goals[4]
rescue.activity={mode='escort',actor='Orik',steps={
 {id='supports',title='Guide Orik past the braced supports',text='Orik: The supports are holding. The exit is just ahead!',kind='arrival',position={340,116,-9135}},
 {id='exit',title='Reach the safe mine exit with Orik',text='The miners are safe! The crew will bring everyone back to the city.',kind='arrival',position={430,116,-8975}},
}}
local final=story('EC-07','Great Furnace',7,{-880,148,-10980},{843,1200},'Defeat Inferno Overlord, restart the safe furnace, and follow the stolen Crownheart.','The city is safe and the workshops are running again! The enemy carried the key toward Gloamwood. That expedition is still being prepared.',{
 goal('furnace_guards','Clear the furnace approach',-110,90,{enemy('Imp',28,3),enemy('VolcanoShaman',29)}),
 goal('coolant_west','Connect the western emergency cooler',-85,10,nil,'The first emergency cooler is connected. The crew is staying behind the safety line.'),
 goal('coolant_east','Connect the eastern emergency cooler',80,10,nil,'Both coolers are ready. Stop Inferno Overlord before the furnace overheats!'),
 goal('overlord','Defeat Inferno Overlord',20,-65,{enemy('InfernoOverlord',30)}),
 goal('restart','Restart the protected city furnace',-75,-95,nil,'The furnace runs safely again! Light returns to the workshops and the miners cheer.'),
 goal('courier','Meet Suri with the enemy delivery orders',70,-130,nil,'Suri: The enemy turned the Crownheart into a portal key. Their commander fled toward the dark forest. Veyr is planning to attack Dawnspire. We will help you stop him!','dialogue','Suri'),
})
final.goals[4].bossEncounter={waves={{health=.65,enemies={enemy('Imp',29,2)}},{health=.30,enemies={enemy('VolcanoShaman',29)}}}}
-- Solo-compatible sequential devices; no simultaneous pads or class-specific spell keys.
for _,c in ipairs(E.chapters)do for _,g in ipairs(c.goals)do
 if #g.enemies==0 and not g.activity and (g.id:find('valve') or g.id=='supports' or g.id=='intake' or g.id=='trial' or g.id=='restart' or g.id=='lift' or g.id:find('coolant_'))then
  g.activity={mode='mechanism',steps={{id='operate',title=g.title,text=g.text,kind='lever',position={table.unpack(g.position)}}}}
 end
end end
local function side(id,zone,title,kind,level,main,center)
 E.zones[zone]={name=title,center=center,size={320,300},requiresMain=main,epic=3}
 local goals={goal('inspect','Inspect the abandoned crew supplies',-65,60,nil,'The missing supplies are here. Clear the route before the crew returns.'),goal('boss','Defeat the enemy blocking the repair crew',0,0,{enemy(kind,level)}),goal('secure','Secure the repair route',75,-65,nil,'The route is safe. Report the recovery to Ketta in Forge City.'),goal('report','Report to Ketta in Forge City',0,0,nil,'Ketta: The repair crew has the supplies and a safe route. Thank you!')}
 local hub=E.zones['EC-02'].center
 for i,g in ipairs(goals)do local p=i==4 and hub or center;if i==4 then g.offset={0,15}end;g.position={p[1]+g.offset[1],p[2],p[3]+g.offset[2]};if i>1 then g.requires={goals[i-1].id}end;if #g.enemies>0 then g.activity={mode='battle'}end end
 table.insert(E.chapters,{id=id,zone=zone,title=title,number=0,epic=3,side=true,minMain=main,reward={xp=0,coins=0},goals=goals,quest={title=title,giver='Ketta',brief='Recover crew supplies and return safely to Forge City.',outcome='The repair crew has a safe supply route.',turnIn='report',discoveryOnly=true,offerPosition={table.unpack(goals[1].position)}}})
end
side('EC-Q2','EC-S1','Ember Raider Nest','MagmaImp',24,17,{-340,116,-9200})
side('EC-Q3','EC-S2','Volcano Shaman Altar','KingVolcanoShaman',26,18,{1500,124,-9560})
side('EC-Q4','EC-S3','Caldera Titan Basin','CalderaTitan',31,21,{-1520,148,-11030})
local tags={goal('tool_tag','Find the lost worker tool tag',-90,120,nil,'A worker at Forge City will recognize this tool tag.'),goal('safety_record','Recover the mine safety record',-30,110,nil,'The record is safe. Return it to Ketta.'),goal('report','Return the record to Ketta',0,0,nil,'Ketta: Our friend will be glad to have this back. Thank you!')}
for i,g in ipairs(tags)do if i==3 then g.offset={0,15}end;local p=E.zones[i==3 and 'EC-02' or 'EC-01'].center;g.position={p[1]+g.offset[1],p[2],p[3]+g.offset[2]};if i>1 then g.requires={tags[i-1].id}end end
tags[3].minMain=15
 table.insert(E.chapters,{id='EC-Q1',zone='EC-01',title='A Worker\'s Lost Mark',number=0,epic=3,side=true,minMain=14,reward={xp=0,coins=0},goals=tags,quest={title='A Worker\'s Lost Mark',giver='Ketta',brief='Find the lost tool tag and return the safety record to Forge City.',outcome='The worker\'s record is safely returned.',turnIn='report',discoveryOnly=true,offerPosition={table.unpack(tags[1].position)}}})
E.edges={{'FV-07','EC-01'},{'EC-01','EC-02'},{'EC-02','EC-03'},{'EC-03','EC-04'},{'EC-04','EC-05'},{'EC-05','EC-06'},{'EC-06','EC-07'},{'EC-03','EC-S1'},{'EC-04','EC-S2'},{'EC-07','EC-S3'}}
return E
