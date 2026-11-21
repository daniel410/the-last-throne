assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local Motion=require(game.StarterPlayer.StarterPlayerScripts.Client.K0BowMotion)
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local c=Instance.new('Model');c.Name='ConfirmedReleaseAudit'
local h=Instance.new('Humanoid');h.Parent=c;c.Parent=workspace
local checks=0
local function check(v,m)checks+=1;assert(v,m)end
c:SetAttribute('K0ClassId','elf');c:SetAttribute('K0State','Attack');c:SetAttribute('K0AttackSeq',1)
c:SetAttribute('K0AttackStartedAt',100);c:SetAttribute('K0BasicAttackRate',1)
c:SetAttribute('K0ArrowReleaseProtocol',1)
local release=Config.BasicAttackProfiles.elf.attacks[1].windup
local pose=Motion.forCharacter(c,100+release+.02)
check(pose and pose.nocked,'predicted release must not erase the arrow before a real server shot')
check(pose.ikWeight==1,'hold the string at anchor while awaiting confirmation')
c:SetAttribute('K0ArrowRelease','0|100|100.8|7')
c:SetAttribute('K0ArrowVisual','7|0|0|0|0|0|-10')
check(Motion.forCharacter(c,100.81).nocked,'stale attack confirmation cannot release a newer draw')
c:SetAttribute('K0ArrowRelease','1|100|100.8|8')
check(Motion.forCharacter(c,100.81).nocked,'release metadata waits for the same projectile snapshot')
c:SetAttribute('K0ArrowVisual','8|0|0|0|0|0|-10')
check(not Motion.forCharacter(c,100.81).nocked,'actual matching projectile releases the held arrow')
c:SetAttribute('K0AttackSeq',2);c:SetAttribute('K0AttackStartedAt',102)
check(Motion.forCharacter(c,102.9).nocked,'old projectile cannot hide the next attack arrow')
c:SetAttribute('K0State','Dodge')
check(Motion.forCharacter(c,102.91)==nil,'interrupted draw produces no fake shot')
c:SetAttribute('K0State','Attack');c:SetAttribute('K0AttackSeq',3);c:SetAttribute('K0AttackStartedAt',104)
c:SetAttribute('K0ArrowRelease','3|104|104.9|9')
c:SetAttribute('K0ArrowVisual','9|0|0|0|0|0|-1')
check(not Motion.forCharacter(c,104.91).nocked,'close-range hit still releases normally')
-- Older servers without the protocol continue their existing timed motion.
c:SetAttribute('K0ArrowReleaseProtocol',nil);c:SetAttribute('K0AttackSeq',4);c:SetAttribute('K0AttackStartedAt',106)
check(not Motion.forCharacter(c,106+release+.02).nocked,'older server compatibility')
local heavy
for _,d in ipairs(Config.Skills.elf) do
 if d.id=='elf.marksman.heavy_draw' then heavy=d;break end
end
assert(heavy)
c:SetAttribute('K0ArrowReleaseProtocol',1);c:SetAttribute('K0SkillId',heavy.id)
c:SetAttribute('K0AttackSeq',5);c:SetAttribute('K0AttackStartedAt',108)
local due=108+heavy.windup
check(Motion.forCharacter(c,due+.05).nocked,'Heavy Draw holds the arrow through a delayed single pulse')
Motion.confirmPulse(c,heavy.id,1,4,due+.07,108,due+.07)
check(Motion.forCharacter(c,due+.07).nocked,'older sequence cannot release Heavy Draw')
Motion.confirmPulse(c,heavy.id,1,5,due+.09,108,due+.09)
check(not Motion.forCharacter(c,due+.1).nocked,'confirmed advanced single pulse releases the held arrow')
Motion.confirmPulse(c,heavy.id,1,5,due+.15,108,due+.15)
check(Motion.forCharacter(c,due+.16).time>.9,'duplicate pulse cannot replay the release')
c:Destroy()
print('ELF_CONFIRMED_RELEASE '..game.HttpService:JSONEncode({checks=checks,passed=true}))
