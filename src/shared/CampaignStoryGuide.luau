-- Read-only story context and discoveries. Existing confirmed journals are the only source.
local function load(name)return game and require(game:GetService('ReplicatedStorage').Shared[name])or dofile('src/shared/'..name..'.luau')end
local C=load('CampaignContent')
local P=load('DeepwoodProgress')
local Patterns=load('EnemyPatterns')
local G={}
G.text={purpose='WHY WE ARE HERE',recap='LAST CONFIRMED RESULT',people='PEOPLE',clues='CLUES',outcomes='OUTCOMES',
 discoveries='DISCOVERIES',read='READ / TALK',back='BACK TO DISCOVERIES',empty='Discover people and evidence during your adventures. Only confirmed discoveries appear here.',
 optional='Optional reading. No reward, progress, or support credit is required or consumed.',
 combatTitle='LEARN AT YOUR OWN PACE',combat='Watch the marked attack area before committing. Move out before impact. DODGE OR MOVE attacks cannot be blocked. Use an opening after the attack to strike back.',
 assistance='Solo play can finish the main story. MAP and QUEST can help you find the next objective. Navigation and attack-area guides can be adjusted in SETTINGS.',
 recorded='Story updated. Review QUEST > CHRONICLE when you are safe.',
 nextReason='WHY NEXT · %s',regionResult='REGION SAVED · %s',
}
G.regions={
 {question='Who is missing from the convoy?',purpose='Bring the travelers and supplies home. Their clues can lead you to the missing workers.',
 result='The convoy and its people are safe. The portal is closed.',next='The cargo trail leads into Gloamwood, where Eryn\'s scouts have gone missing.'},
 {question='Can every scout make it home?',purpose='Follow the scout lanterns into the webs. Rescue your friends and open the old northern road.',
 result='The scouts are safe and the northern road is open.',next='Tali saw the Crownheart convoy heading toward Frozen Vale. Follow the snowy ridge.'},
 {question='Why are the guardians blocking the refuge road?',purpose='Help the stranded travelers, reconnect their shelters, and discover what is wrong with the valley signals.',
 result='The guardians are calm, the storm has eased, and the villages are reunited.',next='The delivery records lead to the great furnace in Ember Caldera.'},
 {question='What was the stolen Crownheart used to make?',purpose='Free the workers and restore the city\'s equipment. Follow the cargo records to uncover the enemy\'s plan.',
 result='The workshops are working again and the invasion plan is exposed.',next='Veyr plans to open an invasion gate at the royal tomb. Your friends are securing the approach.'},
 {question='How will the friends we rescued help us reach the tomb?',purpose='Follow the allied signals, open the royal tomb, and stop Veyr from using the Crownheart against Dawnspire.',
 result='The Crownheart is safe and the invasion portal is closed.',next='Return to Dawnspire. The people you saved are ready to welcome you home.'},
}
local records={
 {id='eryn',kind='people',epic=1,title='Eryn · Following people, not just cargo',stages={
  {keys={'DW-03:exp_1'},text='The recovered medicine helped the survivors speak. The driver\'s signal sketch changed Eryn\'s plan: reconnect the watchtower and find the workers.'},
  {keys={'DW-07:exp_2'},text='The cargo went north. Eryn\'s missing scouts followed it into Gloamwood.'}}},
 {id='selene',kind='people',epic=1,title='Selene · A place for every traveler',selene=true,stages={
  {keys={'DW-02:exp_1'},text='You kept the medicine dry. Selene used it to help the injured traveler speak about the missing driver.'}},
  conversation={'Selene: A rescued traveler is more than a name on a list. Someone is waiting for them to come home.','Selene: I will keep a place ready while you look for the others.'}},
 {id='finn',kind='people',epic=2,title='Finn · One light for a friend',stages={
  {keys={'GW-02:exp_1'},text='Finn was frightened of the webs, but Tali needed a light. He held his three-bar lantern where she could see it.'},
  {keys={'GW-06:rear_guard'},text='Finn led the scouts out. You held the rearguard so every friend could leave safely.'},
  {keys={'HG-04:exp_2'},text='The same three-bar signal guided your allies through Brann\'s gate. Finn and Tali kept their promise.'}}},
 {id='freya',kind='people',epic=3,title='Freya and Ylva · A safe road home',stages={
  {keys={'FV-03:exp_2'},text='The restored crossing connects the travelers\' route. Freya can help them reach shelter.'},
  {keys={'FV-04:exp_2'},text='Ylva helped you compare the guardian\'s behavior with the warning beam. Restoring the shelter signal changed which road it protected.'},
  {keys={'FV-07'},text='The village signals are restored and the travelers can reunite.'}}},
 {id='crew',kind='people',epic=4,title='Dagna, Orik and Brann · A complete loop',stages={
  {keys={'EC-05:exp_2'},text='Dagna traced the supply into the tank. Orik found the return line. Brann connected the city shield. Their separate clues made one working circuit.'},
  {keys={'HG-04:exp_2'},text='Brann\'s gate rig and Finn\'s scout signal opened the way for the allies you helped.'}}},
 {id='lumi',kind='people',epic=5,title='Lumi · The heart belongs at home',stages={
  {keys={'HG-06:exp_1'},text='The Crownheart protects Dawnspire. Veyr forced its protecting power into an invasion gate. Lumi helped you understand what must be freed.'},
  {keys={'HG-07'},text='The heart is safe, the portal is closed, and your friends have the way home.'}}},
 {id='cargo',kind='clues',epic=1,title='The broken-crown cargo mark',stages={
  {keys={'DW-07:exp_2'},text='The same broken-crown mark appears on the stolen cargo and its northern route.'},
  {keys={'FV-04:exp_1'},text='The altered alarm plate bears the same mark. The delivery trail and the false warning are connected.'},
  {keys={'EC-07:exp_2'},text='The empty carrier and Veyr\'s dispatch reveal the royal tomb as the invasion gate\'s destination.'}}},
 {id='lantern',kind='clues',epic=2,title='Three gold bars · Scout signal',stages={
  {keys={'GW-01:exp_1'},text='Three gold bars identify a scout lantern. The light footprints turn toward the webs while the heavy cargo wheels continue north.'},
  {keys={'HG-01:exp_1'},text='The familiar three-bar lantern marks the approach secured by Finn and Tali.'}}},
 {id='alarm',kind='clues',epic=3,title='Warning beam and shelter road',stages={
  {keys={'FV-04:exp_1'},text='The warning points at the refuge road. The guardian follows it as if that safe road were a threat.'},
  {keys={'FV-04:exp_2'},text='Restoring the shelter signal turns the guardian toward protecting travelers again. It did not need to be destroyed.'}}},
 {id='circuit',kind='clues',epic=4,title='Triangle, ring and shield',stages={
  {keys={'EC-05:exp_1'},text='Look for the direction of flow, the return route, and the protection mark. The crew\'s drawings explain the controls.'},
  {keys={'EC-05:exp_2'},text='The triangle supplies the tank, the ring returns coolant, and the shield protects the city. A complete loop needs all three.'}}},
 {id='meal',kind='outcomes',epic=1,title='Liora\'s camp meal',stages={{keys={'DW-Q2'},text='The recovered food reaches the camp table. Liora can serve more than warm water.'}}},
 {id='nell',kind='outcomes',epic=3,title='Nell · A name and a welcome',stages={{keys={'FV-Q1'},text='The badge gives the lost traveler a name. Nessa kept a place for Nell with their waiting friends.'}}},
 {id='jori',kind='outcomes',epic=4,title='Jori · Back on the crew',stages={{keys={'EC-Q1'},text='Ketta kept Jori\'s place on the crew board. Returning the work mark brings a person back to the workshop.'}}},
}
local function earned(s,key)
 if not s then return false end
 if (s.clears or {})[key]then return true end
 local chapter=key:match('^([^:]+):')
 -- Old clears may restore a character's role, but waived new incidents are not witnessed facts.
 if (s.expansionWaivers or {})[key]then return false end
 return (s.flags or {})[key]==true or chapter and not key:find(':exp_',1,true)and (s.clears or {})[chapter]==true or false
