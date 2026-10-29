# Deepwood K0 빌드 기록

## 0.1.0 — 빌드 성공, 실제 플레이 차단 결함 확인

| 항목 | 실제 결과 |
| --- | --- |
| 입력 소스 | `379d34e6ffa9b674ebcf1343ac3e2716ad842a0b`. 소스와 `VERSION=0.1.0` 커밋을 빌드 전에 `origin/main`에 푸시하고 원격 HEAD 일치 확인 |
| 도구·명령 | Rojo `7.7.1`: `rojo build default.project.json --output builds/0.1.0/TheLastThrone-0.1.0.rbxlx` |
| 산출물 | `builds/0.1.0/TheLastThrone-0.1.0.rbxlx`, 84 KiB, SHA-256 `bce5c2a5edd345ccaf5fb2755cb2643d4cf762954812c41124350dda7eacdf75`. `/builds/`는 Git에서 제외된 로컬 빌드 산출물 |
| 콘텐츠·자산·스키마 | K0Config SHA `40d3c41ea8d993abc35f96853a77228489586cc3dcba4372abce519085baeb8e`, K0Text SHA `abf34922a70d76a57847f950358d1accbb9faa4a62cf45d79c6b9c66815c9912`. 월드와 기사 소품은 코드 생성 임시 도형. 저장 데이터 스키마 없음 |
| 엔진 smoke | `run-in-roblox --place <위 빌드> --script tests/k0-build-smoke.luau`: 종료0, 37개 통과, 실패0·수집 런타임 오류0. 당시 소스 커밋 `379d34e`의 테스트 스크립트 사용. Player0. 두 적 초기 HP·접지·Goblin 재생성 확인 |
| 실제 Studio Play | 격리된 PlaceId 0의 해당 빌드에서 LocalPlayer, 영어 HUD, 임시 검/방패, 최대 체력1000을 관측. **첫 캐릭터가 안전 Spawn `(-20, 0.1, 56)`이 아닌 맵 원점 부근 `(0.33, 3.10, 0)`에 나타나 Goblin에게 공격받음**. 첫 스폰 수용 실패 |
| 로그 | Studio에서 `rbxassetid://203785492` 자산 유형 불일치 경고가 반복됨. 출처와 화면 영향 미확인. K0 소스에는 해당 ID가 없음 |
| 릴리스 | 없음. Git 태그/Roblox 게시를 하지 않음 |

Run 모드의 Player 0 smoke는 플레이어 생성 순서를 확인하지 못했다. 다음 빌드는 자동 캐릭터 생성과 안전 Spawn 설정 순서 및 사망 후 리스폰을 고친 뒤 `0.1.1`로 예약한다. 같은 `0.1.0` 결과물을 덮어쓰지 않는다. 실제 PC 입력·터치·패드·협동·지연은 별도 검증이다.

0.1.0 smoke를 재현할 때는 `git show 379d34e:tests/k0-build-smoke.luau > /tmp/tlt-k0-010-smoke.luau`로 당시 스크립트를 복원해 사용한다. 현재 테스트는 이후 추가된 `CharacterAutoLoads=false` 계약을 검사하므로 0.1.0과 같은 검사가 아니다.

## 0.1.1 — 안전 스폰 수정 빌드

| 항목 | 실제 결과 |
| --- | --- |
| 입력 소스 | `2646dea48f8870e833cb33181be9ccdec22492de`, `VERSION=0.1.1`. 빌드 전에 `origin/main` 푸시와 원격 SHA 일치 확인 |
| 도구·명령 | Rojo `7.7.1`: `rojo build default.project.json --output builds/0.1.1/TheLastThrone-0.1.1.rbxlx` |
| 산출물 | `builds/0.1.1/TheLastThrone-0.1.1.rbxlx`, 약96 KiB, SHA-256 `9c265365a4ef872c1e043bcac63c2c2d3f7d0464e2d6b5d22ebafc28a1f91a5e`. 로컬 생성 파일이며 Git 제외 |
| 콘텐츠·자산·스키마 | K0Config SHA `40d3c41ea8d993abc35f96853a77228489586cc3dcba4372abce519085baeb8e`, K0Text SHA `86a50b7923be4fd541ef2e99015c583bb9acf5b8094978d3fcfea5ed0b050a3a`, SpawnService SHA `b497c4b7166379f73035cdfa908bc9c44b04427266514ccb3f5b4b08c6865c77`. 외부 모델 대신 임시 도형, 저장 스키마 없음 |
| 엔진 smoke | `run-in-roblox --place <위 빌드> --script tests/k0-build-smoke.luau`: 종료0, **39개 통과**, 실패·수집 런타임 오류0. Player0이며 실제 캐릭터 검사는 별도 |
| 실제 Studio Play | PlaceId0 독립 세션에서 첫 캐릭터와 사망 뒤 새 캐릭터 모두 root `(-20, 3.096, 56)` 부근, `K0SpawnReady=true`, HP1000·스태미나100을 확인했다. 별도 Play에서 가상 마우스 홀드 연격1~3, 오른쪽 방어/해제, Space 회피와 회피 비용30을 관측했다. [QA 기록](qa.md)의 조건과 한계를 따른다. |
| 남은 문제 | 화면에서 안내 표지의 기둥이 글자를 가리는 시각 결함 발견. 다음 버전에서 기둥을 글자 뒤로 옮겨 재확인한다. 적과의 실제 교전·터치/패드·네트워크와 다인은 미검증 |
| 릴리스 | 없음. Git 태그/Roblox 게시를 하지 않음 |

## 0.1.2 — 표지 가독성 수정 빌드

| 항목 | 실제 결과 |
| --- | --- |
| 입력 소스 | `0750ac2f7582ecec08f5facb44ee0db09f875fcd`, `VERSION=0.1.2`. 빌드 전에 `origin/main` 푸시와 원격 SHA 일치 확인 |
| 도구·명령 | Rojo `7.7.1`: `rojo build default.project.json --output builds/0.1.2/TheLastThrone-0.1.2.rbxlx` |
| 산출물 | `builds/0.1.2/TheLastThrone-0.1.2.rbxlx`, 약96 KiB, SHA-256 `d4105689f76a26f7f8d8d51a70bc269fdfa5b0f81fd894b94227362d5a78f896`. 로컬 생성 파일이며 Git 제외 |
| 콘텐츠·자산·스키마 | K0Config SHA `40d3c41ea8d993abc35f96853a77228489586cc3dcba4372abce519085baeb8e`, K0Text SHA `86a50b7923be4fd541ef2e99015c583bb9acf5b8094978d3fcfea5ed0b050a3a`, 월드 SHA `a36498e72c48121f002116001d79187ee8f5056de15f7afe11524c9029f746a1`. 임시 도형, 저장 스키마 없음 |
| 엔진 smoke | `run-in-roblox --place <위 빌드> --script tests/k0-build-smoke.luau`: 종료0, **39개 통과**, 실패·수집 런타임 오류0. Player0 |
| 실제 Studio Play | PlaceId0 독립 세션에서 시작 표지의 두 줄이 기둥에 가리지 않고 보이는 것을 확인했다. 가상 이동으로 시작점→통로→전투장에 진입했고 Goblin이 추적해 `Windup`/`Melee` 상태가 되고 플레이어 HP가1000에서 약930으로 변한 것을 확인했다. 해당 교전에서 플레이어 검 적중·방어 판정은 확인하지 못했다. |
| 로그·릴리스 | 별도 출처 미확인 `rbxassetid://203785492` 유형 불일치 경고 재관측. Git 태그/Roblox 게시 없음 |

이 빌드는 전투 원형이며 최종 미술이나 공개 출시가 아니다. 공통 자산 실사용, 고블린/오우거 상대 전타와 방어·회피 타이밍, 모바일·패드·다인·네트워크, 보상/저장과 지갑 연동은 후속 검증 대상이다.


## 0.2.0 — 출력 경로 오류로 빌드 실패

입력 소스 `b23119af195f8be6f277d6283d2025fe1af3825f`는 빌드 전에 원격 일치를 확인했고 LFS4개/22MB 전송을 완료했다. `rojo build default.project.json --output builds/0.2.0/TheLastThrone-0.2.0.rbxlx`는 출력 디렉터리가 없어 종료1로 실패했다. 결과 파일과 해시는 없다. 같은 버전을 재사용하지 않고 디렉터리를 준비한 `0.2.1`로 다시 빌드한다. 릴리스/태그/게시는 없다.


## 0.2.1 — TD Meshy 몬스터 연결 빌드

