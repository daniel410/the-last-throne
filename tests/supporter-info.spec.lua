local Info=dofile('src/shared/SupporterInfo.luau')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
check(Info.project(nil).key=='Unknown','missing save is unknown, not a new locked profile')
check(Info.project({flags={}}).key=='Locked','real fresh profile needs rescue')
for _,main in ipairs({3,4,7,14,21})do
 local journal={main=main,flags={['DW-03:report']=true},seleneFollowing=true}
 local copy=Info.project(journal)
 check(copy.unlocked and copy.following,'Story '..main..' retains selection')
 check(copy.cost==0 and copy.durationSeconds==false,'no recurring payment or time limit')
 check(Info.project(journal,nil,nil,true).key=='Selected','lobby explains selected preference rather than active healing')
 check(journal.seleneFollowing and journal.main==main,'projection cannot mutate saved progress')
end
check(Info.transition(nil,'Following')==nil,'initial snapshot is quiet')
check(Info.transition('Following','Following')==nil,'unchanged state is quiet')
check(Info.transition('Following','Available'):find('Invite Selene',1,true),'rest explains free re-invitation')
for _,reason in ipairs({'PartyFull','Respawning','Distance','Range','Threat','Blocked','AtLobby'})do
 local message=Info.transition('Following',reason)
 check(type(message)=='string' and #message>25,'stop reason includes next action: '..reason)
 check(Info.transition(reason,'Following')==Info.text.resumed,'resume is distinct from paid renewal')
end
print('Supporter info: '..checks..' checks passed')
