local RS=game:GetService('ReplicatedStorage')
local Http=game:GetService('HttpService')
local T=require(script.Parent.TDInventoryTheme)
local Menu=require(script.Parent.HeroMenuChrome)
local Copy=require(RS.Shared.DailyLoginText)
local Rules=require(RS.Shared.DailyLogin)
local V={}
function V.create(parent,send)
 local panel=Menu.frame(parent,'DailyLogin',UDim2.fromScale(.5,.5),UDim2.new(1,-32,1,-100));panel.AnchorPoint=Vector2.new(.5,.5);panel.Visible=false
 require(script.Parent.LobbyPanelLayout).bind(panel)
 T.label(panel,'Title',Copy.Title,UDim2.fromOffset(20,10),UDim2.new(1,-88,0,32),21,T.color.gold)
 local close=T.button(panel,'Close',Copy.Close,UDim2.new(1,-60,0,8),UDim2.fromOffset(44,44));close.Activated:Connect(function()panel.Visible=false end)
 T.label(panel,'Subtitle',Copy.Subtitle,UDim2.fromOffset(20,48),UDim2.new(1,-40,0,38),12,T.color.muted)
 local grid=Instance.new('ScrollingFrame');grid.Name='Days';grid.Position=UDim2.fromOffset(16,92);grid.Size=UDim2.new(1,-32,1,-200);grid.BackgroundTransparency=1;grid.BorderSizePixel=0;grid.ScrollBarThickness=5;grid.AutomaticCanvasSize=Enum.AutomaticSize.Y;grid.CanvasSize=UDim2.new();grid.Parent=panel
 local layout=Instance.new('UIGridLayout');layout.CellPadding=UDim2.fromOffset(8,8);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=grid
 local cells={}
 for i=1,7 do
  local cell=T.frame(grid,'Day'..i,UDim2.new(),UDim2.new());cell.LayoutOrder=i
  local title=T.label(cell,'Day',string.format(Copy.Day,i),UDim2.fromOffset(4,6),UDim2.new(1,-8,0,23),12,T.color.text);title.TextXAlignment=Enum.TextXAlignment.Center
  T.icon(cell,'gold',UDim2.new(.5,-18,0,31),UDim2.fromOffset(36,36))
  local reward=T.label(cell,'Reward',string.format(Copy.Reward,Rules.rewards[i]),UDim2.fromOffset(4,68),UDim2.new(1,-8,0,24),12,T.color.gold);reward.TextXAlignment=Enum.TextXAlignment.Center
  local status=T.label(cell,'Status',Copy.Unknown,UDim2.fromOffset(4,96),UDim2.new(1,-8,0,22),10,T.color.muted);status.TextXAlignment=Enum.TextXAlignment.Center
  cells[i]={frame=cell,status=status,reward=reward}
 end
 local message=T.label(panel,'Status','',UDim2.new(0,20,1,-102),UDim2.new(1,-40,0,40),12,T.color.muted)
 local claim=T.button(panel,'Claim',Copy.Loading,UDim2.new(0,16,1,-54),UDim2.new(1,-32,0,44),true)
 local state={status='Loading'};local pending,waiting,feedback=nil,false,''
 local function layoutGrid()
  local width=grid.AbsoluteSize.X;local columns=width>=650 and 7 or width>=380 and 4 or 3
  layout.CellSize=UDim2.new(1/columns,-8,0,124)
 end
 grid:GetPropertyChangedSignal('AbsoluteSize'):Connect(layoutGrid);layoutGrid()
 local function render()
  local ready=state.status=='Ready';local day=state.day or 1
  for i,cell in ipairs(cells)do
   local status=not ready and Copy.Unknown or i<day and Copy.Claimed or i==day and (state.canClaim and Copy.Today or Copy.Claimed)or Copy.Locked
   cell.status.Text=status;cell.status.TextColor3=status==Copy.Today and T.color.gold or status==Copy.Claimed and T.color.green or T.color.muted
   cell.frame.BackgroundColor3=status==Copy.Today and Color3.fromRGB(56,56,38)or T.color.navy
   cell.reward.Text=string.format(Copy.Reward,(state.rewards or Rules.rewards)[i])
  end
  local active=not waiting and (pending~=nil and (state.status=='SaveUnknown' or state.status=='Ready' or state.status=='Busy') or ready and state.canClaim or not pending and state.status~='Ready' and state.status~='Loading' and state.status~='AccountBusy')
  local caption=waiting and Copy.Claiming or pending and Copy.Check or ready and state.canClaim and string.format(Copy.Claim,day,(state.rewards or Rules.rewards)[day])or ready and Copy.Tomorrow or state.status=='Loading' and Copy.Loading or Copy.Retry
  claim.Caption.Text=caption;T.enabled(claim,active==true)
  message.Text=feedback~='' and feedback or state.status=='Loading' and Copy.Loading or Copy[state.status] or ''
 end
 local function requestState()send({action='GetState'})end
 local function sendPending()
  local id=pending;waiting=true;feedback='';send({action='Claim',requestId=id});render()
  task.delay(12,function()
   if waiting and pending==id then waiting=false;state.status='SaveUnknown';feedback=Copy.SaveUnknown;render()end
  end)
 end
 local function requestClaim()
  if waiting then return end
  if pending then sendPending();return end
  if state.status~='Ready'then requestState();return end
  if not state.canClaim then return end
  pending=Http:GenerateGUID(false):gsub('%-','');sendPending()
 end
 claim.Activated:Connect(requestClaim)
 local function receive(data)
  if type(data)~='table' or type(data.state)~='table'then return end
  if waiting and data.requestId~=pending then return end
  state=data.state
  if data.requestId and data.requestId==pending then
   waiting=false
   if data.claimed then
    local record=state.record;feedback=record and string.format(Copy.Success,record.day,record.amount)or '';pending=nil
   elseif data.error=='SaveUnknown'then feedback=Copy.SaveUnknown
   elseif data.error=='Busy'then feedback=Copy.Busy
   else feedback=Copy[data.error]or Copy.Unavailable;pending=nil end
  elseif not pending then feedback='' end
  render()
 end
 render()
 task.spawn(function()
  while panel.Parent do
   task.wait(3)
   if panel.Visible and not waiting and not pending and (state.status=='Loading' or state.status=='Busy') then requestState()end
  end
 end)
 return {panel=panel,receive=receive,open=function()panel.Visible=true;requestState()end,claim=claim,cells=cells,requestClaim=requestClaim}
end
return V
