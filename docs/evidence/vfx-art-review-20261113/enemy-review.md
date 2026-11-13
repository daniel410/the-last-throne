# 몬스터·보스 VFX 아트 전수 리뷰

TLT-033/057/061~065/084 · ART/DES · 2026-11-13 · 소스 `974c2553639691eea8141c2302a09b2d257f4850` / 게임0.104.25.

판정은 **기존 원소 대분류·위험 경계·안전 중심은 유지하고, 예고의 비색상 구분과 종별/접촉 표현을 부분 보강**이다. 카탈로그 리뷰는 마쳤으나 실제 전투·실기기·사용자 미술 수용은 보류한다. 게임 코드·전투 수치·버전은 변경하지 않았다.

## 실제로 검토한 범위

[기계 판독 전수 목록·근거·파일별 SHA256](enemy-review.json)에50종(일반27/보스23),146공격,40투사체 공격을 개별 ID로 기록했다. 시각 모티프35개, 종+모티프+장식60조합이며 전역 모티프+장식은58조합이다. 종별 기본50조합에 공격 override10조합이 더해진다. 데이터 고유 조합 수를 시각 식별 성공 수로 바꾸지 않았다.

| 검토 | 범위 | 확인한 것과 한계 |
| --- | --- | --- |
| 소스·정의 전수 | 146/146공격,6shape | projectile40/cone40/line33/trail14/ring12/circle7. 기존 표시 연결·형상·색·시전/소멸·안전 중심·예산을 읽음. 코드 읽기는 실제 모션 수용이 아님 |
| 최신 모티프 그림 | [60조합/8시트](enemy/manifest.json) 전부 직접 열람 | 좌charge/중primary. Charge1.65배, projectile1.65배/pulse0.45배 정규화. 실제 종별 캐스터 대신 회색 모형 사용.17개 physical charge는 현행 런타임이 시전하는 효과가 아닌 라이브러리 견본 |
| 고리 추가 그림 | [12공격/2시트](enemy-rings/manifest.json) 전부 직접 열람 | 누락된 모든 ring primary 보완. pulse0.45배.4개 physical charge 역시 라이브러리 견본 |
| 근접 접촉 | [20시각 서명/3시트](enemy-impacts/manifest.json) 전부 직접 열람 | family+RGB+magic/heavy 차이20개. 앞면 법선·근접 카메라,1.4배. 형상/재질을 판독하며 실제 명중 위치·위력·모션은 수용하지 않음 |
| 실제 예고 생성기 | [6shape×방어 여부12그림](warnings/manifest.json) 전부 직접 열람 | 원본 공격 정의와 `EnemyPatternEffects.observe/render` 사용. 크기 정규화 없음. 합성 속성/시계·평평한 walkable Ground·회색 배우이며 실제 맵·네트워크·다인 환경은 아님 |
| 기존 시간/캐스터 보조 증거 | [얼음](../monster-spell-art-20261112/ice-timing.png), [비전](../monster-spell-art-20261112/arcane-timing.png), [보스 고리](../monster-spell-art-20261112/boss-ring-timing.png), [화염](../monster-spell-art-20261112/fire-live.gif), [보스 몸부착 접촉](../boss-impact-motion-20261112/contact-preview.png) | 앞의3시트와 화염GIF15/30/45/60프레임, 보스 접촉 표본 직접 열람. 이전 빌드의 제한된 장면이며 전체146공격의 연속 재생이라고 주장하지 않음 |

자기 공격의 primary를 직접 촬영한 것은72/146개(모티프 대표60+ring12)다. 나머지74개는 소스와 같은 종/모티프 조합 및 같은 접촉 서명으로 검토했다. **146개 모두의 실제 캐스터·각 펄스·발사/충돌 동작을 촬영한 것은 아니다.** 각 공격의 직접 프레임 유무와 공유 표본 ID는 JSON에 구분했다.

