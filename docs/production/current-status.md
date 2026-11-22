# 현재 개발 상태


2026-11-15 · TLT-001/050/057/062/084 · 현재 문서 기준. 빌드 버전은 루트 `VERSION`을 읽는다.

- 최신 비공개 게시 빌드 0.115.33은 로비 118·배틀 43에 반영했다. Roblox Player에서 Dawnspire 진입과 기존 영웅 표시를 확인했다. [게시 및 빈 로비 복구 확인](../evidence/release-0.115.33-20261121/README.md)

- 영웅 기술 후보 0.115.46은 네 영웅의 이동 공격에서 방패 밀기, 어깨 충돌, 이동 사격, 서리 이탈을 각각 다른 자세와 명중 효과로 표현한다. 후보 미게시. 실제 4인 교전과 터치 실기기 수용은 후속이다. [이동 공격과 명중 검증](../evidence/hero-movement-skills-20261122/README.md) · [네 영웅 자세와 겹치는 피격](../evidence/hero-contact-weight-20261121/README.md) · [엘프 지연 발사](../evidence/elf-late-shot-motion-20261121/README.md) · [네 영웅의 발사축과 자세](../evidence/hero-release-alignment-20261121/README.md) · [파티 효과 우선순위](../evidence/hero-vfx-priority-20261121/README.md) · [여덟 궁극기와 타격 마무리](../evidence/hero-ultimate-finish-20261121/README.md)

- 에픽 퀘스트 0.115.29 후보는 11장의 반복 방문·조작 26회를 줄이고 다섯 결말과 다음 지역으로 이어지는 대사를 다듬었다. 후보 미게시·G5 진행 중. [Studio와 기존 저장 검증](../evidence/campaign-story-variety-20261121/README.md) · [1차 대표 행동과 현장 지물](../evidence/epic-quest-landmarks-20261119/README.md)
- 에픽 환경 후보 0.115.47은 다섯 에픽 1장·3장의 지물 10개를 최신 소스에 통합하고, GW 피난처 표식 아래 뿌리와 HG 관리 통로 귀환 문턱을 조형했다. 후보 미게시·G5 진행 중. [통합 빌드와 검증](../evidence/epic-early-story-integration-20261122/README.md) · [2장 길목](../evidence/epic-second-chapter-landmark-readability-20261122/README.md) · [4장 복구 지물](../evidence/epic-fourth-chapter-readability-20261121/README.md) · [7장 결말 접근면](../evidence/epic-finale-route-profiles-20261121/README.md)

- 몬스터와 페이즈 로딩은 0.114.25에서 근접 교전 시작 거리, 외형 선행 로드, 처치와 목표 저장을 개선했다. 비공개 로비·배틀에 게시했으며 실제 플레이 수용은 후속이다. [전후 재현·게시 기록·남은 수용](../evidence/monster-phase-loading-20261120/README.md) · [지역 생성과 반복 작업 계측](../evidence/world-runtime-optimization-20261118/README.md).

- 운영 오류 집계에서 확인한 지역 선행 로딩, 지도, 체크포인트와 원정 재접속 수정은 0.115.10 미게시 후보에 포함했다. [수정 근거·검증·인계](../evidence/runtime-errors-20261120/README.md).

- 배틀 입장과 진행 잠금: 0.113.16 후보는 확인된 저장 위치의 지역을 준비하고, 영웅 준비 시 즉시 교전과 스토리를 갱신한다. 일시적인 원정 갱신 오류는 마지막 소유권이 유효한 동안 진행을 막지 않는다. [입장·갱신 장애 재현 및 검증](../evidence/battle-arrival-latency-20261118/README.md). 후보 미게시. [지역 선행 준비·이동 복구](../evidence/battle-loading-20261117/README.md) · [부활·연속 이동 회귀](../evidence/battle-loading-review-20261117/README.md).

- TLT-053 파티 모집과 혼합 진도는 0.112.2로 빌드했다. 가입 전 현재 목적지와 합류 시 바뀔 임무를 확인할 수 있다. 실제 3계정 합류·입장은 게시 후 수용 항목이다. [빌드·Studio 검증](../evidence/party-campaign-sync-20261116/README.md).

