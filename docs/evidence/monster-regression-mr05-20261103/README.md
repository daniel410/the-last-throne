# MR-05 지역 몬스터 전체 회귀 복구

2026-11-03 · TLT-005/032/033/055/057/084 / MR-05 · ENG 자체 검증 완료. 상위 티켓·MR-01~04/06 수용은 유지한다.

## 실패 원인과 수정

0.62.7의 모션 전용 검사는 통과했으나 전체 Frozen Vale 검사는 `destination`의 `inventory.expedition` 호출에서 중단됐다. 두 지역의 저장 모의 객체에 개인 영웅 원정 조회 계약을 추가했다. 재실행에서 발견한 후속 실패도 순서대로 수정했다.

| 실패 | 원인 | 수정·재검증 |
| --- | --- | --- |
| 원정 목적지 조회에서 nil 호출 | 테스트 모의 객체가 새 조회 함수를 제공하지 않음 | 개인 영웅 조회·활성 원정 목적지·원정 없는 저장 지점 복귀 검사 |
| `FV-01:snow_guards` 미완료 | 전투 키에 붙는 `:legacy`를 누락해 실제 적을 찾지 못함 | 두 지역의 실제 적 검색 키를 현재 서버 계약으로 수정. 유한 웨이브·보스·중복 처치 콜백 검사 실행 |
| 안전 야영지 Selene 선택 거부 | 테스트에 활성 지원 이용권 조회/활성화 의존성이 없음 | 이미 활성 이용권을 소유한 조건을 명시한 모의 객체 추가. 실제 구매·이용권 저장 수용과 구분 |

첫 두 재실행의 실패 로그를 [전투 키 실패](failure-missing-run-key.log), [이용권 모의 실패](failure-support-pass-mock.log)에 보존했다. 최초 nil 호출 실패는 [0.62.7 이력](../regional-monster-review-20261103/regression-first.log)에 있다. 게임 구현을 느슨하게 만들거나 실패 검사를 제거하지 않았다. 변경은 두 테스트와 조립 도구에 한정한다.

## 검증 조건과 결과

기존 **0.62.7 Battle** 산출물을 그대로 사용했다. 런타임 소스 `bcc5e0492c0f866245a4dc8641cd9813f0654f49`, Battle SHA256 `810bceb3d7e952886eaaa70377ffa3982406505cd20ea6487fdeaf2d321097ad`가 [기존 빌드 기록](../regional-monster-review-20261103/build.json)과 일치한다. 새 게임 빌드·버전 재사용에 의한 산출물 교체·게시·릴리스 태그는 없다. 현재 로비/원정 미커밋 작업을 빌드에 포함하지 않았다.

실제 Roblox Studio 엔진, PlaceId=0, 실제 Player 0명의 격리 로컬 조건이다. 실제 서버 스토리 모듈을 복제해 `publish`만 테이블 플레이어용으로 대체하고, 실제 InventoryRules로 메모리 프로필을 갱신한다. DataStore 쓰기·유저 계정 지급·상품 구매는 수행하지 않는다. 스토리 API·지형·몬스터 생성/관절은 엔진에서 실행하며 정상 플레이어 입력 완주로 보고하지 않는다.

```bash
python3 tools/assemble-regional-motion-suite.py --scope full --output /tmp/tlt-mr05-full.luau
run-in-roblox --place builds/0.62.7/TheLastThrone-Battle-0.62.7.rbxlx --script /tmp/tlt-mr05-full.luau
python3 tools/assemble-regional-motion-suite.py --scope motion --output /tmp/tlt-mr05-motion.luau
run-in-roblox --place builds/0.62.7/TheLastThrone-Battle-0.62.7.rbxlx --script /tmp/tlt-mr05-motion.luau
```

| 실행 | 결과 | 범위 |
| --- | --- | --- |
| full | **27,345 PASS** | Frozen Vale4,200·Ember Caldera4,402·지역 개별15,910·Deepwood2,813·스트리밍10·부트스트랩10 |
| motion | **26,640 PASS** | 기존 모션 범위 유지. Frozen Vale3,930·Ember Caldera3,967·나머지 동일 |
| 조립 범위 검사 | PASS | motion에서 저장 부분 제외·`motion-only` 표시, full에서 두 지역 저장 부분과 승강기 실패 검사 포함 |
| `git diff --check` | PASS | 변경 파일 공백 검사 |

full은 각 지역 본편7장·선택4퀘스트의 실제 서버 스토리 API 진행, 원본 고정 Gold 예산(FV 종료5,650 / EC 종료10,290), 유한 몬스터 웨이브·빙설 수호자 비살상·Inferno 단계·중복 처치 보상·다음 지역 목적지를 검사한다. 두 지역 첫 이벤트에 `SaveUnknown`→`Busy`→성공을 주입해 같은 개인 이벤트/선택/스텝/원정ID를 재시도하고, 응답 미확정 동안 플래그·프로필 revision·스토리 Gold가 바뀌지 않는지 검사한다. 화산 승강기에 추가 `SaveUnknown`을 주입해 이동 보류→확정 후 안전 지점 이동을 검사한다. 외부 저장 장애를 재현한 것이 아니라 저장 API 응답 경계의 모의 시험이다.

[기계 판독 결과·소스/하네스 해시](results.json) · [full 원시 로그](full-native.log) · [motion 원시 로그](motion-native.log). 로그의 기존 `rbxassetid://203785492` 자산 유형 경고는 남아 있으며 이번 검사의 실패는 없었다. `run-in-roblox` 두 실행은 종료코드0으로 끝났고 해당 임시 Studio 프로세스 종료를 확인했다. 기존 TD Studio 세션은 보존했다.

## 미검증과 다음 담당

MR-05의 로컬 테스트 복구 범위는 완료다. 독립 QA의 재현·실제 DataStore 저장/재접속/동시 서버·게시 테스트 클라이언트·모바일/게임패드·4인+AI1·사용자 미술 수용은 미검증이다. 모션 전용 결과를 전체 스토리 수용으로 대신하지 않으며, full 결과도 실제 저장/기기 수용으로 확대하지 않는다.

다음 ART 작업은 MR-01 주술사3종 독립 팔/지팡이 리깅과 MR-02 임프 날개 분리다. QA는 MR-06의 실제 클라이언트 기준선을 남기고 변경 메시 연결 뒤 재검증한다. MR-04 추가4종 업로드 승인 상태는 별도 그대로다.