초기60장과ring12장의 오른쪽 impact는 회색 표적 뒤로 접점이 놓인 촬영 문제로 가려졌다. 이 부분은 명중 강도/가림 평가에서 전부 제외하고, 표적 앞면으로 생성한 추가20장만 접촉 판단에 사용했다. 제품 런타임의 명중 가림 결함으로 보고하지 않는다. 원본 캡처와 해시는 보존했다.

## 유지할 점

- 어두운 단독 바닥에서 예고 선의 대비가 높고 부채꼴·선·원형·고리·연속 원형·투사체 차이가 읽힌다. 지면을 불투명하게 덮지 않아 대상과 바닥이 남는다.
- 고리의 안전 중심을 채우지 않는 원칙은12종에서 일관된다. 다음 보강도 이 빈 공간과 실제 판정 경계를 보존해야 한다.
- 얼음의 반투명 결정, 흙의 거친 파편, 물리 절삭이 접촉 표본에서 분리된다. 화염의 따뜻한 핵/연기, Lich의 영혼 가면, Veyr의 틈/유색 윤곽, 거미줄의 격자는 대분류 단서가 있다.
- 영웅/바닥 전체를 덮는 상시 화면 효과 대신 국소 기하·짧은 잔향을 쓰는 방향은 유지한다. 이는 GPU/기기 성능 통과나 다인 가림 통과를 뜻하지 않는다.

시각 family는 frost30/earth22/fire31/shadow16/physical17/arcane6/soul8/web6/venom10이다. 이것은 피해 element와 다른 표시 분류다. 예를 들어 물리 돌/뿌리를 earth family로 묶은 것, Mummy의 sand family와 실제 soul 판정 등을 새 피해 규칙이나 오류로 간주하지 않았다.

## 수정 우선순위

| ID·우선 | 직접 관찰·소스 근거 | 권장 변경·수용 조건 |
| --- | --- | --- |
| **EN-ART-01 · P1** | [예고1](warnings/sheet-01.png)·[예고2](warnings/sheet-02.png)에서 바닥 경계 자체의 방어 가능/불가 구분은 황색/적색에 의존한다. 특히 circle/ring/trail 쌍은 비색상 표식이 없다. `EnemyPatternEffects`243~247행도 같은 선 생성에 색만 선택한다.104개 blockable/42개 unblockable에 공통 | 실제 경계·안전 중심을 유지하고 불가 예고에 반복 쐐기/이중 단절선 등 보조 문법을 검토한다. 색 제거 표본과 실제 전투에서 형태만으로 방어 여부를 읽는지 확인한다. 실제 몬스터 포즈가 제공하는 보조 정보까지 없다고 단정한 것은 아님 |
| **EN-ART-02 · P2** | Imp/MagmaImp/InfernoOverlord/KingVolcanoShaman/VolcanoShaman의 비행 견본은 주황 핵과 짧은 연기로 수렴한다. [표본3](enemy/sheet-03.png)·[4](enemy/sheet-04.png)·[5](enemy/sheet-05.png)·[7](enemy/sheet-07.png). `Accent_`는0.09×0.28×0.12stud/투명도0.84여서 데이터상의 종별 조합이 효과의 주 특징으로 강하게 읽히지 않는다 | 선택한 보스의 주 실루엣/꼬리 리듬 하나를 강화하고 전역 광량·입자 수만 늘리는 방식은 피한다. 실제 캐스터를 포함한 같은 전투 거리에서 일반/보스 위계를 다시 본다. 이 정규화 그림만으로 실전에서 모든 종이 혼동된다고 판정하지 않음 |
| **EN-ART-03 · P2** | [KingIceBear snow](enemy/sheet-04.png)와 [Mummy sand](enemy/sheet-05.png)의 중심이 청색/황색의 같은6갈래 별로 보인다. `EnemySpellVFX`112행의 snow/sand/dust가 같은 방사선을 만든다 | 눈은 분기 결정/날카로운 파편, 모래는 거친 입자 흐름처럼 주 형상을 분리한다. 실제 element/피해는 보존한다. 색 제거·실제 전투 거리에서 형상과 움직임으로 구별하는지 확인 |
| **EN-ART-04 · P2** | [고리1](enemy-rings/sheet-01.png)·[고리2](enemy-rings/sheet-02.png)와 기존 실제 보스 표본에서 위험띠의 면적보다 원 둘레의 작은 기둥/룬/불꽃이 주로 보인다. `EnemySpellVFX`215~216행의 crest는radius94%, `EnemySpellArt`175~178행의 분출은radius90%에 집중 | 안전 중심은 비우고 위험띠 안쪽의 제한된 지점에 낮은 균열/분출 리듬을 배치하는 시안을 비교한다. 실제 보스·맵·카메라에서 안전 중심/위험띠가 읽히고 다른 예고를 가리지 않아야 한다. 정규화0.45배로 실제 위력/크기를 판정하거나 회피 실패를 확인한 것은 아님 |
| **EN-ART-05 · P2** | [근접1](enemy-impacts/sheet-01.png)·[2](enemy-impacts/sheet-02.png)·[3](enemy-impacts/sheet-03.png)에서 arcane/soul/shadow/web의 주 접촉 형상이 색이 다른 원형 광륜+각진 방사 파편에 편중된다. 비행의 룬/영혼/틈/실 정체성은 접촉에서 약해진다 | 명중광은 유지하고 web의 실, soul의 상승 흐름, shadow의 안쪽 수렴/불연속 가장자리, arcane의 룬 파편 중 잔향 하나씩을 구별한다. 범용 고리 일부를 대체해 기존 예산을 유지한다. 연속 재생과 실제 영웅에서 얼굴/방패·위험 바닥 가림을 재검토. **명중 자체가 안 보이거나 약하다는 판정은 아님** |