| 항목 | 실제 결과 |
| --- | --- |
| 입력 소스 | `2c32af175cec5d29565d931a3b776fa7388c7060`, VERSION=0.2.1. 빌드 전에 origin/main SHA 일치 확인. 자산/연결 소스는 선행 커밋 `b23119a`에 포함 |
| 빌드 | Rojo7.7.1: `rojo build default.project.json --output builds/0.2.1/TheLastThrone-0.2.1.rbxlx`, 종료0 |
| 결과물 | 662,102bytes, SHA-256 `e48a655f2e9bc4e15479801885106060cf0bda6460c950708263f7396a5f9f6c`. builds 폴더의 로컬 생성 산출물이며 Git 제외 |
| 자산 | TD runtime SHA `14e4e9492d280ce887b229cbe6deea5a7a90af2cb643760dc355bcdcb4433ef5` 고정. 원본 GLB3개와 runtime4개/22MB LFS 업로드 완료. [원본 기록](td-monster-sources.md) 참조 |
| 고정 빌드 엔진 검사 | `run-in-roblox --place <위 빌드 절대경로> --script <tests/k0-build-smoke.luau 절대경로>` 종료0. 177개 통과·실패0·수집 런타임 오류0. 11부위 메시/색맵 콜백22개 Success. [원본 로그](td-monster-build-smoke.log). 첫 검증 실행은 Studio 임시 플러그인 생성의 sandbox 권한으로 실패했고 승인된 실행으로 재검증했다. 게임 빌드 재실행은 아님 |
| 실제 Play | 동일 빌드의 독립 PlaceId0에서 안전 스폰(-20,3.096,56), Ready, 두 적 각각 TD 메시5부위·HP300/6000 확인. 화면에서 두 원본 몬스터·텍스처·대기 접지 확인. 통로를 통해 Goblin에 접근하여 추적·공격과 플레이어 체력 감소를 관측 |
| 모션 관측 | Goblin Windup에서 무기 쪽 Left Shoulder Transform의 sin성분 약0.913으로 팔 회전 확인. Recovery에서 양발 AABB 최저Y 약-0.0031stud. 전체 보행/공격의 연속 접지·최종 미술 수용으로 일반화하지 않음 |
| 남은 검증 | Slime는11부위 로드 검사 중 단일Body로 검증했고 전투 스폰/분열은 없음. Ogre 사망 후 외형 리스폰·전투 전 패턴·모바일/패드·다인·게시 Experience 권한과 성능 미검증 |
| 로그/릴리스 | 기존 출처 미확인203785492 자산 유형 경고 재관측. Git 태그·Roblox 게시 없음 |

기사 소품과 환경은 여전히 임시 도형이다. [첫 리뷰](first-implementation-review.md)의 네 결함은 별도 수정 대상으로 남는다. 이번 빌드는 공유 몬스터 외형의 재사용이며 K0 전체 수용/출시 완료가 아니다.

## 0.3.0 — TD Orc Warrior 추가 빌드

| 항목 | 실제 결과 |
| --- | --- |
| 입력 소스 | `90c81ea639aba20fb606f3fcd52856165eed3c93`, `VERSION=0.3.0`. 빌드 전 `origin/main` SHA 일치 확인 |
| 빌드 | Rojo7.7.1 `rojo build default.project.json --output builds/0.3.0/TheLastThrone-0.3.0.rbxlx`, 종료0 |
| 결과물 | 662,717bytes, SHA-256 `a3187207ff8fec0ded91c0aa8bf8987277a0299d968ebcc509cec07c448b1a5f`. `builds/` 아래 Git 제외 로컬 결과물 |
| 원본 | TD runtime XML SHA `14e4e9492d280ce887b229cbe6deea5a7a90af2cb643760dc355bcdcb4433ef5`. 오크 Meshy 원본 SHA `b612a43d660f11cf24a9b5216462fdf1cf7b98a2e49db625102006cc70fb5ad3`. 8.4MB LFS 전송 성공. [출처 기록](orc-source.md) 참조 |
| 정적/규칙 | 자산 구조·원본 정적 검사134개, K0 규칙83개, 기존 플레이어 스폰·기사 장비 모의 검사 통과 |
| 고정 빌드 엔진 | `run-in-roblox --place <위 빌드 절대경로> --script <tests/k0-build-smoke.luau 절대경로>` 종료0. 327개 통과·실패/수집 오류0. 16 MeshPart 및 각 색맵의 콜백32개 성공, 세 적이 사망 후 복제·리스폰. Player0. [로그](orc-build-smoke.log) |
| 실제 Studio Play | 독립 PlaceId0에서 플레이어 안전 스폰과 Orc Warrior 표시, TD 원본 외형·도끼 및 메시 5부위 확인. 가상 이동으로 오크에게 접근해 추적·예고·공격을 관측했고 플레이어 HP가1000에서 약885로 감소했다. 가상 마우스 검 공격 후 오크 HP900→780, 자세100→76 관측. Windup 중 무기 쪽 어깨 회전과 도끼 표시 확인 |
| 미검증 | 오크 장갑·측후면 전용 피해, 오크 본편 배치·보상, 연속 모션의 미술 수용, 실제폰·패드·다인·네트워크, 게시된 테스트 Experience 권한·성능 |
| 로그/릴리스 | 이전부터 반복 관측된 `rbxassetid://203785492` 유형 불일치 경고는 출처 미확인. Git 릴리스 태그·Roblox 게시 없음 |

오크 수치는 시험 프리셋이다. 기존 [K0 리뷰](first-implementation-review.md)의 전투 판정·입력 결함은 이 추가로 해결됐다고 보고하지 않는다.

## 0.3.1 — K0 판정·입력 타이밍 수정 빌드

| 항목 | 실제 결과 |
| --- | --- |
| 입력 소스 | `17d34cf4a3277fab5a9ca66a3108222a02a71b5e`, `VERSION=0.3.1`. 빌드 전 `origin/main` 푸시와 원격 SHA 일치 확인 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.3.1/TheLastThrone-0.3.1.rbxlx`, 종료 0. 기존 결과물을 덮어쓰지 않음 |
| 결과물 | 668,872 bytes, SHA-256 `594f276c5d28cb9370669271fa6cc7ab546a5319365c07af9aa2532f7486efc3`. `builds/` 아래 Git 제외 로컬 결과물 |
| 고정 빌드 기본 엔진 검사 | `run-in-roblox --place <위 빌드 절대경로> --script <tests/k0-build-smoke.luau 절대경로>` 종료 0. 327개 통과, 실패·검사에서 수집한 런타임 오류 0. 공유 메시와 색맵 콜백 32개 성공, 세 적 리스폰. Player 0. [로그](combat-timing-build-smoke.log) |
| 고정 빌드 판정 검사 | 같은 빌드에 `tests/k0-timing-native.luau`를 재실행해 종료 0, 116검사/37사례 통과. Player 0·신원 모형 사용. [성공 로그](combat-timing-native-retry.log). 첫 실행도 검사 보고서는 통과했으나 Studio 기본 플러그인의 React 오류 출력 뒤 명령 종료 1이었으며 종료 원인은 확인되지 않았다. [첫 로그](combat-timing-native-run.log) |
| 실제 Studio Play | 격리된 PlaceId 0에서 안전 스폰과 실제 Player를 확인했다. 가상 마우스 단발 두 번을 약 310ms 간격으로 입력했을 때 서버 캐릭터의 연격 변화 `1 → 2 → 0`을 관측했다. 일반 오크 교전에서 오크 HP 900→450, 플레이어 HP 1000→151.99가 관측됐다. 입력 시각은 실제 환경 스케줄링에 따르므로 이것만으로 버퍼 경계의 정확성을 주장하지 않는다. |
| 실제 Player를 사용하는 판정 검사 | 위와 별도인 같은 격리 Play 서버에서 게임 서버 소스와 콜백을 복제하고 가상 시각을 주입해 116검사/37사례 통과. 실제 Player/Character 34사례, 신원 모형 3사례. 원격 전송과 입력을 재현하는 검사는 아니다. [Play 로그](combat-timing-native-play.log), [상세 계약](combat-timing-fix.md) |
| 실행 환경 | 기존 `rbxassetid://203785492` 자산 유형 경고가 반복됐다. 첫 고정 빌드 판정 명령의 비정상 종료 원인은 미확인이다. 격리 Play 브리지가 실행 중일 때 별도 명령을 재시도해 로컬 포트 충돌로 종료 2가 났고, 브리지 종료 후 같은 판정 검사 명령은 종료 0으로 통과했다. [포트 충돌 로그](combat-timing-runner-retry.log) |
| 미검증·릴리스 | 게시된 환경의 실제 지연·프레임 정지, 실기기·패드, 4인/8인 부하, 칼 시각 방향 R3와 메뉴/채팅 홀드 해제 R4는 미검증 또는 미수정. Git 릴리스 태그·Roblox 게시 없음 |

## 0.4.0 — TD 플레이어 무기·근접 기본 공격 원형

