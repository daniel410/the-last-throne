"""128개 기술의 개별 VFX 제작값과 검토 의도를 소스·검토표로 출력한다."""
from pathlib import Path
import json,subprocess
ROOT=Path(__file__).resolve().parents[1]
# Shape, lane/count, width, lifetime, individual review decision.
BRANCHES={
'steel_knight':'''counter|2|.19|.42|반격의 짧은 칼날과 방어 호를 분리
crescent|1|.25|.40|전방 부채꼴 끝을 잇는 낮은 강철 초승달
slash|1|.22|.42|도발 공격을 한 번의 검격과 발밑 압력으로 구분
spin|2|.21|.34|두 펄스의 회전 위상을 바꿔 Twin Cyclone의 박자 표시
guard|1|.26|.34|한 대상 방패 파쇄의 전방 수직 면과 접점 집중
counter|2|.16|.46|반격 궤적 뒤에 아군 보호와 구분되는 개인 방어 호
areslash|2|.18|.44|넓은 선동 베기의 두 겹 전방 호
guard|2|.21|.30|돌진 두 펄스마다 진행축에 수직인 방패 파동
thrust|2|.16|.36|일반 검광 대신 좁은 전방 찌르기
spin|3|.16|.28|4회 박자마다 회전 위상 변경과 짧은 잔상
crescent|2|.25|.46|전방 베기와 구별되는 바닥360도 파쇄 호
warcry|3|.16|.32|3회 함성 공격의 전방 압력 파문
guard|3|.24|.55|궁극기의 원형 방어진과 전진 방패를 함께 표현''',
'paladin':'''slash|2|.18|.38|맹세의 두 검격은 펄스별 좌우 반전
crescent|1|.28|.45|금빛 전방 호와 표식 접점을 짧게 유지
warcry|2|.18|.44|맹세 소비는 전방 성광 압력으로 구분
holy|3|.18|.50|Dawn Burst는 시전자 중심 방사형 성광
cleave|1|.32|.40|검격을 수직 내려찍기 실루엣으로 변경
guard|1|.30|.38|Shield Verdict는 좁고 강한 방패 전면
crescent|2|.21|.43|보호가 붙은 전방 검격의 칼날 호 분리
guard|2|.20|.32|성광 돌진은 전진축 방패 면을 유지
guard|3|.16|.42|다대상 전진을 넓고 얇은 방패 압력으로 구분
holy|3|.17|.30|반복 나선은 펄스별 위상 변경
cross|2|.23|.38|Sunward Cross는 실제 교차하는 두 검광
slash|3|.17|.30|세 번 맹세 공격의 교대 검격
holy|4|.23|.70|맹세 궁극기는 중앙이 빈 방사형 성광 인장''',
'iron_axe':'''cleave|1|.32|.38|갑옷 파쇄는 도끼날의 수직 호
axe|1|.14|.40|2펄스 복귀 방향을 실제로 반전
 earth|3|.16|.46|Mountain Sweep은360도 원형 균열
cleave|2|.25|.42|전방 다대상 내려찍기를 쌍 수직 호로 표현
axe|1|.22|.42|강한 관통 투척을 긴 단일 도끼 후류로 구분
earth|4|.19|.48|착지 위치 중심으로 바깥 방향 파편
 guard|1|.23|.34|어깨 밀기는 도끼 마법이 아닌 전방 충격
axe|2|.15|.36|복귀/교차cut은 서버가 보낸 펄스 끝점을 유지
earth|3|.23|.48|전방120도 이내로만 산맥 균열 전개
earth|5|.18|.52|지정 지점의 반경4 파쇄로 장거리 균열 방지
axe|2|.14|.30|두 투척 펄스의 궤적과 회전 위상 구분
earth|3|.14|.48|보호 부여는 낮은 바닥 진동 고리로 유지
earth|5|.25|.66|산맥 궁극기는 원형이 아닌 전방120도 대형 균열''',
'gunner':'''bullet|1|.08|.18|한 발 총격의 짧은 총구와 얇은 탄도
blast|5|.18|.44|수류탄은 지정지점의 바깥 폭발과 파편
mortar|4|.20|.40|포탄은 상공 낙하축과 접지 폭발
bullet|1|.06|.13|속사는 펄스보다 짧은 탄도 수명
blast|6|.13|.32|산개된 실제 서버 중심마다 파편 폭발
blast|3|.19|.38|후퇴 폭발은 전방 부채꼴만 표시
fan|5|.07|.19|산탄은 한 직선 대신5개 부채꼴 탄도
blast|4|.17|.36|두 번 튀는 폭탄의 실제 산개 중심 유지
mortar|4|.17|.42|포격은4회 각각 낙하 흔적
bullet|2|.09|.22|관통탄은 가는 심과 압력 후류로 구분
blast|5|.20|.44|굴림 폭탄 폭발 중심은 서버 확정 지점
mortar|5|.18|.43|두 포격의 개별 서버 위치 표시
mortar|6|.23|.46|궁극기4펄스도 이전 포격 잔상이 겹치지 않게 제한''',
'marksman':'''arrow|1|.11|.32|약점 사격은 단일 정밀 후류
arrow|1|.08|.20|이동3연사는 짧은 개별 사격
arrow|2|.09|.34|관통 직선의 두 가는 압력선
arrow|1|.17|.42|강하게 당긴 화살은 두꺼운 단일 관통 심
arrow|1|.10|.24|약점 소비3연사는 이전 꼬리를 빨리 제거
fan|5|.09|.30|Fan Break의 실제 부채꼴 범위를 화살로 표현
arrow|2|.10|.34|집중 사격의 이중 후류와 실제 보호 표시
arrow|1|.12|.32|후퇴 이동은 현재 발사점에서 시작
fan|5|.11|.36|45stud 관통 부채를 한 줄로 축소하지 않음
arrow|1|.18|.38|표식 파쇄는 굵은 단일 화살 접점
arrow|2|.10|.30|Crossfire의2펄스 교차 방향을 서버 그대로 사용
rain|6|.10|.34|Arrow Rain은 실제 지정지점에만 낙하
fan|7|.12|.30|Grand Volley는90도 부채꼴3회로 구분''',
'magic_archer':'''arrow|1|.13|.35|자연 화살의 가는 마력 나선
arrow|1|.08|.22|번개 속성 화살은 전기 가지가 달린 개별3연사
vine|3|.12|.44|Vine Trap은 지정지점을 감싸는 뿌리
arrow|3|.12|.38|Bloom Shot은 명중점의 꽃잎형3갈래 접점
lightning|3|.14|.28|Storm Arrow는 상공에서 지정지점으로 낙뢰
vine|5|.11|.40|Rooting Fan은 시전자 앞 부채꼴 뿌리
arrow|2|.11|.34|Warden Arrow는 보호 효과와 화살 궤적 분리
arrow|1|.12|.30|전진 사격은 현재 발사점 기준
rain|5|.13|.30|Spirit Rain은 자연 팔레트의 낙하 화살
arrow|2|.14|.36|Elemental Pierce는 좁은 직선 관통
arrow|1|.11|.32|3회 Echo는 각 펄스 나선 위상을 변경
vine|5|.16|.50|Vine Burst는 지점 중심의 뿌리 폭발
rain|7|.16|.46|궁극기는3회 지정지점 화살비와 개별접점''',
'pyro':'''fire|2|.15|.36|Ember Lance는 뾰족한 전방 불꽃 창
steam|3|.17|.48|Steam Burst의 물색 증기를 위로 올림
fire|3|.16|.38|Cinder Ring은 시전자 중심의 빈 원형 화염
fire|1|.13|.24|짧은 시전 Flame Dart는 가늘고 짧게
 earth|5|.18|.48|Earth Rise는 지점 중심의 솟는 암석
fire|3|.16|.38|Ember Step은 이동 후가 아닌 서버의 출발장판 중심
stone|1|.23|.42|Stone Lance는 바닥 균열 대신 공중 돌창
fire|2|.15|.42|Searing Ward는 원형 열기와 보호 부여를 구분
lava|5|.24|.60|Lava Eruption은 반경14 내 방사형 용암 균열
fire|3|.18|.44|Magma Spear는3겹 고온 창 심
fire|2|.14|.34|Molten Line은3펄스의 실제 직선 유지
ash|6|.12|.40|Ashfall은 나선 광선 대신 지면에 떨어지는 불씨
lava|6|.26|.68|Caldera 궁극기는반경20 지점의 용암과 분출''',
'cryo':'''frost|1|.17|.38|Frost Lance는 좁고 뾰족한 얼음 창
frost|3|.12|.34|Ice Shard는3갈래 짧은 결정 파편
frost|5|.13|.46|Frost Ring은 시전자 중심360도 서리
frost|2|.16|.32|표식 파쇄 얼음은 짧은 쌍 결정
lightning|2|.12|.20|Chain Lightning은 확정된 적 사이만 연결
frost|4|.12|.40|Frost Step은 서버 출발 중심의 서리
lightning|1|.19|.26|Thunder Spear는 한 전방축의 전기 창
frost|4|.14|.44|Ice Ward의 냉기와 보호 부여를 분리
frost|6|.18|.56|Froststorm은 지정지점 반경14의 서리 폭풍
frost|1|.26|.46|Glacial Spike는 큰 단일 결정창
lightning|3|.14|.24|Lightning Line은 직선 축 주위 전기 가지
hail|6|.13|.40|Hailfall은 바닥 파편 대신 상공 낙하 결정
frost|7|.22|.64|Eternal Tempest는20반경 지점의 빈 중심 서리 인장'''
}
COMMON={
'knight.common.bash':'guard|1|.24|.32|Shield Bash는 방패 진행축에 수직인 접점',
'knight.common.whirlwind':'spin|2|.21|.38|Whirlwind의360도 검 궤적',
'knight.common.provoke':'warcry|3|.14|.48|도발은 피해광선 대신 발밑 함성 파문',
'dwarf.common.overhead':'cleave|1|.32|.42|Overhead Smash의 수직 궤적과 접점',
'dwarf.common.throw':'axe|1|.14|.38|실제 도끼 투척의 회전 후류',
'dwarf.common.ground':'earth|4|.18|.48|Ground Slam은 시전자 바닥 중심360도',
'elf.common.aimed':'arrow|1|.15|.38|Aimed Shot은 굵은 단일 정밀 후류',
'elf.common.rapid':'arrow|1|.07|.16|Rapid Fire는 각 발사가 겹치지 않는 짧은 후류',
'elf.common.multi':'fan|5|.08|.28|Multi Shot은 실제70도 범위의5방향 화살',
'mage.common.mana_bolt':'arcane|2|.12|.34|Mana Bolt는 비전색 쌍 나선',
'mage.common.water_ball':'water|5|.16|.42|Water Ball의 구면 물보라와 젖음 접점',
'mage.common.gravity':'gravity|2|.14|.56|Gravity는 확정 영역 안쪽으로 당기는 나선',
'knight_driving_thrust':'thrust|1|.19|.32|Driving Thrust는좁은6stud 찌르기',
'knight_crescent_cut':'crescent|1|.25|.38|Crescent Cut은전방110도 단일호',
'knight_guarded_strike':'guard|1|.19|.34|Guarded Strike는단일 방패 접점과 방어호',
'dwarf_hooking_chop':'cleave|1|.24|.30|Hooking Chop은짧은 갈고리형 수직호',
'dwarf_low_sweep':'low|1|.22|.36|Low Sweep은발목 높이 전방110도 호',
'dwarf_braced_throw':'axe|1|.20|.42|Braced Throw는26stud 관통 후류',
'elf_retreating_shot':'arrow|1|.10|.30|Retreating Shot은뒤로 이동해도 발사 방향 유지',
'elf_pinning_shot':'arrow|2|.10|.34|Pinning Shot은끝점의 짧은 고정 접점',
'elf_arrow_screen':'rain|5|.08|.34|Arrow Screen은반경4의 가까운 화살비',
'mage_wind_lance':'wind|3|.14|.48|Wind Lance의전용 공기리본을중복하지않음',
'mage_tidal_ring':'water|6|.19|.46|Tidal Ring은시전자중심5stud 물결',
'mage_arcane_ward':'ward|3|.12|.56|Arcane Ward는시전점중심 보호리본'
}

