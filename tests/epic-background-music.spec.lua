-- Real client selection/startup with issued upload IDs and engine doubles; no playback claim.
local Policy=dofile('src/shared/DeepwoodMusicPolicy.luau')
local Biome=dofile('src/shared/CampaignBiome.luau')
local Content=dofile('src/shared/CampaignContent.luau')
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local regions={'Deepwood','FrozenVale','EmberCaldera','HauntedGraveyard','Gloamwood'}
local uploaded={75927987438822,125591915467925,133002206384547,87214425116358,135245618012178}
for i,region in ipairs(regions)do
 check(Policy.epicIds[region]==uploaded[i],'exact issued TD upload ID '..region)
end
local function signal()
 local callbacks={}
 return {Connect=function(_,fn)callbacks[#callbacks+1]=fn;return {Disconnect=function()end}end,
 Once=function(_,fn)callbacks[#callbacks+1]=fn end,
 fire=function(_,...)for _,fn in ipairs(callbacks)do fn(...)end end}
end
local sounds,tweens={},{}
local soundService={FindFirstChild=function(_,name)return sounds[name]end}
local function sound(name)
 local s={Name=name,IsLoaded=true,TimePosition=0,plays=0,pauses=0}
 function s:IsA(k)return k=='Sound'end
 function s:Play()self.IsPlaying=true;self.plays=self.plays+1 end
 function s:Pause()self.IsPlaying=false;self.pauses=self.pauses+1 end
 function s:Destroy()self.destroyed=true end
 return s
end
-- A sound created during ReplicatedFirst must be adopted, without double playback.
sounds.TLTBackgroundMusic=sound('TLTBackgroundMusic');sounds.TLTBackgroundMusic:Play()
local root={Position={X=0,Y=0,Z=0}};local human={Health=100}
local attrs={K0SessionPhase='Tutorial',TLTRoute='Adventure'}
local char={FindFirstChild=function()return root end,FindFirstChildOfClass=function()return human end,GetAttribute=function()return 'knight'end}
local gui={};local cover
function gui:FindFirstChild()return cover end
local player={Character=char,CharacterAdded=signal(),OnTeleport=signal(),GameplayPaused=false}
function player:GetAttribute(key)return attrs[key]end
function player:GetAttributeChangedSignal()return signal()end
function player:FindFirstChild()return gui end
local beat=signal();local state=signal()
local event={Name='DeepwoodState',IsA=function(_,kind)return kind=='RemoteEvent'end,OnClientEvent=state}
local folder={Name='Remotes',IsA=function(_,kind)return kind=='Folder'end,ChildAdded=signal(),FindFirstChild=function()return event end}
local rs={Shared={DeepwoodMusicPolicy=Policy,CampaignBiome=Biome},ChildAdded=signal(),FindFirstChild=function()return folder end}
local services={SoundService=soundService,ReplicatedStorage=rs,Players={LocalPlayer=player},RunService={Heartbeat=beat},
 TweenService={Create=function(_,s,info,goal)
  check(info==1.5 and (goal.Volume==0 or goal.Volume==.2),'original fade and gain')
  local t={Completed=signal(),Cancel=function()end,Play=function()end};tweens[#tweens+1]=t;return t
 end},ContentProvider={PreloadAsync=function()end}}
local env=setmetatable({game={ReplicatedStorage=rs,GetService=function(_,name)return services[name]end},
 require=function(v)return v end,Instance={new=function()local s=sound();return setmetatable(s,{__newindex=function(t,k,v)rawset(t,k,v);if k=='Name'then sounds[v]=t end end})end},
 TweenInfo={new=function(v)return v end},Enum={PlaybackState={Completed='Completed'},TeleportState={Failed='Failed'}},
 task={spawn=function(fn)fn()end}},{__index=_G})
local source=assert(io.open('src/client/K0BackgroundMusic.luau')):read('*a'):gsub('elapsed%+=dt','elapsed=elapsed+dt')
local Music=assert(load(source,'music','t',env))()
local controller=Music.create()
check(controller.normal==sounds.TLTBackgroundMusic and controller.normal.plays==1,'adopt arrival sound without restart')
for i,region in ipairs(regions)do
 local id=uploaded[i];local expected=sounds['TLTEpicMusic_'..region]
 check(controller.select(nil,id)==expected,'epic theme '..region)
 expected.TimePosition=23;local plays=expected.plays
 check(controller.select(nil,id)==expected and expected.TimePosition==23 and expected.plays==plays,'repeat observation preserves theme position')
 check(controller.select('boss-a',id)==controller.boss,'boss takes priority')
 controller.boss.TimePosition=17;controller.select('boss-a',id)
 check(controller.boss.TimePosition==17,'same boss does not restart')
 controller.select('boss-b',id);check(controller.boss.TimePosition==0,'new boss restarts original track')
 controller.boss.IsLoaded=false
 check(controller.select('boss-b',id)==expected,'unloaded boss retains region music')
 expected.IsLoaded=false
 check(controller.select(nil,id)==controller.normal,'denied regional audio retains Riftstorm')
 expected.IsLoaded=true;controller.boss.IsLoaded=true
 check(controller.select(nil,id)==expected,'late audio load selects region')
end
check(controller.select(nil,0)==controller.normal,'missing ID fallback')
controller.select('boss',uploaded[1])
local delayed=tweens[#tweens]
controller.select(nil,uploaded[2]);controller.select('boss',uploaded[2])
delayed.Completed:fire('Completed')
check(controller.boss.IsPlaying,'late completed tween cannot pause selected boss')
controller.destroy();for _,s in ipairs(controller.tracks)do check(s.destroyed,'destroy releases every track')end
-- Start the real polling/subscription path and move through all actual campaign zones.
sounds={};tweens={};Music.start()
local function selected()
 -- Complete current fades, as an engine would. Ignore canceled callbacks via current guard.
 for _,t in ipairs(tweens)do t.Completed:fire('Completed')end
 local found
 for name,s in pairs(sounds)do if s.IsPlaying then check(not found,'only selected track plays after fade');found=name end end
 return found
end
for id,zone in pairs(Content.zones)do
 root.Position={X=zone.center[1],Y=zone.center[2],Z=zone.center[3]};beat:fire(.3)
 local region=Biome.at(root.Position.X,root.Position.Z)
 check(selected()=='TLTEpicMusic_'..region,'actual zone selects spatial epic '..id)
end
root.Position={X=0,Y=0,Z=0};beat:fire(.3)
state:fire({heroId='knight',encounters={boss={boss=true,active=true,remaining=1,position={0,0,0}}}})
check(selected()=='TLTBossMusic','real story subscription selects existing boss')
cover={Enabled=true};beat:fire(.3);check(selected()=='TLTBackgroundMusic','arrival cover suppresses epic and boss')
cover=nil;beat:fire(.3);check(selected()=='TLTBossMusic','reveal restores current boss')
player.OnTeleport:fire('Started');check(selected()=='TLTBackgroundMusic','departure loading uses Riftstorm')
player.OnTeleport:fire('Failed');check(selected()=='TLTBossMusic','failed teleport restores encounter')
for _,phase in ipairs({'Lobby','LoadingTutorial','ReturningLobby','Respawning'})do
 attrs.K0SessionPhase=phase;beat:fire(.3);check(selected()=='TLTBackgroundMusic','lobby/loading/death fallback '..phase)
end
attrs.K0SessionPhase='Tutorial';attrs.TLTRoute='Training';beat:fire(.3)
check(selected()=='TLTBackgroundMusic','training keeps original fallback')
attrs.TLTRoute='Adventure';human.Health=0;beat:fire(.3);check(selected()=='TLTBackgroundMusic','dead character cannot retain epic or boss')
print('epic-background-music: '..checks..' checks PASS (issued IDs; no Roblox playback claim)')
