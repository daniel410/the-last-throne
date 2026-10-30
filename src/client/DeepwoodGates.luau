local RS=game:GetService('ReplicatedStorage')
local Content=require(RS.Shared.DeepwoodContent)
local Access=require(RS.Shared.DeepwoodAccess)
local Gates={}
function Gates.create()
 local folder=Instance.new('Folder');folder.Name='PersonalStoryGates';folder.Parent=workspace
 local gates={}
 for _,edge in ipairs(Access.edges) do
  local a,b=Content.zones[edge[1]],Content.zones[edge[2]];local first,second=Vector3.new(table.unpack(a.center)),Vector3.new(table.unpack(b.center));local middle=(first+second)/2
  local part=Instance.new('Part');part.Name='SealedRoad';part.Size=Vector3.new(30,14,1);part.CFrame=CFrame.lookAt(middle+Vector3.new(0,7,0),second+Vector3.new(0,7,0));part.Material=Enum.Material.ForceField;part.Color=Color3.fromRGB(135,171,211);part.Anchored=true;part.CanTouch=false;part.CanQuery=false;part.CastShadow=false;part.CanCollide=false;part.Transparency=1;part.Parent=folder
  local gui=Instance.new('BillboardGui');gui.Size=UDim2.fromOffset(240,60);gui.Enabled=false;gui.MaxDistance=75;gui.StudsOffset=Vector3.new(0,4,0);gui.Parent=part
  local text=Instance.new('TextLabel');text.BackgroundTransparency=1;text.Size=UDim2.fromScale(1,1);text.Font=Enum.Font.GothamBold;text.TextSize=15;text.TextColor3=Color3.fromRGB(255,231,161);text.TextStrokeTransparency=.2;text.Text=string.format('ROAD SEALED\nComplete Story %d',b.requiresMain);text.AutoLocalize=false;text.Parent=gui
  table.insert(gates,{part=part,gui=gui,required=b.requiresMain})
 end
 return {update=function(current)
  local main=current and current.journal.main or 0
  local active=current and not current.training
  for _,g in ipairs(gates) do local locked=active and main<g.required;g.part.CanCollide=locked==true;g.part.Transparency=locked and .3 or 1;g.gui.Enabled=locked==true end
 end,destroy=function() folder:Destroy() end}
end
return Gates
