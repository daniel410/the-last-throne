-- Reuse the approved travel artwork only for server-confirmed cold checkpoints.
local Run=game:GetService('RunService')
local Actions=game:GetService('ContextActionService')
local Cover=require(script.Parent.TravelLoadingScreen)
local M={}
function M.start(player)
 local active,latest=nil,0
 local function close()
  if not active then return end
  active.gui:Destroy();active=nil
  Actions:UnbindAction('TLTCheckpointLoading')
  player:SetAttribute('TLTCheckpointLoading',false)
 end
 task.spawn(function()
  local remote=game.ReplicatedStorage:WaitForChild('Remotes'):WaitForChild('CheckpointTravelState')
  remote.OnClientEvent:Connect(function(stage,id,position)
   if stage=='Begin' then
    if type(id)~='number'or id<=latest then return end
    latest=id;close()
    local gui=Cover.create(1);gui.Name='CheckpointLoadingScreen';gui.Parent=player:WaitForChild('PlayerGui')
    active={id=id,gui=gui,character=player.Character,frames=0}
    player:SetAttribute('TLTCheckpointLoading',true)
    Actions:BindActionAtPriority('TLTCheckpointLoading',function()return Enum.ContextActionResult.Sink end,false,
     Enum.ContextActionPriority.High.Value,table.unpack(Enum.PlayerActions:GetEnumItems()))
   elseif active and active.id==id then
    if stage=='Cancelled'then close()
    elseif stage=='Arrived'and typeof(position)=='Vector3' then
     local state=active;state.position=position
     task.spawn(function()
      while active==state and not state.streamed do
       state.streamed=not workspace.StreamingEnabled or pcall(function()player:RequestStreamAroundAsync(position,5)end)
       if not state.streamed then task.wait(.5)end
      end
     end)
    end
   end
  end)
 end)
 Run.RenderStepped:Connect(function()
  local state=active;if not state then return end
  if player.Character~=state.character or player:GetAttribute('K0SessionPhase')~='Tutorial'then close();return end
  local character=state.character
  local root=character and character:FindFirstChild('HumanoidRootPart')
  local human=character and character:FindFirstChildOfClass('Humanoid')
  if human and human.Health<=0 then close();return end
  local camera=workspace.CurrentCamera
  local ready=state.position and state.streamed and root and human and (root.Position-state.position).Magnitude<12
   and character:GetAttribute('K0SpawnReady')==true and character:GetAttribute('TLTLocalAppearanceReady')==true
   and not player.GameplayPaused and camera and camera.CameraSubject==human and camera.CameraType==Enum.CameraType.Custom
   and (camera.Focus.Position-root.Position).Magnitude<16
  if ready then
   local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances={character};ray.RespectCanCollide=true
   ready=workspace:Raycast(root.Position,Vector3.new(0,-32,0),ray)~=nil
  end
  state.frames=ready and state.frames+1 or 0
  if state.frames>=3 then close()end
 end)
end
return M
