local Info=dofile('src/shared/SupporterInfo.luau')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
check(Info.project(nil).key=='Unknown','missing save is unknown, not a new locked profile')
check(Info.project({flags={}}).key=='Locked','real fresh profile needs rescue')
local replay={main=2,flags={},seleneUnlocked=true,seleneFollowing=false}
check(Info.project(replay).unlocked and Info.project(replay).key=='Available','permanent recruitment survives a replay before the rescue report')
check(Info.project(replay,nil,nil,false,{active=false,credits=1}).key=='SupportReady','replay offers saved support credits')
check(Info.project(replay,nil,nil,false,{active=false,credits=0}).key=='SupportPassRequired','replay recruitment grants no free paid support')
check(Info.transition('Locked','SupportReady')==Info.text.SupportReady,'new recruitment explains invitation with saved credits')
check(Info.transition('Locked','SupportPassRequired')==Info.text.SupportPassRequired,'new recruitment explains pass requirement instead of announcing ended support')
check(Info.transition('Locked','Available')==Info.text.recruited,'new recruitment explains explicit camp invitation')
for _,main in ipairs({3,4,7,14,21})do
 local journal={main=main,flags={['DW-03:report']=true},seleneFollowing=true}
 local copy=Info.project(journal)
 check(copy.unlocked and copy.following,'Story '..main..' retains selection')
 check(copy.cost==200 and copy.durationSeconds==false,'story credit costs 200 Gold without a real-time timer')
 check(Info.project(journal,nil,nil,true).key=='Selected','lobby explains selected preference rather than active healing')
 check(journal.seleneFollowing and journal.main==main,'projection cannot mutate saved progress')
end
check(Info.transition(nil,'Following')==nil,'initial snapshot is quiet')
check(Info.transition('Following','Following')==nil,'unchanged state is quiet')
check(Info.transition('Following','Available'):find('Invite Selene',1,true),'rest explains re-invitation within the paid story')
for _,reason in ipairs({'PartyFull','Respawning','Distance','Range','Threat','Blocked','AtLobby'})do
 local message=Info.transition('Following',reason)
 check(type(message)=='string' and #message>25,'stop reason includes next action: '..reason)
 check(Info.transition(reason,'Following')==Info.text.resumed,'resume is distinct from paid renewal')
end
print('Supporter info: '..checks..' checks passed')
