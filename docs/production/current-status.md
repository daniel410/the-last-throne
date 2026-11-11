# 현재 개발 상태

2026-11-11 · TLT-001/050/057/084 · 문서 정리 기준. 빌드 버전은 루트 `VERSION`을 읽는다.

- 장비 착용: 모든 무기·방어구·장신구의 레벨 제한과 가방/상점 요구 레벨 안내를 소스 제거했다. [기존 보유/이관·회귀·미게시](../evidence/equipment-level-free-20261111/README.md).
- 상위 난이도: Hard/Insane/Hell 레벨 제한 제거를 소스 반영했다. [솔로/파티/재접속 회귀·미게시](../evidence/difficulty-level-free-20261111/README.md).
- 영웅 VFX: 0.104.0 소스에서 기본공격 잔상·명중과 8계열 기술의 동작/원소별 리본·파편을 보강했다. [128스킬 엔진 검사·빌드·미게시/미수용](../evidence/hero-vfx-20261111/README.md).
- 엘프 발사: 0.103.11에서 기본 공격의 예상 발사 시간만으로 화살을 숨기던 모션을 서버의 해당 공격/발사체 확인에 연결했다. [재현·피해/속도 회귀·기존 종합 검사 한계](../evidence/elf-confirmed-release-20261111/README.md).
- 맵 접지·충돌: 0.103.10에서 5에픽 건축 기초·에린 앞 큰 나무 충돌을 보강하고 공중 폭포/천막을 제거했다. 스토리3 복귀 봉쇄를 옮기고 빈 장식 케이지를 실제 NPC 구출/문 열림/호위/저장 복원에 연결했다. [엔진 검증·미게시·남은 수용](../evidence/architecture-grounding-20261111/README.md).
- 맵 미술: 0.103.4에서 Blender 환경 키트10종·44지역 지면/원경·지역 조명과 화산 대문 접지를 보강했다. [실제 Studio 전후·검증·미게시·남은 시각/성능 수용](../evidence/epic-environment-20261111/README.md).
- 이동: 스토리 유리벽→개인 지역 바위 장애물, 출구→다음 필수 목표 이동, 구호 NPC 앞 판자 제거를 구현했다. [엔진 검증/미게시/수용 범위](../evidence/story-obstacles-travel-20261111/README.md). 0.102.10에서 나머지4에픽의 보고 안내 반복·통로 물체·경계선 정체를 수정했다. [36스토리/457목표·30연결로·실제 R15 보행10개 통과·미게시](../evidence/epic-map-navigation-20261111/README.md). [Eryn 복귀 수정](../evidence/deepwood-report-navigation-20261111/README.md)을 유지한다.
- 장비 외형: 로비 장착/해제 저장 후 외형 갱신 누락을 소스 수정했다. [전후 회귀·엔진/게시 미검증](../evidence/equipment-lobby-refresh-20261111/README.md). 0.102.8에서 무기·방패·방어구의 메시/색상 로딩 전 회색 노출을 가리고 텍스처를 명시적으로 프리로드한다. [48모델/120메시 엔진 시험·실기기 미검증](../evidence/equipment-asset-loading-20261111/README.md). 0.102.5에서 TD 파생 머리카락을 마법사 모자·기사/드워프 투구·엘프 후드의 네 계열에 적용했다. [32조합·눈 영역/착용 검증·미게시](../evidence/headgear-hair-20261111/README.md). [로브 볼륨·모자 접합·투구 높이 보정](../evidence/mage-armor-fit-20261111/README.md)을 유지한다. 영웅 컨셉 대조 머리카락 수정본은 [로컬 후보·업로드 권한 대기](../evidence/headgear-hair-concept-20261111/README.md)이며 현재 게임에는 미반영이다.
- NPC: 0.102.2에서 전체 에픽의 중복/개인 NPC 얼굴 숨김과 거리 최적화 간섭을 수정했다. [5에픽312장면·24,233검사/기존 회귀 한계·미게시](../evidence/all-epic-npc-visibility-20261111/README.md). 4계열 Meshy 방어구28종 적용은 [0.102.0 검증](../evidence/four-family-armor-20261111/README.md)을 따른다.
- 거점: TD 분홍 크리스탈 왕좌 원본 교정·300×300 Dawnspire 로비·HG07 완료 영웅의 개인 심장 복원. [검증/미게시](../evidence/dawnspire-crystal-throne-20261111/README.md).
- 본편: Deepwood → Gloamwood → Frozen Vale → Ember Caldera → Haunted Graveyard. 35본편·12선택, 반복 웨이브를 경로 교전으로 분산. [검증/미게시·남은 수용](../evidence/campaign-combat-routes-20261110/README.md).
- 마법사 모자:사용자 지정 최대 MP +10/+20/+30/+60으로 변경했다. 지력안을 대체하고 기존 서버 MP 집계/강화/메뉴 표시를 사용한다. [소스 회귀·엔진 미검증](../evidence/mage-hat-mp-20261111/README.md). PNG·신규 Traveler 지급은 기존0.101.0 기준이며 최대MP 변경의 전용 엔진·게시·실기기 수용은 후속이다.
- 최근 장비: Tempered/Veteran/Sentinel 부위별 재지정과 선택형 특수 효과. [수치 검증](../evidence/equipment-values-20261110/README.md), [효과 계약](equipment-special-effects-2026-11-10.md). 기존 장비 효과 자동 배정 없음.
- 최근 게시: **0.103.12**, 로비 버전94·배틀 버전21. 최신 엘프 발사·맵 수정 포함, 기존 Private 유지, Studio 종료 확인. [빌드/게시·검증·미검증 범위](../evidence/release-0.103.12-20261111/README.md).
- 남은 수용: 게시 클라이언트/실계정 저장·재접속, 각 Experience 실제 이동, 1~4인+AI, 모바일/실기기 성능·전투 밸런스·사용자 미술 수용. 상세 범위는 해당 증거와 [QA 계획](qa-and-release-plan.md)을 따른다.

다음 작업은 진행 차단·유실·조작/가독성 결함을 우선해 [백로그](../../backlog.md)에서 선택한다. 문서 정리로 구현 티켓을 완료 처리하지 않는다.
