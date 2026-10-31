local Spec=require(game.ReplicatedStorage.Shared.LobbyFacilities).forge
local A=require(script.Parent.LobbyArchitecture)
local C=A.color
local W={}
function W.create(lobby)
 local model=Instance.new('Model');model.Name='DawnspireWeaponMerchant';model:SetAttribute('DawnspireFacility',true)
 local origin=lobby.origin+Spec.offset;local make=A.builder(model,origin)
 make('ShopFloor',Vector3.new(31,.28,28),Vector3.new(0,.15,0),C.stone,Enum.Material.Cobblestone,true)
 for _,x in ipairs({-14,14}) do
  for _,z in ipairs({-12,10}) do
   make('CanopyPost',Vector3.new(1,14,1),Vector3.new(x,7,z),C.wood,Enum.Material.Wood)
   make('PostFoot',Vector3.new(1.7,.6,1.7),Vector3.new(x,.3,z),C.dark,Enum.Material.Slate)
  end
 end
 make('WorkshopBack',Vector3.new(29,9,.65),Vector3.new(0,4.5,-12),C.wood,Enum.Material.WoodPlanks)
 -- Raised rear roof, open front workbench and approach.
 for _,x in ipairs({-1,1}) do
  make('BlueCanopy',Vector3.new(16,.6,20),Vector3.new(x*7,14.7,-2),C.blue,Enum.Material.Slate,false,CFrame.Angles(0,0,x*math.rad(-12)))
  make('GoldRoofTrim',Vector3.new(16,.3,.6),Vector3.new(x*7,14.7,8.1),C.gold,Enum.Material.Metal,false,CFrame.Angles(0,0,x*math.rad(-12)))
 end
 local counter=make('WeaponCounter',Vector3.new(14,3.4,2.5),Vector3.new(0,1.7,9),C.wood,Enum.Material.Wood,true)
 make('CounterTop',Vector3.new(15,.45,3),Vector3.new(0,3.5,9),C.dark,Enum.Material.Slate)
 local sign=make('ShopSign',Vector3.new(22,3.4,.55),Vector3.new(0,11,10.3),C.blue,Enum.Material.Wood);A.sign(sign,Spec)
 make('ShopSignTrim',Vector3.new(22.5,.3,.7),Vector3.new(0,12.85,10.3),C.gold,Enum.Material.Metal)
 make('AnvilBlock',Vector3.new(4,2.4,3.4),Vector3.new(-7,1.2,0),C.wood,Enum.Material.Wood)
 make('AnvilFoot',Vector3.new(4.4,.6,2.7),Vector3.new(-7,2.7,0),C.iron,Enum.Material.Metal)
 make('AnvilWaist',Vector3.new(2,1.3,1.7),Vector3.new(-7,3.5,0),C.iron,Enum.Material.Metal)
 make('AnvilTop',Vector3.new(5.5,.7,2.5),Vector3.new(-7,4.4,0),C.iron,Enum.Material.Metal)
 local horn=make('AnvilHorn',Vector3.new(2,.7,1),Vector3.new(-3.7,4.4,0),C.iron,Enum.Material.Metal);horn.Shape=Enum.PartType.Cylinder
 make('HammerHandle',Vector3.new(.3,3,.3),Vector3.new(-6.5,5.6,.6),C.wood,Enum.Material.Wood,false,CFrame.Angles(0,0,.5))
 make('HammerHead',Vector3.new(1.5,.7,.8),Vector3.new(-7.2,6.8,.6),C.iron,Enum.Material.Metal)
 -- Bounded emissions; the hearth has no damage or solid invisible volume.
 make('HearthBase',Vector3.new(8,1,7),Vector3.new(8,.5,-6),C.dark,Enum.Material.Brick)
 for _,x in ipairs({4.5,11.5}) do make('HearthSide',Vector3.new(1,5,7),Vector3.new(x,3,-6),C.stone,Enum.Material.Brick) end
 make('HearthBack',Vector3.new(8,5,1),Vector3.new(8,3,-9),C.dark,Enum.Material.Brick)
 make('HearthLintel',Vector3.new(8,1.5,7),Vector3.new(8,6,-6),C.stone,Enum.Material.Brick)
 make('Chimney',Vector3.new(4,9,4),Vector3.new(8,11,-7),C.dark,Enum.Material.Brick)
 local coals=make('ForgeCoals',Vector3.new(6,.3,4),Vector3.new(8,1.2,-5.5),C.fire,Enum.Material.Neon)
 A.light(coals,C.fire,18,1.5)
 local fire=Instance.new('Fire');fire.Name='ForgeFire';fire.Color=C.fire;fire.SecondaryColor=C.gold;fire.Heat=2;fire.Size=3;fire.Parent=coals
 local sparks=Instance.new('ParticleEmitter');sparks.Name='ForgeSparks';sparks.Texture='rbxasset://textures/particles/sparkles_main.dds';sparks.Rate=4;sparks.Lifetime=NumberRange.new(.4,.9);sparks.Speed=NumberRange.new(2,4);sparks.SpreadAngle=Vector2.new(15,15);sparks.Color=ColorSequence.new(C.fire);sparks.LightEmission=1;sparks.Size=NumberSequence.new(.13);sparks:SetAttribute('TLTDecorative',true);sparks.Parent=coals
 local smith=require(script.Parent.NPCVisual).create(model,'aldric',origin+Vector3.new(0,0,4),{yaw=math.pi})
 for _,x in ipairs({-10,10}) do
  local barrel=make('SupplyBarrel',Vector3.new(3.5,3,3),Vector3.new(x,1.8,7),C.wood,Enum.Material.Wood,false,CFrame.Angles(0,0,math.pi/2));barrel.Shape=Enum.PartType.Cylinder
 end
 local source=game.ServerStorage:FindFirstChild('TDPlayerWeaponModels')
 if source then local n=0;for _,original in ipairs(source:GetChildren()) do if original:IsA('Model') and n<4 then
  n+=1;local clone=original:Clone();clone.Name='TDWeaponDisplay'..n
  for _,v in ipairs(clone:GetDescendants()) do if v:IsA('BasePart') then v.Anchored=true;v.CanCollide=false;v.CanTouch=false;v.CanQuery=false;v:SetAttribute('TLTDecorative',true) elseif v:IsA('LuaSourceContainer') then v:Destroy() end end
  clone:ScaleTo(.65);clone:PivotTo(CFrame.new(origin+Vector3.new(-6+n*2.5,5,9)));clone.Parent=model
 end end end
 model.Parent=lobby.folder
 local prompt=A.prompt(counter,Spec);prompt.ObjectText='Aldric · Blacksmith'
 return {model=model,prompt=prompt,counter=counter,npc=smith}
end
return W
