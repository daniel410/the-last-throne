-- The fixture supplies the frozen previous Overhead at semantic anchors.
-- This catches a diagonal/basic fallback even when regenerated golden data passes.
local M=require(game.StarterPlayer.StarterPlayerScripts.Client.K0MeleeMotion)
local clips=require(game.StarterPlayer.StarterPlayerScripts.Client.K0DwarfMixamoClips)
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local report={kind='DWARF_OVERHEAD_REMAP_NATIVE',checks=0,pass=false}
local function check(v,label)report.checks+=1;assert(v,label)end
for _,row in previousOverheadAnchors do
 local rig=row.rig=='R6'and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
 local d=Config.BasicAttackProfiles.dwarf.attacks[1]
 local age=row.age*(d.windup+d.active+d.recovery)/clips.basic.duration
 local p=M.sample('dwarf',1,age,nil,nil,nil,rig)
 for ch,a in row.angles do check((p.angles[ch]-Vector3.new(unpack(a))).Magnitude<.001,'Prior attack anchors retained with relaxed final pose '..row.rig..'/'..ch)end
end
check(clips.basic.duration<previousOverheadDuration,'Previous overhead is faster as a basic attack')
check(clips.skills['dwarf.common.overhead'].source=='Standing Melee Combo Attack Ver. 1','Overhead uses downloaded combo source')
local definition=Config.Skills.dwarf[1]
check(definition.windup+definition.hitDelay==.71,'Existing single authoritative impact retained')
local function distance(a,b)local sum=0;for ch,v in a.angles do sum+=(v-b.angles[ch]).Magnitude end;return sum end
local a=M.sample('dwarf',1,.2925,nil,nil,definition.id,Enum.HumanoidRigType.R15)
local b=M.sample('dwarf',1,.50,nil,nil,definition.id,Enum.HumanoidRigType.R15)
local c=M.sample('dwarf',1,.71,nil,nil,definition.id,Enum.HumanoidRigType.R15)
check(distance(a,b)>80 and distance(b,c)>80,'Combo contains distinct preparation and second striking motion')
report.pass=true;print('DWARF_OVERHEAD_REMAP_NATIVE '..game.HttpService:JSONEncode(report))