- 원정 출발 장애: TLT-053의3인 전원 Ready/Start 뒤 무반응 보고에서, Ready/자동 조회 직후 cooldown으로 거절된 Launch가 유실되는 경로를 재현·수정했다.0.111.33을 로비104·배틀32에 게시했다. [요청 유실 재현·426회귀·게시·실제3인 수용 후속](../evidence/party-launch-request-20261116/README.md). [SortedMap 전환](../evidence/expedition-sorted-backend-20261116/README.md)과 [기존 원정 규칙 보존](../evidence/expedition-resume-rules-20261116/README.md)은 유지한다. 사용자의 실제 장애 원인 확정·게시 클라이언트 전원 입장은 미검증이며 G3 미완료다.

- 골드 경제: TLT-045의 승인된 감액안을 신규 원정19에 적용했다. 최신 정정으로 Studio 테스트 초기 재화는 복구했다. [지급·저장 호환 계약](gold-rewards-2026-11-16.md)·[보상 검증](../evidence/gold-reward-tuning-20261116/README.md)·[테스트 재화 복구 검증](../evidence/studio-test-currency-restore-20261116/README.md). 게시·실플레이 수용은 후속이다.

- FV-02 피난처: 굴뚝/난로 연결을 유지하고 0.111.9에서 실내 목재 마루8장을 배치했다. [고정 빌드·528구문·두 동선12,395표본·동일 카메라/실제 입력·미술 수용 후속](../evidence/fv02-floor-20261116/README.md). 미게시·G5 미완료.

- HG-03 추모 정원: 0.111.5에서 네 묘역의 낮은 측벽과 석재 덮개를 추가했다. [60파트·HG 두 동선9,941표본·같은 장면 비교/남은 실제 카메라 수용](../evidence/hg03-garden-20261116/README.md). 미게시·G5 미완료.
- EC-01 화물 시설: 0.111.1에서 기존 승강장 기둥을 권양 드럼·트러스로 연결했다. [고정 빌드·28파트/접지·두 동선16,922표본·전후 비교/미게시·남은 실제 카메라 수용](../evidence/ec01-freight-headframe-20261116/README.md). G5 미완료.
- 영웅 스킬 아이콘: 승인 Skill Tree 컨셉의 128종을 트리·상세·편성·HUD·궁극기에 연결했다. 0.115.9 후보에서 이미지 다운로드 지연이나 실패 중에도 스킬 약칭을 표시한다. 게시 클라이언트·실기기·미술 수용과 전체 G4는 미완료다. [초기 제작 및 등록](../evidence/hero-skill-icons-20261115/README.md) · [빈 아이콘 재현 및 수정 검증](../evidence/skill-icon-loading-20261120/README.md).

- 네 에픽 도보 경계는 0.115.1에서 노출 뿌리·압설·해빙 현무암 노두·관리로 절단석을 반영했다. [고정 빌드·Studio 왕복·전후 화면](../evidence/epic-boundary-relief-20261121/README.md) · [기존 FV→EC 해빙 지형 검증](../evidence/fv-ec-thaw-20261116/README.md). 실제 입력·실기기·미술 수용과 G5는 미완료다.
- 스토리 연결부 끼임: 0.110.29에서 사선 경계 전체 폭의 바닥·서버 높이를 일치시키고 옛 경사로 충돌/모서리 지형 돌출과 묻힌 복귀 위치 저장을 수정했다. [43연결부·43,173바닥 표본·실제 R15 28보행·R6/R15 복구8검사·두 경로 회귀/미게시·남은 클라이언트 수용](../evidence/story-passage-stuck-20261115/README.md).

- 로비 출발 안내: 솔로/멀티 시작 즉시 TD 공통 프레임으로 `ADVENTURE STARTING...`를 표시하고 저장·이동 준비 동안 유지한다. [출발 경계/격리 UI 검사·실제 Teleport 수용 후속](../evidence/adventure-starting-20261115/README.md).

