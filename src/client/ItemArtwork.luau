-- Small native 3D item illustrations. These are UI representations, not owned gear models.
local PotionIcon=require(script.Parent.PotionIcon)
local Sprites=require(script.Parent.ItemSprites)
local Artwork={}
local metal=Color3.fromRGB(190,208,224)
local gold=Color3.fromRGB(220,171,68)
local blue=Color3.fromRGB(27,84,171)
local leather=Color3.fromRGB(103,63,35)
local function block(model,name,size,position,color,rotation,shape)
	local part=Instance.new(shape=="wedge" and "WedgePart" or "Part")
	part.Name,part.Size,part.CFrame=name,size,CFrame.new(position)*CFrame.Angles(0,0,math.rad(rotation or 0))
	part.Color,part.Material,part.Anchored,part.CanCollide=color,Enum.Material.SmoothPlastic,true,false
	if shape=="ball" then part.Shape=Enum.PartType.Ball end
	part.Parent=model
	return part
end
function Artwork.create(parent,def,position,size)
	if def.potionTier then return PotionIcon.create(parent,def,position,size) end
	local sprite=Sprites.create(parent,def,position,size); if sprite then return sprite end
	local viewport=Instance.new("ViewportFrame")
	viewport.Name,viewport.Position,viewport.Size,viewport.BackgroundTransparency="ItemArtwork",position,size,1
	viewport.Ambient,viewport.LightColor,viewport.LightDirection=Color3.fromRGB(163,178,205),Color3.new(1,1,1),Vector3.new(-1,-2,-3)
	viewport:SetAttribute("DefinitionId",def.id); viewport.Parent=parent
	local model=Instance.new("Model"); model.Name="Illustration"; model.Parent=viewport
	local function p(name,x,y,z,px,py,pz,c,r,shape) return block(model,name,Vector3.new(x,y,z),Vector3.new(px,py,pz),c,r,shape) end
	local slot=def.slot
	if slot=="weapon" then
		p("Grip",.18,1.1,.2,0,-.8,0,leather,-28)
		if def.classId=="knight" then
			p("Blade",.3,2.1,.14,.45,.58,0,metal,-28); p("Tip",.3,.4,.14,1,1.7,0,metal,-28,"wedge")
			p("Guard",.95,.16,.24,.02,-.24,0,gold,-28); p("Gem",.21,.21,.25,.02,-.24,-.15,blue,45)
		elseif def.classId=="dwarf" then
			p("Shaft",.18,2.9,.18,0,0,0,leather,-25); p("AxeHead",1.35,.9,.24,.22,.93,0,metal,-25,"wedge"); p("AxeEdge",.24,1.1,.3,.72,.8,0,metal,-25)
		elseif def.classId=="elf" then
			for i=-3,3 do local angle=i*.29; p("BowLimb",.15,.5,.18,.6*math.cos(angle),i*.4,0,leather,-i*12) end
			p("BowString",.025,2.9,.025,.12,0,0,metal,0)
		else
			p("Staff",.16,2.7,.18,0,0,0,leather,-20); p("Crown",.65,.55,.35,.5,1.2,0,gold,-20); p("Crystal",.38,.55,.38,.56,1.55,0,Color3.fromRGB(128,97,235),20,"ball")
		end
	elseif slot=="offhand" then
		p("ShieldRim",1.9,2.3,.28,0,0,0,gold,0); p("ShieldFace",1.65,2,.34,0,.04,-.05,blue,0)
		p("Crest",.9,.9,.2,0,.15,-.3,metal,45); p("Sapphire",.35,.5,.22,0,.15,-.43,blue,0)
	elseif slot=="head" then
		p("Helmet",1.9,1.7,1.3,0,0,0,metal,0,"ball"); p("FaceOpening",1.28,.7,.22,0,-.32,-.64,Color3.fromRGB(17,27,43),0)
		p("NoseGuard",.18,1.1,.3,0,-.1,-.8,gold,0); p("CrownStripe",.2,1.5,1.35,0,.3,0,gold,0)
	elseif slot=="body" then
		p("Coat",1.7,2.1,.6,0,-.1,0,blue,0); p("Breastplate",1.25,1.3,.26,0,.2,-.4,metal,0)
		for _,x in ipairs({-.95,.95}) do p("Pauldron",.65,.55,.8,x,.85,0,gold,x*12) end
		p("Belt",1.8,.2,.72,0,-.65,-.05,leather,0); p("Buckle",.3,.3,.2,0,-.65,-.5,gold,0)
	elseif slot=="feet" or slot=="hands" then
		for _,x in ipairs({-.62,.62}) do
			p("Pair",.88,slot=="feet" and 1.65 or 1.1,.7,x,.1,0,metal,x*12)
			p("Cuff",.97,.24,.78,x,.85,0,gold,x*12)
			if slot=="feet" then p("Toe",.88,.45,1.15,x,-.72,-.24,leather,x*12) end
		end
	elseif slot=="accessory" then
		for i=1,12 do local a=i*math.pi/6; p("Ring",.38,.18,.22,math.sin(a)*.78,math.cos(a)*.78,0,gold,-i*30) end
		p("Stone",.62,.68,.4,0,.72,-.16,def.id=="amber_charm" and Color3.fromRGB(255,157,40) or blue,45)
	elseif def.id=="iron_ore" then
		p("Ore",1.4,1.3,1,0,-.25,0,metal,28,"wedge");p("OreFragment",.8,.9,.8,.8,-.45,0,Color3.fromRGB(128,150,172),-20,"wedge")
	else
		p("Hide",1.7,2,.12,0,0,0,Color3.fromRGB(164,114,65),-15)
		p("Fold",.25,2.1,.2,-.5,0,-.12,leather,-15)
	end
	local cf,bounds=model:GetBoundingBox()
	local camera=Instance.new("Camera"); camera.FieldOfView=32
	local distance=math.max(bounds.X,bounds.Y,bounds.Z)*1.9
	camera.CFrame=CFrame.lookAt(cf.Position+Vector3.new(distance*.12,distance*.08,-distance),cf.Position)
	camera.Parent=viewport; viewport.CurrentCamera=camera
	return viewport
end
return Artwork