| 항목 | 실제 결과 |
| --- | --- |
| 입력 소스 | `2cecdcd03317945d81d4579ad26ceac65a1e2804`, `VERSION=0.4.0`. 빌드 전 `origin/main` 일치와 LFS 13개 전송 확인 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.4.0/TheLastThrone-0.4.0.rbxlx`, 종료 0 |
| 결과물 | 734,056 bytes, SHA-256 `52482a85df1ea7baec571e6c34ca212f3dbbe493ea00eb9000ea5d5d675f566b`. Git 제외 로컬 결과물 |
| 고정 빌드 검사 | `tests/k0-build-smoke.luau`, 종료 0, 329개 검사 통과·실패 및 수집 런타임 오류 0. Player 0, TD 몬스터 메시·색맵 로드와 3종 리스폰 확인. [로그](player-weapons-build-smoke.log). 플레이어 무기·방패·직업 근접 공격은 [별도 원형 기록](player-weapons.md)의 엔진 fixture 결과를 따른다. |
| 미검증·릴리스 | 이 버전에서 실제 Player Play는 수행하지 않았다. 원본 방패의 사용자 계정 Studio 렌더를 확인했지만 대상 게시 Experience 권한, 기기·네트워크 수용은 별도다. 기존 자산 `203785492` 유형 경고가 재관측됐다. Git 릴리스 태그·Roblox 게시 없음 |

## 0.5.0 — 네 영웅 시험 로비와 튜토리얼

| 항목 | 실제 결과 |
| --- | --- |
| 입력 소스 | `02424864917bed834c2e2f03615cbf3a1f47733b`, `VERSION=0.5.0`. 빌드 전 `origin/main`과 동일 SHA 확인 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.5.0/TheLastThrone-0.5.0.rbxlx`, 종료 0. 해당 버전의 기존 결과물 없음 확인 |
| 결과물 | 799,808 bytes, SHA-256 `b26f395c2f6e53096f6544c3439d4cc729889e6f6929dd115a6ba8b004a6717e`. `builds/` 아래 Git 제외 로컬 결과물 |
| 입력 자산·스키마 | TD 몬스터 runtime SHA `14e4e9492d280ce887b229cbe6deea5a7a90af2cb643760dc355bcdcb4433ef5`, 플레이어 무기 runtime `8171ad84e021935e16f108eec89bd2beb465ee88b4924c02d6dd8f64173b04c9`, 분리 방패 runtime `77f316e479808e6f39e42ba28eb10ad3d7553bc76141315df8fc03ac4c03f823`. 영속 저장 스키마 없음 |
| 고정 빌드 엔진 검사 | `tests/k0-build-smoke.luau` 종료 0, 346개 통과, 실패·수집 런타임 오류 0. Player 0에서 로비 바닥/경계/스폰·Remote 생성, 19개 모듈, 16개 몬스터 메시/텍스처와 세 적 리스폰을 확인했다. [로그](hero-lobby-build-smoke.log) |
| 고정 빌드 실제 Play | PlaceId 0 격리 Studio의 실제 Player 1명. 마우스로 네 영웅 생성, 각 직업 선택·튜토리얼 출발·무기·공격을 확인하고 로비에 복귀했다. Elf의 약 25.70stud 원거리 공격은 Goblin HP 300→230 유지 및 추격을 관찰했다. [화면](hero-lobby-0.5.0.jpg) · [조건과 한계](hero-lobby.md) |
| 미검증·릴리스 | 영웅/연습은 세션 한정, 플레이어 본체는 Roblox 아바타·TD 직업 색상이다. 지속 저장, 정식 리그/모션·성장·보상, 실제 모바일/패드·다인/지연·성능과 게시 Experience 자산 권한은 미검증이다. 기존 `203785492` 유형 경고가 재관측됐다. Git 릴리스 태그·Roblox 게시 없음 |

## 0.6.0 — 튜토리얼 전투 피드백

| 항목 | 실제 결과 |
| --- | --- |
| 입력 소스 | `97b4202a3c1d3b1001cc3e0ef8d477b449cbfd84`, `VERSION=0.6.0`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.6.0/TheLastThrone-0.6.0.rbxlx`, 종료 0 |
| 결과물 | 817,588 bytes, SHA-256 `7048971d4822ec8a499d4eadc8f3ac51d91abec635ae77a5e558d7b3d8a0f887`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | `tests/k0-build-smoke.luau` 종료 0, 435개 통과, 실패·수집 런타임 오류 0, Player 0. 네 적의 외형·리스폰과 작은 체력 바의 수치/색/사망 시 숨김 확인. [로그](combat-feedback-build-smoke.log) |
| 실제 Play | 빌드 전 동일 런타임 소스로 격리 Studio의 Player 1명·R15 검/방패 방향, 네 직업 동작 일부와 마법 Q 입력을 측정. [상세](combat-feedback.md). 이 빌드 파일 자체의 Player Play는 수행하지 않았다. |
| 상태 | 사용자 추가 요청에 따라 엘프 발사 동작을 다음 버전에서 개선한다. 기존 `203785492` 유형 경고 관측. 모바일/패드·다인 및 게시 Experience 권한은 미검증, 릴리스 태그·Roblox 게시 없음. |

## 0.6.1 — 엘프 발사 동작 조정

| 항목 | 실제 결과 |
| --- | --- |
| 입력 소스 | `34eedb4f33169454c0657d89868cc56d2550c863`, `VERSION=0.6.1`, 빌드 전 origin/main과 동일 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.6.1/TheLastThrone-0.6.1.rbxlx`, 종료 0 |
| 결과물 | 818,630 bytes, SHA-256 `a77153d6a25fc08350e31083cc4597ace5add79b709a576666dd8ccd79d27990`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | `tests/k0-build-smoke.luau` 종료 0, 435개 통과, 실패·수집 런타임 오류 0, Player 0. [로그](elf-release-build-smoke.log) |
| 고정 빌드 실제 Play | 격리 Studio의 실제 Player 1명·R15에서 Elf를 로비 UI로 생성하고 튜토리얼로 진입했다. 클라이언트에서 서버에 시험 공격 요청을 보내 활시위 당김 약 0.46 studs, 팔꿈치 회전, 화살 발사와 발사 중 걸린 화살 숨김·복원을 확인했다. 입력 기기와 정밀 손 접촉의 수용 검사는 별도다. |
| 상태 | 세션 전용 시험판. 모바일·패드·다인·게시 Experience 자산 권한은 미검증, Git 릴리스 태그·Roblox 게시 없음. 기존 `203785492` 유형 불일치 경고가 재관측됐다. |

## 0.7.0 — 원거리 표적과 무기 동작 수정

| 항목 | 실제 결과 |
| --- | --- |
| 입력 소스 | `d70aedb019bfb75be46576a7ac9c3a6f003dd4ef`, `VERSION=0.7.0`. 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.7.0/TheLastThrone-0.7.0.rbxlx`, 종료 0 |
| 결과물 | 832,585 bytes, SHA-256 `2a8b92d426f4ec4fb3b4492b6a673a77e55ff37e5c54b41dbb7bb52d7ac53d75`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | `tests/k0-build-smoke.luau` 종료 0, 436개 통과, 실패·수집 런타임 오류 0, Player 0. [로그](targeted-build-smoke.log). 표적 서버 145개·무기 2,177개·기존 타이밍 116개 검사는 [작업 기록](targeted-combat.md)의 소스 fixture 결과다. |
| 고정 빌드 실제 Play | 격리 Studio 실제 Player 1명/R15에서 Elf와 Mage를 로비에서 생성해 튜토리얼 진입. Elf 활이 LeftHand에 붙고 RightHand가 시위를 당겼으며, 시위 깊이는 대기 1.192 → 준비 1.651 → 발사 1.198 → 복귀 1.192 studs, 화살이 복구되는 것을 확인. Mage 버튼이 CAST로 표시됨. 공격 자체는 테스트 스크립트에서 서버 요청을 보냈다. |
| 미검증·릴리스 | 손과 시위의 정확한 접촉·최종 애니메이션 품질, R6 실플레이, 모바일·패드·다인·게시 Experience의 원본 메시 권한은 미검증이다. 기존 `203785492` 유형 경고가 재관측됐다. Git 릴리스 태그·Roblox 게시 없음. |

## 0.7.1 — 엘프 활 잡는 손 높이 조정

| 항목 | 실제 결과 |
| --- | --- |
| 입력 소스 | `6989c5398b9dbd15c7c3d1a28364bc1a2be81e61`, `VERSION=0.7.1`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.7.1/TheLastThrone-0.7.1.rbxlx`, 종료 0 |
| 결과물 | 832,585 bytes, SHA-256 `ebd43bf8fe051a84b4ebd7c6c1c1537afba93834e691a93d6be9dc5162ebf94c`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | `tests/k0-player-weapons-native.luau`, 종료 0, 무기/활 동작 2,177개 검사 통과, Player 0. [로그](bow-lower-build-native.log) |
| 실제 Play | 빌드 전 동일 게임 소스로 격리 Studio의 R15 Player를 측정. 왼손과 시위 중앙의 높이 차이 약 0.04 studs. [상세](bow-hand-adjustment.md). 이 빌드 파일 자체의 Player Play는 별도 수행하지 않았다. |
| 미검증·릴리스 | 사용자 아바타별 화면 수용, R6 실플레이·모바일·다인 및 게시 환경은 미검증. Git 릴리스 태그·Roblox 게시 없음. |

