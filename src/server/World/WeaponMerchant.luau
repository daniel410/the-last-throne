local W={}
function W.create(lobby)
 local model=Instance.new('Model');model.Name='DawnspireWeaponMerchant';model.Parent=lobby.folder
 local origin=lobby.origin+Vector3.new(-35,0,8)
 local function part(name,size,offset,color)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.Position=origin+offset;p.Color=color;p.Anchored=true;p.Parent=model;return p
 end
 part('ShopFloor',Vector3.new(20,.3,15),Vector3.new(0,.2,0),Color3.fromRGB(105,94,73))
 local counter=part('WeaponCounter',Vector3.new(14,4,3),Vector3.new(0,2,0),Color3.fromRGB(92,55,30))
 for _,x in ipairs({-8,8}) do part('CanopyPost',Vector3.new(.8,12,.8),Vector3.new(x,6,1),Color3.fromRGB(71,49,31)) end
 part('BlueCanopy',Vector3.new(19,.7,10),Vector3.new(0,12,0),Color3.fromRGB(20,55,116))
 part('GoldTrim',Vector3.new(19,.5,.5),Vector3.new(0,11.6,5),Color3.fromRGB(235,184,55))
 local keeper=part('Merchant',Vector3.new(2,3,1.2),Vector3.new(0,3,-4),Color3.fromRGB(85,115,157))
 local head=part('MerchantHead',Vector3.new(1.7,1.7,1.7),Vector3.new(0,5.4,-4),Color3.fromRGB(219,183,132));head.Shape=Enum.PartType.Ball
 local sign=Instance.new('BillboardGui');sign.Name='ShopSign';sign.Size=UDim2.fromOffset(230,56);sign.StudsOffsetWorldSpace=Vector3.new(0,10,0);sign.Parent=counter
 local text=Instance.new('TextLabel');text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Text='DAWNSPIRE ARMORY\nBUY / SELL WEAPONS';text.TextColor3=Color3.fromRGB(255,220,112);text.TextStrokeTransparency=.15;text.TextSize=18;text.Font=Enum.Font.GothamBold;text.Parent=sign
 local source=game.ServerStorage:FindFirstChild('TDPlayerWeaponModels')
 if source then local n=0;for _,original in ipairs(source:GetChildren()) do if original:IsA('Model') and n<4 then
  n+=1;local clone=original:Clone();clone.Name='TDWeaponDisplay'..n
  for _,v in ipairs(clone:GetDescendants()) do if v:IsA('BasePart') then v.Anchored=true;v.CanCollide=false;v.CanTouch=false;v.CanQuery=false elseif v:IsA('Script') or v:IsA('LocalScript') then v:Destroy() end end
  clone:ScaleTo(.6);clone:PivotTo(CFrame.new(origin+Vector3.new(-6+n*2.5,5.5,0)));clone.Parent=model
 end end end
 local prompt=Instance.new('ProximityPrompt');prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.ObjectText='Dawnspire Armory';prompt.ActionText='Buy or sell weapons';prompt.KeyboardKeyCode=Enum.KeyCode.F;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=false;prompt.Parent=counter
 return {model=model,prompt=prompt,counter=counter}
end
return W
