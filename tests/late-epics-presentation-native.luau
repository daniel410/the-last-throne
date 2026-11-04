assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local report={kind='LATE_EPICS_PRESENTATION_NATIVE',checks=0}
local function check(v,m)report.checks+=1;assert(v,m)end
local V=require(client.LateEpicPresentation)
local world=assert(workspace:FindFirstChild('DeepwoodCampaign'));local props=world.LateEpicProps
V.update({flags={['HG-07:portal']=true,['HG-07:crownheart']=true,['GW-07:exit']=true}})
check(props.InvasionPortal.LocalTransparencyModifier==1,'saved portal closure is personal')
check(props.Crownheart.LocalTransparencyModifier==1,'recovered heart leaves the throne')
for _,name in ipairs({'InvasionPortalVisual','CrownheartVisual'})do local m=assert(props:FindFirstChild(name));local n=0;for _,p in ipairs(m:GetDescendants())do if p:IsA('BasePart')then n+=1;check(p.LocalTransparencyModifier==1,'saved completion hides derived visual '..name)end end;check(n>5,'actual multi-part finale visual')end
local streamed=Instance.new('Part');streamed.Name='LateStreamedPortal';streamed:SetAttribute('LateStoryHideKey','HG-07:portal');streamed.Parent=props;task.wait()
check(streamed.LocalTransparencyModifier==1,'late streamed object reapplies confirmed completion')
V.update({flags={}})
check(props.InvasionPortal.LocalTransparencyModifier==0 and streamed.LocalTransparencyModifier==0,'switching to unfinished hero restores portal')
for _,name in ipairs({'InvasionPortalVisual','CrownheartVisual'})do for _,p in ipairs(props[name]:GetDescendants())do if p:IsA('BasePart')then check(p.LocalTransparencyModifier==0,'unfinished hero restores derived visual '..name)end end end
streamed:Destroy()
local lobby=require(game.ServerScriptService.Server.World.LobbyWorld).create()
local Home=require(client.DawnspireHomecoming)
Home.update({heroId='done',heroes={done={deepwood={clears={['HG-07']=true}}}}})
check(lobby.folder:FindFirstChild('DawnspireHomecoming')~=nil,'complete hero sees restored Dawnspire throne')
check(lobby.folder.DawnspireHomecoming.Crownheart.HomecomingGreeting.TextLabel.Text:find('WELCOME HOME',1,true),'English homecoming greeting')
Home.update({heroId='new',heroes={new={deepwood={clears={}}}}})
check(lobby.folder:FindFirstChild('DawnspireHomecoming')==nil,'unfinished hero cannot inherit another hero ending')
report.pass=true;return report
