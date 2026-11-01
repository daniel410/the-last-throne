-- Constructor prefixes stop before callbacks/requests; no account data is sent.
local client=game.Players.LocalPlayer.PlayerScripts.Client
local report={kind='LAUNCHER_STARTUP_NATIVE',checks=0,cases={}}
local function check(ok,message)report.checks+=1;assert(ok,message)end
for _,spec in ipairs({{'InventoryGui','InventoryGui','OpenBag','launcher','showLauncher','local function setOpen'}, {'HeroGrowthGui','HeroGrowthGui','OpenHero','launch','showLaunch','local function visible'}, {'SettingsGui','GameSettings','OpenSettings','launcher','showLauncher','local function setOpen'}})do
 local fake=Instance.new('Folder');fake.Name='LauncherQA';fake.Parent=workspace
 local pg=Instance.new('Folder');pg.Name='PlayerGui';pg.Parent=fake
 local module=Instance.new('ModuleScript');module.Name=spec[1]..'StartupQA';module.Parent=client
 local ref=Instance.new('ObjectValue');ref.Name='TestPlayer';ref.Value=fake;ref.Parent=module
 local ok,err=xpcall(function()
  local source=(_G.TLTLauncherQASources or {})[spec[1]] or client[spec[1]].Source
  local at=assert(source:find(spec[6],1,true));source=source:sub(1,at-1)
  source=source:gsub('local player%s*=%s*Players.LocalPlayer','local player=script.TestPlayer.Value')
  source=source:gsub('(require%(script.Parent.TopMenuLayout%).bind%([^\n]+)', '%1\n task.wait(.15)')
  local export=spec[1]=='InventoryGui' and 'InventoryGui' or spec[1]=='HeroGrowthGui' and 'Gui' or 'M'
  source=source..'return {gui=gui,button='..spec[4]..',refresh='..spec[5]..'}\nend\nreturn '..export
  module.Source=source
  local view,constructError
  task.spawn(function()local success,value=pcall(function()return require(module).create(fake)end);if success then view=value else constructError=value end end)
  task.wait(.05)
  local gui=assert(pg:FindFirstChild(spec[2]),'constructor GUI exists')
  check(not gui[spec[3]].Visible,'hidden during delayed constructor: '..spec[1])
  task.wait(.2);assert(not constructError,constructError);assert(view,'constructor completed')
  local phases={'LoadingLobby','Lobby','ReturningLobby','LoadingTutorial','Tutorial','Respawning'}
  view.refresh();check(not view.button.Visible,'unknown replicated phase stays hidden')
  for _,phase in phases do fake:SetAttribute('K0SessionPhase',phase);view.refresh();check(not view.button.Visible,'hidden during '..phase)end
  fake:SetAttribute('K0SessionPhase','SpawnFailed');view.refresh();check(view.button.Visible,'existing failure fallback preserved')
  fake:SetAttribute('TLTProgressionOpen',true);fake:SetAttribute('TLTInventoryOpen',true);view.refresh();check(not view.button.Visible,'other detail menu still hides fallback')
  table.insert(report.cases,{module=spec[1],delayed_constructor_hidden=true,unreplicated_phase_hidden=true,lobby_hidden=true})
 end,debug.traceback)
 fake:Destroy();module:Destroy()
 if not ok then report.pass=false;report.error=err;return report end
end
report.pass=true;return report