## 0.8.0 — 슬라임 분열·피격 인식·엘프 발사 자세

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `901b9259fde27d8b5e1e83d2c56352e55dcd3c2c`, `VERSION=0.8.0`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.8.0/TheLastThrone-0.8.0.rbxlx`, 종료 0 |
| 결과물 | 837,141 bytes, SHA-256 `4466693d670e152fa9b6ffd0b069f7169874e42b6be08cfdb1bab010e2621454`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | `tests/k0-build-smoke.luau`, 종료 0, 449개 통과, 검사 수집 런타임 오류 0, Player 0. 자식 분열·크기·체력·재생성 확인. [로그](slime-awareness-build-smoke.log) |
| 소스 fixture와 Play | 공격 인식 182개, 무기 2,177개, 타이밍 116개 검사 및 격리 R15 손 위치 측정은 [작업 기록](slime-awareness-bow.md) 참고. 실제 손 위치 조정은 동일 소스의 격리 Play에서 수동으로 측정했다. |
| 미검증·릴리스 | 다양한 아바타 체형의 자세와 시각 수용, 실제 사용자 조작·다인·게시 환경은 미검증. Git 릴리스 태그·Roblox 게시 없음. |

## 0.8.1 — 기사·드워프·마법사 근접 공격 동작

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `f801ed7b5312c2c37969a560938ed585c679b690`, `VERSION=0.8.1`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.8.1/TheLastThrone-0.8.1.rbxlx`, 종료 0 |
| 결과물 | 837,882 bytes, SHA-256 `2e639c08eb766a193e991f4c61934feab81736c606d12fcf8626d0a4a788103f`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | `tests/k0-melee-motion-native.luau`, 종료 0, 28개 통과. 실제 R6/R15 리그와 무기 소켓의 순운동학 검사. [로그](melee-swing-build-native.log) |
| 소스 fixture 및 실제 Play | 기존 무기 2,177개 검사와 격리된 실제 R15 플레이의 무기 끝 위치 측정은 [작업 기록](melee-swing-motion.md) 참고. 이 빌드 파일 자체의 Player Play는 수행하지 않았다. |
| 미검증·릴리스 | 사용자 화면 평가, 다양한 아바타 체형, R6 Play·다인·모바일·게시 환경은 미검증. Git 릴리스 태그·Roblox 게시 없음. |

## 0.8.2 — 드워프·마법사 전방 공격 동작

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `52d80bffedba0b6e545a4e5bb8bebb1226574830`, `VERSION=0.8.2`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.8.2/TheLastThrone-0.8.2.rbxlx`, 종료 0 |
| 결과물 | 837,921 bytes, SHA-256 `50db22edcaacf10ed7f1cf7863d8cab9881a86574fa6ade6a3ec8fe40b214b64`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | `tests/k0-melee-motion-native.luau`, 종료 0, 32개 통과. R6/R15 관절 및 무기 소켓의 순운동학 검사. [로그](forward-melee-build-native.log) |
| 소스 fixture 및 실제 Play | 기존 무기 2,177개 검사 및 격리된 R15 플레이 측정은 [작업 기록](forward-melee-motion.md) 참고. 이 빌드 파일 자체의 Player Play는 별도 수행하지 않았다. |
| 미검증·릴리스 | 다양한 체형의 시각 평가, R6 실제 Play·다인·모바일·게시 환경은 미검증. Git 릴리스 태그·Roblox 게시 없음. |

## 0.9.0 — 서버 확정 명중 피드백

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `65ee3212213e7fbfe5cef459805cca66cede2094`, `VERSION=0.9.0`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.9.0/TheLastThrone-0.9.0.rbxlx`, 종료 0 |
| 결과물 | 845,941 bytes, SHA-256 `ad81950e3fd8642ba71ce0ab4978ac882b54a939e717dd33e58e96dbf4856411`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | `tests/k0-build-smoke.luau` 451개 통과·수집 런타임 오류 0, Player 0. [로그](hit-feedback-build-smoke.log). `tests/k0-hit-effects-native.luau` 64개 통과. [로그](hit-feedback-build-native.log) |
| 소스 fixture 및 실제 Play | 서버 공격 192개 검사와 격리된 R15 플레이의 드워프·마법사 이벤트 및 임시 음원 로드 확인은 [작업 기록](hit-feedback.md) 참고. 이 빌드 파일 자체의 Player Play는 수행하지 않았다. |
| 미검증·릴리스 | 실제 화면·음성의 사용자 수용, R6 실플레이, 다양한 체형·다인·모바일·게시 환경과 장거리 투사체 시각 동기화는 미검증. Git 릴리스 태그·Roblox 게시 없음. |

## 0.9.1 — 영상 참고 드워프 도끼 공격

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `b5d179adf6ee587321512c94cd29873953c2bd54`, `VERSION=0.9.1`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.9.1/TheLastThrone-0.9.1.rbxlx`, 종료 0 |
| 결과물 | 846,627 bytes, SHA-256 `80f470cca47c29e08de99c25344394c9c119bb7a6a07ffde6924d1b589e4a71e`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | `tests/k0-melee-motion-native.luau` 36개 통과 [로그](axe-reference-build-motion.log), `tests/k0-basic-attacks-native.luau` 196개 통과 [로그](axe-reference-build-combat.log). Player 0의 리그 순운동학·서버 fixture 검사다. |
| 실제 Play 및 한계 | 빌드 전 동일 게임 소스의 격리된 R15 플레이에서 도끼 자세와 슬라임 명중 시점을 측정했다. [상세](axe-reference-motion.md). 이 빌드의 Player Play, 사용자 시각 수용, 다양한 체형·R6·다인·모바일·게시 환경은 미검증이다. 릴리스 태그·Roblox 게시 없음. |

## 0.9.2 — 오른발 회피·기사 대기 검 자세

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `75902835b040b78b304a32ed25a98dc8320c6a4b`, `VERSION=0.9.2`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.9.2/TheLastThrone-0.9.2.rbxlx`, 종료 0 |
| 결과물 | 847,303 bytes, SHA-256 `f826e5725732d27981c5b11fc62c76c8a95a30f81d05897bae4ab11e9b378066`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | `tests/k0-dodge-pose-native.luau` 28개 통과. 네 직업 R6/R15 관절 순운동학과 기사 대기 검 방향을 검사. Player 0. [로그](dodge-right-foot-build-native.log) |
| 실제 Play 및 한계 | 빌드 전 동일 소스의 격리 R15 기사로 실제 회피·검 자세를 측정했다. [상세](dodge-right-foot.md). 이 빌드 파일의 Player Play, 사용자 시각 수용, 다양한 체형·R6·다인·모바일·게시 환경은 미검증. 릴리스 태그·Roblox 게시 없음. |

## 0.10.0 — 낮은 근접 공격·교대 회피

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `ee9a62b3fa2dfe80377df9f4cf67d1d2fec6b7e1`, `VERSION=0.10.0`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.10.0/TheLastThrone-0.10.0.rbxlx`, 종료 0 |
| 결과물 | 847,736 bytes, SHA-256 `e077b556269a164ed5af0f675f544fb147c787b508515a42e66ab21c569fd3e2`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | `tests/k0-dodge-pose-native.luau` 60개, `tests/k0-melee-motion-native.luau` 40개, `tests/k0-timing-native.luau` 121개 통과. Player 0의 관절·서버 fixture 검사다. [회피](alternating-dodge-build-native.log), [무기](low-swing-build-native.log), [서버](alternating-dodge-build-timing.log) |
| 실제 Play 및 한계 | 빌드 전 격리 R15 플레이의 발 교대·무기 궤적 측정은 [상세](low-swing-alternating-dodge.md) 참고. 이 빌드의 Player Play, 다양한 체형·R6·실기기·다인·게시 환경과 사용자 시각 평가는 미검증이다. 릴리스 태그·Roblox 게시 없음. |

## 0.11.0 — 근접 표적 공격·높은 도끼 자세

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `49167bbd32a79b16f1234a4fa3190750680b61ca`, `VERSION=0.11.0`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.11.0/TheLastThrone-0.11.0.rbxlx`, 종료 0 |
| 결과물 | 849,825 bytes, SHA-256 `0a6029b8dc0c0b39f765e6aea503d314f1b06013881b225c89e04380444f6b7c`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | `tests/k0-build-smoke.luau` 451개, `tests/k0-melee-motion-native.luau` 40개, `tests/k0-basic-attacks-native.luau` 256개 통과. Player 0의 모델·관절·서버 fixture 검사다. [스모크](melee-target-0110-smoke.log), [동작](melee-target-0110-motion.log), [서버](melee-target-0110-server.log) |
| 실제 Play 및 한계 | 빌드 전 동일 표적 코드로 격리된 R15 기사 플레이에서 마우스 클릭 표적·측면 자동 회전·피해를 확인했다. 도끼 높이의 최종 변경과 이 빌드 파일 자체의 Player Play, 다양한 체형·R6·실기기·다인·게시 환경과 사용자 시각 평가는 미검증. 기존 `203785492` 유형 경고가 재관측됐다. [상세](melee-target-high-axe.md). 릴리스 태그·Roblox 게시 없음. |

