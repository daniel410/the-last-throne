# 현재 개발 상태

2026-11-11 · TLT-001/050/057/084 · 문서 정리 기준. 빌드 버전은 루트 `VERSION`을 읽는다.

- 이동: 0.102.6에서 딥우드의 폐기 투명 경계·새 길의 나무 충돌·복귀 산책로/경사면을 수정했다. [검증 범위·미게시·다른 지역 후속](../evidence/deepwood-boundary-stuck-20261111/README.md).
- 장비 외형: 0.102.5에서 TD 파생 머리카락을 마법사 모자·기사/드워프 투구·엘프 후드의 네 계열에 적용했다. [32조합·눈 영역/착용 검증·미게시](../evidence/headgear-hair-20261111/README.md). [로브 볼륨·모자 접합·투구 높이 보정](../evidence/mage-armor-fit-20261111/README.md)을 유지한다.
- NPC: 0.102.2에서 전체 에픽의 중복/개인 NPC 얼굴 숨김과 거리 최적화 간섭을 수정했다. [5에픽312장면·24,233검사/기존 회귀 한계·미게시](../evidence/all-epic-npc-visibility-20261111/README.md). 4계열 Meshy 방어구28종 적용은 [0.102.0 검증](../evidence/four-family-armor-20261111/README.md)을 따른다.
- 거점: TD 분홍 크리스탈 왕좌 원본 교정·300×300 Dawnspire 로비·HG07 완료 영웅의 개인 심장 복원. [검증/미게시](../evidence/dawnspire-crystal-throne-20261111/README.md).
- 본편: Deepwood → Gloamwood → Frozen Vale → Ember Caldera → Haunted Graveyard. 35본편·12선택, 반복 웨이브를 경로 교전으로 분산. [검증/미게시·남은 수용](../evidence/campaign-combat-routes-20261110/README.md).
- 마법사 모자:사용자 지정 최대 MP +10/+20/+30/+60으로 변경했다. 지력안을 대체하고 기존 서버 MP 집계/강화/메뉴 표시를 사용한다. [소스 회귀·엔진 미검증](../evidence/mage-hat-mp-20261111/README.md). PNG·신규 Traveler 지급은 기존0.101.0 기준이며 최대MP 변경의 전용 엔진·게시·실기기 수용은 후속이다.
- 최근 장비: Tempered/Veteran/Sentinel 부위별 재지정과 선택형 특수 효과. [수치 검증](../evidence/equipment-values-20261110/README.md), [효과 계약](equipment-special-effects-2026-11-10.md). 기존 장비 효과 자동 배정 없음.
- 최근 게시 기준은 [0.95.1 방패 확대 기록](../evidence/shield-size-20261109/README.md) 및 [0.95.0 게시 기록](../evidence/release-0.95.0-20261109/README.md)에서 확인한다. 로컬 버전을 게시 완료로 간주하지 않는다.
- 남은 수용: 게시 클라이언트/실계정 저장·재접속, 각 Experience 실제 이동, 1~4인+AI, 모바일/실기기 성능·전투 밸런스·사용자 미술 수용. 상세 범위는 해당 증거와 [QA 계획](qa-and-release-plan.md)을 따른다.

다음 작업은 진행 차단·유실·조작/가독성 결함을 우선해 [백로그](../../backlog.md)에서 선택한다. 문서 정리로 구현 티켓을 완료 처리하지 않는다.