- EC-03 구조 시설: 0.111.25에서 지지대·연속 채굴면과 TD 현무암3덩어리를 통합하고 하부를 매립했다. [두 동선16,922표본·535구문·원본 충돌/전후·접근 화면·미게시/남은 실제 플레이 수용](../evidence/ec03-quarry-mass-20261116/README.md). [기존 지지대13파트](../evidence/ec03-mine-support-20261116/README.md). G5 미완료.

- EC-03 채굴 흔적: 0.110.28에서 구조 통로 주변 비전투 여백을 TD 현무암 잔석3군집·9메시로 구성했다. [접지/충돌99검사·두 동선16,922표본·전후 비교/미게시·남은 실제 플레이 수용](../evidence/ec03-mine-spoil-20261115/README.md). G5 미완료.

- HG-03 관리 통로 지형: 0.110.24에서 주변 석질 언덕2·풍화 둔덕3을 조성하고 기존4묘역을 유지했다. [지형377검사·두 동선9,941표본·전후 비교/미게시·남은 실제 플레이 수용](../evidence/hg03-passage-banks-20261115/README.md). G5 미완료.

- HG 모델: TD 최신 Zombie·Ghoul을 연결하고, 0.110.13에서 종별 보행·양팔 공격·강공격 준비와 손 접지를 개선했다. [전후 포즈·고정 빌드 모션/표면/방향 검증·게시/미술 수용 후속](../evidence/undead-motion-review-20261115/README.md).

- 에픽 음악: 0.110.10 단일 빌드에 TD 신규5곡의 승인된 실제ID를 에픽별 설정으로 연결했고 TLT Experience 사용권한 성공 기록을 확인했다. 실제 TLT 재생/청취는 미검증이다. [소스 회귀·실제ID/권한·청취 후속](../evidence/epic-music-20261115/README.md).

- 난이도별 캠페인: 0.110.7에서 로비 퀘스트·지도는 활성 난이도의 실제 진도로 표시하고, 숨긴 로비 갱신이 필드의 미완료 장면을 공통 완료 모습으로 덮지 않도록 수정했다. [고정 빌드·9,319개 엔진 검사·미게시/일반 입력 수용 후속](../evidence/campaign-mode-consumer-fix-20261115/README.md).

- 몬스터 동작은 50종 146개 공격의 [기본 동작과 추격 보행](../evidence/monster-actions-20261116/README.md)을 사용한다. [무장 보스의 무기 손과 관절](../evidence/monster-weapon-hands-20261116/README.md)에 이어, 0.111.28에서 Veyr가 오른손 대검을 든 채 대기하고 오른쪽 위에서 몸 왼쪽까지 벤다. [같은 속도의 전후 영상·검끝과 손의 실측](../evidence/veyr-sword-swing-20261116/README.md).
- 몬스터 본체 소실: Sovereign의 누락 연결을 보완한0.111.33에서50종·분열체153모델의 연결/중력/이동/공격 재생23,759검사와 자산218개 Studio 로딩을 통과했다. 추가 분리 결함은 발견하지 않았으며 게시 클라이언트·기기 표시는 별도 수용이다. [전수 범위·증거·미검증](../evidence/all-monster-visibility-20261117/README.md).
- 몬스터 전투: 0.110.11에서 Hard/Insane/Hell 일반·정예·보스 공격력을25%/35%/50% 상향하고, 시선 회전이 추적 이동을 끊던 결함을 수정했다. 50종 개별 공략·23보스3단계·공격권은 유지한다. [현행 사양](monster-combat-design-2026-11-15.md)·[변경 전후 실제 R15·고정 빌드 엔진 검증/미게시·다인·실기기 수용 후속](../evidence/advanced-monster-combat-20261115/README.md).

