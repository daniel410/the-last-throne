"""Exercise actual feedback transitions using a Luau GUI double."""
from pathlib import Path
import subprocess
import tempfile
source=Path('src/client/K0Hud.luau').read_text()
start=source.index('showFeedback = function(value, duration, transparentBackground)')
end=source.index('\n\t\tclearFeedback =',start)
show=source[start:end].strip().removesuffix(',')
script='''local feedbackSequence=0
local feedback={Parent=true}
local task={delay=function(_,fn) end}
local handler={'''+show+'''}
handler.showFeedback('HIT',nil,true)
assert(feedback.BackgroundTransparency==1 and feedback.Visible,'hit background')
handler.showFeedback('BLOCKED')
assert(feedback.BackgroundTransparency==.6 and feedback.Text=='BLOCKED','other messages restore background')
handler.showFeedback('HIT',nil,true)
assert(feedback.BackgroundTransparency==1,'hit remains transparent after another message')
print('hit-feedback-transparency: PASS; native UI NOT RUN')
'''
client=Path('src/client/init.client.luau').read_text()
assert 'hud.showFeedback(message, nil, feedbackKind == "Hit")' in client
with tempfile.NamedTemporaryFile(mode='w',suffix='.luau') as f:
 f.write(script);f.flush();subprocess.run(['/tmp/td233-luau/luau',f.name],check=True)