## 0.11.1 — PC V 회피·Space 점프

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `350e8f31f434cb2890af1f7344a1e4ddcf222b17`, `VERSION=0.11.1`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.11.1/TheLastThrone-0.11.1.rbxlx`, 종료 0 |
| 결과물 | 849,802 bytes, SHA-256 `9fca8c5d1ff0ab19c69dde292377598748066921f1e3925bd50231f05329afe7`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | `tests/k0-build-smoke.luau` 451개 통과, 수집 런타임 오류 0, Player 0. [로그](dodge-v-0111-smoke.log) |
| 실제 Play 및 한계 | 빌드 전 동일 소스의 격리 Studio R15 Knight에서 가상 PC Space 점프와 V 회피, V HUD를 확인했다. 이 빌드 파일 자체의 Player Play·실기기·패드/터치·다인·게시 환경은 미검증이다. [상세](dodge-v.md). 기존 `203785492` 유형 경고가 재관측됐다. 릴리스 태그·Roblox 게시 없음. |

## 0.12.0 — 네 영웅 공통 기술·마나·스태미나 제거

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `1be1c39b916a9e65424cd6919a482e08589d3f84`, `VERSION=0.12.0`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.12.0/TheLastThrone-0.12.0.rbxlx`, 종료 0 |
| 결과물 | 861,964 bytes, SHA-256 `c2b171dafdaec154a218441ba204de67375c0d26b93e24dee00336563e49c8fc`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | `tests/k0-build-smoke.luau` 451개, `tests/k0-basic-attacks-native.luau` 317개 통과. Player 0의 모델·서버 fixture 검사다. [스모크](hero-skills-0120-smoke.log), [서버](hero-skills-0120-server.log) |
| 소스 검사 | 순수 전투 규칙 122개, 격리 Studio 타이밍 106개 및 무기 2,177개 통과. [타이밍](hero-skills-source-timing.log), [무기](hero-skills-source-weapons.log). 타이밍·무기는 최종 피해 효과 조건만 변경하기 전 동일 동작 소스 결과다. |
| 실제 Play 및 한계 | 빌드 전 격리 Studio R15의 MP 소비·기술별 대기·V 연속 회피·스태미나 HUD 부재와 일부 직업 입력을 확인했다. 이 빌드의 Player Play, 모바일·패드·다인·게시 환경, 전체 모션·밸런스 수용은 미검증이다. [상세](basic-skills-mana.md). 기존 `203785492` 유형 경고 재관측. 릴리스 태그·Roblox 게시 없음. |

## 0.13.0 — 공통 액션·스킬 자원과 세션 편성

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `b07e994b6926ed1e723871db2125a6e4b08c1a24`, `VERSION=0.13.0`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.13.0/TheLastThrone-0.13.0.rbxlx`, 종료 0 |
| 결과물 | 873,717 bytes, SHA-256 `179588a4af190937fb3e36ea6230a1e0da325b480eca74e2cf02a09afb05330a`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | `tests/k0-build-smoke.luau` 451개 통과, 수집 런타임 오류 0, Player 0. [로그](action-skill-0130-smoke.log) |
| 소스·실제 Play 및 한계 | 격리 Studio 서버 325·타이밍 106·로비 348개, 로컬 규칙 122·세션 89개 통과. 빌드 전 동일 핵심 전투 소스 R15 Player Play의 Knight 편성·방어·달리기·회피·4번 기술 및 Mage 1번 MP 기술 확인. 최종 빌드 Player Play, 실기기·다인·게시 환경과 사용자 수용은 미검증. 기존 `203785492` 유형 경고 재관측. [상세](action-skill-prototype.md). 릴리스 태그·Roblox 게시 없음. |

## 0.14.0 — Mage 기본 주문

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `6f9436625f9215f9af7825a9124c8046c829302f`, `VERSION=0.14.0`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.14.0/TheLastThrone-0.14.0.rbxlx`, 종료 0 |
| 결과물 | 874,789 bytes, SHA-256 `9a15ed5da472de845a9a0e7967d3baa5303f127be766f306649b0eea65c7dd93`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | `tests/k0-build-smoke.luau` 451개 통과, 수집 런타임 오류 0, Player 0. [로그](mage-spells-0140-smoke.log) |
| 소스·실제 Play 및 한계 | 격리 Studio 서버 fixture 332개, 로컬 규칙 122개·세션 89개 통과. 빌드 전 동일 소스 R15 Player에서 세 주문 이름·1~3 입력·MP·쿨다운 확인. Gravity 실전 적중·시각 수용, 최종 빌드 Player Play, 실기기·다인·게시 환경 미검증. 기존 `203785492` 자산 유형 경고 재관측. [상세](mage-basic-spells.md). 릴리스 태그·Roblox 게시 없음. |

## 0.15.0 — 기사 기본 스킬·Gravity 광역

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `8e9dc6eb8e9fe9e90d471798f3f617a10c91264a`, `VERSION=0.15.0`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.15.0/TheLastThrone-0.15.0.rbxlx`, 종료 0 |
| 결과물 | 879,255 bytes, SHA-256 `dc9cade18d4c75b5de1f6ff85bb57958015d4aeea360c0074288bc36991f03e5`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | 최초 스모크는 Roblox Studio TexturePack 업로드 429 요청 제한 오류가 수집되어 실패했다. [원본 로그](knight-gravity-0150-smoke-initial.log). 제한 시간이 지난 후 같은 빌드 파일의 재검사에서 451개 통과, 런타임 오류 0, Player 0. [재검사 로그](knight-gravity-0150-smoke.log) |
| 소스·실제 Play 및 한계 | 서버 fixture 351개, 로컬 규칙 122개·세션 89개 통과. 빌드 전 동일 소스 R15 Player에서 기사 세 기술의 이름·1~3 입력·Stamina·쿨다운 확인. 실제 Player 다중 적 광역·도발·시각 수용, 최종 빌드 Player Play, 실기기·다인·게시 환경은 미검증. 기존 `203785492` 자산 유형 경고 재관측. [상세](knight-gravity-area.md). 릴리스 태그·Roblox 게시 없음. |

## 0.16.0 — 드워프·엘프 기본 스킬

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `31a28b5facd3d372dddc1f911cadb92a2d5907d9`, `VERSION=0.16.0`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.16.0/TheLastThrone-0.16.0.rbxlx`, 종료 0 |
| 결과물 | 882,976 bytes, SHA-256 `dfa0d389f0fc50c7c8fd71bcf77110d55b148a8c749004c54f1b5f1889d0721d`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | `tests/k0-build-smoke.luau` 451개 통과, 수집 런타임 오류 0, Player 0. [로그](dwarf-elf-0160-smoke.log) |
| 소스·실제 Play 및 한계 | 서버 fixture 374개, 로컬 규칙 122개·세션 89개 통과. 빌드 전 동일 소스 R15 Player에서 드워프·엘프의 기술 이름·1~3 입력·Stamina·쿨다운 및 엘프 화살 시퀀스 확인. 실제 Player 다중 적 광역·연출의 시각 수용, 최종 빌드 Player Play, 실기기·다인·게시 환경은 미검증. 기존 `203785492` 자산 유형 경고 재관측. [상세](dwarf-elf-starter-skills.md). 릴리스 태그·Roblox 게시 없음. |

