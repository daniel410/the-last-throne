# Deepwood K0 빌드 기록

## 0.1.0 — 빌드 성공, 실제 플레이 차단 결함 확인

| 항목 | 실제 결과 |
| --- | --- |
| 입력 소스 | `379d34e6ffa9b674ebcf1343ac3e2716ad842a0b`. 소스와 `VERSION=0.1.0` 커밋을 빌드 전에 `origin/main`에 푸시하고 원격 HEAD 일치 확인 |
| 도구·명령 | Rojo `7.7.1`: `rojo build default.project.json --output builds/0.1.0/TheLastThrone-0.1.0.rbxlx` |
| 산출물 | `builds/0.1.0/TheLastThrone-0.1.0.rbxlx`, 84 KiB, SHA-256 `bce5c2a5edd345ccaf5fb2755cb2643d4cf762954812c41124350dda7eacdf75`. `/builds/`는 Git에서 제외된 로컬 빌드 산출물 |
| 콘텐츠·자산·스키마 | K0Config SHA `40d3c41ea8d993abc35f96853a77228489586cc3dcba4372abce519085baeb8e`, K0Text SHA `abf34922a70d76a57847f950358d1accbb9faa4a62cf45d79c6b9c66815c9912`. 월드와 기사 소품은 코드 생성 임시 도형. 저장 데이터 스키마 없음 |
| 엔진 smoke | `run-in-roblox --place <위 빌드> --script tests/k0-build-smoke.luau`: 종료0, 37개 통과, 실패0·수집 런타임 오류0. Player 0. 두 적 초기 HP·접지·Goblin 재생성 확인 |
| 실제 Studio Play | 격리된 PlaceId 0의 해당 빌드에서 LocalPlayer, 영어 HUD, 임시 검/방패, 최대 체력1000을 관측. **첫 캐릭터가 안전 Spawn `(-20, 0.1, 56)`이 아닌 맵 원점 부근 `(0.33, 3.10, 0)`에 나타나 Goblin에게 공격받음**. 첫 스폰 수용 실패 |
| 로그 | Studio에서 `rbxassetid://203785492` 자산 유형 불일치 경고가 반복됨. 출처와 화면 영향 미확인. K0 소스에는 해당 ID가 없음 |
| 릴리스 | 없음. Git 태그/Roblox 게시를 하지 않음 |

Run 모드의 Player 0 smoke는 플레이어 생성 순서를 확인하지 못했다. 다음 빌드는 자동 캐릭터 생성과 안전 Spawn 설정 순서 및 사망 후 리스폰을 고친 뒤 `0.1.1`로 예약한다. 같은 `0.1.0` 결과물을 덮어쓰지 않는다. 실제 PC 입력·터치·패드·협동·지연은 별도 검증이다.
