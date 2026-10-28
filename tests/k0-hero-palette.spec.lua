-- Run: lua tests/k0-hero-palette.spec.lua
-- Standalone Lua test doubles: lifecycle and color preservation only, not native
-- avatar rendering, clothing acceptance, network replication or device QA.
local function signal()
 local callbacks = {}
 local s = {}
 function s:Connect(fn)
  local c = {Connected=true}
  function c:Disconnect() self.Connected=false end
  table.insert(callbacks,{connection=c,fn=fn})
  return c
 end
 function s:Fire(...)
  local snapshot={table.unpack(callbacks)}
  for _,row in ipairs(snapshot) do if row.connection.Connected then row.fn(...) end end
 end
 function s:Count()
  local n=0
  for _,row in ipairs(callbacks) do if row.connection.Connected then n=n+1 end end
  return n
 end
 return s
end
Color3={fromRGB=function(r,g,b)return r..','..g..','..b end}
local players={PlayerAdded=signal(),PlayerRemoving=signal(),list={}}
function players:GetPlayers() return self.list end
game={GetService=function(_,name)assert(name=='Players');return players end}
warn=function(text)error(text)end
local function colors(prefix)
 return {TorsoColor3=prefix..'torso',LeftArmColor3=prefix..'left',RightArmColor3=prefix..'right',HeadColor3=prefix..'head',LeftLegColor3=prefix..'leg',IsA=function(_,kind)return kind=='BodyColors'end}
end
local function character(palette,body)
 local c={class=palette,colors=body,ChildAdded=signal(),ChildRemoved=signal(),Destroying=signal(),changed=signal(),clothes={},accessories={},face={}}
 function c:GetAttribute(name)assert(name=='K0ClassId');return self.class end
 function c:GetAttributeChangedSignal(name)assert(name=='K0ClassId');return self.changed end
 function c:FindFirstChildOfClass(name)assert(name=='BodyColors');return self.colors end
 function c:SetClass(value)self.class=value;self.changed:Fire()end
 return c
end
local initial=colors('A')
local old=character('knight',initial)
local player={Parent=players,Character=old,loaded=false,CharacterAdded=signal(),CharacterRemoving=signal(),CharacterAppearanceLoaded=signal()}
function player:HasAppearanceLoaded()return self.loaded end
players.list={player}
local palette=dofile('src/server/Cosmetics/HeroPalette.luau')
assert(type(palette.start)=='function')
palette.start();palette.start()
assert(players.PlayerAdded:Count()==1 and old.changed:Count()==1,'start duplicates listeners')
assert(initial.TorsoColor3=='Atorso','colored before appearance loaded')
player.loaded=true;player.CharacterAppearanceLoaded:Fire(old)
assert(initial.TorsoColor3=='175,180,190' and initial.LeftArmColor3=='55,110,215')
assert(initial.HeadColor3=='Ahead' and initial.LeftLegColor3=='Aleg','unowned colors altered')
local clothes,face,accessories=old.clothes,old.face,old.accessories
old:SetClass('mage')
assert(initial.TorsoColor3=='90,50,140' and initial.RightArmColor3=='70,40,110')
old:SetClass(nil)
assert(initial.TorsoColor3=='Atorso' and initial.LeftArmColor3=='Aleft' and initial.RightArmColor3=='Aright','baseline lost across class change')
old:SetClass('priestess');assert(initial.TorsoColor3=='Atorso','unsupported class colored')
old:SetClass('elf');assert(initial.TorsoColor3=='70,140,70')
old.colors=nil;old.ChildRemoved:Fire(initial)
assert(initial.TorsoColor3=='Atorso','detached BodyColors not restored')
local replacement=colors('B');old.colors=replacement;old.ChildAdded:Fire(replacement)
assert(replacement.TorsoColor3=='70,140,70')
old:SetClass(nil);assert(replacement.TorsoColor3=='Btorso','replacement snapshot wrong')
old:SetClass('dwarf');assert(replacement.TorsoColor3=='130,90,55' and replacement.LeftArmColor3=='200,120,50')
player.CharacterRemoving:Fire(old)
assert(replacement.TorsoColor3=='Btorso' and old.changed:Count()==0,'old life cleanup failed')
local nextColors=colors('C');local nextChar=character(nil,nextColors)
player.Character=nextChar;player.loaded=false;player.CharacterAdded:Fire(nextChar)
player.CharacterAppearanceLoaded:Fire(old)
nextChar:SetClass('knight')
assert(nextColors.TorsoColor3=='Ctorso','old life late event authorized new life')
nextChar:SetClass(nil);player.loaded=true;player.CharacterAppearanceLoaded:Fire(nextChar)
assert(nextColors.TorsoColor3=='Ctorso','neutral lobby recolored')
nextChar:SetClass('knight');assert(nextColors.TorsoColor3=='175,180,190')
players.PlayerRemoving:Fire(player)
assert(nextColors.TorsoColor3=='Ctorso' and nextChar.changed:Count()==0 and player.CharacterAppearanceLoaded:Count()==0,'player exit cleanup failed')
nextChar:SetClass('mage');assert(nextColors.TorsoColor3=='Ctorso','disconnected player recolored')
assert(old.clothes==clothes and old.face==face and old.accessories==accessories,'avatar content was replaced')
print('PASS HeroPalette Lua mock lifecycle: delayed/current appearance, four palettes, neutral/unsupported, class restore, BodyColors replacement, late old event, life/player cleanup, idempotent start. Not Studio/device QA.')
