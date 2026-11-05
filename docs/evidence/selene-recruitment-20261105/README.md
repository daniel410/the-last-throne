# Selene 영입 표시·초대 안내 수정 · 0.73.3

2026-11-05 · TLT-016/057/061/072/084 · ENG → QA · 로컬 수정, 미게시.

사용자가 Deepwood 퀘스트 완료 뒤 Selene가 지원 동료로 따라오지 않는다고 보고했다. 현재 결정표의 2026-11-02 승인은 구조 보고로 무료 영입 해금, 로비에서 지원권 구매, 캠프에서 명시적으로 초대, 메인스토리마다 1 credit 소비다. 퀘스트 완료만으로 자동 동행하거나 다음 스토리 지원권을 자동 갱신하지 않는다. 이번 변경에서도 이 계약을 유지한다. 사용자 계정의 실제 구매/초대 상태는 확인하지 못했으므로 보고된 현상의 원인을 확정하지 않는다.

코드에서 확인한 결함은 재도전 투영이 제공하는 영구 `seleneUnlocked`를 NPCPresentation과 SupporterInfo가 무시하고 현재 원정의 `DW-03:report`만 확인하는 것이다. 이미 영입한 영웅도 DW-03 이전 재도전에서는 초대 버튼이 숨겨지거나 동행 모델보다 구조 보고 모델이 우선 표시될 수 있었다. 두 화면이 서버와 같은 `DeepwoodProgress.seleneUnlocked`를 사용하도록 수정했다. 최초 해금 전환에서는 보유 지원권/구매 필요/캠프 초대를 설명하고, 처음 영입했는데 지원이 종료됐다는 잘못된 알림을 보내지 않는다. 서버의 중복 알림 덮어쓰기도 제거했다.

파일 범위는 NPCPresentation, SupporterInfo/Text, SeleneCompanion, 관련 테스트와 VERSION·작업 기록이다. 보상·지원권 가격/소비·영구 저장 구조·동료 상한은 유지한다. 명확한 결함 수정이므로 제작 스킬의 예외에 따라 별도 비교 리서치는 생략했다. 기존 미추적 애니메이션·사용자 첨부·증거 파일은 포함하지 않는다.

검증:

- `lua tests/supporter-info.spec.lua`: 45 PASS. 재도전 영구 해금과 신규 영입 안내·지원권 없음/보유 상태.
- `lua tests/selene-recruitment.spec.lua`: 23 PASS.
- `lua tests/support-passes.spec.lua`: 30 PASS. 명시적 초대·멱등 차감·저장 불명 복구·스토리 종료 계약.
- `lua tests/story-continuation.spec.lua`: 1,017 PASS.
- `/private/tmp/td233-luau/luau-compile`로 변경한 Luau 4개와 새 네이티브 검사 파일 컴파일 PASS.
- `git diff --check`: PASS.

Studio MCP로 직접 검사하려 했으나 열린 Battle Edit의 Network capability 제한으로 require/시험 모듈 배치가 거부됐다. 이 실패를 실제 화면 검증으로 보고하지 않는다. 별도 Rojo 로컬 fixture에서 `run-in-roblox --place /tmp/tlt-selene-recruitment-qa/fixture.rbxlx --script /tmp/tlt-selene-recruitment-qa/run.luau`로 실제 NPCPresentation을 실행해 7검사 PASS했다. 영구 해금의 초대 버튼, 동행 모델 우선 표시, 지원 종료 후 명시적 재초대, 미해금/거리 차단을 확인했다. 이는 가상 플레이어/단순 모델을 사용하는 엔진 검사이며 정상 플레이 화면 수용과 구분한다. 기존 203785492 asset type 경고는 이번 변경과 별개로 남는다. 수정 전 HEAD의 NPCPresentation으로 동일 검사를 실행하면 `permanent unlock exposes invite before replay report`에서 실패하여 결함 재현도 확인했다([수정 전](before-native.log), [수정 후](native.log)).

고정 소스 `bd68b4358ddbbd5df160c8096a7a970444fd048d`를 origin/main에 푸시하고 원격 SHA 일치를 확인한 뒤 `python3 tools/build-game.py --source HEAD --record docs/evidence/selene-recruitment-20261105/build.json`으로 단일 Lobby/Battle 빌드에 성공했다. 산출물은 `builds/0.73.3/TheLastThrone-0.73.3.rbxlx`, SHA-256 `6119d576d6a980a15b075ae6742b0aaee426cf91872e15c993137345bd51509a`이며 실제 바이트 해시를 재확인했다. 기존 LFS 입력 검증 성공·신규 LFS 자산 없음. [입력/명령/해시](build.json).

고정 산출물 자체에 `run-in-roblox`로 같은 네이티브 검사를 실행해 7검사 PASS했다([고정 빌드 엔진 로그](fixed-native.log)). `python3 tests/single-build.spec.py --artifact builds/0.73.3/TheLastThrone-0.73.3.rbxlx`도 역할10·도착 로딩108·프로젝트 마운트/산출물 일치 검사를 통과했다. 실제 지원 회복/이동이나 플레이 계정의 구매를 이 검사에서 실행한 것은 아니다.

다음 담당은 QA다. 실제 플레이 계정에서 구조 보고 완료→지원권 보유→캠프 초대→지원 동행, 같은 스토리 재접속, 다음 스토리 명시적 재초대를 확인해야 한다. 실제 DataStore·게시 클라이언트·모바일/패드·다인 수용은 미검증이며 부모 티켓은 In Progress다. Roblox 게시·릴리스 태그는 수행하지 않는다.
