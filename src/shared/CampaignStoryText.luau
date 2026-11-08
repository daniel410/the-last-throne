-- Approved 2026-11-07 story transitions. IDs and substep counts are preserved.
local rows={
 {chapter="DW-07",goal="core_record",text="Orders: Carry the Crownheart through the old road in Gloamwood.",title="Read the convoy orders",step="cost"},
 {chapter="DW-07",goal="core_record",text="Eryn: Our scouts followed that convoy into Gloamwood. We have not heard from them. First, let us close this portal!",title="Share the clue with Eryn",step="replacement"},
 {chapter="DW-07",goal="separate",text="The orders mark the old road into Gloamwood. Return to Eryn with the news.",title="Take the delivery orders",step="secure"},
 {chapter="DW-07",field="outcome",text="The portal is closed and the convoy is home! Follow the Crownheart trail into Gloamwood and find the missing scouts."},
 {chapter="DW-07",goal="restoration",text="Eryn: Our friends and supplies are home! Shall we help the forest camp or deliver supplies to the village first? Both groups will get help. Then we can follow the Crownheart trail into Gloamwood!"},
 {chapter="GW-01",field="brief",text="Follow the Crownheart convoy trail into Gloamwood and help Maeve find the missing scouts."},
 {chapter="GW-01",goal="maeve",text="Maeve: Our scouts followed the Crownheart convoy along this old road. Now they are trapped in the webs. Follow their lantern marks!",title="Meet Maeve at the forest entrance",step="confirmed"},
 {chapter="GW-01",goal="marks",text="Wheel tracks pass a broken cart. Beside them, scout marks point deeper into the webs. Finn is waiting ahead.",title="Read the missing scout trail marks",step="confirmed"},
 {chapter="GW-02",goal="bindings",text="Tali: You found me! The Crownheart convoy passed before the spiders caught us. Our other scouts are still deeper in the forest.",title="Cut the web bindings",step="confirmed"},
 {chapter="GW-03",goal="wisp",text="Wispkeeper: The old road reaches the snowy mountains. Follow the lanterns past the roots, and bring your friends safely through.",title="Ask the Wispkeeper for the northern route",step="confirmed"},
 {chapter="GW-07",field="brief",text="Defeat the Widow Queen, free the northern exit, and learn where the Crownheart convoy went."},
 {chapter="GW-07",goal="exit",text="The old road is open. Beyond the clearing mist, snowy mountains rise above the forest.",title="Cut the web sealing the northern exit",step="confirmed"},
 {chapter="GW-07",goal="entrance",text="Tali: I saw them carry the Crownheart toward Frozen Vale. Take the northern road. We will keep this path safe for everyone!",title="Ask Tali where the convoy went",step="confirmed"},
 {chapter="GW-07",field="outcome",text="Every scout is safe! The northern road is open, and the Crownheart trail leads to Frozen Vale."},
 {chapter="FV-01",field="brief",text="Follow Tali's lead into Frozen Vale. Find Freya, rescue the stranded travelers, and relight the shelter lanterns."},
 {chapter="FV-07",goal="reunion",text="Ivo: The roads are open! These delivery records say the Crownheart was taken to the great furnace in Ember Caldera. The enemy plans to reshape it there. Our friends can show you the way!",title="Bring the good news to Ivo"},
 {chapter="FV-07",field="outcome",text="The storm has eased and the villages are reunited! The delivery records lead to the great furnace in Ember Caldera."},
 {chapter="EC-07",goal="courier",text="Suri: The enemy turned the Crownheart into a portal key. Veyr will use it at the royal tomb to attack Dawnspire. Brann marked their route. Maeve's scouts are securing the approach. Let us stop him together!",title="Meet Suri with the enemy delivery orders",step="confirmed"},
 {chapter="EC-07",field="outcome",text="The city is safe and the workshops are running again! Veyr's orders reveal the royal tomb and its approach. Your friends are ready. Set out for Haunted Graveyard!"},
 {chapter="HG-01",goal="rook",text="Rook: We followed the route Brann marked. The scouts you rescued in Gloamwood secured the approach. The elves and dwarves are ready. Let us stop Veyr together!",title="Meet Rook at the hidden entrance",step="confirmed"},
}
local T={}
function T.install(content)
 for _,row in ipairs(rows)do
  local chapter=assert(content.byId[row.chapter])
  if row.field then chapter.quest[row.field]=row.text
  else
   local goal
   for _,g in ipairs(chapter.goals)do if g.id==row.goal then goal=g;break end end
   assert(goal,'Unknown story goal')
   local target=goal
   if row.step then
    target=nil
    for _,step in ipairs(goal.activity.steps)do if step.id==row.step then target=step;break end end
    assert(target,'Unknown story step')
   end
   if row.title then target.title=row.title end;target.text=row.text
   -- Single-step objectives share the same authored instruction in HUD and phases.
   if row.step and #goal.activity.steps==1 then goal.title=target.title;goal.text=target.text end
   if row.title and (not row.step or #goal.activity.steps==1)then
    for _,phase in ipairs(chapter.quest.phases)do
     if #phase.goals==1 and phase.goals[1]==goal.id then phase.title=goal.title end
    end
   end
  end
 end
end
return T
