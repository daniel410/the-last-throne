assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local report={kind='LATE_EPICS_PRESENTATION_NATIVE',checks=0}
local function check(v,m)report.checks+=1;assert(v,m)end
local V=require(client.LateEpicPresentation)
local world=assert(workspace:FindFirstChild('DeepwoodCampaign'));local props=world.LateEpicProps
V.update({flags={['HG-07:portal']=true,['HG-07:crownheart']=true,['GW-07:exit']=true}})
check(props.InvasionPortal.LocalTransparencyModifier==1,'saved portal closure is personal')
check(props.Crownheart.LocalTransparencyModifier==1,'recovered heart leaves the throne')
local streamed=Instance.new('Part');streamed.Name='LateStreamedPortal';streamed:SetAttribute('LateStoryHideKey','HG-07:portal');streamed.Parent=props;task.wait()
check(streamed.LocalTransparencyModifier==1,'late streamed object reapplies confirmed completion')
V.update({flags={}})
check(props.InvasionPortal.LocalTransparencyModifier==0 and streamed.LocalTransparencyModifier==0,'switching to unfinished hero restores portal')
streamed:Destroy()
local lobby=require(game.ServerScriptService.Server.World.LobbyWorld).create()
local Home=require(client.DawnspireHomecoming)
Home.update({heroId='done',heroes={done={deepwood={clears={['HG-07']=true}}}}})
check(lobby.folder:FindFirstChild('DawnspireHomecoming')~=nil,'complete hero sees restored Dawnspire throne')
check(lobby.folder.DawnspireHomecoming.Crownheart.HomecomingGreeting.TextLabel.Text:find('WELCOME HOME',1,true),'English homecoming greeting')
Home.update({heroId='new',heroes={new={deepwood={clears={}}}}})
check(lobby.folder:FindFirstChild('DawnspireHomecoming')==nil,'unfinished hero cannot inherit another hero ending')
report.pass=true;return report
