-- Check the pose that the actual character renderer selects for every action.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local client=game.StarterPlayer.StarterPlayerScripts.Client
local config=require(game.ReplicatedStorage.Shared.K0Config)
local visual=require(client.K0SwordVisual)
local bow=require(client.K0BowMotion)
local mage=require(client.K0MageMotion)
local report={checks=0,actions=0,rigs={},maxRedrawJumpDegrees=0}
local function check(value,label)
    report.checks+=1
    assert(value,label)
end
for _,rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15} do
    local desc=Instance.new("HumanoidDescription")
    local actor=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig)
    desc:Destroy()
    actor.Parent=workspace
    actor.HumanoidRootPart.Anchored=true
    table.insert(report.rigs,rig.Name)
    for _,classId in {"elf","mage"} do
        local motion=classId=="elf" and bow or mage
        actor:SetAttribute("K0ClassId",classId)
        local actions={config.BasicAttackProfiles[classId].attacks[1]}
        for _,d in config.Skills[classId] do table.insert(actions,d) end
        local silhouettes={}
        for i,d in actions do
            actor:SetAttribute("K0State","Dodge")
            motion.forCharacter(actor,99)
            actor:SetAttribute("K0State","Attack")
            actor:SetAttribute("K0AttackStartedAt",100)
            actor:SetAttribute("K0AttackSeq",i)
            actor:SetAttribute("K0SkillId",d.id)
            actor:SetAttribute("K0AttackKind",d.magic and "Arcane" or "Basic")
            actor:SetAttribute("K0AttackPhase","Windup")
            local pose=assert(visual.renderArms(actor,1/60,100+d.windup*.55))
            check(pose.right and pose.left and pose.angles.rightKnee.X>1,"Missing planted preparation")
            silhouettes[d.id or "basic"]=pose.angles.torso
            report.actions+=1
            if d.id=="elf.common.rapid" then
                actor:SetAttribute("K0RapidShotCount",0)
                local held=motion.forCharacter(actor,100+d.windup+.03)
                check(held.nocked and held.draw>.99,"Hold rapid anchor before confirmed release")
                actor:SetAttribute("K0RapidShotCount",1)
                actor:SetAttribute("K0RapidShotAt",100+d.windup)
                local t=100+d.windup+.04
                local a,b=motion.forCharacter(actor,t-.00001),motion.forCharacter(actor,t+.00001)
                for _,joint in {"right","elbow","wrist","torso","left","weapon"} do
                    local delta=(a.angles[joint]-b.angles[joint]).Magnitude
                    report.maxRedrawJumpDegrees=math.max(report.maxRedrawJumpDegrees,delta)
                    check(delta<.25,"Release/redraw seam "..joint)
                end
                check(not b.nocked and motion.forCharacter(actor,t+.04).nocked,"Re-nock after the release hand starts back")
            end
        end
        local function distinct(first,second)
            check((silhouettes[first]-silhouettes[second]).Magnitude>10,"Distinct preparations "..first.." / "..second)
        end
        if classId=="elf" then
            distinct("elf.marksman.heavy_draw","elf_retreating_shot")
            distinct("elf.marksman.grand_volley","elf.magic_archer.spirit_arrowfall")
        else
            distinct("mage.pyro.ember_lance","mage.cryo.frost_lance")
            distinct("mage.cryo.frost_lance","mage.cryo.thunder_spear")
            distinct("mage.pyro.caldera_s_judgment","mage.cryo.eternal_tempest")
        end
    end
    actor:Destroy()
end
report.pass=true
print("RANGED_ACTION_POSES_NATIVE "..game.HttpService:JSONEncode(report))
