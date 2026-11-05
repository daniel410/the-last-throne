-- Reuse the pinned TD forest portal; never remove the invasion story portal.
local Shared=game:GetService('ReplicatedStorage').Shared
local Rules=require(Shared.CheckpointTravel)
local Content=require(Shared.CampaignContent)
local Env=require(script.Parent.DeepwoodEnvironment)
local Portal={}
function Portal.ensure(world,journal,onTravel)
 local target=Rules.report(journal)
 if not target or not world.spawns[target.zone]then return end
 local folder=world.folder:FindFirstChild('StoryCheckpointPortals')
 if not folder then folder=Instance.new('Folder');folder.Name='StoryCheckpointPortals';folder.Parent=world.folder end
 if folder:FindFirstChild('ErynReturnPortal')then return end
 local source
 for _,g in ipairs(Content.byId['DW-07'].goals)do if g.id=='separate'then source=g.activity.steps[#g.activity.steps].position end end
 if not source then return end
 local position=Vector3.new(table.unpack(source))+Vector3.new(14,0,0)
 local model=Env.portal(folder,position);model.Name='ErynReturnPortal'
 local anchor=Instance.new('Part');anchor.Name='TravelAnchor';anchor.Size=Vector3.new(2,2,2);anchor.Position=position+Vector3.new(0,3,0);anchor.Anchored=true;anchor.Transparency=1;anchor.CanCollide=false;anchor.CanTouch=false;anchor.CanQuery=false;anchor.Parent=model
 local prompt=Instance.new('ProximityPrompt');prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.KeyboardKeyCode=Enum.KeyCode.F;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.RequiresLineOfSight=false;prompt.MaxActivationDistance=14;prompt.HoldDuration=.4;prompt.ObjectText=Rules.text.portal;prompt.ActionText=Rules.text.use;prompt:SetAttribute('CheckpointTarget',target.id);prompt.Parent=anchor
 prompt.Triggered:Connect(function(player)
  local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
  if root and (root.Position-anchor.Position).Magnitude<=18 then onTravel(player,target.id)end
 end)
end
return Portal
