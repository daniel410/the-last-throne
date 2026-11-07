# 전투 중 Selene 상호작용 클릭 간섭 수정

2026-11-06 · TLT-016/028/057/084 · ENG → QA · 0.79.4 · 로컬 구현·미게시, 부모 티켓 In Progress.

사용자 보고: 배틀에서 셀린이 반복해서 클릭돼 조작을 방해한다. 코드에서 동행 모델 생성 시에도 캠프용 selectionPrompts를 호출하여 Invite/Rest/SupporterDetails 세 프롬프트를 부착하는 경로를 확인했다. InteractionPrompts는 이 프롬프트를 클릭·터치 가능한 BillboardGui로 표시하므로 이동하는 동료가 전투 입력 영역에 버튼을 끌고 다녔다. 실제 제보 기기의 입력 이벤트 기록은 없으며 소스상 확인한 간섭 경로를 수정했다.

SeleneCompanion에서 이동 동료에 프롬프트를 붙이는 호출을 제거했다. 고정 캠프의 초대·휴식·상세 보기와 로비 구매/동행, 실제 지원·지원권 소비/저장·AI 상한은 유지한다. 셀린 메시/루트는 기존부터 CanQuery/CanCollide/CanTouch=false이며 이번 수정은 상호작용 버튼 생성만 바꾼다. 명확한 결함 수정이므로 제작 스킬의 리서치 예외를 적용했다. 기존 사용자 모델/첨부/미추적 산출물은 포함하지 않는다.

검증:

- `/private/tmp/td233-luau/luau-compile src/server/Story/SeleneCompanion.luau tests/selene-departure-native.luau`: 컴파일 PASS.
- `lua tests/selene-departure.spec.lua`, `selene-trial.spec.lua`, `selene-recruitment.spec.lua`, `supporter-info.spec.lua`, `support-passes.spec.lua`: 각각26/28/23/45/30, 총152검사 PASS. 존재하지 않는 selene-support.spec.lua 실행은 파일 부재로 실패했으며 검사 수에 포함하지 않았다.
- 기존0.79.3 빌드의 SeleneCompanion 소스만 교체한 격리 후보 `/tmp/tlt-selene-click-candidate.rbxlx`에서 `run-in-roblox --place /tmp/tlt-selene-click-candidate.rbxlx --script tests/selene-departure-native.luau`: **25검사 PASS**([로그](candidate-native.log)). 실제 TD 모델·서비스/규칙을 사용하며 계정/플레이어는 메모리 모의다. 이동 동료 프롬프트0·캠프 프롬프트3·로비 추적/출발·파티AI1·1회 소비/다른 소유자 권리·완료 후 비갱신을 확인했다. 기존203785492 자산 종류 경고1건은 남아 있다.
- `git diff --check`: PASS.

미검증: 실제 게시된 클라이언트와 PC/터치/패드의 연속 공격·화면 터치 수용, 실제 회복 전투. QA는 동행 셀린 근처에서 공격해 상세창/버튼이 나타나지 않는지와 캠프/로비 기능을 확인한다. Roblox 게시·릴리스 태그는 수행하지 않는다. 고정 소스 빌드 결과는 후속 기록한다.

고정 소스 `a74256de62b9496571ad7edd7b8e049bf7b7f7b4`와 VERSION0.79.4의 단일 빌드 성공. `python3 tools/build-game.py --source HEAD --record docs/evidence/selene-combat-click-20261106/build.json` 실행, [입력·LFS 검증·해시](build.json). 산출물 `builds/0.79.4/TheLastThrone-0.79.4.rbxlx`, SHA-256 `d9d5ca970112e29cfd1592e647ecc9aa9597929c959f5f5845a9b278d53429b5` 실제 바이트 일치. `python3 tests/single-build.spec.py --artifact builds/0.79.4/TheLastThrone-0.79.4.rbxlx` 마운트/원본 일치·역할10·도착로딩108검사 PASS([로그](checks.log)). 신규 LFS 자산 없음. 기존 미커밋 모델 변경은 고정 입력에서 제외했다. 엔진25검사는 위 후보 기준이며 실제 게시·기기 수용과 구분한다. origin/main에 소스와 증거를 푸시하고 원격 동일 SHA를 확인한다.
