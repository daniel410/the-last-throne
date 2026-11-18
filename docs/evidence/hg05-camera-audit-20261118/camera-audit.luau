local origin=Vector3.new(-270,197,-17330)
local aim=Vector3.new(-285,190,-17359)
local camera=CFrame.lookAt(origin,aim)
local root=workspace.DeepwoodCampaign.CampaignExpansion.Epic5
local out={}
for _,key in ipairs({'HG-05_exp_1','HG-05_exp_2'})do
 local beam=root[key]:FindFirstChild('ShieldBeam',true)
 assert(beam,'Missing beam '..key)
 local delta=beam.Position-origin
 local depth=delta:Dot(camera.LookVector)
 local corrected=beam.Position+Vector3.new(15,9,29)
 table.insert(out,{scene=key,beam=tostring(beam.Position),oldDepth=depth,oldCenterInFront=depth>0,correctedOrigin=tostring(corrected),correctedAim=tostring(beam.Position),canQuery=beam.CanQuery})
end
assert(out[1].oldDepth<0,'Previous western center unexpectedly in front')
return game:GetService('HttpService'):JSONEncode(out)
