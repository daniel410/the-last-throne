# 완료 스토리 지도 이동과 Eryn 복귀 포탈

2026-11-04 · TLT-028/050/057/061/084 · ENG/DES → QA · 0.72.0 로컬 구현, 게시/다인 수용 전

사용자 요청으로 완료 후 긴 복귀를 줄인다. 기존 TD 공통 상세 지도에 무료 `TRAVEL · <destination>` 버튼을 추가했다. 현재 에픽의 **완료한 본편 스토리** 지역을 지도에서 선택해 해당 안전 체크포인트로 이동한다. 첫 방문/미완료 지역은 열지 않으며 에픽 전환·본편 진행은 기존 저장/전환 계약이 담당한다.

Deepwood Story7의 `separate`(마지막 공급품·명령서 수집)까지 저장되고 Eryn 최종 보고가 남으면, 마지막 수집 위치 옆에 `Return to Eryn` 포탈이 생긴다. MAP을 열어도 `TRAVEL · ERYN`을 제공한다. 포탈 F/패드X/터치 상호작용 또는 지도 버튼으로 Eryn 보고 목표에서6stud 떨어진 위치에 도착한다. 최종 보고/선택은 자동으로 완료하지 않는다. 자동 강제 이동·비용·새 보상은 없다.

서버가 저장된 journal·영웅 일치·생존/모험 상태·계정/이동 잠금·저장 큐·진행 중 교전·로드된 목적지를 검사한다. 클라이언트는 허용된 목적지ID만 요청하며 좌표·완료 주장을 보내지 않는다. 기존 `relocateForStoryGate`로 이동해 이동 검증/속도를 동기화하며 HP/MP·퀘스트·보상/원정ID를 다시 만들지 않는다. 파티원은 각자 이용하며 다른 사람을 강제로 옮기지 않는다. 공유 포탈의 프롬프트는 개인 진행으로 표시/서버 자격 검사한다. 다른 파티원이 미완료이면 포탈 외형을 없애지 않는다.

표현/원본: 기존 `TDInventoryTheme` 프레임/버튼·상세 지도 배치/기능을 유지한다. 포탈은 `DeepwoodEnvironment.portal`의 원본 TD Forest kit PortalGate/PortalEnergy10개 MeshPart를 재사용하며 기존 침공 MonsterPortal과 구분한다. `assets/shared/td-deepwood-environment/manifest.json`의 forest-kit SHA-256 `d08038b65d548abf742d5517b46265c3d2e4688f42f04170341c639d3a0278d5`와 현재 파일 일치. 원본 사용은 기존 사용자 공유 승인 범위이며 게시 Experience의 자산 권한/실제 렌더 수용은 별도다. [조사](../../research/2026-11-04-checkpoint-travel.md).

| 검증 | 결과/증거 수준 |
| --- | --- |
| `lua tests/checkpoint-travel.spec.lua` |1,927개 통과. 실제 전체 캠페인 reducer로 완료 지역·마지막 공급품 이전 잠금·Eryn 목표·파티 독립 이동·영웅/전투/저장/로드 잠금·위조 입력·진도/재화 불변식 |
| `lua tests/checkpoint-map-layout.spec.lua` |36개 통과. 실제 지도 footer 레이아웃 본문의6해상도 geometry adapter 검사 |
| Studio Edit `tests/checkpoint-portal-native.luau` |16개 통과. 실제 원본TD10메시·프롬프트·생성 전 잠금·중복 모델 방지. 진행/계정은 fixture, 임시 ServerStorage 폴더 정리 완료 |
| Studio Edit `tests/checkpoint-map-native.luau` |25개 통과. 실제TDTheme·원본 아트·production footer 본문·1366×768/844×390/667×375/390×844/320×568의 버튼 크기·텍스트맞춤·겹침. 전체 지도/실기기 시각 수용과 구분, 임시CoreGui 정리 완료 |
| Studio Edit 변경6모듈 Luau `loadstring` |구문 통과 |
| `lua tests/story-region-handoff.spec.lua` |52개 통과. 새 체크포인트 알림 의존성도 실제 모듈로 주입 |
| `lua tests/story-lobby-resume.spec.lua` |24개 통과 |
| `lua tests/story-completion.spec.lua` |356개 통과 |
| `lua tests/story-continuation.spec.lua` |1,017개 통과 |
| `lua tests/party-story.spec.lua` |2,765개 통과 |

미검증: 실제 Roblox 클라이언트의 도착 바닥/스트리밍·NPC 거리/카메라/셀렌느 동행, 실제2~4인 저장/동시 이용/폰·패드 입력/성능, 최종 시각·사용자 수용. 기존 열린 Studio의 문서/세션과 사용자 미커밋 이동·무기·회피 작업은 변경/포함하지 않는다. TD 소스·계정·상품·실제 Place 게시를 변경하지 않는다. 다음 담당 QA:7/7 공급품 마지막 단계→포탈/지도→Eryn 대화→Frozen Vale와 로비 복귀/재입장, 완료한 중간 스토리 지도 이동·저장 지연 중 거부를 실제 기기로 검증한다. 부모 티켓 In Progress.

## 고정 소스 빌드/마감

입력 `96924afd589ff0a6318e2eec674ebdd0e980be8d` / VERSION `0.72.0` / Rojo7.7.1. 소스 원격 푸시 후 별도 `/tmp/tlt-checkpoint-0720` worktree에서 `rojo build default.project.json -o <Lobby 산출물>`과 `rojo build battle.project.json -o <Battle 산출물>` 모두 성공했다. 두 XML의 새/변경6모듈 Source가 고정 커밋 파일과 일치하는 것도 확인했다.

| 산출물 | SHA-256 |
| --- | --- |
| `builds/0.72.0/TheLastThrone-Lobby-0.72.0.rbxlx` | `41a6757398c0b4a68a67b4b48ee1ba77640c0f8b471b071fb30b9fdcd95a14fe` |
| `builds/0.72.0/TheLastThrone-Battle-0.72.0.rbxlx` | `239bb22a04d21bde83b35d5023f552861b971c9fd1af8c41bc89529d5b28291d` |

고정 worktree에서 새 체크포인트1,927·지도 geometry36·지역인계52·로비복귀24·배틀 시작223개 검사 재통과. 빌드는 게시/실제 기기 수용을 대신하지 않는다. 신규 LFS 원본이 없으며 빌드 출력은 ignore된 로컬 산출물이다. 구현 `96924af`를 `origin/main`에 푸시했다. 이번 작업은 일반 빌드로 Roblox 게시와 릴리스 태그를 만들지 않았다.
