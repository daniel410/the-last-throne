# 네 에픽 리뷰·확장 계획 검증

2026-11-07 · TLT-001/050/057/061/063/064/065/084/087 · 문서 완료, 상위 구현 미완료

산출물은 [총괄 리뷰](../../production/other-epic-expansion-review-2026-11-07.md) 및 DW/GW/EC/HG의 개별7장 계획이다. 본편28장, 기존8사이드 개선과 신규4선택 후보를 구분했다. 기존 통합안/리서치/README/plan/backlog/decisions에 연결했다.

## 원천·방법

`lua`의 `dofile('src/shared/CampaignContent.luau')`로 현재 캠페인을 읽고 FV 외 장을 집계했다. 사용한 소스 커밋과 장별 목표/전투 목표/활동 하위 단계 수는 [content-inventory.json](content-inventory.json)에 있다. battleGoals는 비어 있지 않은 enemies 목록의 수이며 실제 웨이브/처치 수/플레이 시간이 아니다.

원본 DeepwoodContent/EmberCalderaContent/LateEpicContent와 현재 CampaignStoryText 투영을 대조했다. 월드는 DeepwoodWorld/EmberCalderaWorld/LateEpicWorld/EpicWorldArt, 활동은 DeepwoodActivities, 마지막 시각/안내는 HauntedFinaleVisual/StoryCompletion을 읽었다. 현재 Orik/Tali 호위와 Deepwood의 기존 조사/추적/지름길을 보존 대상으로 다뤘다. 과거 원본의 GW→HG·EC→GW 안내를 현재 연결로 오인하지 않았다. 원정 완료창 안내와 실제 로비 후일담 구현은 구분했다.

공식 Diablo II Act I/Act V, Diablo III 2.4.3, Roblox 스트리밍 문서를 웹에서 확인하고 같은 날짜의 리서치에 추가했다. 사실과 TLT 적용안은 별도 문장으로 작성했다.

## 검증 결과

- 인벤토리의 본편28개 ID가 각 지역 계획의 표에 각각1회씩 등장하는지 확인: PASS.
- 표의 기존 목표 접점이 현재 장의 실제 목표ID인지 대조: PASS.
- 새 계획/총괄/리서치/증거의 상대 링크 존재와 JSON 구문 검사: PASS.
- `git diff --check`: PASS.
- 런타임/보상 정본/VERSION 변경 없음. 문서 검증 범위에 맞춰 게임 테스트·빌드·Studio·게시를 수행하지 않았다.

## 미검증·다음 담당

실제 첫 완주/재도전 시간, 플레이 재미/반복감, 맵 최종 좌표·충돌·시야·성능, 영어 사용자 수용, 기존 계정 이관, 파티/기기 결과는 미검증이다. QA/PLAN이 기준 플레이를 기록하고 ENG가 버전/저장/보상 계약을 먼저 설계한다. 그 뒤 DES/ENG의 지역별 파일럿을 제작한다. 계획의 목표시간은 가설이며 기존 완료자는 추가 필수 진행을 강요받지 않는다.

문서만 선별 커밋·푸시한다. 기존 사용자 자산의 수정/삭제와 미추적 파일은 포함하지 않는다. 새 빌드/릴리스가 아니므로 VERSION/태그를 만들지 않는다.
