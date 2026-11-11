-- Reuse approved cage/NPC art; clients project only their own saved rescue state.
local T={}
function T.prepare()
 local RS=game.ReplicatedStorage
 if RS:FindFirstChild('CaptiveSceneTemplates')then return end
 local folder=Instance.new('Folder');folder.Name='CaptiveSceneTemplates'
 local cage=require(script.Parent.StoryProps).build(folder,'PrisonCage',Vector3.zero)
 local door=Instance.new('Model');door.Name='RescueDoor';door.Parent=cage
 local hardware={DoorHasp=true,CaptiveDoorLock=true,LockShackle=true,LockKeyhole=true,ForgedDoorHinge=true}
 for _,p in ipairs(cage:GetChildren())do if p:IsA('BasePart')and
  ((p.Name=='DoorPrisonBar'or p.Name=='FrontIronRail')and p.Position.Z>0 or hardware[p.Name])then p.Parent=door end end
 door.WorldPivot=CFrame.new(-3.8,0,4.23)
 door:SetAttribute('ClosedLocalPivot',door:GetPivot())
 for _,spec in ipairs({{'spirit','Freed Forest Spirit',true},{'prisoners','Freed Prisoner',false},{'rescue_captives','Altar Captive',false}})do
  local actor=require(script.Parent.NPCVisual).actor(folder,spec[2],Vector3.zero,spec[3]);actor.Name=spec[1]
 end
 for _,p in ipairs(folder:GetDescendants())do assert(not p:IsA('LuaSourceContainer'),'no executable template content')end
 folder.Parent=RS
end
return T