- GW-01 조사 흔적: 0.110.8에서 정찰대 발자국을 밝은 압착 토양으로 표현해 밤에 화물 바퀴와 구분했다. [밤 조명/게임 범위 카메라 비교·11,213검사·두 동선 회귀·남은 실제 클라이언트/기기 수용](../evidence/gw01-night-readability-20261115/README.md). [앞선 둥근 형태/렌더 실패 수정](../evidence/gw-rounded-traces-20261115/README.md). [0.110.9 로컬 Play 보행·조사·회피/줌 검증 및 지역명 수정, 실제 마우스 회전 미검증](../evidence/gw01-play-camera-20261115/README.md).

- 지역 바닥 겹침: 0.109.3에서 GW·EC·HG의 새48면과 기존 FV20면을 공통 처리했다. [세 지역 A/B·물리 불변/복구·두 경로/실제 보행8조건·미게시/기기 수용 후속](../evidence/regional-underlays-20261115/README.md).

- FV-03 식생: 0.109.1에서 TD 설목을 크기·방향이 다른12개/5군집으로 배치했다. [원본 보존·전후 화면·두 경로/FV보행 검증·미게시/미술·기기 수용 후속](../evidence/fv03-verge-20261115/README.md).

- Caldera 경사: 0.108.1에서 평탄 접합부와 이전 바닥 충돌 은퇴로 남은 단차 검출6건을 해소했다. [두 경로 sweep·R15왕복4조건/미게시·넓은 측면/실기기 수용 후속](../evidence/ec-landings-20261115/README.md).

- 스토리 접근로: 0.107.12에서 기존/Easy 교전 경로를 각각 예약하고 묘지 소품을 안전 재배치에 포함해 GW-01·EC-05 및 HG-03/06 차단을 수정했다. [4지역 두 경로 sweep·실제 R15 접근4조건·전후 화면/미게시·남은 기기 수용](../evidence/route-blockers-20261115/README.md).

- 협곡 지형: 0.107.10에서 FV-03의 안전한 가장자리에 눈·노출 얼음·암반 지형을 추가했다. [대표 제작표·전후 화면·고정 엔진 검증과 남은 지역 차단/게시·실기기 수용](../evidence/fv03-glacial-landforms-20261115/README.md).

- 원정 네비: 0.107.9에서 같은 영웅의 새 원정에 이전 교전 좌표가 남는 진행 차단을 수정했다. [Hard 재입장·엔진/Studio 검증·미게시/남은 수용](../evidence/hard-route-stale-navigation-20261114/README.md).

- Dawnspire 왕좌: TD 최신 파란 크리스탈 원본을 동기화했다. [고정 빌드·엔진 검증/게시·기기·미술 수용](../evidence/dawnspire-blue-throne-20261114/README.md).

- 0.114.31에서 로비 카메라를 기존 구도로 복원하고 모바일 가로 HUD의 PLAY·영웅 아이콘·XP를 줄였다. XP를 영웅 아이콘 옆에 배치해 PLAY를 아래로 내렸다. [Studio 측정·캡처와 남은 수용](../evidence/lobby-compact-hud-011431/README.md).

- 무기 방어: 0.110.17에서 Elf·Dwarf·Mage의 무기를 턱 아래 전방에서 양손으로 받치도록 정렬했다. R15 팔꿈치/중립 손목·R6 강체 팔 풀이, 진입/해제·엘프 화살 정리를 적용했다. [실제 엔진·전후 비교/게시·기기·사용자 수용](../evidence/natural-weapon-block-20261115/README.md).

- 엘프·마법사 액션은 0.111.19에서 각 기본 공격과 스킬 32종에 사격·시전 자세를 적용했다. 엘프 연사는 발사 후 손의 경로를 이어 주고, 마법사 원소창과 궁극기는 지팡이와 빈손의 준비 방향을 구분한다. [전후 동작·전체 스킬 자세표·Studio 검증](../evidence/ranged-actions-20261116/README.md).
- 기사·드워프 액션은 0.111.18에서 기본 6동작과 스킬 64종의 체중 이동·무기 준비·회수를 수정했다. 기사의 내려베기→올려베기→가로베기와 드워프의 한손 도끼 3연격을 유지한다. [R6/R15 검증·로컬 Play·R15 전후 동작과 스킬 자세표](../evidence/melee-actions-20261116/README.md) · [기사 기본 검호 기준](../evidence/knight-wide-combo-20261115/README.md). 게시 클라이언트·실기기·사용자 수용은 후속이다.

