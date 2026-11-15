local H=require(game.StarterPlayer.StarterPlayerScripts.Client.StoryHeading)
local Text=require(game.ReplicatedStorage.Shared.K0Text)
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local report={checks=0,regions={}}
for _,e in ipairs(C.epics)do
 local title,subtitle=H.resolve({region=e.region})
 assert(title==string.upper(e.region),'authored region heading '..e.region)
 assert(subtitle==(e.region=='Deepwood'and Text.Subtitle or e.title),'authored epic subtitle '..e.region)
 report.checks+=2;report.regions[e.region]={title,subtitle}
end
local a,b=H.resolve(nil);assert(a==Text.TrainingTitle and b==Text.TrainingSubtitle);report.checks+=1
local x,y=H.resolve({region='Unknown'});assert(x==Text.Title and y==Text.Subtitle);report.checks+=1
return game.HttpService:JSONEncode(report)
