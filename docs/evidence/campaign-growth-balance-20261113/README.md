# 성장·난이도 규칙16 검증

2026-11-13 · TLT-027/029/050/061~065/084 · [현재 사양·사용자 목표·미검증/인계](../../production/campaign-growth-balance-2026-11-13.md)

- [growth.csv](growth.csv): 같은 영웅의 Easy→Hard→Insane→Hell5회, 에픽별 퀘스트/처치/누적XP와 완료 레벨. Easy10/17/23/27/30, 이후60/80/90/95/97/98/99.
- [easy-combat.csv](easy-combat.csv): 새 Easy 솔로 본편의 체력·피해·인구·실제 무리 최대치.
- [0.106.1 고정 빌드](build.json)·[입력 일치 검사](fixed-build-check.json): 소스 `4f44f4e63d20e4c423af6dfc4d889b96194a3e61`, 생성 파일 `builds/0.106.1/TheLastThrone-0.106.1.rbxlx`. 변경된22개 소스 모두 빌드 내부와 일치,19,128,218바이트, SHA-256 `5a956b35c8c12973ca0443dd7dcea9c4e852ca3d354b1b22aa2403b08a796d22`. Roblox 게시·릴리스 태그 없음.
- [Studio Luau 결과](studio-luau.json): 실제 Studio의 격리된 Luau 검사. 소스65개 컴파일, 성장330,657검사·레벨/포인트3,710·원정 화면24·기존 보상2,162검사, 실제 서버 `applyBalance`의 Model 속성7,694조건 통과. live 계정/DataStore·Place 소스 변경 없음.
- `tests/campaign-growth-v16.spec.lua`:1~4인 개인 XP 보존, 원본 처치ID/Gold 보존, 새/구 경로·재접속 위치, 실제 InventoryRules/AdventureRules로8캠페인 진행, 회차 기록·응답 재시도·상한99·포인트392/98·로드 보존·잘못된 저장 거부.

재현 명령:

```sh
lua tests/campaign-growth-v16.spec.lua
lua tools/measure-campaign-growth.lua
lua tools/measure-campaign-growth.lua combat
python3 tools/prepare-campaign-growth-native.py
```

기존130개 순수 Lua 검사 중 이번 변경 전에도 실패한23개는 고정 기준 소스와 비교해 분리했다. 기존 모델/아이템 카탈로그 가정·선택/확장 목표 처리·Lua/Luau 구문 차이 등의 실패를 이번 변경으로 통과시킨 것으로 보고하지 않는다. 이번 변경으로 달라진 성장/레벨 상한·XP 화면 계약 검사는 갱신했고, 새 좌표 변환 누락을 검사 중 발견해 수정했다. 정확한 실행 결과는 회귀 로그와 빌드 기록을 함께 본다.

[최종 회귀 로그](regression.json): 동시 작업에서 추가된 검사까지131개 중107개 통과, 기존 실패23개와 다른 변경의 `InventoryService` 의존성을 아직 반영하지 않은 기존 서비스 stub 실패1개를 구분했다. 이 서비스 파일·stub는 이번 패치에서 수정하지 않았다. 본 패치의 성장·능력치·화면·입장·기존 보상·경로 검사는 통과했다.

별도로 규칙15의 Easy 능력치는 앞선 리뷰에 저장한576개 그룹 전부와 일치했다. 기존 경로315지점 검사77,381조건도 통과해 추가43개 Easy 지점 때문에 구원정 지점이 바뀌지 않음을 확인했다.

Studio 검사는 순수 Luau 계정/원정 로직과 실제 Model 속성 적용 경계를 확인하는 범위다. 실제 전투 조작·적 AI 교전·전체 맵43개 추가 지점의 R15 이동·게시 클라이언트·실기기·실계정 저장/Teleport·사용자 수용은 미검증이다. 기준 계산은 선택 임무/재도전/반복 사냥/사망 손실을 제외하며 기존 고레벨 영웅을 목표 레벨로 낮추지 않는다.
