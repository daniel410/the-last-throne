# 오늘 보고된 런타임 오류 수정

2026-11-11 · TLT-057/084 · ENG · 소스 회귀 통과, 엔진/게시 수용은 아래 실제 결과 참조

## 범위와 원본

Creator Hub Error report에서 Experience 전체의 `Last 1 day`를 선택해 [원본 CSV](experience-errors-last24hours.csv)를 다운로드했다. URL: https://create.roblox.com/dashboard/creations/experiences/10773575153/analytics/errors?annotation=CreatorRegexChange&rangeType=Last1Day&granularity=Daily . 달력 Custom의11월11일은 UTC 날짜 구간이어서 현지11월11일 저녁 테스트를 빠뜨릴 수 있다. 따라서 이번 수정 범위는 현재 테스트를 포함한 최근24시간으로 잡았다. 정확한 현지 자정~현재의 개별 이벤트 목록은 CSV에 없다. First seen은 최초 관측이며 재발 시각이 아니다.

| 그룹 | 건수 | 변경/근거 |
| --- | ---: | --- |
| ColorMap 권한 오류 | 253 | [0.104.6 서버/클라이언트 MapContent 권한 수정과 일반 Script53검사](../battle-equipment-retry-20261111/README.md) 유지 |
| 화살통 몸통 미준비 | 21 | R15 UpperTorso/R6 Torso가 없는 동안 KnightAppearance가 엘프 부착을 시작하지 않도록 수정. ChildAdded로 몸통 생성 후 재개하며 제거/재생성도 처리 |
| 장비 로딩 경고 | 39 | 위 권한 예외가 클라이언트 다운로드 실패처럼 잡히던 경로. 0.104.6에서 수정, 신규 실제 자산 다운로드 검증으로 확인 |
| DeepwoodState 무한 대기 | 1 | 배경음악이 훈련에서도 선택적으로 존재하는 스토리 Remote를 무제한 WaitForChild. 폴더/Remote 복제를 관찰하고 기존 객체는 즉시 연결하며 음악은 계속 재생 |

총314건9그룹. 이전7일 보고서의 안전 스폰·파티 큐·로비 boolean·MemoryStore 오류는 이번24시간 범위에 없다. 당일 수정에 관련 없는 과거 항목까지 변경하지 않았다.

## 변경·검증 범위

변경 파일: `KnightAppearance`, `K0BackgroundMusic`, 각 회귀 시험과 일반 서버 Script 엔진 시험, 현재 상태 링크와 이 증거/빌드 버전. 저장/소유권/피해/TD·사용자 원본 자산은 변경하지 않는다.

- `lua tests/k0-appearance.spec.lua`: 기존 기사 외형 생명주기와 추가 엘프 R6/R15 손 선행·몸통 지연·제거·복구·중복 생성 방지 통과. 오래된 mock의 GetDescendants 누락도 실제 Instance 순회 의미로 보완했다.
- `lua tests/background-music-late-story.spec.lua`:10검사 통과. 훈련에서 스토리 Remote 부재, 기존 Remote, 지연 Remote/폴더, 중복 관찰 격리.
- 위 두 회귀 시험을 수정 전 소스에 실행하면 각각 `elf must wait quietly for torso after hands`, `music cannot wait for optional story remotes`로 실패하고 수정 후 통과한다.
- `lua tests/battle-presentation.spec.lua`:41검사 통과.
- 장비 로더21·캐릭터 로더12·장착 준비13·도착 화면283검사 통과.
- `git diff --check`: 통과.

다음 담당: 빌드/엔진 검증 후 게시 QA. 실제 게시 계정의 배틀/훈련 진입, 엘프 재스폰·무기/화살통, 음악, 이후 Creator Hub 새 오류를 확인한다. 게시 클라이언트·실기기·실제 Teleport·사용자 수용은 별도이며 소스 통과만으로 완료 처리하지 않는다.


## 빌드·일반 서버 Script 결과

**0.104.7 빌드 성공**. [입력 커밋·산출물 SHA-256](build.json), 소스 `85cd9487d8b1433a6b2a5ad1927d546757e6a2c8`, 단일 파일 `builds/0.104.7/TheLastThrone-0.104.7.rbxlx`.

`run-in-roblox --place builds/0.104.7/TheLastThrone-0.104.7.rbxlx --script tests/equipment-permissions-runtime-native.luau`: **일반 서버 Script63검사 통과**. [결과](runtime-native.json), [로그](runtime-native.log).

- 기존 ColorMap 읽기 거부/MapContent 읽기 허용 대조, 기본+4계열 활5종의 무기/화살통 팔레트·다운로드116콜백·최종 실패0개를 확인했다.
- 실제 Roblox R6/R15 리그를 사용해 손 준비 뒤 몸통 지연, 몸통 복귀 시 무기/화살통 생성, 중복 생성 없음, 몸통 제거 시 잘못된 재생성 없음, 복귀 후 회복10검사를 추가했다. 플레이어 계정 없이 재현하기 위해 Players 서비스 경계만 BindableEvent 기반 fixture로 치환한 동일 KnightAppearance 소스를 일반 Script에서 호출했다. 실제 플레이어 세션 수용과 구분한다.
- 엔진의 일부 `No asset content representation found while do_not_fallback_to_baseline is set to true` 경고는 남았으며 최종 실패 콜백은 없었다. 화살통 몸통 미준비/ColorMap 권한 경고는 이 시험에서 발생하지 않았다.
- 배경음악 지연 연결은10검사 단위 회귀로 검증했으며 실제 클라이언트 오디오/볼륨 전환 수용은 미검증이다.

Roblox 게시와 릴리스 태그는 수행하지 않았다. 원본 CSV의 과거 누적 건수는 수정만으로 없어지지 않으며 새 게시 버전 이후의 신규 발생 건수로 재확인해야 한다.
