# 사이드 퀘스트 전투 시작 누락 수정

2026-11-06 · TLT-050/061/084 · ENG → QA · 0.78.4 · 로컬 수정/미게시

사용자 첨부는 Waterfall Quarry의 `Defeat King Ogre` 4stud 앞에서 전투가 시작되지 않고 접근 안내가 유지되는 화면이다. `DeepwoodActivityWorld`와 클라이언트는 battle 목표의 수동 프롬프트를 숨기지만 `DeepwoodService`의0.2초 근접 스캔은 `if not c.side`로 선택 퀘스트를 제외했다. 이 때문에 수락/선행 조건이 충족돼도 시작할 경로가 없었다. 원인이 명확한 결함 수정으로 별도 게임성 조사·제품 규칙 변경 없이 처리한다.

스캔에서 선택 퀘스트 제외 조건만 제거한다. 기존 `Progress.available`의 수락·스토리/선행 목표·미완료·현재 원정 검사를 유지하고32stud 이내 접근 시 같은 서버 `begin` 경로를 사용한다. 기존 원정별 중복 방지·인원/전투·보상·저장 계약을 보존한다. 프롬프트·화면 배치·영어 문자열·TD 자산 변경은 없다. 기존 사용자의 Blender 변경/미추적 자료는 포함하지 않는다.

## 검증

- `lua tests/side-quest-battle-start.spec.lua`: 수정 전 `DW-Q2:goblin_king` 진입 실패를 재현. 수정 후 **1029개 PASS**, King Ogre 포함 선택 전투9개·메인64개 목표 전체. 미수락/완료/선행 미충족/다른 원정/범위 밖/훈련/유효 컨텍스트 없음 차단, 같은 원정 중복 방지·다른 원정 비차단·0.2초 주기를 검사한다. 실제 프로덕션 heartbeat 본문을 추출하고 정본 콘텐츠/진행 함수를 사용한다.
- `python3 tools/assemble-side-battle-test.py` → `run-in-roblox --place builds/0.78.3/TheLastThrone-0.78.3.rbxlx --script /tmp/tlt-side-battle-native.luau`: 격리 로컬 Studio의 Luau에서 같은 **1029개 PASS**. 정본 콘텐츠/진행은 로컬 빌드 ModuleScript를 사용하고 변경된 서버 callback 본문을 주입했다. [결과](native.json). 기존203785492 타입 경고는 결과에 영향 없음.
- `lua tests/journal-missing-target.spec.lua`:13개 PASS. `lua tests/story-completion.spec.lua`:356개 PASS. `lua tests/battle-startup.spec.lua`:223개 PASS.
- `/tmp/td233-luau/luau-compile src/server/Story/DeepwoodService.luau`: PASS. `git diff --check`: PASS.

플레이어·거리·`begin` 호출은 fixture 대역이다. 위 검사는 실제 적 생성/처치나 저장·게시 클라이언트·실기기 수용을 증명하지 않는다. 다음 QA는 수정 빌드에서 DW-Q3의 도구 조사 → King Ogre 접근 → 실제 보스 처치 → 장치 조사 → 보고와 DW-Q2/Q4 전투를 확인한다. 부모 티켓은 In Progress를 유지한다. Place 게시·릴리스 태그·TD 변경은 하지 않았다.
