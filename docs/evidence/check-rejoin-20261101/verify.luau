local old=game.CoreGui:FindFirstChild('RejoinLauncherQA');if old then old:Destroy()end
local gui=Instance.new('ScreenGui');gui.Name='RejoinLauncherQA';gui.IgnoreGuiInset=true;gui.Parent=game.CoreGui
local create=require(game.StarterPlayer.StarterPlayerScripts.Client.LobbyRejoinButton).create
local b=create(gui,function()end);task.wait(.1);local checks=0;local function check(v,m)assert(v,m);checks+=1 end
check(b.Position==UDim2.fromOffset(12,12) and b.Size==UDim2.fromOffset(136,44),'TD position and size')
check(b.TDButtonArt.Image=='rbxassetid://126012242626142','same TD shell')
check(b.TDButtonArt.ImageRectOffset==Vector2.new(514,64) and b.TDButtonArt.ImageRectSize==Vector2.new(254,102),'same TD shell crop')
check(math.abs(b.TDButtonArt.SliceScale-.45)<.001,'same shell slicing')
check(b.RejoinEmblem.Image=='rbxassetid://97570429280107','same revive artwork')
check(b.RejoinEmblem.ImageRectOffset==Vector2.new(248,519) and b.RejoinEmblem.ImageRectSize==Vector2.new(275,196),'same revive crop')
check(b.RejoinEmblem.Size==UDim2.fromOffset(28,28) and b.RejoinEmblem.AnchorPoint==Vector2.new(0,.5),'same emblem size/anchor')
check(b.Caption.Position==UDim2.fromOffset(48,4) and b.Caption.Size==UDim2.new(1,-72,1,-8),'same TD caption geometry')
check(b.Caption.Text=='CHECK REJOIN' and b.Caption.TextFits,'two-line caption fits')
check(b.BackgroundTransparency==1,'no blue rectangle outside TD shell')
gui:Destroy();return {checks=checks,result='passed'}
