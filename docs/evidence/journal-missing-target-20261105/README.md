# 재접속 후 잘못된 본편 완료 표시

2026-11-05 · TLT-028/050/057/061/084 · ENG → QA · 로컬 소스 수정·미게시.

사용자는 Deepwood 7/7 이후 로비 왕복 시 Waterfall Quarry에서 `EPIC 5 COMPLETE`와 선택 요청/로비 안내만 보이는 화면을 제공했다. 화면은 실제 관찰 증거이며 해당 계정의 저장 원본·입장 임무는 확인하지 않았다.

코드에서 목표를 찾지 못하는 모든 경우를 전체 본편 완료로 표시하는 결함을 확인했다. 본편7개 완료 후 별도 `DW-Q3` 원정에 입장하는 실제 순수 데이터 경로로 재현했다. 원정은 선택 퀘스트만 허용하지만 클라이언트 기본 추적은 다음 본편을 선택하므로 목표가 없어졌다. 첨부 현상과 일치하는 재현 경로이며 사용자의 실제 입장 임무 확정과는 구분한다.

변경 범위는 `DeepwoodQuestLog`의 추적/표시 함수와 이를 사용하는 `DeepwoodJournal`, 회귀 검사다. 별도 선택 원정의 목표를 자동 복원하고 선택 원정 완료 시 다음 본편 지역/임무와 ADVENTURES 입장 방법을 표시한다. 본편 목표가 없는 경우도 로비에서 이어갈 안내를 제공하며35개를 모두 완료했을 때만 전체 완료 문구를 표시한다. 기존 TD 프레임·버튼·아이콘·배치와 저장·보상·서버 입장 자격은 유지한다. 원인이 명확한 결함이므로 제작 스킬의 조사 생략 조건을 적용했다.

검증:

- `lua tests/journal-missing-target.spec.lua`: 13 PASS. 정상 저장/입장으로 DW7완료→DW-Q3 목표 소실 재현→선택 목표 복원→선택 완료/Frozen Vale 안내→FV-01 입장·목표, 진행 변경 없음,35개 실제 완료 구분.
- `lua tests/deepwood-quests.spec.lua`:31 PASS.
- `lua tests/story-lobby-resume.spec.lua`:24 PASS.
- `lua tests/story-continuation.spec.lua`:1,017 PASS.
- `lua tests/story-completion.spec.lua`:356 PASS.
- `lua tests/difficulty-enhancement.spec.lua`:125 PASS.
- `/private/tmp/td233-luau/luau-compile src/shared/DeepwoodQuestLog.luau src/client/DeepwoodJournal.luau`: PASS.
- `git diff --check`: PASS.

총1,566개 순수 Lua 검사다. Studio/실제 DataStore/게시 클라이언트·실기기/다인 검증은 수행하지 않았다. 빌드·Roblox 게시·릴리스 태그 없음, VERSION 유지. 사용자 기존 Blender 변경·증거·첨부 파일은 작업에서 제외한다. 다음 담당 QA는 새 게시본에서7/7의 마지막 Eryn 보고 여부와 실제 입장 임무를 확인하고 Waterfall Quarry 선택 원정의 진행/완료 후 로비→Frozen Vale Easy 입장을 검증한다. 부모 티켓 In Progress 유지.
