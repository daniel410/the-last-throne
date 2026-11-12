-- Training never owns story remotes. Music must continue and bind a later campaign once.
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local function signal()
 local list={}
 return {Connect=function(_,fn)local c={active=true};table.insert(list,{fn,c});return {Disconnect=function()c.active=false end}end,
 fire=function(_,value)for _,item in ipairs(list)do if item[2].active then item[1](value)end end end}
end
local function node(kind,name)
 local n={Name=name,ChildAdded=signal(),children={}}
 function n:IsA(k)return k==kind end
 function n:FindFirstChild(k)return self.children[k]end
 function n:WaitForChild()error('music cannot wait for optional story remotes')end
 function n:add(c)self.children[c.Name]=c;self.ChildAdded:fire(c)end
 return n
end
local source=assert(io.open('src/client/K0BackgroundMusic.luau')):read('*a'):gsub('elapsed%+=dt','elapsed=elapsed+dt')
for _,timing in ipairs({'existing','late-event','late-folder','training'})do
 local rs=node('ReplicatedStorage','RS');rs.Shared={DeepwoodMusicPolicy={bossKey=function(s)return s and s.boss end}}
 local folder=node('Folder','Remotes');local event=node('RemoteEvent','DeepwoodState');event.OnClientEvent=signal()
 if timing~='late-folder' then rs:add(folder)end
 if timing=='existing'then folder:add(event)end
 local player={CharacterAdded=signal(),GetAttributeChangedSignal=function()return signal()end,GetAttribute=function(_,key)return key=='TLTRoute'and'Training'or'Tutorial'end}
 local heartbeat=signal();local selections={};local count=0
 local env=setmetatable({game={ReplicatedStorage=rs,GetService=function(_,name)
  return ({Players={LocalPlayer=player},RunService={Heartbeat=heartbeat},ReplicatedStorage=rs})[name]or{}
 end},require=function(x)return x end,task={spawn=function(fn)fn()end}},{__index=_G})
 local music=assert(load(source,'K0BackgroundMusic','t',env))()
 music.create=function()return {select=function(key)count=count+1;selections[count]=key or 'normal'end}end
 music.start();music.start();heartbeat:fire(6)
 check(count==1 and selections[1]=='normal','normal music survives without story: '..timing)
 if timing~='training'then
  if timing=='late-folder'then rs:add(folder)end
  if timing~='existing'then folder:add(event)end
  event.OnClientEvent:fire({boss='boss-1'})
  check(count==2 and selections[2]=='boss-1','late story connects without yielding: '..timing)
  folder.ChildAdded:fire(event);rs.ChildAdded:fire(folder);event.OnClientEvent:fire({boss='boss-2'})
  check(count==3 and selections[3]=='boss-2','replication observations never duplicate subscriptions: '..timing)
 end
end
print('background-music-late-story: '..checks..' checks PASS')
