# 확장 체크포인트 캐릭터 부활 실패 수정

2026-11-09 · TLT-003/050/057/061~065/084 · ENG → QA · 소스 수정·미게시.

사용자 첨부 화면은 Deepwood 7/7, HP0, RETRYING과 `Character could not load. Please wait or rejoin to retry.`를 표시한다. 서버 로그/해당 계정은 확보하지 않아 이 실행의 원인을 확정하지는 않았다. 소스에서 같은 증상을 만드는 확정 결함을 발견했다. `DeepwoodService.destination`이 저장된 확장 사건 체크포인트를 일반 Part로 생성하지만 `SpawnService.isSafeSpawnAvailable`은 Workspace의 활성 SpawnLocation만 허용한다. 사망 후 resolver가 이 Part를 반환하면 LoadCharacterAsync 실행 전에 계속 재시도한다. 최초 재입장도 같은 목적지 계약을 사용한다.

체크포인트를 활성·중립 SpawnLocation(Duration0)으로 생성하도록 수정했다. 저장된 위치·이름·투명·고정·비충돌/비접촉/비쿼리 속성 및 재사용은 유지한다. 스폰 서비스의 목적지 검사는 완화하지 않았다. 저장·보상·사망XP·전투 수치는 변경하지 않았다. 프로젝트 제작 스킬의 명확한 결함 수정에 해당해 별도 게임성 조사는 생략했다. 사용자 자산/생성 로그/첨부 변경은 커밋에서 제외한다.

검증:

- `lua tests/story-respawn.spec.lua`: 기존28검사 및 확장82체크포인트를 포함한 누적685검사 PASS. 실제 destination 본문·CampaignExpansionCheckpoints 규칙·전체 캠페인 데이터를 사용하며 엔진 객체는 대역이다. 활성 SpawnLocation 계약·위치·재시도 재사용을 확인한다.
- `/tmp/tlt-respawn-before-test.lua`: HEAD의 수정 전 destination 본문으로 동일 검사 실행. `DW-01 expanded respawn is an enabled engine spawn`에서 기대대로 FAIL. 원본 소스 변경 없음.
- `lua tests/k0-spawn.spec.lua`: PASS. 4플레이어·재시도/백오프·늦은 Humanoid·목적지 변경 경합·이전 생명 이벤트·사망/이탈.
- `lua tests/k0-hero-session.spec.lua`:121 PASS.
- `lua tests/campaign-expansion.spec.lua`:7,688 PASS,35메인/12사이드/82사건/246새단계.
- Studio MCP Edit(`TheLastThrone-0.95.1.rbxlx`): 수정 destination 본문과 대역 저널/규칙을 실제 Instance/Workspace에 실행. SpawnLocation 타입/Enabled·Workspace 소속·중립/Duration/표시/충돌 속성·좌표·중복 없는 재사용5검사 PASS. 임시 폴더 정리, 열린 게임 소스는 변경하지 않았다. 실제 Player 생성/RespawnLocation 대입은 도구 WritePlayer 권한 부족으로 실행 불가였으며, 해당 주장은 통과 결과에서 제외했다.
- `git diff --check`: PASS.

빌드·Roblox 게시·릴리스 태그 없음, VERSION0.95.1 유지. 실제 계정/서버 로그·사망→LoadCharacterAsync→조작 복구·모바일/다인·게시 클라이언트 검증은 후속이다. QA는 다음 고정 게시본에서 확장 사건을 일부 완료하고 사망한 뒤 같은 저장 체크포인트에 생성되고 Ready가 되는지 확인한다. 이 증거로 부모 티켓을 완료 처리하지 않는다.