## 0.17.0 — 기본 스킬 동작·적중 효과

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `b5b972cb2d070e04ceb32cafd9fd4173ea1732a4`, `VERSION=0.17.0`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.17.0/TheLastThrone-0.17.0.rbxlx`, 종료 0 |
| 결과물 | 892,120 bytes, SHA-256 `4e76f1cb6a43e7e9d2ecb85a012554d7deb994104f723e0ed26cc7ea3a9d9c18`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | `tests/k0-build-smoke.luau` 451개 통과, 수집 런타임 오류 0, Player 0. [로그](skill-visuals-0170-smoke.log) |
| 소스·실제 Play 및 한계 | 스킬 자세 30·타격 효과 99·서버 376·기본 근접 40·무기 2,177개 통과. 빌드 전 격리 R15 Player에서 Elf 실제 명중 효과·Rapid Fire 시점, Knight 도발 표시·몸통 회전 확인. 전체 Player 시각 수용, 최종 빌드 Player Play, 실기기·다인·게시 환경은 미검증. 기존 `203785492` 자산 유형 경고 재관측. [상세](starter-skill-visuals.md). 릴리스 태그·Roblox 게시 없음. |

## 0.17.1 — 쿨다운 숫자를 아이콘 안에 표시

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `c5d836506ce266349241356e51c4ae88285ca734`, `VERSION=0.17.1`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.17.1/TheLastThrone-0.17.1.rbxlx`, 종료 0 |
| 결과물 | 892,236 bytes, SHA-256 `839aca8fa69ca6cb208092d54bb564a7b15e519b0973165d61d4bb7729a91d3e`, Git 제외 로컬 결과물 |
| 고정 빌드 검사 | 첫 실행은 Studio에서 `K0 shared sources missing`으로 시작 전 중단됐다. 빌드 XML에 Shared/K0Config 존재를 확인하고 같은 파일을 절대 경로로 재검사해 451개 통과, 수집 런타임 오류 0, Player 0. [최초 로그](cooldown-0171-smoke-initial.log) · [재검사 로그](cooldown-0171-smoke.log) |
| 실제 Play 및 한계 | 빌드 전 동일 GUI 소스의 격리 R15 Player에서 Whirlwind 쿨다운 시간의 아이콘 내부 위치·키/스킬명 비중첩과 만료 시 아이콘 복원을 확인했다. 최종 빌드 Player Play, 모바일·패드와 사용자 시각 수용은 미검증. [상세](cooldown-inside-icon.md). 릴리스 태그·Roblox 게시 없음. |

## 0.18.0 — 전투 연출, 몬스터 크기 및 TD 일반 배경 음악

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `34bf6f2d11212d766b1a89a44010255cb34043c2`, `VERSION=0.18.0`, 빌드 전 origin/main 일치 |
| 빌드 | `rojo build default.project.json --output builds/0.18.0/TheLastThrone-0.18.0.rbxlx`, 성공 |
| SHA-256 | `271c8b38966afef466582c6e971565311c8401587af88e1c116a7f04bb46873e` |
| 빌드 검증 | 격리 Studio `tests/k0-build-smoke.luau` 452개 검사 통과, 런타임 오류 0. 확대된 TD 외형 및 리그 검증. |
| 음악 검증 | 격리 Studio에서 Riftstorm `73105938035554` 로드·재생 상태, 61.538초, 반복 및 음량 0.20 확인. 실제 청취와 게시된 RPG Experience 사용 권한은 미검증. |
| 전투 검증 | [소스 픽스처 및 제한](2026-10-28-combat-and-bgm.md) 참고. 실제 Player Play·모바일·체감 수용은 미검증. |

일반 빌드이며 릴리스 태그와 Roblox 게시를 하지 않았다.

## 0.18.1 — Ground Slam 도약과 오우거 축소

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `79181ce48b65cb38f04c127de0213dc5a7e393e1`, `VERSION=0.18.1`, 빌드 전 origin/main 일치 |
| 빌드 | `rojo build default.project.json --output builds/0.18.1/TheLastThrone-0.18.1.rbxlx`, 성공 |
| SHA-256 | `51fab35c0e19d474b1cb78de45176afd464d65f4dc9b042f833b6c8d97d3998d` |
| 격리 Studio | 무기·연출 픽스처 2198개 검사 및 빌드 smoke 452개 검사 통과. 오우거 외형 높이 약 10.33, 오크 약 6.90 스터드. 런타임 오류 0. |
| 제한 | 실제 플레이어의 애니메이션 체감, 네트워크 복제와 모바일 실기는 미검증. [상세](2026-10-28-ground-slam-ogre.md) 참고. |

일반 빌드이며 릴리스 태그와 Roblox 게시를 하지 않았다.

## 0.18.2 — 고블린·슬라임 확대

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `51a254904c3e8a9ca9e975503e1c9c550ca5deea`, `VERSION=0.18.2`, 빌드 전 origin/main 일치 |
| 빌드 | `rojo build default.project.json --output builds/0.18.2/TheLastThrone-0.18.2.rbxlx`, 성공 |
| SHA-256 | `22d3debe79690ab16c388f7c4e966a56286cb897ae79b4d10654190c91ab3b33` |
| 격리 Studio | 빌드 smoke 458개 검사 통과, 런타임 오류 0. 확대된 외형·리그, 부모와 분열 자식의 체력바·절반 크기·체력 확인. |
| 제한 | 실제 플레이의 크기 체감과 모바일 화면은 미검증. [상세](2026-10-28-goblin-slime-scale.md) 참고. |

일반 빌드이며 릴리스 태그와 Roblox 게시를 하지 않았다.

## 0.18.3 — 양손 무기 방어 및 버튼 배치

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `bc67459207f937b146c988d65a5e43648c73eefb`, `VERSION=0.18.3`, 빌드 전 origin/main 일치 |
| 빌드 | `rojo build default.project.json --output builds/0.18.3/TheLastThrone-0.18.3.rbxlx`, 성공 |
| SHA-256 | `1d2fbce48152c5904d3d20e2c61a06908f5df86b98cedb2f5d53dcf7cb9705ba` |
| 격리 Studio | 빌드 smoke 458개 검사 통과, 런타임 오류 0. 무기·동작 2238개 및 움직이는 리그 방어 위치 15개 검사 통과. |
| 제한 | 실제 플레이의 손 접촉·자세, 네트워크 복제 및 모바일 버튼 수용 미검증. [상세](2026-10-28-two-handed-guard.md) 참고. |

빌드 당시에는 일반 빌드였으며, 이후 아래와 같이 별도로 게시했다.

### 0.18.3 Roblox 게시 기록

- 2026-10-28 20:24 EDT: 사용자가 Studio의 `TheLastThrone-0.18.3.rbxlx`에서 기존 The Last Throne Experience `10773575153`, 시작 Place `70829337938054`에 게시했다. 자동화는 구 Studio 창만 제어하여 게시 동작은 사용자가 직접 수행했다.
- Studio Edit에서 Place/Experience ID와 양손 방어 코드 존재를 확인했다. Creator Dashboard의 Version History에서 **게시된 Place 버전 4**와 시간을 확인했다. Experience의 게임 접근과 대상은 확인 당시 Private이었다.
- Roblox의 Place 버전 4와 게임 빌드 버전 `0.18.3`은 서로 다른 번호다. 빌드 SHA-256은 위의 0.18.3 기록과 같다. 실제 게시된 Roblox 클라이언트에서의 시각·입력·음원 재생 및 제한 자산 권한은 별도 검증 대상이다.
- 주석 태그 `v0.18.3`은 빌드 입력 커밋 `bc67459207f937b146c988d65a5e43648c73eefb`를 가리키며 원격에 푸시하고 역참조를 확인했다.

## 0.18.4 — 양손 방어 접촉 보정

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `b02c926b6b75abc9e7f3d8254189000e8715e723`, `VERSION=0.18.4`, 빌드 전 origin/main 일치 |
| 빌드 | `rojo build default.project.json --output builds/0.18.4/TheLastThrone-0.18.4.rbxlx`, 성공 |
| SHA-256 | `24ba152a580ed44329f6a458f4bde3a1500dbe1a9f1bdaf6ec6e52fc6c8b5820` |
| 격리 Studio | 빌드 smoke 458개, 움직이는 R6/R15 접촉·회전·해제 30개, 무기·동작 회귀 2238개 검사 통과. |
| 제한 | 실제 플레이 및 다양한 체형의 자연스러움과 네트워크 복제는 미검증. [상세](2026-10-28-guard-hand-contact.md) 참고. |

일반 빌드이며 Roblox 게시와 릴리스 태그는 수행하지 않았다.

## 0.18.5 — HP·스태미나 회복 조정

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `8e53714d9986df99f11c72cad7349c48f008bd1e`, `VERSION=0.18.5`, 빌드 전 origin/main 일치 |
| 빌드 | `rojo build default.project.json --output builds/0.18.5/TheLastThrone-0.18.5.rbxlx`, 성공 |
| SHA-256 | `23a83aa3ab54e3848300c1a03f00b9543fe8d75b80e823f1cae0045b1daf9d91` |
| 격리 Studio | 서버 전투 400개 검사와 빌드 smoke 458개 검사 통과. 기본 HP 회복 대체 스크립트 배치 확인. |
| 제한 | 실제 플레이어 생성 시 기본 회복 중복 여부 및 회복 속도 체감은 미검증. [상세](2026-10-28-player-regen.md) 참고. |

일반 빌드이며 Roblox 게시와 릴리스 태그는 수행하지 않았다.

