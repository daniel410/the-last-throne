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
