-- TD Riftstorm / Throne Under Siege. Local presentation never starts an encounter.
local SoundService=game:GetService('SoundService')
local TweenService=game:GetService('TweenService')
local Policy=require(game.ReplicatedStorage.Shared.DeepwoodMusicPolicy)
local Music={}
local started=false
function Music.create(options)
 options=options or {}
 local tracks,tweens,current,currentKey={},{},nil,nil
 local function track(name,id)
  local s=SoundService:FindFirstChild(name)
  if s and not s:IsA('Sound') then return nil end
  if not s then s=Instance.new('Sound');s.Name=name;s.Volume=0;s.Parent=SoundService end
  s.SoundId='rbxassetid://'..id;s.Looped=true;table.insert(tracks,s);return s
 end
 local normal=track('TLTBackgroundMusic',Policy.normalId)
 local boss=track('TLTBossMusic',Policy.bossId)
 local ready=options.isReady or function(sound) return sound.IsLoaded end
 local api={normal=normal,boss=boss}
 function api.select(key)
  local target=key and boss and ready(boss) and boss or normal
  local restart=target==boss and currentKey~=key
  if target==current and not restart then return current end
  current,currentKey=target,key
  for _,sound in ipairs(tracks) do
   if tweens[sound] then tweens[sound]:Cancel() end
   if sound==target then
    if restart then sound.TimePosition=0 end
    if not sound.IsPlaying then sound:Play() end
   end
   local tween=TweenService:Create(sound,TweenInfo.new(Policy.fade),{Volume=sound==target and Policy.volume or 0});tweens[sound]=tween
   tween.Completed:Once(function(state) if state==Enum.PlaybackState.Completed and current~=sound then sound:Pause() end end)
   tween:Play()
  end
  return current
 end
 function api.destroy()
  for _,t in pairs(tweens) do t:Cancel() end
  for _,s in ipairs(tracks) do s:Destroy() end
 end
 api.select(nil);return api
end
function Music.start()
 if started then return end;started=true
 local Players=game:GetService('Players');local Run=game:GetService('RunService');local RS=game:GetService('ReplicatedStorage')
 local player=Players.LocalPlayer;local controller=Music.create();local snapshot,received=nil,0
 local function refresh()
  local c=player.Character;local h=c and c:FindFirstChildOfClass('Humanoid');local root=c and c:FindFirstChild('HumanoidRootPart')
  local session={alive=h~=nil and h.Health>0,mode=player:GetAttribute('K0SessionPhase'),route=player:GetAttribute('TLTRoute'),heroId=c and c:GetAttribute('K0HeroId'),position=root and {root.Position.X,root.Position.Y,root.Position.Z}}
  controller.select(os.clock()-received<6 and Policy.bossKey(snapshot,session) or nil)
 end
 player.CharacterAdded:Connect(function() snapshot=nil;refresh() end)
 player:GetAttributeChangedSignal('K0SessionPhase'):Connect(refresh);player:GetAttributeChangedSignal('TLTRoute'):Connect(refresh)
 local elapsed=0;Run.Heartbeat:Connect(function(dt) elapsed+=dt;if elapsed>=.2 then elapsed=0;refresh() end end)
 task.spawn(function()
  local event=RS:WaitForChild('Remotes'):WaitForChild('DeepwoodState')
  event.OnClientEvent:Connect(function(value) snapshot=value;received=os.clock();refresh() end)
 end)
 -- Keep normal music until the boss asset is ready; failed/denied audio never mutes it.
 task.spawn(function()
  if controller.boss then pcall(function() game:GetService('ContentProvider'):PreloadAsync({controller.boss}) end);refresh() end
 end)
end
return Music
