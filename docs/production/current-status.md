# 현재 개발 상태

2026-11-13 · TLT-001/050/057/084 · 현재 문서 기준. 빌드 버전은 루트 `VERSION`을 읽는다.

- 동작·착용·VFX 수명: 엘프 잔여 화살/얼굴 앞 시위 접점, Traveler·Tempered·Sentinel 후드 턱 겹침, Axe Throw 도착 후 궤적 재생을 수정했다. 전 영웅128기술·몬스터50종146공격에서 늦은 준비/발사 재생도 검사했다. [수정·엔진 검증·미게시/남은 수용](../evidence/visual-lifecycle-fit-20261113/README.md).
- 몬스터 공격: 0.104.15에서 기존35모티프·50조합에 원소별 재질/곡선 흐름·입자/국소광·표면 충돌/방사 파편을 보강했다. [실제 연속 재생·조사·고정 빌드 검증/미게시](../evidence/monster-spell-art-20261112/README.md). 기존 [종별 공격 연결](../evidence/monster-spell-vfx-20261112/README.md)과 [보스 피격·연속 준비/회수](../evidence/boss-impact-motion-20261112/README.md)를 유지하며 최종 미술/기기 수용은 별도다.
- 배틀 입장·장비: 0.104.7에 ColorMap 읽기 권한·엘프 몸통 생성 순서·훈련 음악의 스토리 Remote 무한 대기 수정을 포함했다. [최근24시간 CSV·일반 Script63검사·게시/실기기 미검증](../evidence/today-errors-20261111/README.md). 큰 나무 CollisionFidelity 권한 결함의 [5에픽 초기화34검사](../evidence/battle-world-permissions-20261111/README.md)를 유지한다.
- 장비 착용: 모든 무기·방어구·장신구의 레벨 제한과 가방/상점 요구 레벨 안내를 소스 제거했다. [기존 보유/이관·회귀·미게시](../evidence/equipment-level-free-20261111/README.md).
- 난이도·성장: 0.106.1의 새 원정 규칙16에 Easy 에픽10/17/23/27/30 → Hard60 → Insane80 → Hell1~5회90/95/97/98/99, 최고99와 지역 난이도 완충을 구현했다. 기존 원정·Gold/Diamonds/재료/장비와 Hard 개방/상위 모드 무레벨 조건을 유지한다. [정본 사양](campaign-growth-balance-2026-11-13.md)·[고정 빌드·계정/원정·Studio Luau 검증·미게시/남은 수용](../evidence/campaign-growth-balance-20261113/README.md).
- 영웅 VFX: 속성별 주 형상·금빛 성속성·전용 바람, 번개 분기·냉기 성장·가속 하강을 유지한다. [미술 기준](element-vfx.md), [무료 원천/권한](../evidence/curated-vfx-20261112/README.md).
- VFX: 0.105.6에서 돌진11공격의 예고 수명·패턴 예고 설정OFF를 수정하고, 궁극기3종·검기3종·명궁2종·화염3종의 식별성과 중복 장식을 정리했다. [고정 빌드18묶음 엔진 회귀·전후/막펄스51장·미게시/남은 실제 수용](../evidence/vfx-review-fixes-20261113/README.md). 실제 지역/다인/실기기·사용자 미술 수용은 남아 있다.
- 화살·마법의 발사 방향: 실제0.104.29 Play에서 몸/발사선32.73도 차이와 발사 확인의 시간 기준 불일치를 재현했다. 로컬 소유자의 시전 방향 제어·회전 정책 복원, 최종 서버 발사선 공유, 마법 정면/근접 원점을 수정했다. [실제 기록·엔진/Play 검증·미게시/남은 수용](../evidence/cast-facing-clock-20261113/README.md).
- 맵 접지·충돌: 0.103.10에서 5에픽 건축 기초·에린 앞 큰 나무 충돌을 보강하고 공중 폭포/천막을 제거했다. 스토리3 복귀 봉쇄를 옮기고 빈 장식 케이지를 실제 NPC 구출/문 열림/호위/저장 복원에 연결했다. [엔진 검증·미게시·남은 수용](../evidence/architecture-grounding-20261111/README.md).
- 맵 미술·지역 조명: 0.105.4에서 도보 재배치 뒤27구역 조명 오판정을 수정하고 대표물 규모/접근 방향·거미줄 연결·중경 암석·길 위계/재료를 보강했다. [고정 빌드·엔진/실제 화면·미게시/남은 수용](../evidence/story-terrain-fixes-20261113/README.md). Deepwood의 철회된 DW-03 거목 작업은 다시 적용하지 않았다.
- 스토리 물품: 0.104.13에서 숲길 책상 반복을 제거하고 사건별 물품을 직접 연결했다. [물품 사양·엔진/화면 검증·미게시/남은 수용](../evidence/story-props-context-20261112/README.md).
- 이동: 다섯 에픽을 본편 순서대로 인접 배치하고 네 경계의 도보 왕복 길·금빛 안내를 연결했다. 마지막 스토리 저장 뒤 강제 순간이동을 제거하고 재입장 시 이전 지역도 생성한다. [실제 R15 왕복·저장 실패·차단·회귀 검증/미게시](../evidence/epic-overland-20261113/README.md). 기존 [지역 장애물·목표 이동](../evidence/story-obstacles-travel-20261111/README.md), [에픽 내부 길](../evidence/epic-map-navigation-20261111/README.md), [Eryn 복귀](../evidence/deepwood-report-navigation-20261111/README.md)를 유지한다.
- 장비 외형: 로비 장착/해제 저장 후 외형 갱신 누락을 소스 수정했다. [전후 회귀·엔진/게시 미검증](../evidence/equipment-lobby-refresh-20261111/README.md). 0.102.8에서 무기·방패·방어구의 메시/색상 로딩 전 회색 노출을 가리고 텍스처를 명시적으로 프리로드한다. [48모델/120메시 엔진 시험·실기기 미검증](../evidence/equipment-asset-loading-20261111/README.md). 0.102.5에서 TD 파생 머리카락을 마법사 모자·기사/드워프 투구·엘프 후드의 네 계열에 적용했다. [32조합·눈 영역/착용 검증·미게시](../evidence/headgear-hair-20261111/README.md). [로브 볼륨·모자 접합·투구 높이 보정](../evidence/mage-armor-fit-20261111/README.md)을 유지한다. 영웅 컨셉 대조 머리카락 수정본은 [로컬 후보·업로드 권한 대기](../evidence/headgear-hair-concept-20261111/README.md)이며 현재 게임에는 미반영이다.
- NPC: 0.102.2에서 전체 에픽의 중복/개인 NPC 얼굴 숨김과 거리 최적화 간섭을 수정했다. [5에픽312장면·24,233검사/기존 회귀 한계·미게시](../evidence/all-epic-npc-visibility-20261111/README.md). 4계열 Meshy 방어구28종 적용은 [0.102.0 검증](../evidence/four-family-armor-20261111/README.md)을 따른다.
- 거점: TD 분홍 크리스탈 왕좌 원본 교정·300×300 Dawnspire 로비·HG07 완료 영웅의 개인 심장 복원. [검증/미게시](../evidence/dawnspire-crystal-throne-20261111/README.md).
- 본편: Deepwood → Gloamwood → Frozen Vale → Ember Caldera → Haunted Graveyard. 35본편·12선택, 반복 웨이브를 경로 교전으로 분산. 0.104.3에서 GW/HG·EC-05의 길목 전투13개와 기존 부분 저장 호환을 보강하고 전투 HUD 초기화를 연출 시작과 분리했다. [검증/미게시·남은 수용](../evidence/story-combat-pacing-20261111/README.md).
- 마법사 모자:사용자 지정 최대 MP +10/+20/+30/+60으로 변경했다. 지력안을 대체하고 기존 서버 MP 집계/강화/메뉴 표시를 사용한다. [소스 회귀·엔진 미검증](../evidence/mage-hat-mp-20261111/README.md). PNG·신규 Traveler 지급은 기존0.101.0 기준이며 최대MP 변경의 전용 엔진·게시·실기기 수용은 후속이다.
- 최근 장비: Tempered/Veteran/Sentinel 부위별 재지정과 선택형 특수 효과. [수치 검증](../evidence/equipment-values-20261110/README.md), [효과 계약](equipment-special-effects-2026-11-10.md). 기존 장비 효과 자동 배정 없음.
- 최근 게시: **0.104.1**, 로비 버전95·배틀 버전22. 최신128스킬 VFX·장비 착용/상위 난이도 레벨 제한 제거 포함, 기존 Private 유지. 읽기 전용 중복 Studio 창 종료는 미완료. [게시·검증·미검증 범위](../evidence/release-0.104.1-20261111/README.md).
- 남은 수용: 게시 클라이언트/실계정 저장·재접속, 각 Experience 실제 이동, 1~4인+AI, 모바일/실기기 성능·전투 밸런스·사용자 미술 수용. 상세 범위는 해당 증거와 [QA 계획](qa-and-release-plan.md)을 따른다.

다음 작업은 진행 차단·유실·조작/가독성 결함을 우선해 [백로그](../../backlog.md)에서 선택한다. 문서 정리로 구현 티켓을 완료 처리하지 않는다.
