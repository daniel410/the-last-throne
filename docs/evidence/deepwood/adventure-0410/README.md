# Deepwood 새 모험·Selene 시험 구현 · 0.41.0

2026-10-31 · TLT-001/016/050/061/072 부분 구현 · ENG/PLAN → QA/DES/ART

## 변경과 원천

[승인5에픽](../../../production/five-epic-adventure-story-2026-10-30.md)과 [조사/적용 판단](../../../research/2026-10-31-deepwood-adventure-revision.md)에 맞춰 Deepwood7스토리를 보급대 구조·친구와 협력·King Shaman 격파·포탈 폐쇄·Frozen Vale행 Crownheart 운반 명령서로 개정했다. [현재7시나리오와 전체 영어 단계](../../../production/deepwood-five-epic-scenarios.md)를 정본으로 삼는다. 기존 목표58개의ID/선행/좌표·선택 구조·보상1173 XP/2290 Gold와 기존32구간 보상 JSON은 유지한다. 기존 저장값 `sanctuary/shared`는 도움을 먼저 줄 장소 선택으로 표시하며 과거 선택값과 수령 기록은 초기화하지 않는다.

Selene는 DW-03:report의 account/missing을 모두 완료한 개인에게 무료 해금된다. 보고 첫 응답/파티장 완료/부분 구조만으로 해금하지 않는다. 기존 보고 완료자도 해금된다. 야영지에서 Invite Selene / Ask Selene to rest를 선택한다. 해금은 기존 보고 플래그에서 파생하고 편성은 같은 RPG 계정 journal에 저장한다. 저장 실패/불명 응답은 성공으로 표시하지 않고 같은 선택을 재시도한다. 임의 지급/새 보상은 없다.

TD의 `meshy-factions-refresh-v1/runtime.rbxmx` 중 `nun`의Body/ArmR/ArmL을 추출해 [핀/현재 해시](../../../../assets/shared/td-selene/manifest.json)를 남겼다. 원본 메시/텍스처를 유지하고 개별 동행자에 대해 소유자 뒤10studs 대형/최대28studs 추종·경로 찾기·거리/시야·위험근접 판단과 제한 지원을 추가했다. 정식 애니메이션 리그가 없는 고정 메시 이동 시험이다. 현행 기절 해제·제한 회복·보호막의 시험 수치는 시나리오 문서에 기록한다. 모든 상태/저주 해제나 부활을 제공한다고 보고하지 않는다.

작업 중 최신 사용자 지시로4인에도 추가AI를 허용했다. 현재 인간1/2/3/4명에 파티AI최대2/2/1/1이다. 인간 정원은4이며4인+AI1도 가능하다. 현재 구현 동료는Selene이며 선택자가 상한보다 많을 때UserId 순으로 대표를 선택한다. 다른 소유자는 선호를 보존하고 슬롯 대기 안내를 본다. 대표 선택 전용UI와 모든 동료 구현은 후속이다.

TD ForestKit 포탈을 제단에 추가했다. 완료자의 에너지에만 LocalTransparencyModifier를 적용하고 공유 모델은 삭제하지 않아 미완료자의 진행을 유지한다. 저널은 구조 결과·Selene 상태·북쪽 목적지와 Frozen Vale 미개방을 명확히 안내한다.

## 검증

| 명령/환경 | 결과·근거 |
| --- | --- |
| `lua tests/deepwood-progress.spec.lua` | 570검사 통과.7스토리/부분 단계·중복 수령·순서/분기·보상·호환 |
| `lua tests/deepwood-quests.spec.lua` / `lua tests/deepwood-bosses.spec.lua` | 31/96검사 통과. 선택 수락·보고/증거·보스 계약 |
| `lua tests/selene-recruitment.spec.lua` | 23검사 통과. 부분 보고/해금/미강제 편성·무료/중복/소유자/불명 저장 재시도·인원별 상한 |
| `lua tests/inventory.spec.lua` / `lua tests/economy.spec.lua` | 265/26검사 통과. 계정소유·용량·영수증/복구·지갑 회귀 |
| 기존HEAD 콘텐츠와 현재 콘텐츠58목표 대조 | ID/선행/좌표/선택 여부·장별 보상 불변 |
| `python3 scripts/simulate_story_progression.py --output /private/tmp/tlt-0410-progression.json` | 기존 정본 계산 실행 성공. 기존32구간의결과이며 새5에픽 전체Lv1~80 수용 증거가 아님 |
| `tests/selene-support-native.luau` source probe / 미게시 빈Place·네이티브 엔진·신원/계정/시계 대역 | 32검사 통과. 실제TD모델·서버 회복/보호/기절 해제·거리/개인 해금·슬롯1/2/3/4·쿨다운/재편성·실제경로 이동·개인 포탈 에너지. [결과](selene-result.json)·[입력해시](selene-source-manifest.json) |

전체 시나리오 네이티브 최종 재검사 **589개 통과**. 구조/호위·실제TD 보스/증원·선택 보고·초반 무료 해금·미확정 저장/동일 선택 재시도를 포함한다. [결과](story-result.json)·[입력해시](story-source-manifest.json). 퀘스트 저널의실제GUI 생성·탭/목표/보상/보고 안내5검사도 통과했다. [UI결과](ui-result.json). 빌드 결과는 마감 시 추가 기록한다. 첫 전체 엔진 실행은581검사를 통과했고, 개인 영입/저장 재시도를 추가한 검사에서 재구성 월드의야영지 참조 누락을 찾아 복구 경로를 수정했다. 초기 컴파일/정적 통과를 해당 새 경로의통과로 대신하지 않는다.

검사 도구: `python3 tests/make_k0_source_probe.py --output-dir <임시폴더> --test-script <검사파일>` 후 출력의빈Place/runner로 `run-in-roblox` 실행. 이 환경은 실제 Roblox 엔진과원본 메시를 사용하지만 실제Player 입력/운영DataStore·게시 클라이언트·실기기/네트워크 테스트가 아니다. 추종 대형 검사에서 신원 대역의기본4studs 폭Part가 광선을 가로막는 문제를 찾아 실제HRP와같은2studs 폭으로 수정했고 최종32검사를 통과했다. 저장 fence를잃은AccountBusy는 무한재시도하지 않고 기존오류/재접속 경로를 유지한다.

기존 원본 `rbxassetid://203785492`의타입 불일치 경고가 나왔으며 새수녀 리그/애니메이션 완성이나 모든원본 표시의수용으로 해석하지 않는다.

## 빌드·미검증·인계

소스와VERSION을 커밋 고정한 후 `python3 docs/evidence/deepwood/adventure-0410/build.py`로 Lobby/Battle을 만든다. 빌드는 `build.json`에 정확한소스커밋·명령·산출물SHA-256·성공/실패를 남기며 기존파일을 덮지 않는다. Roblox 게시/릴리스태그는 이번 범위에 포함하지 않는다. 게시판은0.40.2다.

미검증: 네클래스정상 전투입력으로7스토리완주·실제4인+AI1·모바일/패드·기기성능/네트워크·라이브 저장/재접속·초보자의이해도/재미. 수녀의정식 보행/시전 리그·대표선택UI·모든상태정화·다른동료와복합 편성·Dawnspire 프롤로그 습격/첫만남 연출·Frozen Vale입장은 후속이다. 수용 증거 없이 상위티켓을 완료하지 않는다.

다음 DES/ART는TD원형 기반 정식동행 리그/모션·Selene의야영지/스토리모델 중복 표현과대표선택UX를 정리한다. ENG/QA는4인+AI1의실전난이도/부하와 저장/이동/재접속을 게시테스트 및실기기에서 수용한다.
