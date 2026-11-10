# 지도·퀘스트 에픽 순서 일치 · 0.95.2

2026-11-09 · TLT-028/050/057/061~065/084 · 구현·로컬 엔진 검증 / 미게시

사용자 요청: 맵과 퀘스트에서 Gloamwood가 Deepwood 바로 다음이어야 한다. 본편 CampaignContent와 로비/전투 지도는 이미 Deepwood → Gloamwood → Frozen Vale → Ember Caldera → Haunted Graveyard 순서였다. 로비 퀘스트 목록만 이전 순서를 별도 상수로 유지한 결함을 확인해, 지도와 동일하게 CampaignContent.epics에서 표시명·지역 접두사를 읽도록 수정했다. 기존 안정ID·보상·저장·진행/해금 조건·TD 공통 UI는 보존한다. 원인이 명확한 기존 승인 순서 결함 수정으로 별도 신규 리서치는 생략했다.

변경: src/client/LobbyQuestJournal.luau, 기존 지도/퀘스트 네이티브 검사의 이전 순서 기대값, VERSION. 사용자 Blender·삭제/첨부·다른 생성 파일은 포함하지 않는다.

검증:

- `lua tests/campaign-reorder.spec.lua`: 1,870 PASS. 기존 이관/권리 보존 및 본편 순서 회귀.
- `python3 tests/lobby-quest-tabs.spec.py`: 기존 다섯 탭 크기/배치 PASS.
- `run-in-roblox --place /tmp/tlt-epic-order-candidate.rbxlx --script /tmp/tlt-epic-order-ui.luau`: 실제 Roblox GUI에서 퀘스트70·지도87 PASS. 두 번째 Gloamwood 표시·Deepwood 완료(main7) 후 개방, Frozen Vale(main14)·Ember Caldera(main21)·Haunted Graveyard(main28) 및 화면 크기 회귀 확인.

빌드는 입력 커밋 고정 후 build.json에 기록한다. 게시·릴리스 태그 없음. 기존 열린 Studio는 읽기만 했으며 사용자 세션을 수정/종료하지 않았다. 실제 계정/게시 클라이언트·실기기 및 사람의 시각 수용은 미검증. 다음 담당 QA는 새 빌드에서 지도/퀘스트 전환과 실제 영웅 진행을 확인한다. 부모 티켓은 완료 처리하지 않는다.
