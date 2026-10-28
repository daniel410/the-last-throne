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
