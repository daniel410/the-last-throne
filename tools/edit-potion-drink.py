"""Render two gulps into one PCM WAV; no runtime looping or delayed playback."""
from array import array
from pathlib import Path
import sys
import wave

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets/audio/potion-drink-v1"
with wave.open(str(ASSETS / "source.wav"), "rb") as source:
    assert source.getnchannels() == 1 and source.getsampwidth() == 2
    rate = source.getframerate()
    samples = array("h", source.readframes(source.getnframes()))
if sys.byteorder != "little":
    samples.byteswap()

fade = round(rate * 0.008)
def gulp(gain):
    return array("h", (round(value * gain * min(1, i / fade, (len(samples) - 1 - i) / fade))
                       for i, value in enumerate(samples)))

edited = gulp(1.0) + array("h", [0] * round(rate * 0.055)) + gulp(0.94)
assert max(abs(value) for value in edited) <= 32767
assert edited[0] == edited[-1] == 0
if sys.byteorder != "little":
    edited.byteswap()
target = ASSETS / "potion-drink.wav"
with wave.open(str(target), "wb") as output:
    output.setparams((1, 2, rate, 0, "NONE", "not compressed"))
    output.writeframes(edited.tobytes())
print(f"{target}: {len(edited) / rate:.6f}s, {rate}Hz, mono PCM16")