P1/P2는 이번 ART 수정 우선순위이며 서버 결함/출시 차단의 자동 판정이 아니다. 실제 구현 전에는 기존 Diablo/WoW/Roblox 조사와 연결해 시안을 비교하고, 기존 피해·범위·시전 순서·예산을 보존한다. 이 리뷰에서는 시안을 자동 적용하지 않았다.

## 고리12개별 판독

| 공격ID | primary에서 읽힌 것 | 다음 확인 |
| --- | --- | --- |
| AncientHollowbark.4 | 녹색/황색 작은 뿌리 가시의 외곽 고리, 중심 비움 | 위험띠 내부의 뿌리 흐름·보스 위력 |
| Golem.2 | 낮은 흙빛 파편/외곽 원 | 바위 분출의 무게·실제 지면 대비 |
| HollowbarkSovereign.4 | AncientHollowbark와 가까운 뿌리 가시 고리 | Sovereign 주 특징·일반 보스와 구별 |
| InfernoOverlord.4 | 주황 기둥/불꽃·연기 원, 중심 비움 | 띠 안쪽의 화염 위력과 위험 예고 공존 |
| KingIceBear.4 | 청색 핀형 결정의 원 | 눈/빙진 흐름·IceGolem 계열과 주 특징 구별 |
| KingIceGolem.4 | 청색 결정+옅은 냉기 뭉치의 원 | 거친 결정 덩어리/분열 리듬 |
| KingOgre.4 | Golem과 가까운 낮은 흙빛 외곽 원 | 왕의 강공격 위력·행동 문맥 |
| KingShaman.4 | 보라색 X형 룬/밝은 점을 둔 원 | 단순 장식보다 위험 분출로 읽히는지 |
| KingVolcanoShaman.4 | InfernoOverlord와 가까운 화염/연기 원 | 분출 리듬·토템/룬 계열 특성 |
| LichSovereign.4 | 민트색 X형 룬/밝은 점의 원 | 영혼의 흐름·비전 고리와 형상 구별 |
| Mummy.2 | 작은 황색 별/룬의 원 | 모래의 입자감. 실제 soul 판정은 유지 |
| Veyr.3 | 보라색 X형 룬의 원, 중심 비움 | 틈/그림자 흐름. 이 공격은blockable·heavy=false이므로 강공격 위력 지적의 직접 대상은 아님 |

