#!/usr/bin/env python3
"""Reproduce the PixelFX review board. Requires Node >=18 and Pillow in an isolated venv."""
import argparse
import hashlib
import html
import json
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

PIN = "a84159688af3ca37a4be05a0d422b94451b2e24e"
GOLD = ["#423019", "#806036", "#bb9550", "#ffd785", "#ffe5ac", "#fff0cb", "#ffffff"]
SAMPLES = [
    ("melee/sword-slash", "Knight / sword contact", "기사 · 검 접촉 잔광", "짧은 금빛 잔광. 실제 검 궤적은 기존 3D 효과 유지.", True, 0.10),
    ("impacts/crit-hit", "Dwarf / heavy impact", "드워프 · 강타 접촉 섬광", "도끼가 적에게 닿는 위치에 짧게 방출할 후보.", False, 0.10),
    ("nature/leaf-storm", "Elf / nature accent", "엘프 · 자연 마법 보조", "마법 계열 보조 연출 후보. 신규 기술 제안이나 해금 변경이 아님.", False, 0.80),
    ("fire/fireball", "Mage / fire projectile", "마법사 · 화염 투사체", "비행 방향과 꼬리 표현 참고. 측면 스프라이트의 카메라 한계 주의.", False, 0.40),
    ("ice/frost-nova", "Mage / frost burst", "마법사 · 냉기 확산", "얼음 파편 참고용. 바닥 고리는 3D로 재구성 권장.", False, 0.90),
    ("holy/heal-aoe", "Selene / healing accent", "Selene · 치유 보조", "금빛 치유 입자 후보. 원형 바닥은 기존 3D 범위 표시 유지.", True, 0.90),
]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("checkout", type=Path, help="A local patch-gg/pixelfx checkout at the pinned commit")
    parser.add_argument("--output", type=Path, default=Path(__file__).resolve().parents[1] / "assets/concepts/2026-11-04-pixelfx-preview")
    args = parser.parse_args()
    checkout, out = args.checkout.resolve(), args.output.resolve()
    actual = subprocess.check_output(["git", "-C", str(checkout), "rev-parse", "HEAD"], text=True).strip()
    if actual != PIN:
        raise SystemExit(f"Expected {PIN}, got {actual}")
    out.mkdir(parents=True, exist_ok=True)
    subprocess.run(["node", "tools/check.mjs", *[s[0] for s in SAMPLES]], cwd=checkout, check=True)
    shutil.copyfile(checkout / "LICENSE", out / "LICENSE.pixelfx.txt")
    records, clips, heroes = [], [], []
    font = ImageFont.load_default(size=19)
    small = ImageFont.load_default(size=13)
    for id_, label, title, desc, gold, hero_t in SAMPLES:
        opts = {"light": 0.35}
        if gold:
            opts["palette"] = GOLD
        subprocess.run(["node", "tools/render.mjs", id_, "--sheet", "--no-actor", "--opts", json.dumps(opts), "--out", str(out / "samples")], cwd=checkout, check=True)
        folder, name = out / "samples" / id_, id_.split("/")[-1]
        data = json.loads((folder / f"{name}.json").read_text())
        atlas = Image.open(folder / f"{name}.png").convert("RGBA")
        frames = []
        for entry in data["frames"]:
            r = entry["frame"]
            frames.append(atlas.crop((r["x"], r["y"], r["x"] + r["w"], r["y"] + r["h"])))
        m = data["meta"]["pixelfx"]
        def panel(frame, label=label, m=m):
            p = Image.new("RGB", (320, 250), "#11191e")
            d = ImageDraw.Draw(p)
            d.text((15, 12), label, font=font, fill="#f3dfb4")
            k = min(2, 294 // frame.width, 183 // frame.height)
            # Fractional downscaling is only needed for an unusually large future sample.
            if k < 1:
                k = min(294 / frame.width, 183 / frame.height)
            f = frame.resize((int(frame.width * k), int(frame.height * k)), Image.Resampling.NEAREST)
            p.paste(f, ((320 - f.width) // 2, 42 + (183 - f.height) // 2), f)
            d.text((15, 228), f'{m["frames"]} frames | {m["fps"]} fps | ' + ("loop" if m["loop"] else "one-shot"), font=small, fill="#a3b8b5")
            return p
        clips.append((frames, m, panel))
        heroes.append(panel(frames[min(len(frames)-1, round(hero_t * m["fps"]))]))
        gif = [panel(f) for f in frames]
        durations = [round((i+1)*1000/m["fps"])-round(i*1000/m["fps"]) for i in range(len(gif))]
        if not m["loop"]:
            durations[-1] += 550
        gif[0].save(folder / "preview.gif", save_all=True, append_images=gif[1:], duration=durations, loop=0)
        records.append({"id": id_, "title": title, "description": desc, "options": opts, "sheet": f"samples/{id_}/{name}.png", "gif": f"samples/{id_}/preview.gif", "metadata": data, "atlasSize": list(atlas.size)})
    def board(panels):
        b = Image.new("RGB", (960, 560), "#091215")
        d = ImageDraw.Draw(b)
        d.text((18, 13), "THE LAST THRONE / PixelFX candidates", font=font, fill="#f3dfb4")
        d.text((18, 38), "Effect-only study / not a Roblox capture / light 0.35", font=small, fill="#a3b8b5")
        for i, p in enumerate(panels):
            b.paste(p, ((i % 3) * 320, 60 + (i // 3) * 250))
        return b
    board(heroes).save(out / "overview.png")
    animation = []
    for tick in range(60):
        t, panels = tick / 15, []
        for frames, m, panel in clips:
            duration = len(frames) / m["fps"]
            phase = t % (duration + (0 if m["loop"] else .55))
            panels.append(panel(frames[min(len(frames)-1, int(phase*m["fps"]))]))
        animation.append(board(panels))
    animation[0].save(out / "preview.gif", save_all=True, append_images=animation[1:], duration=[70, 60, 70]*20, loop=0)
    manifest = {"source": "https://github.com/patch-gg/pixelfx", "commit": PIN, "license": "MIT", "status": "effect-only study; no Roblox upload or runtime integration", "samples": records}
    (out / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
    cards = "".join(f'<article><h2>{html.escape(r["title"])}</h2><canvas width="576" height="384" aria-label="{html.escape(r["title"])}"></canvas><p>{html.escape(r["description"])}</p><small>{r["id"]} · {r["metadata"]["meta"]["pixelfx"]["frames"]} frames · <a href="{r["gif"]}">GIF</a> · <a href="{r["sheet"]}">PNG atlas</a></small></article>' for r in records)
    page = '''<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>The Last Throne · PixelFX 검토</title>
<style>*{box-sizing:border-box}body{margin:0;background:#0b1519;color:#ebeee5;font:16px/1.6 system-ui,sans-serif}main{max-width:1250px;margin:auto;padding:35px 24px}h1{font-size:32px;line-height:1.25;margin:8px 0 18px}h2{font-size:20px;margin:0 0 12px}p{color:#b9cbc6}a{color:#eacb8f}small{color:#9eaea9}.tag{color:#eacb8f;letter-spacing:2px;font-size:12px}.controls{display:flex;gap:12px;margin:25px 0;flex-wrap:wrap}button,select{font:inherit;color:#efe3c8;background:#233338;border:1px solid #63766b;border-radius:7px;padding:8px 16px}.grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:18px}article{padding:18px;background:#152228;border:1px solid #31403f;border-radius:12px}canvas{display:block;width:100%;aspect-ratio:3/2;object-fit:contain;background:#10191e;image-rendering:pixelated;border-radius:6px}article p{min-height:80px;font-size:14px}footer{margin:28px 0;font-size:13px;color:#a4b3ae}@media(max-width:950px){.grid{grid-template-columns:repeat(2,minmax(0,1fr))}}@media(max-width:600px){.grid{grid-template-columns:1fr}}@media(prefers-reduced-motion:reduce){canvas{opacity:.95}}</style>
<main><div class="tag">THE LAST THRONE · VFX 연구 보드</div><h1>PixelFX 적용 후보 6종</h1><p>원본 효과를 직접 렌더링한 개발 검토 자료입니다. 실제 게임 화면·TD 메뉴 미리보기가 아닙니다.<br>기사·Selene는 금빛 팔레트, 전체는 light 0.35. 게임 적용·자산 업로드·성능 수용은 후속입니다.</p>
<div class="controls"><button id="pause">일시 정지</button><button id="restart">처음부터</button><select id="bg" aria-label="배경"><option value="#10191e">어두운 배경</option><option value="#c5d3bb">밝은 배경</option><option value="#54664a">숲 배경색</option></select></div><div class="grid">CARDS</div><footer>배경색 비교는 실제 월드 조명 검증을 대신하지 않습니다. 2D 고리의 원근과 가림 문제는 Roblox 실험이 필요합니다.<br>PixelFX · Copyright (c) 2026 Patch / Hugo Duprez · <a href="LICENSE.pixelfx.txt">MIT license</a> · <a href="manifest.json">원천·프레임·옵션</a></footer></main>
<script>const samples=DATA;let running=!matchMedia('(prefers-reduced-motion: reduce)').matches,time=0,last=performance.now();const canvases=[...document.querySelectorAll('canvas')];const imgs=samples.map(s=>{const i=new Image();i.src=s.sheet;return i});function update(){document.querySelector('#pause').textContent=running?'일시 정지':'재생'}update();document.querySelector('#pause').onclick=()=>{running=!running;update()};document.querySelector('#restart').onclick=()=>time=0;document.querySelector('#bg').onchange=e=>canvases.forEach(c=>c.style.background=e.target.value);function draw(now){if(running)time+=(now-last)/1000;last=now;canvases.forEach((c,i)=>{const s=samples[i],m=s.metadata.meta.pixelfx,im=imgs[i];if(!im.complete||!im.naturalWidth)return;const duration=m.frames/m.fps,phase=time%(duration+(m.loop?0:.55)),index=Math.min(m.frames-1,Math.floor(phase*m.fps)),r=s.metadata.frames[index].frame,ctx=c.getContext('2d');ctx.clearRect(0,0,c.width,c.height);ctx.imageSmoothingEnabled=false;const k=Math.max(1,Math.floor(Math.min((c.width-24)/r.w,(c.height-24)/r.h)));ctx.drawImage(im,r.x,r.y,r.w,r.h,Math.floor((c.width-r.w*k)/2),Math.floor((c.height-r.h*k)/2),r.w*k,r.h*k)});requestAnimationFrame(draw)}requestAnimationFrame(draw);</script></html>'''
    (out / "index.html").write_text(page.replace("CARDS", cards).replace("DATA", json.dumps(records, ensure_ascii=False)))
    hashes = {str(p.relative_to(out)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(out.rglob("*")) if p.is_file() and p.name != "sha256.json"}
    (out / "sha256.json").write_text(json.dumps(hashes, indent=2) + "\n")
    print(f"Wrote {len(records)} samples, overview, animated board and local gallery: {out}")


if __name__ == "__main__":
    main()
