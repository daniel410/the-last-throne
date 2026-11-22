# 다섯 에픽 초반 지형 통합

2026-11-22 · TLT-061 · TLT-065 · TLT-062 · TLT-063 · TLT-064 · G5 진행 중

0.115.46의 영웅 동작 개선 위에 별도 브랜치의 1장과 3장 지물을 통합했다. 아트 담당이 3장 기존 Studio 비교 10쌍을 검토했고, 3D 모델링 담당이 야간 접근·귀환에서 주변 지형과 섞이던 두 지물의 단면을 다시 조형했다. [1장 이전 검증](../epic-opening-landmark-profiles-20261122/README.md) · [3장 이전 검증](../epic-third-chapter-integrated-20261122/README.md) · [공식 RPG 사례와 제작 근거](../../research/2026-11-22-epic-third-chapter-rescue-surfaces.md)

| 에픽 | 1장 첫 사건 | 3장 구조·정비 |
| --- | --- | --- |
| Deepwood | 화물 이동로의 개울 받침 | 구조 명부대의 종이 받침과 하부 버팀 |
| Gloamwood | 수레 자국 갈림길의 노출 뿌리 | 피난처 표식 아래 야간 셰일 파단면과 뿌리 속목 확대 |
| Frozen Vale | 바람막이 오르막의 압설 둔턱 | 교량 뒤 난간의 무광 암반 받침과 압설 경계 |
| Ember Caldera | 화물 운반대 차륜 받침 | 광차선 아래 점검구의 내화벽과 광물 수위 자국 |
| Haunted Graveyard | 정찰 접근로의 석재 주춧돌 | 관리 통로 귀환 문턱과 귀돌의 마모 석회석 단면 확대 |

## 빌드와 검증 조건

기준은 0.115.46의 `c0ee3534`, 후보는 0.115.47의 `4bf0e379`이다. Rojo 7.7.1과 `tools/build-game.py`로 각 커밋에서 Place 파일을 만들었다. 기준 파일 해시는 기존 0.115.46 산출물과 일치했다. [후보 빌드 기록](build.json)

Lua에서 지도 105,907건, 이야기 소품 4,264건, 난이도 진행 4,269건, 전투 경로 77,381건을 통과했다.

## Studio 결과

- 기준과 후보의 같은 카메라에서 20쌍을 비교했다. 0.115.45의 동일 카메라와도 대조해 GW-03 귀환 사선의 셰일 파단면과 HG-03 귀환 문턱이 더 구별됨을 확인했다. GW-03 첫 접근은 명암 차이가 작고 HG-03 뒤쪽 석재는 먼 거리에서 어둡다. [1장 비교판](opening.jpg) · [3장 비교판](third-chapter.jpg)
- 1장 지물은 41→55부품, 3장 지물은 60→90부품이다. 지물 10개의 앵커·피벗·외곽과 다른 지물 25개의 측정값이 일치했다. 바닥 50점에서 높이 오차는 0이었고, 3장 지물의 보행선 최소 이격은 4.90스터드였다. 양쪽 빌드 각각 10구간에서 점프 없이 R15 자동 왕복을 통과했다. [Studio 측정](studio-results.json)
- 양쪽 Place에서 Luau 컴파일과 캠페인 회귀 9,310건을 통과했고 3,981개 동선 표본에서 차단은 0건이었다. 최초 실행에서 Studio 세션 간섭과 기준 스크립트의 소스 불일치가 발생했다. 실행 포트를 분리하고 각 커밋에서 회귀 스크립트를 준비해 순차 재실행했다. [Studio 측정](studio-results.json)

환경 아트와 QA의 다음 검증은 실제 입력으로 GW-03 야간 첫 발견, FV-03 교량 복구 전후 시야, HG-03 통로 개방 뒤 귀환을 확인하는 것이다. 게시 클라이언트·실기기·멀티플레이 스트리밍·전투 카메라·사용자 미술 수용은 미검증이며 G5는 진행 중이다. 0.115.47은 로컬 후보 빌드다.

## 재현

1. 각 고정 소스에서 `python3 tools/build-game.py --source HEAD --record <build.json>`을 실행한다.
2. 1장과 3장의 이전 검증에 있는 `camera-setup.luau`를 각각 공통 `epic-approach-readability-20261118/capture-approaches.luau`, `epic-third-chapter-landmarks-20261120/walk-approaches.luau`와 순서대로 이어 붙인다. 이 회차는 두 장에 같은 R15 보행 스크립트를 사용한다.
3. 해당 소스에서 `tools/prepare-campaign-expansion-native.py`로 캠페인 회귀를 각각 생성한다. 고정 Place마다 카메라·보행 두 스크립트와 해당 캠페인 회귀를 순차 실행한다. 기준 로그 파일 접두어는 `base-`, 후보는 `candidate-`다. 그 뒤에 각 이전 증거 폴더 이름 또는 `campaign`을 붙이고 확장자는 `.log`로 지정한다.
4. `python3 docs/evidence/epic-early-story-integration-20261122/compare.py <로그 폴더>`를 실행한다.
