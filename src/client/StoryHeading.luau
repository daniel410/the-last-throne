-- Resolve the story region from authored campaign metadata, including later epics.
local Shared=game:GetService('ReplicatedStorage').Shared
local Content=require(Shared.CampaignContent)
local Text=require(Shared.K0Text)
local H={}
function H.resolve(story)
 if not story then return Text.TrainingTitle,Text.TrainingSubtitle end
 for _,epic in ipairs(Content.epics)do
  if epic.region==story.region then
   return string.upper(epic.region),epic.region=='Deepwood'and Text.Subtitle or epic.title
  end
 end
 return Text.Title,Text.Subtitle
end
return H