- 드워프 기본3연격: 내려베기→되받아베기→넓은 마무리 베기의 서버3타·R6/R15 후보 검증을 통과했다. [빌드/검증·남은 수용](../evidence/dwarf-three-hit-20261114/README.md).

- 에픽 지도 연결: 실제 도보 경계의 왕복 연결선·다음 지도 버튼·선행 잠금 상태를 소스 추가했다. 후보 Studio 검증, 미게시. [검증/후속 수용](../evidence/epic-map-connections-20261114/README.md).

- 다이아몬드 Robux 상품: TD 구성의 세 묶음·ROBUX 탭·RPG 영구 영수증 지급을 소스 추가했다. 사용자 생성 상품ID 세 개와 상품별 아이콘·실시간 가격 조회를 소스 연결했다. [소스/이전 Studio Edit 검증·남은 게시/실구매 수용](../evidence/diamond-robux-products-20261114/README.md).

- 동작·착용·VFX 수명: 엘프 잔여 화살/얼굴 앞 시위 접점, Traveler·Tempered·Sentinel 후드 턱 겹침, Axe Throw 도착 후 궤적 재생을 수정했다. 전 영웅128기술·몬스터50종146공격에서 늦은 준비/발사 재생도 검사했다. [수정·엔진 검증·미게시/남은 수용](../evidence/visual-lifecycle-fit-20261113/README.md).
- 몬스터 공격: 0.104.15에서 기존35모티프·50조합에 원소별 재질/곡선 흐름·입자/국소광·표면 충돌/방사 파편을 보강했다. [실제 연속 재생·조사·고정 빌드 검증/미게시](../evidence/monster-spell-art-20261112/README.md). 기존 [종별 공격 연결](../evidence/monster-spell-vfx-20261112/README.md)과 [보스 피격·연속 준비/회수](../evidence/boss-impact-motion-20261112/README.md)를 유지하며 최종 미술/기기 수용은 별도다.
- 배틀 입장·장비: 0.104.7에 ColorMap 읽기 권한·엘프 몸통 생성 순서·훈련 음악의 스토리 Remote 무한 대기 수정을 포함했다. [최근24시간 CSV·일반 Script63검사·게시/실기기 미검증](../evidence/today-errors-20261111/README.md). 큰 나무 CollisionFidelity 권한 결함의 [5에픽 초기화34검사](../evidence/battle-world-permissions-20261111/README.md)를 유지한다.
- 장비 착용: 모든 무기·방어구·장신구의 레벨 제한과 가방/상점 요구 레벨 안내를 소스 제거했다. [기존 보유/이관·회귀·미게시](../evidence/equipment-level-free-20261111/README.md).
- 난이도·성장: 0.106.2의 규칙17에서 고정 처치/퀘스트 XP와 증가하는 고레벨 요구량을 분리하고 Hell 반복 감액·6회차 XP0을 제거했다. Easy 에픽10/17/23/27/30·Hard약60·Insane약80·Hell1~5회약90/95/97/98/99는 정상 누적 시 예상치다. 기존 난이도 완충·레벨99 상한·진도/레벨/XP·Gold/Diamonds/재료/장비를 유지한다. [정본 사양](campaign-growth-balance-2026-11-13.md)·[전후/회귀/Studio/고정 빌드 검증·미게시/남은 수용](../evidence/campaign-growth-rereview-20261113/README.md).
- 영웅 스킬 연출 0.115.17 후보는 Shield Breaker, Mountain Strike, Pinning Shot, Shatter Dart의 자세와 명중 형태를 다듬고 파티 효과가 겹칠 때 범용 섬광을 줄였다. [전후 화면·128개 스킬 회귀·남은 수용](../evidence/hero-impact-clarity-20261121/README.md) · [명중 방향과 회수](../evidence/hero-contact-direction-20261121/README.md) · [115개 기술의 무기 소켓 준비 효과](../evidence/hero-skill-choreography-20261120/README.md).
- 화살·마법의 발사 방향: 실제0.104.29 Play에서 몸/발사선32.73도 차이와 발사 확인의 시간 기준 불일치를 재현했다. 로컬 소유자의 시전 방향 제어·회전 정책 복원, 최종 서버 발사선 공유, 마법 정면/근접 원점을 수정했다. [실제 기록·엔진/Play 검증·미게시/남은 수용](../evidence/cast-facing-clock-20261113/README.md).
- 맵 접지·충돌: 0.103.10에서 5에픽 건축 기초·에린 앞 큰 나무 충돌을 보강하고 공중 폭포/천막을 제거했다. 스토리3 복귀 봉쇄를 옮기고 빈 장식 케이지를 실제 NPC 구출/문 열림/호위/저장 복원에 연결했다. [엔진 검증·미게시·남은 수용](../evidence/architecture-grounding-20261111/README.md).
- 맵 미술·지역 조명: 0.105.4에서 도보 재배치 뒤27구역 조명 오판정을 수정하고 대표물 규모/접근 방향·거미줄 연결·중경 암석·길 위계/재료를 보강했다. [고정 빌드·엔진/실제 화면·미게시/남은 수용](../evidence/story-terrain-fixes-20261113/README.md). Deepwood의 철회된 DW-03 거목 작업은 다시 적용하지 않았다.
- 스토리 물품·장면: 기존 [사건별 물품 지정](../evidence/story-props-context-20261112/README.md)에0.107.1의 DW-01 실제 길을 따르는 수레/발자국, FV-03 양안 봉화 응답, EC-01 기어 장착/화물 가동을 연결했다. [사양](quest-setpieces-2026-11-14.md)·[고정 빌드/개인 저장 투영 검사·미게시/남은 수용](../evidence/quest-setpieces-20261114/README.md). 실제 지형 재굴착·탑승형 이동 발판은 추가하지 않았다.
- 이동: 다섯 에픽을 본편 순서대로 인접 배치하고 네 경계의 도보 왕복 길·금빛 안내를 연결했다. 마지막 스토리 저장 뒤 강제 순간이동을 제거하고 재입장 시 이전 지역도 생성한다. [실제 R15 왕복·저장 실패·차단·회귀 검증/미게시](../evidence/epic-overland-20261113/README.md). 기존 [지역 장애물·목표 이동](../evidence/story-obstacles-travel-20261111/README.md), [에픽 내부 길](../evidence/epic-map-navigation-20261111/README.md), [Eryn 복귀](../evidence/deepwood-report-navigation-20261111/README.md)를 유지한다.
- 장비 외형: 로비 장착/해제 저장 후 외형 갱신 누락을 소스 수정했다. [전후 회귀·엔진/게시 미검증](../evidence/equipment-lobby-refresh-20261111/README.md). 0.102.8에서 무기·방패·방어구의 메시/색상 로딩 전 회색 노출을 가리고 텍스처를 명시적으로 프리로드한다. [48모델/120메시 엔진 시험·실기기 미검증](../evidence/equipment-asset-loading-20261111/README.md). 0.102.5에서 TD 파생 머리카락을 마법사 모자·기사/드워프 투구·엘프 후드의 네 계열에 적용했다. [32조합·눈 영역/착용 검증·미게시](../evidence/headgear-hair-20261111/README.md). [로브 볼륨·모자 접합·투구 높이 보정](../evidence/mage-armor-fit-20261111/README.md)을 유지한다. 영웅 컨셉 대조 머리카락 수정본은 [로컬 후보·업로드 권한 대기](../evidence/headgear-hair-concept-20261111/README.md)이며 현재 게임에는 미반영이다.
- NPC: 사용자 승인5k 모델29명과 Aldric·Brann 해머 수정본을0.113.6으로 로비109·배틀34에 게시했다. Selene는 유지한다. [게시·태그·남은 실제 플레이 수용](../evidence/release-0.113.6-20261117/README.md), [업로드·엔진 검증](../evidence/npc-apply-20261117/README.md). 중복/개인 NPC 표시의 기존 검증은 [5에픽312장면](../evidence/all-epic-npc-visibility-20261111/README.md), 4계열 방어구28종은 [검증 기록](../evidence/four-family-armor-20261111/README.md)을 따른다.
- 거점: TD 분홍 크리스탈 왕좌 원본 교정·300×300 Dawnspire 로비·HG07 완료 영웅의 개인 심장 복원. [검증/미게시](../evidence/dawnspire-crystal-throne-20261111/README.md).
- 본편: Deepwood → Gloamwood → Frozen Vale → Ember Caldera → Haunted Graveyard. 35본편·12선택, 반복 웨이브를 경로 교전으로 분산. 0.104.3에서 GW/HG·EC-05의 길목 전투13개와 기존 부분 저장 호환을 보강하고 전투 HUD 초기화를 연출 시작과 분리했다. [검증/미게시·남은 수용](../evidence/story-combat-pacing-20261111/README.md).
- 마법사 모자:사용자 지정 최대 MP +10/+20/+30/+60으로 변경했다. 지력안을 대체하고 기존 서버 MP 집계/강화/메뉴 표시를 사용한다. [소스 회귀·엔진 미검증](../evidence/mage-hat-mp-20261111/README.md). PNG·신규 Traveler 지급은 기존0.101.0 기준이며 최대MP 변경의 전용 엔진·게시·실기기 수용은 후속이다.
- 최근 장비: Tempered/Veteran/Sentinel 부위별 재지정과 선택형 특수 효과. [수치 검증](../evidence/equipment-values-20261110/README.md), [효과 계약](equipment-special-effects-2026-11-10.md). 기존 장비 효과 자동 배정 없음.
- 남은 수용: 게시 클라이언트/실계정 저장·재접속, 각 Experience 실제 이동, 1~4인+AI, 모바일/실기기 성능·전투 밸런스·사용자 미술 수용. 상세 범위는 해당 증거와 [QA 계획](qa-and-release-plan.md)을 따른다.

