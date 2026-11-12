# 배틀 장비 다운로드 무한 재시도 차단 수정

2026-11-11 · TLT-057/084 · ENG · 소스 회귀 통과, 게시 클라이언트 수용 대기

사용자 보고: 기존 플레이어가 배틀 도착 화면의 `Equipment could not load. Retrying...`에서 진행하지 못한다.

## 근거와 변경 범위

`CharacterAssetLoading`은 다운로드 실패 후 동일 구성을 무제한 재시도했다. `EquipmentAssetLoading`은 이미 세 번 실패 후 마스크를 해제하지만 도착 화면의 별도 준비 검사는 영원히 실패할 수 있었다. `EquipmentWarmup.prepare` 예외는 기존 보호 범위 밖이어서 준비 작업 자체를 종료시킬 수도 있었다. 사용자 계정에서 실패한 개별 자산/권한/네트워크 원인은 직접 재현하지 못했으며 이 수정으로 해당 자산을 복구했다고 판단하지 않는다.

변경 파일은 클라이언트 로더, 해당 회귀 시험, 현재 상태 링크, VERSION 및 이 증거다. 동일하고 복제가 완성된 착용 구성의 다운로드 실패를 세 번까지 재시도한 후 경고와 `TLTLocalAppearanceDegraded`를 기록하고 도착 준비를 완료한다. 예외도 같은 복구 경로로 처리한다. 실패한 자산 ID/상태 또는 장비 정의/예외를 Output에 남긴다. 새 구성에서는 재시도 횟수를 초기화하고 다운로드 성공 시 저하 상태를 해제한다.

장비 모델/부품 복제, 현재 캐릭터·구성 일치, 기존 장비 마스크 준비, 맵/카메라/서버 입장 검사는 유지한다. 데이터 로드 실패·장비 소유권·저장·재화·TD는 변경하지 않는다. 외형 다운로드 실패 시 일부 외형이 늦거나 누락될 수 있다. 무응답인 PreloadAsync의 별도 시간 제한은 이번 변경에 포함하지 않는다.

이전 [캐릭터 외형 검사](../character-asset-loading-20261111/README.md)의 실패 시 무제한 커버 유지 동작은 이 복구 경로로 대체한다. 플랫폼 참고: [ContentProvider 공식 문서](https://create.roblox.com/docs/reference/engine/classes/ContentProvider), 2026-11-11 확인. 외형 자산 다운로드와 서버 입장 승인을 구분하며 문서도 로딩 화면 자동 종료를 권장한다.

## 검증

- `lua tests/character-asset-loading.spec.lua`: 12검사 통과. 다운로드 지연·캐릭터 교체·변경된 구성의 오래된 완료 격리, 영구 실패 세 번 후 진입 준비, 불완전 복제 차단, 다음 구성 다운로드 성공 복구.
- `lua tests/equipment-warmup.spec.lua`: 13검사 통과. 장착 명령의 다운로드 실패 거부/재시도·성공 캐시 유지.
- `lua tests/equipment-asset-loading.spec.lua`: 21검사 통과. 장비 마스크·실패 세 번 후 해제 유지.
- `lua tests/arrival-loading.spec.lua`: 283검사 통과. 외형/맵/카메라 도착 게이트 유지.
- `git diff --check`: 통과.

**빌드 0.104.5 성공**: 입력 소스 `4cbae32d15e3bb4042262825d021335c94ffe5d6`, [빌드 기록과 SHA-256](build.json). 단일 산출물은 `builds/0.104.5/TheLastThrone-0.104.5.rbxlx`다. Roblox Place 게시와 릴리스 태그는 수행하지 않았다.

Studio 엔진·게시 테스트 Experience 간 실제 Teleport·기존 계정 재접속·캐시 없는 실기기·사용자 수용은 미검증이다. 열려 있는 사용자 Studio 원본과 live DataStore는 변경하지 않았다. 전체 작업 수용 완료로 처리하지 않는다.

다음 담당: QA/사용자. 새 빌드를 두 테스트 Place에 반영한 뒤 동일 기존 영웅의 배틀 진입·이동·공격·재접속을 확인하고, Output의 `Character appearance download attempt`로 실패 자산을 특정한다. 실제 자산/권한 문제는 해당 ID의 별도 복구가 필요하다.

## Creator Hub CSV 원인 조사와 권한 수정

사용자 후속 지시에 따라 Creator Hub → Monitoring → Error report에서 Experience 전체 기본 범위 CSV와 Battle Place `129388473517823`의 최근7일 CSV를 다운로드했다. 후자를 [원본 CSV](battle-errors-last7days.csv)로 보존했다. 수집 URL: https://create.roblox.com/dashboard/creations/experiences/10773575153/analytics/errors?annotation=CreatorRegexChange&filter_Place=129388473517823&rangeType=Last7Days . CSV는 그룹별 건수이며 개별 세션/전체 오류 시각/실패 자산 ID를 포함하지 않는다. First seen은 선택 기간의 발생 시각과 다를 수 있다.

16그룹302건 중 `ColorMap` 읽기 권한 오류238건, 현재 행 번호55의 화살통 몸통 미준비19건, 과거 행 번호28의 같은 경고2건, 장비 로딩 경고15건(String7/NockedArrow7/Weapon1), 나머지28건이다. `ColorMap`과 현재 화살통 미준비, 특정 플레이어 활 부품 경고의 최초 관측은 배틀 V23의11월11일20:23대다. V23은 웹의 Roblox Place 버전이며 저장소 VERSION과 같은 번호가 아니다.

확정된 코드 결함:

1. 서버 `ElfQuiverAppearance.colors`가 `surface.ColorMap`을 직접 읽어 엘프 무기/화살통 부착을 실패시킨다. 이후 부착 재시도로 같은 경고가 반복될 수 있다.
2. 클라이언트 `EquipmentAssetLoading.preload`도 같은 보호 속성과 NormalMap/MetalnessMap/RoughnessMap을 읽는다. 예외가 pcall에 잡혀 장비 로딩 실패처럼 처리되고, `CharacterAssetLoading`에서는 도착 준비가 반복 실패한다. 이는 실제 CDN 다운로드 실패와 다른 로컬 권한 예외다. 원본 CSV에 개별 클라이언트 예외 스택은 없어 특정 사용자 세션과의 일대일 연결까지 확정하지 않는다.

공식 [SurfaceAppearance 스키마](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/SurfaceAppearance.yaml),2026-11-11확인: 기존 Map 속성은 read=PluginSecurity, 대응 MapContent 속성은 read=None/write=PluginSecurity다. 두 경로를 읽기 허용된 `*MapContent.Uri`로 수정하고 빈 Content는 다운로드 입력에서 제외한다. 외형/팔레트/PBR·서버 권위를 유지한다.

단위 회귀 mock은 구 Map 속성을 읽으면 실제와 같은 권한 예외를 발생시키도록 수정했다. 수정 전 소스에서 실패하고 수정 후21검사 통과했다. 이전 Studio 플러그인 권한 fixture는 이 결함을 잡지 못했으므로 별도의 일반 서버 Script 권한 시험을 추가했다. 화살통 몸통 미준비 경고와 나머지 과거 오류는 이 수정으로 해결됐다고 판단하지 않는다.
