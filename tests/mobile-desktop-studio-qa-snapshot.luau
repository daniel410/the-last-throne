-- Snapshot only existing basic menus/icons; detailed windows intentionally excluded.
local p=game.Players.LocalPlayer
local report={viewport=tostring(workspace.CurrentCamera.ViewportSize),touch=game:GetService('UserInputService').TouchEnabled,objects={}}
local function collect(root)
 if not root then return end
 local all={root};for _,v in root:GetDescendants()do table.insert(all,v)end
 for _,v in all do
  if v:IsA('GuiObject') then
   local key=v:GetFullName():gsub('^Players%.[^.]+%.PlayerGui%.','')
   local data={class=v.ClassName,parent=v.Parent.Name,position=tostring(v.Position),size=tostring(v.Size),absolutePosition=tostring(v.AbsolutePosition),absoluteSize=tostring(v.AbsoluteSize)}
   if v:IsA('ImageLabel') or v:IsA('ImageButton') then data.image=v.Image;data.cropOffset=tostring(v.ImageRectOffset);data.cropSize=tostring(v.ImageRectSize);data.scaleType=v.ScaleType.Name end
   report.objects[key]=data
  elseif v:IsA('UIScale')then report.objects[v:GetFullName():gsub('^Players%.[^.]+%.PlayerGui%.','')]={scale=v.Scale} end
 end
end
collect(p.PlayerGui:FindFirstChild('LobbyTopMenu'))
local top=p.PlayerGui:FindFirstChild('DeepwoodTopHud');collect(top and top.Root:FindFirstChild('Minimap'))
return report
