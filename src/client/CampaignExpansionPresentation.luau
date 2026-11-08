-- Personal incident results; shared floors/collision and server progress never change.
local M={}
local models={};local current
local function paint(m)
 if not m.Parent then models[m]=nil;return end
 local s=current and not current.training and current.journal
 local event=m:GetAttribute('ExpansionEvent');local chapter=m:GetAttribute('ExpansionChapter')
 local restored=s and (s.flags[event]==true or s.clears[chapter]==true)or false
 local visible=m:GetAttribute('ExpansionAfter')==restored
 for _,v in ipairs(m:GetDescendants())do
  if v:IsA('BasePart')then v.Transparency=visible and (v:GetAttribute('ExpansionTransparency')or 0)or 1
  elseif v:IsA('BillboardGui')or v:IsA('PointLight')or v:IsA('ProximityPrompt')then v.Enabled=visible end
 end
end
local started=false
local function start()
 if started then return end;started=true
 local function add(v)if v:IsA('Model')and v:GetAttribute('ExpansionEvent')then models[v]=true;paint(v)end end
 for _,v in ipairs(workspace:GetDescendants())do add(v)end
 workspace.DescendantAdded:Connect(add)
 workspace.DescendantRemoving:Connect(function(v)models[v]=nil end)
end
function M.update(value)
 current=value;start()
 for m in pairs(models)do paint(m)end
 require(script.Parent.DeepwoodAtmosphere).restoration(value and value.journal)
end
return M
