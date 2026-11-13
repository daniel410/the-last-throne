-- Production uses monotonic combat time and absolute replicated pose time.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local source=game.ServerScriptService.Server.Combat.CombatService
local copy=source:Clone();copy.Name='PublicClockQA'
copy.Source=copy.Source:gsub('return CombatService%s*$',[[return {shot=applyArrowShot,setFolder=function(v)enemyFolder=v end}]])
copy.Parent=source.Parent
local api=require(copy)
local Bow=require(game.StarterPlayer.StarterPlayerScripts.Client.K0BowMotion)
local d=require(game.ReplicatedStorage.Shared.K0Config).BasicAttackProfiles.elf.attacks[1]
local folder=Instance.new('Folder');folder.Parent=workspace;api.setFolder(folder)
local c=Instance.new('Model');c.Parent=folder
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Position=Vector3.new(20000,1000,20000);root.Parent=c
local h=Instance.new('Humanoid');h.RequiresNeck=false;h.Parent=c
c:SetAttribute('K0ClassId','elf');c:SetAttribute('K0State','Attack');c:SetAttribute('K0AttackSeq',1)
c:SetAttribute('K0ArrowReleaseProtocol',1);c:SetAttribute('K0AttackStartedAt',1794600000)
local state={character=c,root=root,humanoid=h,baseClassId='elf',arrowSeq=0,feedbackSeq=0,attackSeq=1,
 attack={started=100,definition=d,direction=Vector3.new(0,0,-1),hits={},hitCount=0,maxTargets=1,maxHeight=10}}
api.shot(state,100+d.windup)
local packet=string.split(c:GetAttribute('K0ArrowRelease'),'|');local checks=0
local function check(v,m)checks+=1;assert(v,m)end
local ok,err=xpcall(function()
 check(math.abs(tonumber(packet[2])-1794600000)<.002,'Public start is not the unrelated monotonic combat clock')
 check(math.abs(tonumber(packet[3])-(1794600000+d.windup))<.002,'Release uses the same absolute clock as the visible draw')
 check(not Bow.forCharacter(c,1794600000+d.windup+.02).nocked,'Real server packet releases the held arrow when clocks have different epochs')
end,debug.traceback)
copy:Destroy();folder:Destroy()
print('ARROW_PUBLIC_CLOCK_NATIVE '..game.HttpService:JSONEncode({pass=ok,checks=checks,error=err}));assert(ok,err)
