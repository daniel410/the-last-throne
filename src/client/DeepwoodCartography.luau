-- Surveyed scenery and roads, projected from campaign coordinates without 3D clones.
local Art={}
function Art.shape(parent,name,x,y,w,h,color,layer,round)
 local f=Instance.new('Frame');f.Name=name;f.BorderSizePixel=0;f.BackgroundColor3=color
 f.AnchorPoint=Vector2.new(.5,.5);f.Position=UDim2.fromScale(x,y);f.Size=UDim2.fromScale(w,h);f.ZIndex=layer;f.Parent=parent
 if round then local c=Instance.new('UICorner');c.CornerRadius=UDim.new(round,0);c.Parent=f end
 return f
end
local Survey=require(game.ReplicatedStorage.Shared.CampaignCartography)
-- Keep strong contrasts at HUD scale, while retaining the regional material palette.
local palettes={
 DW={Color3.fromRGB(85,113,65),Color3.fromRGB(198,177,119),Color3.fromRGB(85,98,83),Color3.fromRGB(39,77,47),Color3.fromRGB(171,173,132)},
 GW={Color3.fromRGB(47,71,60),Color3.fromRGB(155,163,126),Color3.fromRGB(73,92,89),Color3.fromRGB(24,51,43),Color3.fromRGB(132,156,145)},
 FV={Color3.fromRGB(199,220,230),Color3.fromRGB(114,166,185),Color3.fromRGB(75,111,142),Color3.fromRGB(44,91,104),Color3.fromRGB(141,175,201)},
 EC={Color3.fromRGB(67,53,57),Color3.fromRGB(160,128,107),Color3.fromRGB(39,36,45),Color3.fromRGB(87,59,59),Color3.fromRGB(129,110,115)},
 HG={Color3.fromRGB(81,96,91),Color3.fromRGB(163,165,148),Color3.fromRGB(58,64,85),Color3.fromRGB(40,58,57),Color3.fromRGB(155,164,179)},
}
function Art.region(parent,id,z,point,width,height,compact,line)
 local survey=Survey.zones[id];local colors=palettes[id:sub(1,2)]
 local center=point(z.center[1],z.center[3]);local sx,sy=z.size[1]/width,z.size[2]/height
 if compact then parent.BackgroundColor3=colors[3]end
 local n=Survey.resolution
 local function footprint(name,x,y,w,h,color,layer)
  local function tile(cx,cy,cw,ch)
   local f=Art.shape(parent,name,cx,cy,cw,ch,color,layer);f:SetAttribute('SurveyRegion',id);return f
  end
  if not compact then return tile(x,y,w,h)end
  -- UICorner rounds only its own background. Clip child footprints explicitly.
  local step=sy/n;local bottom=y+h/2;local top=y-h/2
  while top<bottom-.000001 do
   local nextY=math.min(bottom,top+step)
   local farY=math.max(math.abs(top-.5),math.abs(nextY-.5))
   if farY<.49 then
    local half=math.sqrt(.49*.49-farY*farY)
    local left,right=math.max(x-w/2,.5-half),math.min(x+w/2,.5+half)
    if right>left then tile((left+right)/2,(top+nextY)/2,right-left,nextY-top)end
   end
   top=nextY
  end
 end
 footprint('SurveyGround_'..id,center.X,center.Y,sx,sy,colors[1],2)
 for _,r in ipairs(survey.rects)do
  local color=r[5]==6 and Color3.fromRGB(66,156,183) or r[5]==7 and Color3.fromRGB(247,111,43) or colors[r[5]] or colors[5]
  local tile=footprint('SurveyFootprint',center.X+((r[1]+r[3]/2)/n-.5)*sx,center.Y+((r[2]+r[4]/2)/n-.5)*sy,r[3]/n*sx,r[4]/n*sy,color,3)
  if tile then tile:SetAttribute('SurfaceKind',r[5])end
 end
 for _,r in ipairs(survey.roads)do
  line('SurveyTrail',point(r[1],r[2]),point(r[3],r[4]),colors[2],compact and 1.5 or 2,4,nil,id,r[5])
 end
end
return Art
