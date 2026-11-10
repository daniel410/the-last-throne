-- GW uses provisional zero fixed rewards; HG keeps the approved stable reward rows.
local L={version=1,chapters={},zones={},edges={}}
local function enemy(kind,level,count)return {kind=kind,level=level,count=count or 1}end
local function fight(id,title,kind,level,count)return {id=id,title=title,enemies={enemy(kind,level,count)}}end
local function act(id,title,text,mode,actor,kind)return {id=id,title=title,text=text,enemies={},activity={mode=mode or 'mechanism',actor=actor},stepKind=kind or (mode=='dialogue' and 'actor' or mode=='travel' and 'arrival' or 'lever')}end
local function story(id,title,number,center,reward,brief,outcome,goals)
 local epic=number<=28 and 4 or 5
 local c={id=id,zone=id,title=title,number=number,epic=epic,side=false,minMain=number-1,reward={xp=reward[1],coins=reward[2]},goals=goals,quest={title=title,brief=brief,outcome=outcome,phases={}}}
 L.zones[id]={name=title,center=center,size={440,400},requiresMain=number-1,epic=epic}
 for i,g in ipairs(goals)do
  local x=(i%2==1 and -65 or 65);local z=110-(i-1)*48
  g.position={center[1]+x,center[2],center[3]+z};g.requires=i>1 and {goals[i-1].id} or {};g.text=g.text or ''
  if #g.enemies>0 then g.activity={mode='battle',intro='Protect your friends. Watch enemy attack warnings and keep moving.'}
  else g.activity.steps={{id='confirmed',title=g.title,text=g.text,kind=g.stepKind,position={table.unpack(g.position)}}}end
  g.stepKind=nil;table.insert(c.quest.phases,{title=g.title,goals={g.id}})
 end
 table.insert(L.chapters,c)
 if #L.chapters>1 then table.insert(L.edges,{L.chapters[#L.chapters-1].zone,id})end
 return c
