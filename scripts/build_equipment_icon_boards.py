"""Build local review boards from generated icon records; never modifies PNGs."""
import html
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / 'assets/concepts/2026-11-04-equipment-icons'
GRADES = {'Rare':'generated-rare-v1','Epic':'generated-v1','Legendary':'generated-legendary-v1','Unique':'generated-unique-v1'}
STYLE = '''body{margin:24px;background:#17202b;color:#eef3fc;font:15px system-ui}a{color:#b4d9ff}button,input{padding:10px;margin:4px;border:1px solid #728da9;border-radius:6px;background:#29394b;color:white}main{display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,620px),1fr));gap:16px}article{padding:12px;background:#243446;border-radius:10px}.pair{display:grid;grid-template-columns:repeat(var(--cols,2),minmax(0,1fr));gap:10px}figure{margin:0;padding:8px;border:2px solid #639ef3;border-radius:8px}figure.Epic{border-color:#b574f2}figure.Legendary{border-color:#ffb34f}figure.Unique{border-color:#ffe079;box-shadow:inset 0 0 0 1px #e8ce8c}img{width:100%;aspect-ratio:1;object-fit:contain}figcaption{font-size:12px;overflow-wrap:anywhere;line-height:1.5}small{display:block;color:#b5c5d8}.tiny img{width:48px;height:48px}.light figure{background:#dde3eb;color:#17202b}.light small{color:#344458}[hidden]{display:none!important}h3{margin:4px 0 12px}'''
SCRIPT = '''let group='all';function filter(g){group=g;apply()}function apply(){const q=document.querySelector('input').value.toLowerCase();document.querySelectorAll('article').forEach(a=>a.hidden=(group!=='all'&&a.dataset.group!==group)||!a.textContent.toLowerCase().includes(q))}function grades(all){document.querySelectorAll('figure').forEach(f=>f.hidden=!all&&['Rare','Epic'].includes(f.dataset.grade));document.documentElement.style.setProperty('--cols',all?4:2)}'''

def page(title, cards, single=False):
    controls=''.join(f'<button onclick="filter(\'{c}\')">{c.title()}</button>' for c in ['all','shared','knight','elf','dwarf','mage'])
    if not single: controls+='<button onclick="grades(false)">Legendary / Unique</button><button onclick="grades(true)">Rare / Epic / Legendary / Unique</button>'
    controls+='<button onclick="document.body.classList.toggle(\'tiny\')">48px</button><button onclick="document.body.classList.toggle(\'light\')">배경 전환</button><input placeholder="아이템 이름 검색" aria-label="아이템 이름 검색" oninput="apply()">'
    catalog='../catalog-160.html' if single else 'catalog-160.html'
    return '<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>'+title+'</title><style>'+STYLE+'</style><h1>'+title+'</h1><p><a href="'+catalog+'">160종 등급·클래스·이름 통합 목록</a></p><p>등급·클래스·아이템명으로 식별합니다. 아이콘 생성본이며 실제 게임 등록·효과·실기기 수용은 별도입니다. Unique 최소 착용Lv60은 사용자 확정입니다. Rare10/Epic20/Legendary40은 재산정 시험 기준입니다. 현재 능력치는 통합 목록의 재산정 링크를 확인하세요.</p><p><a href="'+('../comparison.html' if single else 'generated-unique-v1/index.html')+'">'+('전체 등급 비교' if single else 'Unique40 단독 보기')+'</a></p>'+controls+'<main>'+''.join(cards)+'</main><script>'+SCRIPT+('' if single else ';grades(false)')+'</script></html>'

def build():
    balance={(i['rarity'],i['familyId']):i for i in json.loads((ROOT.parents[2]/'assets/balance/equipment-recalculated-2026-11-05.json').read_text())['items']}
    manifest=json.loads((ROOT/'manifest.json').read_text())
    records={g:{r['familyId']:r for r in json.loads((ROOT/d/'generation.json').read_text())['records']} for g,d in GRADES.items()}
    combined=[];single={g:[] for g in GRADES}
    for f in manifest['families']:
        group=f['classId'] or 'shared';figures=[]
        for grade,folder in GRADES.items():
            r=records[grade][f['id']];d=r['displayMetadata'];path=folder+'/'+r['file'];name=html.escape(d['name']);caption=html.escape(d['classLabel'])+' · '+html.escape(f['slot'])+'<br>'+html.escape(d.get('setName') or 'Standalone')
            caption+='<br>Lv'+str(balance[(grade,f['id'])]['requiredLevel'])+(' · Approved' if grade=='Unique' else ' · Trial')
            if grade=='Unique':caption+='<br>Boss: '+html.escape(r['bossKind'])+' · Hell only'
            fig=f'<figure class="{grade}" data-grade="{grade}"><a href="{path}"><img loading="lazy" src="{path}" alt="{name}"></a><figcaption>{name}<small>{caption}</small></figcaption></figure>'
            figures.append(fig);single[grade].append(f'<article data-group="{group}">'+fig.replace(path,r['file'])+'</article>')
        combined.append(f'<article data-group="{group}"><h3>{html.escape(f["name"])}</h3><div class="pair">'+''.join(figures)+'</div></article>')
    (ROOT/'comparison.html').write_text(page('Rare40 / Epic40 / Legendary40 / Unique40 · 160종 비교',combined))
    for grade,folder in GRADES.items(): (ROOT/folder/'index.html').write_text(page(grade+' · 장비 아이콘 40종',single[grade],True))
    print('Built four 40-icon boards and 160-icon comparison; default Legendary/Unique comparison')

if __name__ == '__main__': build()
