# TLT-064 · HG-05 추모 중심 후보

2026-11-18 UTC. 맵 구현·환경 아트·환경 모델링 순차 수행. 생산 미채택 / G5 미완료.

## 제작과 근거

| epicId / storyId | 원천 | 사건과 표현 | 배치·상태·목적 |
| --- | --- | --- | --- |
| 5 / HG-05 | CampaignStoryText, CampaignContent, CampaignExpansionContent HG-05 | 실제 서/동 장치 해제와 왕릉 접근. 기존 후보의 중앙 장식 방어 기둥이 실제 목표와 혼동될 가능성 | 중앙 석축의 TwinShieldPylons 장식22파트를 기존 KeeperMemorialCluster 파생9파트로 교체. 중앙(270,206.05,-17530)에 접지한 낮은 추모 조형으로 왕릉 묘역 문법 유지. 진행 전후 정적 장식이며 실제 장치·저장·보상은 수정하지 않음 |

실제 콘텐츠 목표 west=(282.15,188,-17247.4), east=(282.15,188,-17343.4). 이전 후보 중앙 기둥은(270,상면206.05,-17520)으로 옮긴 별도 RegionalConcept 장식이다. 동일 장치가 아님을 소스와 생성 장면에서 확인했다. 혼동 가능성은 미술 가설이며 사용자 관찰 결과가 아니다. 원래 장식 위치로 되돌리는 대신 이번 후보에서는 낮은 추모물로 대체한다. 앞선 안내의 원위치 보존 계획은 이 방식으로 변경했다.

기존 EpicEnvironmentKit/EpicArchitecture 기반 후보를 재사용. 신규 외부 자산/Blender 없음. 93→80 BasePart, 최종 고체33개. 추가 스크립트/상호작용/권위 로직 없음. 동일 카메라 전후 화면에서 보라색 중앙 기둥의 목표 유사 실루엣은 사라졌다. 낮은 장식의 가독성과 세 직각 석축 반복은 여전히 수용 필요하다.

## 재현과 검증

- 입력 소스 6ebe2b29. 별도 작업트리에서 작업. /tmp/tlt-hg05-review.rbxlx를 /tmp/tlt-hg05-device-review.rbxlx로 복사. 기존 0.113.2 QA fixture이며 최신 생산 빌드 검증 아님.
- 자체 Studio 3ddbaf74-33f8-4cd2-8ef3-59c92133a523, PlaceId0. BaseScript 비활성화. 기존 terraces 후보 ModuleScript 설치 → terraces/setup → access/access → asymmetry/reshape → 이번 refocus.luau. 중복 생성된 QA world는 제거하고 _G.HGWorld 하나만 유지한 뒤 측정했다. 사용자 Studio 수정 없음.
- navigation.luau: HG7장105목표4749표본. 차단/바닥/보정/안내/작은단차0. navigation.json.
- points를 worldPoints로 치환:119목표5192표본. HG-06 seal:confirmed의 StoryStandingStone 차단2건. 나머지 실패0. navigation-easy.json. 후보 전체를 DataModel에서 분리해 같은 검사를 반복해 물체/접촉 좌표/차단2건이 동일함을 확인했다(baseline-without-terraces-easy.json). 이 baseline은 후보만 제거한 장면으로 원래 삭제된 소품까지 복원한 생산 기준 장면은 아니다. 전체 Easy 통과로 보고하지 않는다.
- before.jpg/after.jpg: 동일 Edit 카메라(520,370,-17270)→(270,205,-17520), 동일 장면 조명. 실제 플레이 카메라 아님.
- 이번 R15/회피/귀환/상태 복구/실제 장치 조작/게시/실기기/다인/스트리밍/성능/사용자 수용 미검증. 이전 후보 보행 결과를 이번 결과로 재사용하지 않는다. VERSION/빌드/태그/게시 변경 없음.

다음 MAP/ENG/QA: HG-06 차단을 최신 고정 빌드에서 재현해 fixture 결함과 현행 결함을 구분하고, 실제 HG-05 장치 조작과 추모물의 목표 오인 여부를 게임 카메라로 검증한다. 후보를 본편에 통합하기 전에 이 검증과 미술 수용이 필요하다.