- GW-01 숲 가장자리: 0.110.5에서 반복 수목을 높이·깊이가 다른6군집으로 구성했다. [고정 빌드·110검사·지역 경로 감사·전후 화면·남은 수용](../evidence/gw01-verge-20261115/README.md). 실제 게임 카메라/실기기·미술 수용은 미검증이다.

다음 작업은 진행 차단·유실·조작/가독성 결함을 우선해 [백로그](../../backlog.md)에서 선택한다. 문서 정리로 구현 티켓을 완료 처리하지 않는다.

- GW-01 수색 지형: 0.110.6에서 석질 능선3·초피 둔덕4를 구성했다. [3,581 지형 검사·두 동선 감사·전후 비교·남은 실제 카메라/기기 수용](../evidence/gw01-search-ridges-20261115/README.md). G5 미완료.

- EC-03 광산 외곽: 0.111.30에서 기존 현무암 능선2곳의 매립 기저를 넓혀 하부 틈을 줄였다. 광산 시설56파트의 월드 변환/크기/충돌은 이전과 일치한다. [530구문·두 동선16,922표본·전후 화면/기각 후보·미게시/남은 실제 플레이 수용](../evidence/ec03-quarry-shoulders-20261117/README.md). G5 미완료.

- EC-03 구조 지지대: 철제 받침·목재 결속·압력판·균열 보를 소스 개선했다. 기존 크기/손잡이·다른 소품54종을 격리 Studio에서 확인했다. [0.113.2 실제 Play](../evidence/ec03-play-20261117/README.md)에서 지지대 접근·조작·개인 손잡이 색과 worm 진입을 확인했다. [후속 실제 Play](../evidence/ec03-rescue-play-20261117/README.md)에서 worm3경로·대피 준비3조작·Orik 호위2단계를 완료했다. 게시·미술 수용은 미검증이다. [비교·검증·후속](../evidence/ec03-brace-20261117/README.md).
