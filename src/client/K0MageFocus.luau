-- One local emitter and short-range light per equipped staff; no physics parts.
-- Charge follows the authored clip. Flash is called only for a server shot.
local Focus={}
local states=setmetatable({},{__mode="k"})
local colors={arcane=Color3.fromRGB(178,138,255),gravity=Color3.fromRGB(146,85,232),water=Color3.fromRGB(85,190,255),wind=Color3.fromRGB(155,242,220),fire=Color3.fromRGB(255,138,62),frost=Color3.fromRGB(170,230,255),earth=Color3.fromRGB(230,177,100),lightning=Color3.fromRGB(197,180,255)}
function Focus.clear(model)
 local s=states[model];if not s then return end
 s.emitter.Rate=0;s.emitter:Clear();s.light.Enabled=false
 if s.stone and s.stone.Parent then s.stone.Color=s.color end
end
function Focus.render(model,pose,hidden)
 if not pose or hidden then Focus.clear(model);return end
 local s=states[model]
 if not s then
  local tip=model:FindFirstChild("WeaponTip",true);if not tip or not tip:IsA("Attachment") then return end
  local emitter=Instance.new("ParticleEmitter");emitter.Name="K0StaffFocus";emitter.Texture="rbxasset://textures/particles/sparkles_main.dds"
  emitter.Rate=0;emitter.Lifetime=NumberRange.new(.16,.24);emitter.Speed=NumberRange.new(.15,.45);emitter.SpreadAngle=Vector2.new(180,180)
  emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.14),NumberSequenceKeypoint.new(1,0)})
  emitter.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.2),NumberSequenceKeypoint.new(1,1)})
  emitter.LightEmission=1;emitter.Parent=tip
  local light=Instance.new("PointLight");light.Name="K0StaffFocusLight";light.Range=5;light.Shadows=false;light.Enabled=false;light.Parent=tip
  local stone=model:FindFirstChild("SmallCrystal",true)
  s={emitter=emitter,light=light,stone=stone,color=stone and stone.Color};states[model]=s
 end
 local amount=math.clamp(pose.focus or 0,0,1);local color=colors[pose.element] or colors.arcane
 s.emitter.Color=ColorSequence.new(color);s.emitter.Rate=8*amount
 s.light.Color=color;s.light.Brightness=1.4*amount;s.light.Enabled=amount>.03
 if s.stone and s.stone.Parent then s.stone.Color=s.color:Lerp(color,amount*.85) end
end
function Focus.flash(model)
 local s=states[model];if s and model.Parent and model.Parent:GetAttribute("TLTEquippedWeapon")~="" then s.emitter:Emit(10) end
end
return Focus