end
function G.discoveries(s,kind,epic)
 local result={}
 for _,record in ipairs(records)do if (not kind or record.kind==kind)and (not epic or record.epic==epic)then
  local lines={}
  for _,stage in ipairs(record.stages)do
   for _,key in ipairs(stage.keys)do if earned(s,key)then table.insert(lines,stage.text);break end end
  end
  if #lines>0 or record.selene and s and P.seleneUnlocked(s)then
   local row={id=record.id,kind=record.kind,epic=record.epic,title=record.title,lines=lines}
   if record.conversation and s and P.seleneUnlocked(s)then for _,line in ipairs(record.conversation)do table.insert(lines,line)end end
   table.insert(result,row)
  end
 end end
 return result
end
function G.context(s,chapter)
 if not s then return nil end
 chapter=chapter or C.byId[s.expeditionMission]or C.mainChapters[math.min(C.mainCount,s.main+1)]
 if not chapter then return nil end
 local region=G.regions[chapter.epic or 1]
 return {question=region.question,purpose=chapter.side and chapter.quest.brief or region.purpose}
end
function G.recap(s,chapter)
 if not s then return nil end
 chapter=chapter or C.byId[s.expeditionMission]or C.mainChapters[s.main+1]
 local latest
 if chapter then
  for _,goal in ipairs(chapter.goals)do
   local key=chapter.id..':'..goal.id
   if goal.expansion and earned(s,key)then latest=goal.text end
  end
  if (s.clears or {})[chapter.id]then return chapter.quest.outcome end
 end
 if latest then return latest end
 local previous=C.mainChapters[s.main or 0]
 return previous and (s.clears or {})[previous.id]and previous.quest.outcome or nil
end
function G.completedRegion(s,chapter)
 if not chapter or chapter.side or chapter.number%7~=0 or not s or not (s.clears or {})[chapter.id]then return nil end
 return G.regions[chapter.epic]
end
function G.inCombat(value)
 for _,fight in pairs(value and value.encounters or {})do
  if (fight.remaining or 0)>0 or (fight.pillars or 0)>0 then return true end
 end
 return false
end
function G.lesson(goal)
 local lines={};local seen={}
 for _,enemy in ipairs(goal and goal.enemies or {})do
  local profile=Patterns.profiles[enemy.kind]
  for _,attack in ipairs(profile and profile.attacks or {})do
   if not seen[attack.id]and #lines<4 then
    seen[attack.id]=true
    table.insert(lines,attack.name..' · '..(attack.blockable and 'Block the hit or leave the marked area.'or 'DODGE OR MOVE · This attack cannot be blocked.'))
   end
  end
 end
 return lines
end
return G