## 0.18.6 — 가로 방어와 슬라임 추가 확대

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `19eac45a9766822aac3d378b11e6c37e87ad5f05`, `VERSION=0.18.6`, 빌드 전 origin/main 일치 |
| 빌드 | `rojo build default.project.json --output builds/0.18.6/TheLastThrone-0.18.6.rbxlx`, 성공 |
| SHA-256 | `fe022b9f7379d4b99044bed31e83c0600ac81ed6f74c2b97853fec670296dab4` |
| 격리 Studio | 빌드 smoke 458개, 동적 양손·수평 방어 42개, 무기·동작 회귀 2238개 검사 통과. 슬라임 분열 및 체력바 검사 포함. |
| 제한 | 실제 Player·다양한 체형의 미관, 네트워크 복제와 모바일 성능 미검증. [상세](2026-10-28-horizontal-block-slime.md) 참고. |

일반 빌드이며 Roblox 게시와 릴리스 태그는 수행하지 않았다.

## 0.18.7 — Overhead Smash 회전과 타격 효과

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `a52048f3082d4c4fba1e6df31ca1ee5ceced101d`, `VERSION=0.18.7`, 빌드 전 origin/main 일치 |
| 빌드 | `rojo build default.project.json --output builds/0.18.7/TheLastThrone-0.18.7.rbxlx`, 성공 |
| SHA-256 | `323813d9fbb4fafe815b38197fe3f559c982f6d5f7b93f73a662b1db5dc1db99` |
| 격리 Studio | 빌드 smoke 458개, 서버 전투 401개, 스킬 자세 35개, 효과 102개, 실제 리그 회전 경로 6개, 무기 회귀 2238개 검사 통과. |
| 제한 | 실제 Player 및 네트워크·모바일·동작 체감 미검증. [상세](2026-10-28-overhead-smash.md) 참고. |

일반 빌드이며 Roblox 게시와 릴리스 태그는 수행하지 않았다.

## 0.18.8 — Stamina 제거

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `f239075287ec022d25130bbff0da5a632e35a745`, `VERSION=0.18.8`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.18.8/TheLastThrone-0.18.8.rbxlx`, 종료 0 |
| 결과물 | 906,697 bytes, SHA-256 `0ae7fd67b09a6c16b397854e6ff2e448f98225a3cb473e918f88026cf145bea9`. Git 제외 로컬 파일 |
| 격리 Studio | 고정 빌드 smoke 458개·서버 452개·UI 83개·타이밍 106개 통과. [스모크 로그](stamina-0188-smoke.log), [상세](2026-10-29-stamina-removal.md) |
| 실제 Player와 한계 | 로컬 Studio의 네 직업 기본 기술 입력·자원 표시와 Dwarf 사망/리스폰 일부 확인. MP 부족 실제 입력·다인·실기기·사용자 체감 및 게시 환경은 미검증. 기존 `203785492` 유형 경고가 재관측됐다. |

일반 빌드이며 Roblox 게시와 릴리스 태그는 수행하지 않았다.

## 0.18.9 — 전직 슬롯 안내 수정

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `ea21dd0e59a4cf55248699608030470e78ed2ec5`, `VERSION=0.18.9`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.18.9/TheLastThrone-0.18.9.rbxlx`, 종료 0 |
| 결과물 | 906,746 bytes, SHA-256 `131694ba180af11c4c644ea03221b6c9281a140717008ebe3933983bf48d2792`. Git 제외 로컬 파일 |
| 격리 Studio | 고정 빌드 smoke 458개·UI 85개 통과. [스모크 로그](stamina-0189-smoke.log), [상세](2026-10-29-stamina-removal.md) |
| 실제 Player와 한계 | 수정된 Lv20/40 안내·연습 전용 버튼 및 Knight 기술 1개를 확인. 0.18.8의 네 직업 검사를 이 빌드 전체의 실플레이 수용으로 간주하지 않는다. 작은 화면·다인·게시 환경·사용자 체감은 미검증. 기존 `203785492` 유형 경고가 재관측됐다. |

일반 빌드이며 Roblox 게시와 릴리스 태그는 수행하지 않았다.

## 0.18.10 — 슬라임 분열 직후 같은 타격의 재적중 수정

| 항목 | 결과 |
| --- | --- |
| 입력 소스 | `a054243d2ce4d4c4aa49075f36525e5869afa2f8`, `VERSION=0.18.10`, 빌드 전 origin/main 일치 |
| 빌드 | Rojo 7.7.1 `rojo build default.project.json --output builds/0.18.10/TheLastThrone-0.18.10.rbxlx`, 종료 0 |
| 결과물 | 907,341 bytes, SHA-256 `e7e0fdf6ce5ae63ab0be90afa6b06e65515960abbda0449def27a4d90c662b00`. Git 제외 로컬 파일 |
| 격리 Studio | 고정 빌드 서버 전투 466개·타이밍 106개·smoke 458개 통과, 각 명령 종료 0. smoke 실패·수집 런타임 오류 0. [서버](slime-01810-server.log) · [타이밍](slime-01810-timing.log) · [smoke](slime-01810-smoke.log) |
| 실제 Player와 한계 | 서버에서 부모 HP를 조절한 단일 Knight Play에서 처치한 검격 뒤 작은 슬라임 둘이 HP 55로 생존하고 다음 검격에 피해를 받았다. Mage의 MP 가득 참·소모 후 물약도 부분 확인했다. 사용자 시각 수용·실기기·다인·MP 부족·게시 환경은 미검증. [상세](2026-10-29-player-combat-and-slime.md). 기존 `203785492` 유형 경고가 재관측됐다. |

일반 빌드이며 Roblox 게시와 릴리스 태그는 수행하지 않았다.

## 0.19.0~0.19.3 — 장비·아이템·가방·공용 창고와 TD UI

새 기능 묶음으로 MINOR를 올리고, 실제 Player 검사에서 발견한 표시·입력/가독성 수정을 MICRO로 분리했다. 모든 입력 커밋은 빌드 전에 origin/main과 일치를 확인했고, Rojo 7.7.1 `rojo build default.project.json --output builds/<version>/TheLastThrone-<version>.rbxlx`는 각각 종료0이었다. 산출물은 Git 제외 로컬 파일이다.

| 버전 | 입력 소스 커밋 | bytes | SHA-256 | 결과/범위 |
| --- | --- | --- | --- | --- |
| 0.19.0 | `bc47ed023c997eebf9e49cc96cb51175d2d4931f` | 1,003,308 | `5dce98f09dffc03b860e856aa89335ebae38462d9f3ba43ce53bab2c2f0da7ae` | 빌드 성공. 실제 Player에서 장착/대기 수령·F 창고 진입 확인, 정상 조회 오류/초기 배지·수량 포커스 결함 발견 |
| 0.19.1 | `5b50ac23756eba4f2ae75136bfc8183dd498bedd` | 1,003,982 | `d694c0cd73d3c8b6bdd766a448600cbe3fbcea1eee6fa5199d161c0134f047a4` | 빌드 성공. 오류/배지 수정과 실제 수량7·부분 보관 확인 |
| 0.19.2 | `13663a338983078c333b12c5008f3d3f30991354` | 1,005,264 | `e8e08929a74f1ba25892818f71135fc3ce71ff7db2eb0613cfb1d6d88d95642c` | 빌드 성공. 8슬롯·다른 영웅 인출/병합·클래스 거부·물약 재전송/리스폰·메뉴 입력 차단과 폭 제한 UI 확인 |
| 0.19.3 | `1eebb93f41c303be765d7e12d21855078f69b33b` | 1,005,956 | `a10e9dd493b42e0183c9a4dd183aadf7305d60b38f0c15770693a33440672de6` | 빌드 성공. 최종 필터/수량/로비 안내, 등록·잠금·검색과 폭 제한 목록→상세→뒤로 확인 |

0.19.3 고정 빌드: 서버 전투481·타이밍106·UI85·무기2238개 모두 종료0/통과. [서버](../inventory/0.19.3-combat.log) · [타이밍](../inventory/0.19.3-timing.log) · [UI](../inventory/0.19.3-ui.log) · [무기](../inventory/0.19.3-weapons.log). smoke468개·실패/수집 런타임 오류0·Player0, [완료 보고서 요약](../inventory/0.19.3-smoke-summary.json). 별도 순수 Lua 인벤토리143·기존 규칙125·세션89개 통과.

실제 Player는 격리 비게시 Studio의 단일 R15와 도구 입력이다. Studio는 세션 어댑터를 사용하며 게시 DataStore·실제 재접속·동시 서버·실기기/패드 수용은 미검증이다. 화면 폭 제한은 실기기 결과가 아니다. 새 방어구 외형·정식 성장/보상/상품/리셋/판매·제작은 후속이다. `203785492` 유형 경고 및 Studio `MaterialManager` 경고는 수집 런타임 오류0과 별도로 남는다. [상세·화면·실패/수정 과정](../inventory/README.md).

