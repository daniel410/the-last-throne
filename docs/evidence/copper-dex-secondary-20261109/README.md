# Copper Ring DEX와 장갑·신발 수치

2026-11-09 · TLT-029/041/052/057/084 · 0.93.1 · ENG→QA

Copper Ring(Common/Lv1)은 공격력3을 제거하고 DEX3만 제공한다. 장갑공격/신발방어는 Traveler2/Tempered4/Veteran7/Sentinel15로 변경했다. 사용자의 후속 명시값이 직전 일괄-1 요청보다 우선한다. 다른 부위/HP·MP·장신구·레벨/가격/안정ID·보유품·강화단계는 유지한다. 기존 반지도 현재 정의로 효과를 다시 계산하고 환급/재지급하지 않는다. [최신 부위별 정본](../../production/equipment-four-tier-reorganization-2026-11-09.md).

프로젝트 제작 스킬 적용. 직접 지정한 수치/옵션 변경이며 기존 DEX공식/상한을 사용하고 새 게임성/밸런스 대안을 도입하지 않았다. 장비DEX는 실제 배분/포인트·저장 growth에 합산하지 않는다. `Growth.derived`의 선택적 equipment입력에서만 투자DEX와 함께 공속/이속 및 totalStats.DEX에 반영한다. 무투자 반지는 기본공속1.5%/기본이속0.3% 증가, 기존공속2배/이속1.3배 상한 유지다. 서버 스폰/갱신과 미리보기가 같은식을 사용한다. 장비 교체는 HP/MP를 회복하지 않는다.

강화규칙6은 DEX도 원래값3%/단계로 처리하며 비용/성공률/재료/실패단계유지·영수증은 유지한다. 기존+9반지는DEX3.81이다. 가방/상점/강화/영웅합계·포인트출처/DEX반지 장착비교에 DEX·공속·이속을 표시한다. 늘어난 비교행의 스크롤 높이를 계산한다. 새이미지/3D/업로드 없음.

순수 Lua12개 총10295검사 PASS(`tests.log`): 새반지130, 가족458, 시작206, 비교52, 고정공격110, 스탯효과576, 성장3711, 스킬미리보기1392, 삭제171, 강화2869, 상점304, 초기화316. 투자199/200/299/300 경계·강화DEX/배분미소비·가방효과없음·새시작공격5/방어기사8·그외5·기존강화정의·서버변경 전후 비교를 검증했다. 스킬미리보기의 직전 장비개편 전 기대(Tempered무기3/후드2)는 현재5/3으로 수정했다. 최초검사에서 이 오래된 기대가 실패했으며 수정후 통과했다.

다른 진행중 자산작업은 변경/커밋에 포함하지 않는다. 커밋된 src/tests를 임시archive 후 작업파일만 overlay하여 검사했다(`test-source.json`). 실제계정/게시클라이언트/기기·UI실제렌더/밸런스 수용은 미검증이고 부모티켓은 완료 처리하지 않는다. Roblox 게시/태그 없음. 후속QA는 반지탈착·강화·DEX상한·실제공격/이동/배분출처·모든가족 장갑/신발을 확인한다.

고정 소스 `c840c9351f1a9383e58049a5ea763aca9b23f9ae`를 origin/main에 푸시한 뒤 단일 빌드 **0.93.1 성공**. `builds/0.93.1/TheLastThrone-0.93.1.rbxlx` SHA256 `ac81f221361b23cdb54d3d7b6d0cad60aebe7c2ea381a2fbff436d4c5155280c`. `python3 tests/single-build.spec.py --artifact builds/0.93.1/TheLastThrone-0.93.1.rbxlx`: 역할10/도착로딩192/마운트·아티팩트구성 PASS. `run-in-roblox --place builds/0.93.1/TheLastThrone-0.93.1.rbxlx --script docs/evidence/copper-dex-secondary-20261109/native.luau`: 새반지130/가족458/시작206/비교52/고정공격110/삭제171/실제서버39=**1166검사 PASS**(`native.log`). 실제 production refreshEquipment/startAttack과 네 클래스 native Humanoid로 공속/이속·반지해제·공격동작길이·HP/MP 미회복·복제 공속을 검증했고 UI6개 모듈을 로딩했다. UI 렌더/실제플레이 입력 수용은 아니다. 최초 native 검사는 Humanoid WalkSpeed의 단정밀도 저장에 비해1e-7 허용오차가 작아 실패했다(`native-initial.log`). fixture 허용오차만1e-5로 수정하고 **같은 바이트의 빌드**로 재검증했다. 게임코드는 재빌드/변경하지 않았다. 테스트 fixture 수정은 이 증거와 함께 별도커밋한다. 연결된 사용자 Studio에는 소스를 적용하지 않았고 Roblox 미게시다. 새LFS 자산 없음.
