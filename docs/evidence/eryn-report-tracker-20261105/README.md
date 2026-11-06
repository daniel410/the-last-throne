# Eryn 최종 보고를 스토리 HUD에 명시

2026-11-05 · TLT-028/050/057/061/084 · ENG → QA · 로컬 수정·미게시.

사용자 지시: Eryn 보고가 남았으면 스토리 정보에 남은 보고를 명확하게 알려야 한다. 프로젝트 제작 스킬의 기존 목표 표시 결함 수정으로 처리했으며 별도 사례 조사는 생략했다.

`main=6`, `DW-07:separate` 완료, `restoration` 미완료 상태에서는 HUD에 `MAIN STORY 7 / 7 · REPORT TO ERYN`, `Return to Eryn and report your findings.`를 표시한다. Deepwood가 아직 끝나지 않았으며 금색 길잡이·복귀 포탈·MAP [M] 이동으로 Eryn에게 돌아갈 수 있음을 설명한다. 해당 원정이 보고를 허용하면 선택 요청보다 Eryn 보고를 우선 추적하며 좌표는 기존 보고 목표를 쓴다. 다른 임무 입장으로 보고가 차단돼 목표가 없는 경우에도 남은 보고와 로비 ADVENTURES의 Deepwood Story7 재입장을 설명한다. 진행 중인 별도 선택 원정의 유효 목표는 유지한다.

보고 확정 후에는 안내를 제거하고 기존 Frozen Vale 자동 추적을 유지한다. 저장·보상·선택·입장 권한과 TD 프레임/버튼/배치는 변경하지 않았다. 기존 사용자 Blender 변경·생성 증거·첨부는 제외한다.

검증 결과:

- `lua tests/story-lobby-resume.spec.lua`:32 PASS. 실제 저장 규칙으로 최종 수집 완료→로비 새 입장→Eryn 우선 목표/제목/문구/이동 방법→보고 저장→FV-01 전환을 검사한다. 별도 입장으로 차단된 보고 안내도 검사했다.
- `lua tests/journal-missing-target.spec.lua`:13 PASS.
- `lua tests/deepwood-quests.spec.lua`:31 PASS.
- `lua tests/story-continuation.spec.lua`:1,017 PASS.
- `lua tests/checkpoint-travel.spec.lua`:1,927 PASS.
- `lua tests/story-completion.spec.lua`:356 PASS.
- `/private/tmp/td233-luau/luau-compile src/shared/DeepwoodQuestLog.luau src/client/DeepwoodJournal.luau`: PASS.
- `git diff --check`: PASS.

합계3,376개 순수 Lua 검사이며 실제 DataStore·Studio/게시 클라이언트·모바일 가독성/길 안내·다인 검증과 구분한다. 게임 빌드/게시·릴리스 태그 없음, VERSION 유지. 다음 담당 QA는 실제 로비 왕복 후 Eryn 보고 안내와 복귀 경로, 보고 후 Frozen Vale 목표 전환을 확인한다. 부모 티켓 In Progress 유지.