end
story('GW-01','Lantern Trail',22,{-700,156,-11600},{0,0},'Follow the missing scouts into Gloamwood. Maeve needs your help.','The scouts left trail marks. Follow them to the tangled camp.',{
 act('maeve','Meet Maeve at the forest entrance','Maeve: Our scouts are trapped in the webs. Follow their lantern marks. We will bring everyone home.','dialogue','Maeve'),
 fight('trail','Clear the lantern trail','Webling',28,3),
 act('marks','Read the missing scout trail marks','The marks point to a camp beyond the webs. Finn is waiting there.','investigate',nil,'tracks'),
 act('lantern','Light the trail lantern','The lantern lights a safe path for the rescue team.',nil,nil,'lantern'),
})
story('GW-02','A Light in the Webs',23,{-100,160,-12100},{0,0},'Help Finn take the first step and cut the trapped scout free.','Tali is free! Bring the scouts to Lantern Refuge.',{
 act('finn','Speak with Finn','Finn: I am scared of spiders. But Tali needs us. Will you come with me?','dialogue','Finn'),
 fight('web_guards','Drive the spiders away from Tali','Silkweaver',29,3),
 act('bindings','Cut the web bindings','Tali: You found me! The others are deeper in the forest. Let us reach the refuge first.',nil,nil,'bindings'),
 act('tali','Meet Tali beside the cleared path','Tali: Stay beside me. I know a safe path through these roots.','dialogue','Tali'),
})
local refuge=story('GW-03','Lantern Refuge',24,{500,164,-12600},{0,0},'Guide Tali to the refuge and help Maeve plan the next rescue.','The first scouts are safe. Your friends have marked a path to the old ent.',{
 act('escort','Guide Tali to Lantern Refuge','Keep Tali safe and stay close.','escort','Tali'),
 act('report','Report the rescue to Maeve','Maeve: Everyone here is safe. The ancient ent blocks the next trail. We will keep these lanterns lit.','dialogue','Maeve'),
 act('wisp','Ask the Wispkeeper for a safe route','Wispkeeper: Even in a dark forest, there are friends. Follow the lanterns past the old roots.','dialogue','Wispkeeper'),
})
refuge.goals[1].activity.steps={
 {id='path',title='Guide Tali past the roots',text='Tali: There is the refuge lantern!',kind='arrival',position={480,164,-12530}},
 {id='safe',title='Reach the refuge with Tali',text='Tali has reached the refuge. Maeve is ready to help the others.',kind='arrival',position={550,164,-12575}},
}
story('GW-04','The Ancient Rootway',25,{1100,168,-13100},{0,0},'Clear the rootway and defeat the ancient ent blocking the rescue route.','The rootway is open. The missing scouts left another lantern ahead.',{
 fight('roots','Clear the rootway hunters','Barkstalker',30,3),
 fight('ent','Defeat Ancient Hollowbark','AncientHollowbark',31),
 act('lantern','Relight the scout lantern','The light reaches the next trail. Maeve can guide the rescue team through.',nil,nil,'lantern'),
})
story('GW-05','Venomcoil Crossing',26,{500,172,-13600},{0,0},'Cross the centipede hunting ground and open a safe route for the scouts.','The crossing is safe. The last scouts are trapped near the queen nest.',{
 fight('centipedes','Clear the centipede crossing','VenomcoilCentipede',31,3),
 fight('king','Defeat Venomcoil King','VenomcoilKing',32),
 act('rope','Secure the scout crossing rope','The rope marks a safe route. The rescued scouts can cross without entering the hunting ground.',nil,nil,'bindings'),
})
story('GW-06','One Brave Step',27,{-100,176,-14100},{0,0},'Help Finn rescue his friends, then hold off Hollowbark Sovereign while the scouts escape.','Hollowbark Sovereign is defeated and all the scouts are safe. Finn leads them home while you stop the queen.',{
 fight('bats','Clear the nest approach','Gloambat',32,3),
 act('webs','Cut the last scout web bindings','The last scouts are free. Finn steps forward to guide them.',nil,nil,'bindings'),
 act('courage','Encourage Finn','Finn: I am still scared. But I will not leave my friends. We can do this together!','dialogue','Finn'),
 -- Keep rear_guard and its two existing guard receipt positions; append the new boss.
 {id='rear_guard',title='Defeat Hollowbark Sovereign and protect the scouts',enemies={enemy('Silkweaver',32,2),enemy('HollowbarkSovereign',32)}},
})
local queen=story('GW-07','The Queen of the Webs',28,{-700,180,-14600},{0,0},'Defeat the Widow Queen and open the road to Veyr fortress.','The scouts are safe and the forest road is open! Tali has shown you the hidden entrance to Haunted Graveyard.',{
 fight('nest','Clear the queen nest','Webling',33,3),
 fight('queen','Defeat the Widow Queen','WidowQueen',34),
 act('exit','Cut the web sealing the forest exit','Daylight reaches the trail again. Every scout has a safe way out.',nil,nil,'bindings'),
 act('entrance','Learn the hidden graveyard entrance from Tali','Tali: You saved us. Now we can help you! This old passage leads behind Veyr walls.','dialogue','Tali'),
})
queen.goals[2].bossEncounter={waves={{health=.65,enemies={enemy('Webling',33,2)}},{health=.3,enemies={enemy('Silkweaver',33)}}}}
story('HG-01','Mist Gate',29,{-700,184,-15300},{495,600},'Meet the friends who have come to help stop Veyr.','Your friends have secured the entrance. Gather at the keeper shelter.',{
 act('rook','Meet Rook at the hidden entrance','Rook: The scouts showed us the way. The elves and dwarves are here too. We will stop Veyr together!','dialogue','Rook'),
 fight('mist','Clear the mist gate','Zombie',34,3),
 fight('lantern_guards','Secure the keeper lantern path','Skeleton',34,2),
 act('shelter','Reach the keeper shelter','The shelter lantern is lit. Garrick is waiting with news.','travel'),
})
story('HG-02','Friends at the Old Shelter',30,{-100,188,-15800},{212,220},'Make a plan with Garrick, Elowen, and your returning friends.','The alliance is ready. Lumi knows a quiet passage into the fortress.',{
 act('garrick','Ask Garrick about the fortress','Garrick: Veyr is opening a great portal at the royal tomb. Stay on the lantern path.','dialogue','Garrick'),
 act('eryn','Meet Eryn and the elf scouts','Eryn: You helped our forest. Now let us open a path for you!','dialogue','Eryn'),
 act('brann','Meet Brann and the dwarf crew','Brann: Our tools are ready. We will open the outer gate. Friends help friends!','dialogue','Brann'),
 act('elowen','Ask Elowen how to restore the Crownheart','Elowen: Break the throne devices, recover the Crownheart, and close the portal. We will help you bring it home.','dialogue','Elowen'),
})
story('HG-03','Lumi Secret Passage',31,{500,192,-16300},{929,780},'Follow a friendly ghost through the quiet crypt passage.','Lumi has shown you a safe passage. Your friends can reach the outer wall.',{
 act('lumi','Meet Lumi at the lantern arch','Lumi: Hello! I am a friendly ghost. Follow my lantern. There is a quiet way around the guards.','dialogue','Lumi'),
 fight('crypt','Clear the passage guardians','Ghoul',35,3),
 fight('mummy','Open the sealed crypt route','Mummy',35,2),
 act('passage','Open Lumi hidden passage','Lumi: That is it! I will guide everyone behind you. Go help your friends at the wall.',nil,nil,'lever'),
})
story('HG-04','The Alliance Opens the Gate',32,{1100,196,-16800},{1373,900},'Protect Brann crew and defeat the commander at the fortress gate.','The gate is open! The elves mark the route and the scouts guide everyone to safety.',{
 fight('wall','Clear the fortress wall','SkeletonKnight',36,3),
 act('winch','Operate the gate winch with Brann crew','Brann: The gate is moving! Keep the commander away from the crew.',nil,nil,'lever'),
 fight('commander','Defeat Dread Commander','DreadCommander',37),
 act('allies','Signal the allied scouts','Rook: The gate is secure. We will guide everyone through while you stop the throne devices.',nil,nil,'lantern'),
})
story('HG-05','The Black Throne Devices',33,{500,200,-17300},{855,980},'Break the devices that protect the black throne. Any hero can operate them.','The outer throne shield is gone. Veyr last guards wait in the royal tomb.',{
 fight('hellhounds','Clear the throne approach','Hellhound',37,3),
 act('west','Break the western throne device','One shield link is broken. Keep moving toward the eastern device.',nil,nil,'rune'),
 fight('lich','Defeat the device keeper','Lich',38),
 act('east','Break the eastern throne device','Both outer shield links are broken. The path to the royal tomb is open.',nil,nil,'rune'),
})
story('HG-06','The Royal Tomb',34,{-100,204,-17800},{975,1200},'Defeat the tomb guards and secure a path for the Crownheart rescue.','The tomb guards are defeated. Veyr stands before the portal with the Crownheart.',{
 fight('knights','Clear the royal tomb guard','DeathKnight',38,2),
 fight('sovereign','Defeat Lich Sovereign','LichSovereign',39),
 act('seal','Open the royal tomb seal','Elowen: The final path is open. Take the Crownheart from the throne after Veyr falls.',nil,nil,'rune'),
})
local final=story('HG-07','Together We Bring Back the Light',35,{-700,208,-18300},{1252,1600},'Defeat Veyr, recover the Crownheart, and close the invasion portal.','The Crownheart is safe and the portal is closed! Return to Dawnspire. Your friends are waiting to celebrate the five regions you saved together.',{
 fight('guard','Defeat Veyr final guard','DeathKnight',39),
 fight('veyr','Defeat Veyr at the black throne','Veyr',40),
 act('crownheart','Recover the Crownheart from the black throne','The Crownheart shines again. Now close the portal before more monsters arrive.',nil,nil,'relic'),
 act('portal','Close the invasion portal','The great portal closes. Dawnspire is safe! Return to the lobby to restore the throne and celebrate with your friends.',nil,nil,'rune'),
})
final.goals[2].bossEncounter={shieldLinks=true,waves={{health=.7,enemies={enemy('Skeleton',39,2)}},{health=.35,enemies={enemy('Hellhound',39,2)}}}}
table.insert(L.edges,1,{'EC-07','GW-01'})
return L
