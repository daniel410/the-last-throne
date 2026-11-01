"""Exercise the production tab resize function with deterministic geometry doubles."""
from pathlib import Path
import subprocess
import tempfile
source=Path('src/client/LobbyQuestJournal.luau').read_text()
start=source.index(' local function resizeTabs()')
end=source.index(" root:GetPropertyChangedSignal('AbsoluteSize')",start)
setup='''
local root={AbsoluteSize={X=800}}
local buttons={{},{},{},{},{}}
local tabs={}
local summary={}
local list={}
local UDim2={new=function(xs,xo,ys,yo)return {X={Scale=xs,Offset=xo},Y={Scale=ys,Offset=yo}}end,fromOffset=function(x,y)return {X={Scale=0,Offset=x},Y={Scale=0,Offset=y}}end}
'''
checks='''
for _,width in ipairs({768,694,238}) do
 root.AbsoluteSize.X=width;resizeTabs()
 for _,b in ipairs(buttons) do
  assert(b.Size.X.Offset>=44 and b.Size.Y.Offset==44,'touch size')
  assert(b.Position.X.Offset+b.Size.X.Offset<=width,'button clipped')
  assert(b.Position.Y.Offset+44<=summary.Position.Y.Offset,'summary overlap')
 end
 assert(list.Position.Y.Offset>summary.Position.Y.Offset,'list overlaps summary')
end
print('lobby-quest-tabs: five visible buttons and summary spacing PASS; native UI NOT RUN')
'''
with tempfile.NamedTemporaryFile(mode='w',suffix='.luau') as script:
 script.write(setup+source[start:end]+checks);script.flush()
 subprocess.run(['/tmp/td233-luau/luau',script.name],check=True)
