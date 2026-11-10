# 로비 Continue의 이전 원정 선택 재사용 수정 · 0.95.4

2026-11-09 · TLT-050/057/061~065/084 · 구현·로컬 회귀 / 미게시

사용자는 Deepwood 완료 후 로비 Continue로 입장했을 때 Deepwood가 다시 시작됐다고 보고했다. 제작 스킬과 엔지니어/QA 계약에 따라 확인했다. 실제 사용자 계정 저장은 읽거나 수정하지 않았다. 열린 사용자 Studio는 Edit 상태였으며 데이터/세션 변경 없음.

확인된 결함: ExpeditionService.beforeHeroAction의 StartTutorial(로비 시작)은 Service.solo를 호출하면서, 원정 창 Configure가 남긴 selections[player]를 그대로 사용했다. 이 캐시는 정상 본편 선택 AdventureRules.selection보다 우선한다. 따라서 완료 기록이 남아 있어도 이전 Deepwood 선택으로 재입장할 수 있다. 로비 시작 시 캐시를 제거해 현재 저장 진행을 다시 선택하도록 수정했다. 원정 창의 명시적 Solo/파티/재플레이 선택은 유지한다. 실제 사용자 계정에서 같은 원인이었는지는 미확인이다.

확장 이관 검사에서는 기존 완료 기록의 손실을 재현하지 못했다. 별도 추가 회귀에서 확장 이전 Deepwood7장 완료 영웅을 현행 규칙13의 GW-01로 입장시켜 main7·완료7장·Gold를 보존하고 Gloamwood를 추적하는 것을 확인했다. 기존 규칙12 복귀 검사는 확장 뒤 바뀐 goals 인덱스와 기본 규칙13을 혼용해 실패하던 fixture를 coreGoals/명시 규칙12로 고쳤다. 실패를 제품 성공으로 기록하지 않았다.

변경: src/server/Network/ExpeditionService.luau, tests/story-lobby-resume.spec.lua, tests/campaign-expansion.spec.lua, VERSION 및 이 기록. 기존 사용자 자산/삭제/로컬 생성 파일은 제외한다. 명확한 결함 수정으로 별도 신규 리서치는 생략한다.

검증:

- `lua tests/story-lobby-resume.spec.lua`: 33 PASS. 실제 서비스 함수 본문을 호출해 Deepwood 캐시 제거 후 GW-01 선택 재현, 기존 미완료 Eryn 보고/선택 재플레이/권리 회귀.
- `lua tests/campaign-expansion.spec.lua`: 7,698 PASS. 기존 완료 유지·확장 admission·중복/보상/현재 및 과거 규칙 회귀.
- `lua tests/campaign-reorder.spec.lua`: 1,870 PASS. 기존 본편 재정렬·저장/권리 보존.

build.json에 커밋 고정 빌드를 기록한다. 실제 계정/게시 클라이언트 Continue·Teleport·실기기 검증은 미실행이다. 실제 게시/릴리스 태그 없음. 다음 QA는 새 빌드에서 사용자 영웅의 DW-07 완료 여부와 로비 시작 목적지를 확인한다. 부모 티켓 완료 처리 없음.
