local Projection=require(game:GetService('ReplicatedStorage').Shared.PartyMapProjection)
local Theme=require(script.Parent.TDInventoryTheme)
local M={}
function M.create(parent,project,compact)
 local nodes={}
 local function remove(id)nodes[id].root:Destroy();nodes[id]=nil end
 local function update(members)
  local seen={}
  for _,member in ipairs(members or {})do
   local point=Projection.position(member,project,compact)
   if point and type(member.userId)=='number'and not seen[member.userId]then
    seen[member.userId]=true
    local node=nodes[member.userId]
    if not node then
     local size=compact and 18 or 22
     local root=Instance.new('Frame');root.Name='PartyMember_'..member.userId;root.AnchorPoint=Vector2.new(.5,.5);root.Size=UDim2.fromOffset(size,size);root.BorderSizePixel=0;root.ZIndex=11;root.Parent=parent
     local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(1,0);corner.Parent=root
     local outline=Instance.new('UIStroke');outline.Color=Color3.fromRGB(4,22,20);outline.Thickness=2;outline.Parent=root
     local number=Theme.label(root,'Number','',UDim2.new(),UDim2.fromScale(1,1),compact and 11 or 13,Color3.fromRGB(4,22,20));number.TextXAlignment=Enum.TextXAlignment.Center;number.Font=Enum.Font.GothamBold;number.ZIndex=12
     local arrow=Theme.label(root,'Direction','›',UDim2.fromScale(.5,.5),UDim2.fromOffset(16,16),20,Theme.color.text);arrow.AnchorPoint=Vector2.new(.5,.5);arrow.TextXAlignment=Enum.TextXAlignment.Center;arrow.ZIndex=12
     local name=Theme.label(root,'PartyName','',UDim2.fromOffset(size+4,-3),UDim2.fromOffset(136,30),11,Theme.color.text);name.TextStrokeTransparency=0;name.TextTruncate=Enum.TextTruncate.AtEnd;name.ZIndex=12;name.Visible=not compact
     node={root=root,number=number,arrow=arrow,name=name};nodes[member.userId]=node
    end
    node.root.Position=UDim2.fromScale(point.x,point.y);node.root.BackgroundColor3=point.downed and Color3.fromRGB(255,164,82)or Color3.fromRGB(113,235,137)
    node.number.Text=point.downed and '+'or tostring(member.slot or '')
    node.arrow.Visible=point.outside;node.arrow.Rotation=point.angle
    local angle=math.rad(point.angle);node.arrow.Position=UDim2.new(.5,math.cos(angle)*15,.5,math.sin(angle)*15)
    node.name.Text=tostring(member.name or '')..(point.downed and ' · '..Projection.text.downed or '')..(point.outside and ' · '..Projection.text.outside or '')
    node.name.AnchorPoint=Vector2.new(point.x>.6 and 1 or 0,.5);node.name.Position=UDim2.new(point.x>.6 and 0 or 1,point.x>.6 and -5 or 5,.5,0)
   end
  end
  for id in pairs(nodes)do if not seen[id]then remove(id)end end
 end
 return {nodes=nodes,update=update}
end
return M
