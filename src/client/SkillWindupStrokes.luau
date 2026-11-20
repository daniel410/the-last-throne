-- Short preparation strokes in character-facing space, centered on a weapon socket.
-- Their dimensions carry no range or damage information.
local Windup = {}
local v = Vector3.new

function Windup.style(classId,d,motion,effect)
 if classId=="knight" then
  if motion=="shield" or motion=="counter" then return "ShieldBrace",4 end
  if motion=="thrust" then return "SwordPoint",2 end
  return "DrawnEdge",3
 elseif d.branch=="gunner" then
  if motion=="lob" then return "FuseCurl",3 end
  return motion=="mortar" and "MortarBrace" or "BoreBrackets",2
 elseif classId=="dwarf" then
  if motion=="throw" then return "AxeCoil",3 end
  return "RisingGrit",3
 elseif classId=="elf" then
  if effect=="lightning" then return "GatheringFork",4 end
  if d.branch=="magic_archer" then return "LeafDraw",4 end
  return d.form=="ground" and "HighDraw" or "SightDraw",2
 elseif effect=="lightning" then return "GatheringFork",4
 elseif effect=="frost" then return "CrystalTips",6
 elseif effect=="earth" or effect=="lava" then return "RisingGrit",3
 elseif effect=="fire" then return "EmberCurl",6
 elseif effect=="water" or effect=="steam" then return "WaterCurl",6 end
 return "WardPetals",6
end

function Windup.stroke(style,i,u,scale)
 local side=i%2==0 and -1 or 1
 local a,b
 if style=="ShieldBrace" then
  local x=side*(1.12-.33*u)
  local y=i<=2 and .72 or -.72
  a=v(x,y,-.42)
  b=v(x*.54,y+(i<=2 and -.24 or .24),-.42)
 elseif style=="SwordPoint" or style=="SightDraw" or style=="HighDraw"
  or style=="BoreBrackets" or style=="MortarBrace" then
  local spread=side*((style=="MortarBrace" and .83 or .6)-.35*u)
  local climb=style=="HighDraw" and u*.54 or 0
  local length=style=="BoreBrackets" and .38 or style=="SightDraw" and 1.1 or .65
  a=v(spread,climb,style=="SightDraw" and -.32 or .28)
  b=v(spread*.48,climb+.12,-length)
 elseif style=="RisingGrit" then
  local x=(i-2)*(.73-.45*u)
  local y=-.96+u*.94-i%2*.3
  a=v(x,y,i%2*.4)
  b=v(x*.78,y+.38,-.2)
 elseif style=="GatheringFork" then
  local x=side*(.9-.57*u)
  local y=i<=2 and .62 or -.42
  local joint=v(x*.54,side*.17,.11)
  a=i<=2 and v(x,y,.14) or joint
  b=i<=2 and joint or v(side*.08,.05,-.12)
 elseif style=="CrystalTips" or style=="LeafDraw" or style=="WardPetals" then
  local lane=math.ceil(i/2)
  local angle=lane*math.pi*2/3
  local radial=v(math.cos(angle),math.sin(angle),0)
  local tangent=v(-radial.Y,radial.X,0)
  local radius=.97-.55*u
  a=radial*radius
  b=radial*(radius-.28)+tangent*(side*.21)-v(0,0,.15)
 else
  local turn=(style=="WaterCurl" and -1 or 1)*u*2.9
  local radius=.79-.44*u
  local angle=i*2.39996+turn
  local function curl(t)
   local height=style=="EmberCurl" and u*.82+(t-angle)*.5 or (t-angle)*.24
   if style=="WaterCurl" or style=="AxeCoil" then
    return v(math.cos(t)*radius,height,math.sin(t)*radius)
   end
   return v(math.cos(t)*radius,math.sin(t)*radius+height,-.08)
  end
  a,b=curl(angle),curl(angle+.51)
 end
 return a*scale,b*scale
end

return Windup
