-- Read-only supporter projection; never grants recruitment, currency or support.
local Shared=game and game:GetService('ReplicatedStorage').Shared
local Text=Shared and require(Shared.SupporterText) or dofile('src/shared/SupporterText.luau')
local Budget=Shared and require(Shared.SeleneSupport) or dofile('src/shared/SeleneSupport.luau')
local Info={text=Text}
function Info.project(journal,status,key,lobby,pass)
 local unlocked=journal and journal.flags and journal.flags['DW-03:report']==true or false
 if lobby and journal and unlocked and journal.seleneFollowing and not key then key='Selected' end
 key=key or (not journal and 'Unknown' or not unlocked and 'Locked' or journal.seleneFollowing and 'Following' or 'Available')
 if unlocked and pass and not pass.active then key=pass.credits>0 and 'SupportReady' or 'SupportPassRequired' end
 local state=key=='Range' and string.format(Text.Range,Budget.range) or Text[key] or status or Text.Unknown
 return {id='selene',name=Text.name,role=Text.role,portrait='nun',key=key,status=state,unlocked=unlocked,
  following=journal and journal.seleneFollowing==true or false,cost=200,durationSeconds=false,lobby=lobby==true,pass=pass,
  lines={Text.policy,Text.duration,Text.unlock,
   string.format(Text.heal,math.floor(Budget.healFraction*100+.5)),
   string.format(Text.protect,math.floor(Budget.shieldFraction*100+.5),Budget.shieldDuration),
   string.format(Text.cleanse,Budget.cooldown,Budget.range),
   lobby and Text.lobby or Text.invite,Text.camps,Text.persistence,Text.slots,Text.other}}
end
function Info.transition(previous,current)
 if not previous or previous==current then return nil end
 if current=='Available' and previous~='Locked' and previous~='Unknown' then return Text.ended end
 if current=='Following' and previous~='Locked' and previous~='Available' and previous~='Unknown' then return Text.resumed end
 if current=='SupportReady' or current=='SupportPassRequired' then return Text.SupportEnded end
 if current=='AtLobby' or current=='PartyFull' or current=='Respawning' or current=='Distance' or current=='Threat' or current=='Blocked' then return Text[current] end
 if current=='Range' then return string.format(Text.Range,Budget.range) end
end
return Info