일반 로컬 시험 빌드이며 Roblox 게시·실제 DataStore 변경·릴리스 태그를 수행하지 않았다. 사용자와 다른 작업의 스토리 문서 커밋이 사이에 포함됐으며 해당 문서는 보존했다.

## 0.20.0~0.20.2 — TD 배틀 HUD

TD 배틀 HP 프레임과 공통 패널·버튼 셸을 HUD에 적용했다. 원본/해시는 [공유 manifest](../../../assets/shared/td-ui-runtime/manifest.json)에 고정했다. Rojo7.7.1 빌드 명령은 각 `rojo build default.project.json --output builds/<version>/TheLastThrone-<version>.rbxlx`이며 모두 종료0. 입력 커밋은 각 빌드 전 푸시했고 원격 일치를 확인했다. 산출물은 Git 제외 로컬 파일이다.

| 버전 | 입력 커밋 | bytes | SHA256 | 검증/수정 |
| --- | --- | --- | --- | --- |
| 0.20.0 | `d60fb58f0f3b428d56ddaf1a11b00d9edff61e72` | 1,009,152 | `04e7405b996cd5c7a191c548b114ee4427c043abb682f58108d9ced1ac3337ea` | GUI100·smoke469개 통과, Player에서 가방/귀환 겹침 발견 |
| 0.20.1 | `de300d886eb93a6ca05d06efa0216cc6ebabd911` | 1,009,152 | `b77d0fd539358cd5a0703bf50092cb82854492b928314bec9568d7074ba1fe9a` | GUI101개 통과, 실제 Mage MP/쿨다운·390px Root 확인, 낮은 가로 배치 겹침 발견 |
| 0.20.2 | `5bbf013ca43668edf31a522c36c85adc50772d2d` | 1,009,431 | `2c2e3c4af5e2d53025cd1a1095251088994660aff3955fefe5ad67b81d1cf68b` | GUI101개 통과. 실제 Knight 방어/스킬·B가방·귀환,390×700/640×360 Root 배치 확인 |

[상세·원시 로그·화면·미검증](../battle-hud/README.md). 일반 로컬 시험 빌드이며 실제 디바이스/게시 Experience 수용·Roblox 게시·릴리스 태그를 수행하지 않았다.0.20.0 smoke 전체를 마지막 두 배치 수정에서 반복하지 않았다.

## 0.20.3 — 사용자 요청 UI 균형 조정

입력 소스 `32cc0d05e270c30e14c619061cb6e939d242567e`를 origin/main에 고정 후 `rojo build default.project.json --output builds/0.20.3/TheLastThrone-0.20.3.rbxlx` 성공(종료0).1,009,590 bytes, SHA256 `3ad8b612a880f353ed16c8610ac58135f33444d8fb099c2feb44e75b7843561d`. Dodge V 제거/R 유지, Attack16px 왼쪽/Sprint14px 오른쪽, 아이템과 스킬32px 간격·붉은 아이템 셸 적용. GUI101개 통과, 실제 Knight Player에서 V→회피0/R→회피1과 표시·390×700/640×360 Root 배치 확인. [로그·화면·범위](../battle-hud/README.md). 로컬 일반 빌드이며 Roblox 게시·릴리스 태그·실기기 검증은 수행하지 않았다.

## 0.20.4~0.20.5 — Attack 추가 이동·HP 자연 회복 감속

각 소스/VERSION을 커밋·푸시하고 원격 일치 확인 후 Rojo7.7.1 `rojo build default.project.json --output builds/<version>/TheLastThrone-<version>.rbxlx` 성공(종료0). 각각1,009,590 bytes, Git 제외 로컬 산출물이다.

| 버전 | 소스 | SHA256 | 결과 |
| --- | --- | --- | --- |
| 0.20.4 | `93373b9520af360825a01197364c0c08e6128e59` | `4e38367dc573e7e6cff00d6cb1bd19c4db98da8d910186dc64903988c1ca8742` | Attack x118→102,실제 Knight Player 위치/비겹침 assert 통과 |
| 0.20.5 | `aa4d691c69fa81ea6c3bfb3476b44ca5bf6c94f0` | `fa205ba9b64373b9ce72e0fda0fb71dd089c5c3309a639d7e3fcf5c07cbc7f13` | HP 초당0.2%→0.1%,서버481개 통과. 실제 Knight HP500→504.996/5.011초 측정 |

[검증·화면·미검증](../battle-hud/README.md). Studio 격리 시험이며 Roblox 게시·릴리스 태그·실기기 수용을 수행하지 않았다. 다른 작업의 스토리 문서 커밋은 보존했다.

## 0.21.0~0.22.2 — 물약8종·컨셉 가방 재디자인

각 소스/VERSION을 커밋·푸시하고 원격 일치 확인 후 Rojo7.7.1 `rojo build default.project.json --output builds/<version>/TheLastThrone-<version>.rbxlx` 종료0. 산출물은 Git 제외 로컬 파일이다.

| 버전 | 입력 소스 | bytes | SHA256 | 결과 |
| --- | --- | --- | --- | --- |
| 0.21.0 | `573cbe12a97d53b01618203b71deb4065d1c98b0` | 1,014,554 | `4eb7751b6f1eb3f4b394184d766850f6f705440b883f6b86a647b4fbb083cd05` | 최초6종,서버505/GUI120개 통과. 사용자 디자인 지적/회복량 변경으로 대체 |
| 0.22.0 | `8cd973ffa8899bd9dbcd67b7e2885f83476c6aef` | 1,026,714 | `42826484e5ef7496791ae7af44f78776d69822151162fff148d6093dae1a6086` | 8종/재디자인,서버513/GUI126개 통과. 프레임/카드 표시 결함 발견 |
| 0.22.1 | `3d68ad747ba69f4947a45ef78badd378793f9fd2` | 1,030,061 | `d21e4733c82ef3dcf02688b895102828c22fcc71901e0184869cd91f08a77bfd` | 새 삽화/프레임 수정,GUI126개 통과. 사용자 글자 배경 제거 요청 |
| 0.22.2 | `a96ee69c3f21a9bb322889b00bcc33350dc41350` | 1,030,080 | `0a0cfc39b657ca5b31de94767591dd0d999739bb69c69d52ee403d778accd79c` | 글자 배경 제거/글자 크기·crop 수정,GUI134개 통과. 실제 Mage 양쪽XL 회복/각x0·장착·부분 이동·폭 제한 전환 확인 |

별도 순수 인벤토리226개 통과. 새 RPG 삽화 이미지135019494060990 업로드/Studio 로드 확인,원본/해시는 [manifest](../../../assets/ui/item-icons-v1/manifest.json). [상세·원시 로그·화면·미검증](../potions/README.md). 일반 로컬 시험 빌드이며 Roblox Place 게시·릴리스 태그·실기기/게시 저장 수용은 수행하지 않았다. 다른 작업의 스토리/결정표 변경은 보존했다.

## 0.23.0~0.24.1 — 영웅 성장·8계열 전직

각 입력 소스/VERSION을 커밋·원격 푸시한 후 Rojo7.7.1로 생성했다. 아래 모두 로컬 빌드 성공이며 일반 빌드에 릴리스 태그나 Roblox 게시를 추가하지 않았다.

| 버전 | 입력 소스 | bytes | SHA256 | 결과 |
| --- | --- | --- | --- | --- |
| 0.23.0 | `a702f23188e6c10864cad47f54be16670fc4ad49` | 1,060,687 | `63fbe3d5aaa3709c0b17fa029c227ca06a277ed2d2ca60f84b87afc97c9e3898` | 기본 성장/숙련/TD 영웅 UI. 이전 시작HP 시험판 |
| 0.23.1 | `9c6b28dac621a5458ec8adccb5746192bcb89de6` | 1,061,195 | `556bfb0d9159b4e6243204f669e85c537541bc2b0c315660b3850d4e1ad13246` | HP/MP 상시 표시·메뉴 이동 차단. 이후 전직 포함/시작HP 변경 지시로 대체 |
| 0.24.0 | `d34b4955132e2f9d2a8b459e06c111a42f15704d` | 1,095,222 | `cd68d030021a2bd689daddb6a91c54633ab48f9ddedcecf7ff75182851d0fc47` | 최신 HP·8계열104개 기술 확장. smoke479·서버823개 통과 |
| 0.24.1 | `036809b8bf437b9e007b62f99e0d31a231f87463` | 1,095,733 | `c89155e6c225e61624497811de7569d1cc8ac21df105710339f3229c4725225a` | 직접 스킬 선택→슬롯 편성. 실제 Player 최신 자원/전직/궁극기·마법궁수 MP 확인 |

[전체 범위·검증 명령·실제 Player QA 조건·한계](../progression/README.md), [빌드 메타데이터](../progression/builds.json). Studio 세션/서버 대역 검사이며 실제 게시 저장·재접속·다인/실기기·최종 미술 수용은 미검증이다.
