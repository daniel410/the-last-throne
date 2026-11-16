# Studio 테스트 초기 재화 복구

2026-11-16 · TLT-045/041/084 · 최신 사용자 지시: 테스트 초기 재화를 남긴다. [현재 계약](../../production/gold-rewards-2026-11-16.md#studio-초기-재화)을 따른다.

`StudioTestRules.new`의 신규 시험 지갑 지급을 복구했다. Studio 전용 래퍼를 사용하는 신규 프로필에만 적용하며, 운영 기본 프로필·기존 잔액·재접속 시 잔액은 유지한다. 골드 감액 규칙19와 지급 함수는 변경하지 않았다.

## 검증

- `lua tests/studio-test-defaults.spec.lua`: [통과](tests.log). 신규 Studio 지급,4클래스/Lv10, 기존 지출 후 잔액·재접속 보존, 운영0잔액 분리를 확인했다.
- 감액 소스4개(`GoldRewardTuning`, `Difficulty`, `DeepwoodEncounterBalance`, `InventoryRules`)가 변경 전 커밋과 바이트 단위로 일치함을 확인했다.
- Studio 시험 모듈이 감액 작업 전 `873a8059`의 원본과 바이트 단위로 같음을 확인했다.
- **0.111.14 빌드 성공**: 소스 `5927156399814f197bb1c5e2f04440d373859752`를 커밋·푸시하고 원격 일치를 확인한 뒤 [빌드 기록](build.json)의 단일 파일 `builds/0.111.14/TheLastThrone-0.111.14.rbxlx`를 생성했다. 생성된 파일의 SHA256도 기록과 대조했다.
- **고정 빌드 Studio 엔진 통과**: `run-in-roblox --place builds/0.111.14/TheLastThrone-0.111.14.rbxlx --script /tmp/tlt-studio-test-currency-restore-native.luau`, 종료 코드0. [로그](native.log)의 `STUDIO_TEST_CURRENCY_RESTORE_NATIVE_PASS`를 확인했다. 격리 PlaceId0/플레이어0에서 수정 모듈과 계정 서비스·지급 규칙 등5개 Source 일치를 선행하고 동일 기본값/계정 검사를 실제 모듈로 실행했다. 운영 기본0잔액·기존 재접속 잔액·규칙19 유지도 확인했다. 실운영 DataStore 검증은 아니다.

게시·실제 입력/실기기·실계정 저장 수용은 미검증이며 Roblox 게시/릴리스 태그는 만들지 않는다. 다음 담당은 QA/사용자다. 상위 티켓 완료 처리 없음.