def inventory():
 code="""local C=dofile('src/shared/K0Config.luau');local A=dofile('src/shared/AdvancedSkills.luau');script={Parent={AdvancedSkills='A'}};require=function()return A end;local P=dofile('src/shared/SkillPresentation.luau');for _,c in ipairs({'knight','dwarf','elf','mage'})do for i,d in ipairs(C.Skills[c])do local p=P.get(d);print(table.concat({c,tostring(i),d.id,d.name,d.branch or 'common',d.form or 'common',p.effect,tostring(d.range),tostring(d.radius or d.areaRadius or 0),tostring(d.angle or 0),tostring(d.pulses or d.shotCount or 1)},'\\t'))end end"""
 rows=subprocess.check_output(['lua','-'],input=code,text=True,cwd=ROOT).splitlines()
 return [dict(zip(['classId','index','id','name','branch','form','beforeEffect','range','radius','angle','pulses'],r.split('\t')))for r in rows]

def main():
 rows=inventory();profiles={};review=[]
 for branch,text in BRANCHES.items():
  defs=[r for r in rows if r['branch']==branch];specs=text.strip().splitlines();assert len(defs)==len(specs)==13
  for r,spec in zip(defs,specs):profiles[r['id']]=spec.strip()
 profiles.update(COMMON);assert len(profiles)==len(rows)==128
 lines=['-- Individually authored silhouettes. Presentation only; no combat values.','local Profiles = {byId = {']
 for r in rows:
  shape,count,width,life,note=profiles[r['id']].split('|')
  data={'shape':shape.strip(),'lanes':int(count),'width':float(width),'life':float(life)}
  lines.append(' ["'+r['id']+'"] = {shape="'+data['shape']+'",lanes='+count+',width='+width+',life='+life+'},')
  review.append({**r,**data,'review':note,'visualStatus':'Not Run','engineStatus':'Not Run'})
 lines+=['}}','function Profiles.get(id) return Profiles.byId[id] end','return Profiles']
 (ROOT/'src/client/SkillVFXProfiles.luau').write_text('\n'.join(lines)+'\n')
 out=ROOT/'docs/evidence/skill-vfx-individual-20261111';out.mkdir(parents=True,exist_ok=True)
 (out/'review.json').write_text(json.dumps(review,ensure_ascii=False,indent=2)+'\n')
 print('Authored profiles:',len(review))
if __name__=='__main__':main()
