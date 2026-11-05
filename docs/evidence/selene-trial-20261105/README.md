# Selene 첫 스토리 무료 지원 · 0.74.0

2026-11-05 · TLT-016/028/043/057/061/072/084 · ENG → QA · 로컬 구현·미게시.

## 승인과 동작

사용자 요청에 따라 Deepwood DW-03 구조 스토리를 완료한 뒤 한 메인스토리를 무료로 지원한다. 영웅별1회이며, 안전 캠프/현재 전투 컨텍스트/파티AI슬롯을 확인해 자동으로 시작한다. 정상 순서는 DW-03 완료→캠프의 Selene가 DW-04에 무료 동행이다. 기존 완료 저장도 아직 미사용이라면 다음 유효 메인스토리의 캠프에서 체험할 수 있다. 슬롯 점유 시 기회를 보존한다. 최초 체험 이후에는 기존 로비 지원권 구매와 캠프 명시적 초대를 사용하며 자동 유료 갱신은 없다.

무료 사용 표식 `supportPasses.trials[heroId]`와 현재 권리의 `trial`을 선택형 필드로 추가한다. 활성화/사용 여부/팔로우는 기존 AccountStore 단일 계정 트랜잭션으로 저장한다. 기존 저장을 초기화하지 않고 영수증이 순환 삭제돼도 사용 표식은 유지한다. Gold와 구매 credits는 소비하지 않는다. 휴식/사망/같은 원정의 같은 스토리 재접속은 기존 지원을 재개한다. 메인스토리 완료 또는 Return to Lobby 선택으로 종료하며 재지급하지 않는다. 최종 본편 완료 뒤나 해금 전에는 새 체험을 시작하지 않는다.

시작 알림은 무료 한스토리/근접 치유·보호·정화/다음 로비 방문을 설명한다. 상세창은 FREE SUPPORT READY/ACTIVE로 구별하고 완료 카드·종료 알림에서 Dawnspire 로비 Selene의 추가 지원권 구매와 캠프 초대를 안내한다. 종료 알림은 직전 일시중단 알림의4초 제한에 가려지지 않게 한다. 기존 승인 TD 화면/버튼/초상과 지원 능력·AI상한을 사용한다. 신규 미술·상품ID·보상 정본·TD 데이터는 변경하지 않는다.

[최신 결정](../../decisions.md) · [동료 사양](../../companions-and-support.md) · [사례 조사](../../research/2026-11-05-selene-first-support-trial.md).

## 검증

- `lua tests/selene-trial.spec.lua`: 28 PASS. 실제 원정의 DW-01~04 진행·첫 지원 무료/구매권 보존·캠프/해금 차단·같은 스토리 재초대/복사 재접속·종료/유료 후속·불명 저장 복구·기존 저장·잘못된 표식/권리 거절.
- `lua tests/support-passes.spec.lua`: 30 PASS. 기존 유료 검사는 체험 사용 영웅 fixture로 명시한다.
- `lua tests/story-continuation.spec.lua`: 1,017 PASS. 기존 유료 이어가기 fixture도 체험 사용 여부를 명시한다.
- `lua tests/supporter-info.spec.lua`: 45 PASS.
- `lua tests/selene-recruitment.spec.lua`: 23 PASS.
- `lua tests/story-completion.spec.lua`: 356 PASS.
- `lua tests/inventory.spec.lua`: 271 PASS.
- `/private/tmp/td233-luau/luau-compile`: 수정한 런타임6모듈과 새 네이티브 테스트 컴파일 PASS.
- `run-in-roblox --place builds/0.73.3/TheLastThrone-0.73.3.rbxlx --script /tmp/tlt-trial-native/candidate.luau`: 실제6모듈을 메모리에 교체한 후보 검사에서 실제 SeleneCompanion/TD모델/권리·저널을 실행해14검사 PASS([로그](candidate-native.log)). 두 fixture 영웅 중1명만 자동 동행·다른영웅 무료권 보존, 지원 루프·시작/종료 안내·휴식/사망/재개·완료 후 비갱신을 검사했다. 플레이어/계정은 메모리 fixture이고 치유 적용 콜백은 시험용이다. 실제 CombatService 피해/치유 수치를 재검증한 결과는 아니다.

첫 후보 시험은 주입 문자열의 unicode escape, 다음은 미생성 Remotes, 이후 fixture 캐릭터의 Raycast 간섭으로 실패했다. 시험 환경을 바로잡은 뒤 종료 안내가 직전 알림의 제한에 가려지는 실제 분기를 발견해 수정하고 재통과했다. 원래203785492 asset type 경고는 남는다. 고정 소스 `d234227aa163f05753a36fb4640bfb5e730da356`를 origin/main에 푸시하고 원격 SHA 일치를 확인한 뒤 `python3 tools/build-game.py --source HEAD --record docs/evidence/selene-trial-20261105/build.json`으로 단일 Lobby/Battle 빌드에 성공했다. 신규 LFS 자산은 없으며 기존 입력의 LFS 해시 검증도 통과했다. 산출물 `builds/0.74.0/TheLastThrone-0.74.0.rbxlx`의 SHA-256은 `355a25ac2d4bc01d40bfe9a766538bed49912581c294f4d27d0805fd4ddda591`로 실제 바이트를 다시 확인했다. [입력/명령/산출물](build.json).

고정 산출물 자체에서 `run-in-roblox --place builds/0.74.0/TheLastThrone-0.74.0.rbxlx --script tests/selene-trial-native.luau`로14검사를 재통과했다([로그](fixed-native.log)). `python3 tests/single-build.spec.py --artifact builds/0.74.0/TheLastThrone-0.74.0.rbxlx`도 실제 산출물의 역할10·도착 로딩108·공통 마운트/구성 일치 검사 PASS다.

## 미검증·다음 담당

정상 플레이 계정에서 DW-03 완료→자동 동행 전체 조작·실제 DataStore/게시된 클라이언트/모바일·패드/2~4인 동기화/4인+AI성능·경제·10~15세 문구 이해도는 QA 후속이다. 후보 네이티브 검사를 정상 플레이/실기기 수용으로 보고하지 않는다. 기존 미추적 사용자 첨부·모션·증거는 보존하고 포함하지 않는다. 부모 티켓은 In Progress, Roblox 게시·릴리스 태그는 수행하지 않는다.
