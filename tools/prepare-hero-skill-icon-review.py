"""스킬 아이콘 UI를 저장/전투 서버와 분리해 Studio에서 검증하는 실행문을 만든다."""
from pathlib import Path
import json
import re
import hashlib

ROOT = Path(__file__).resolve().parents[1]
sources = {}

def add(path):
    if path in sources:
        return
    file = ROOT / path
    source = file.read_text()
    sources[path] = source
    for dependency in re.findall(r"dofile\(['\"]([^'\"]+)['\"]\)", source):
        if (ROOT / dependency).is_file():
            add(dependency)
    for name in re.findall(r"load\(['\"]([^'\"]+)['\"]\)", source):
        dependency = 'src/shared/' + name + '.luau'
        if (ROOT / dependency).is_file():
            add(dependency)
    for name in re.findall(r"require\(script\.Parent\.([A-Za-z0-9_]+)\)", source):
        add(str(Path(path).parent / (name + '.luau')))
    for name in re.findall(r"(?:Shared|\.Shared)\.([A-Za-z0-9_]+(?:\.[A-Za-z0-9_]+)?)", source):
        dependency = 'src/shared/' + name.replace('.', '/') + '.luau'
        if (ROOT / dependency).is_file():
            add(dependency)

for seed in ['src/client/HeroSkillTree.luau', 'src/client/K0Hud.luau', 'src/shared/K0Text.luau']:
    add(seed)

code = 'local sources={\n' + ''.join('[' + json.dumps(k) + ']=' + json.dumps(v, ensure_ascii=False) + ',\n' for k, v in sources.items()) + '}\n'
code += '''
local originalGame=game
local compiledModules=0
for path,source in pairs(sources)do
 local fn,why=loadstring(source,'@'..path);assert(fn,why);compiledModules+=1
end
local tree={}
local function node(parent)
 local n={Parent=parent}
 function n:WaitForChild(name)return assert(self[name],name)end
 function n:FindFirstChild(name)return self[name]end
 return n
end
for path in pairs(sources)do
 local parent=tree
 for part in path:gmatch('[^/]+')do
  local name=part:gsub('%.luau$','');parent[name]=parent[name]or node(parent);parent=parent[name]
 end
 parent.path=path
end
local previous=originalGame.CoreGui:FindFirstChild('TLTHeroSkillIconReview')
if previous then previous:Destroy()end
local probe=originalGame.CoreGui:FindFirstChild('TLTSkillIconLoadingQA');if probe then probe:Destroy()end
local gui=Instance.new('ScreenGui');gui.Name='TLTHeroSkillIconReview';gui.IgnoreGuiInset=true;gui.DisplayOrder=100000;gui.Parent=originalGame.CoreGui
local root=Instance.new('Frame');root.Name='ReviewCanvas';root.Size=UDim2.fromOffset(1160,700);root.BackgroundColor3=Color3.fromRGB(8,16,30);root.Parent=gui
local playerGui=Instance.new('Folder');playerGui.Name='FixturePlayerGui';playerGui.Parent=gui
local attributes=Instance.new('Folder');attributes.Name='FixtureAttributes';attributes.Parent=gui
local characterAdded=Instance.new('BindableEvent');characterAdded.Parent=gui
local actor={UserId=42,Name='Icon Review',DisplayName='Icon Review',Character=nil,CharacterAdded=characterAdded.Event}
function actor:WaitForChild(name)assert(name=='PlayerGui',name);return playerGui end
function actor:GetAttribute(name)return attributes:GetAttribute(name)end
function actor:SetAttribute(name,value)attributes:SetAttribute(name,value)end
function actor:GetAttributeChangedSignal(name)return attributes:GetAttributeChangedSignal(name)end
actor:SetAttribute('K0SessionPhase','Lobby')
local players={LocalPlayer=actor,GetPlayers=function()return {}end}
local replicated=node(nil);replicated.Shared=tree.src.shared
local proxy={ReplicatedStorage=replicated,Players=players}
function proxy:GetService(name)return self[name]or originalGame:GetService(name)end
local cache={}
local function req(n)
 if cache[n]then return cache[n]end
 local fn,why=loadstring(assert(sources[n.path],n.path),'@'..n.path);assert(fn,why)
 setfenv(fn,setmetatable({game=proxy,script=n,require=req},{__index=getfenv()}))
 local value=fn();cache[n]=value;return value
end
'''
code += 'local verify=assert(loadstring(' + json.dumps((ROOT / 'tests/hero-skill-icons-native.luau').read_text(), ensure_ascii=False) + '))()\n'
code += '''
local ok,result=xpcall(function()return verify(req,tree,root,actor)end,debug.traceback)
_G.TLTHeroSkillIconReview={gui=gui,root=root,actor=actor,req=req,tree=tree,result=result}
assert(ok,result)
result.compiledModules=compiledModules
print('HERO_SKILL_ICONS_NATIVE '..originalGame:GetService('HttpService'):JSONEncode(result))
return result
'''
target = ROOT / 'builds/hero-skill-icons-review.luau'
target.parent.mkdir(exist_ok=True)
target.write_text(code)
(ROOT / 'builds/hero-skill-icons-source-hashes.json').write_text(json.dumps({p: hashlib.sha256(s.encode()).hexdigest() for p, s in sources.items()}, indent=2) + '\n')
print(json.dumps({'modules': len(sources), 'bytes': len(code.encode()), 'script': str(target)}))