## 보류·실전에서 확인할 항목

`BossHeroImpact`의 물리/거미줄 라이브러리 표본은 둘 다 옅은 X형 교차선으로 보인다. 다만 현행23보스·146공격 중 실제 element가web인 보스 공격은0개다. 따라서 활성 보스의 실제 구분 결함으로 올리지 않고 예비 표현의 보류 메모로만 남겼다. 몸부착 얼음/불/독 장식이 실제 지속 상태이상으로 오해되는지도 아직 사용자 관찰이 없다.

`K0EnemyControlEffects`의3개 별/회전·만료/사망 정리 경로는 소스로 확인했다.50종의 실제 머리/이름표와 겹치는지는 미검증이다. 아군/적의 비슷한 청색/주황 원소가 동시에 나오는 장면, 기울어진/밝은 눈/용암 바닥, 회피 중 표적 가림,4인+AI, 터치/패드·작은 화면·낮은 그래픽·색각·GPU/프레임 시간도 미검증이다.

다음 ART/ENG는 EN-ART-01을 먼저 시안화하고 EN-ART-02~05를 같은 캐스터·조명·카메라에서 비교한다. 다음 QA는 실제 전투의 정보 식별/위험 가림과 기기 비용을 검증한다. 이 증거가 충족돼야 미술 수용/부모 티켓 상태를 갱신한다.

## 소스 동일성·재현

아래 전체 SHA256은 현재 파일과 비교 기준 커밋에서 동일하다. [JSON](enemy-review.json)에 baseline/current 값을 각각 보존했다. 따라서0.104.15 이후 몬스터 VFX가 바뀐 것으로 보고하지 않았다. 기존0.104.14 얼음/비전/화염 보조 자료와0.104.15 차이는 `EnemySpellArt`의ring 분출 추가뿐이며, 다른 경로의 과거 표본을 현행 전체 수용으로 확대하지 않는다.

| 파일 | 비교 기준 | 현재/기준 공통 SHA256 |
| --- | --- | --- |
| EnemyPatterns |09176c81|`a6eb166aa36221be66c99ee7b9288576dabc420287cadc0098531977761eda98`|
| EnemySpellProfiles |09176c81|`fbced7b3c67ef8bb11ba4eac847e853691c38c8608e1b279f9d88a1fd3c48639`|
| EnemySpellVFX |09176c81|`3f41ff92e0c4439b43aca595f3a3b5265a264d028eb4a0eb0d5a9bdcbb56fab5`|
| EnemySpellArt |09176c81|`0ff7672f7d3e6a4a222b890fad3187e4ac62e58e67b9b7518c5c67a9e6e29586`|
| EnemyPatternEffects |09176c81|`13d1abf5d020852f1a26f6f802eb69a96c22297e2f08877ad65b3c5dfe84145e`|
| K0EnemyControlEffects |09176c81|`22b5c00c5da0447289f30010e93e461ceb722d23a68ff63d46fb980d334cbefb`|
| BossHeroImpact |11dff28c|`0036a456336c9996f33d78381abdd4545b9c68c81ceca92ba22dda17445bc391`|

생산 모듈을 담은 root의 계정/저장 없는 격리 Place에서 [모티프](enemy-capture.luau) → [예고](enemy-warning-capture.luau) → [고리](enemy-ring-capture.luau) → [근접 접촉](enemy-impact-capture.luau)을 순차 실행했다. 각각 생산 생성기의 그림이며 공격 판정/RemoteEvent/실제 맵을 실행한 것이 아니다. 처음 무압축 전송이CLI1MB 한도를 넘어 무손실 Zstd 전송으로 바꿨고 최종 그림은640폭8bit RGB다. 이 전송 실패를 제품 렌더링 실패로 간주하지 않는다. 캡처 도구4개는 Luau 컴파일을 통과했다.
