-- Shared lobby window footprint; retain each panel's battle layout outside the lobby.
local Layout={}
function Layout.bind(panel,player)
 local host=panel.Parent
 local limit=panel:FindFirstChildOfClass('UISizeConstraint') or Instance.new('UISizeConstraint')
 limit.Parent=panel
 local original={size=panel.Size,position=panel.Position,anchor=panel.AnchorPoint,max=limit.MaxSize}
 local function resize()
  if player and player:GetAttribute('K0SessionPhase')~='Lobby' then
   panel.Size=original.size;panel.Position=original.position;panel.AnchorPoint=original.anchor;limit.MaxSize=original.max
   return
  end
  local height=host.AbsoluteSize.Y
  local short=height>0 and (height<400 or host.AbsoluteSize.X<720)
  panel.AnchorPoint=Vector2.new(.5,.5)
  panel.Size=short and UDim2.new(1,-24,1,-24)or UDim2.new(1,-120,1,-164)
  panel.Position=short and UDim2.fromScale(.5,.5)or UDim2.new(.5,0,.5,58)
  limit.MaxSize=Vector2.new(800,510)
 end
 local connections={host:GetPropertyChangedSignal('AbsoluteSize'):Connect(resize)}
 if player then table.insert(connections,player:GetAttributeChangedSignal('K0SessionPhase'):Connect(resize)) end
 panel.Destroying:Connect(function()for _,connection in ipairs(connections)do connection:Disconnect()end end)
 resize()
end
return Layout
