# 전 맵 이동·도로 충돌 점검과 수정 · 0.81.3

2026-11-07 · TLT-050/057/061~065/084 · ENG/DES/QA · 로컬 구현·엔진 검증 / 미게시

사용자 요청: Deepwood 스토리4에서 발견한 것처럼 길 위에서 막히는 부분을 맵마다 찾아 수정한다. 기존 제작 스킬·맵 명세와 [이전 전 맵 점검](../campaign-route-audit-20261103/README.md)을 이어받아 실제 생성본의 물리 몸체·바닥·메인/사이드/귀환 동선과 로비를 검사한다. 재현된 결함 수정이며 별도 게임성 리서치·성장/전투/보상/저장 정책 변경은 수행하지 않는다.

## 범위와 방법

- Deepwood10·Gloamwood7·Frozen Vale10·Ember Caldera10·Haunted Graveyard7, **44지역**, 메인35·사이드12챕터. Dawnspire 로비의 실제 상점/창고/포탈/NPC와 훈련장도 생성한다. 캠페인 거점 창고5개는 실제 서버와 같은 생성 순서/오프셋으로 추가한다.
- 도로 중심/좌우의 폭4·높이5stud 몸체를 `GetPartsInPart`로 검사한다. 경계 상자만 겹치는 원통형 테라스는 실제 물리 겹침과 구분한다. 바닥 Raycast·목표/단계/스폰360개·로비 길 표본100개·시설/NPC/훈련 적12곳의 점프 없는 접근을 검사한다.
- 47챕터232내부 구간·같은 에픽 연결로39개·귀환 접근34개, **총305구간**을 Radius2/Height5/CanJump=false로 검사한다. 에픽 간4연결은 현재 서비스의 별도 입장/이동 대상이며 긴 직선 보행 경로로 검사하지 않는다. 실제 Experience 이동 성공을 뜻하지 않는다.
- 비충돌 큰 장식의 몸 높이 경계 후보도 별도 수집한다. 단순 Part인 오두막 벽/뒷벽의 침범은 회귀 실패로 처리하고, 속이 빈 포탈·수목·병합 절벽 메시의 경계 상자 후보를 실제 충돌/미술 결함으로 자동 확정하지 않는다.

## 수정

| 지역 | 변경 |
| --- | --- |
| Deepwood 전역 | 실제 StoryProps로 대체된 수레·바퀴·감옥 등 숨은 프록시의 충돌/쿼리를 제거한다. 길에 걸린 나무는 원본 외형과 단순 충돌체를 함께 옮기고, 유적/제단 장식도 이동 경로를 비운다. 제단의 보라색 봉인 장식도 함께 이동한다. |
| Deepwood 선택 탐험 포켓 | ReturnLoop를 경사로 모서리 밖으로 확장하고 그 바닥의 Terrain을 정리한다. 새 도로와 겹친 옛 InvestigationPath/WornForestTrack 그림은 숨겨 서로 다른 길 그림이 지형을 가로지르지 않게 한다. 기존 실제 바닥/경사로는 보존한다. |
| Frozen Vale | 대체된 투명 SignalMirror 벽을 비충돌로 생성/정리한다. 길 위 표지판·기념물은 상호작용 위치와 도로를 피해 옮긴다. |
| Ember Caldera | EC-07의 한 장짜리 용광로 벽에 폭40/높이12stud의 실제 통로를 만든다. 측벽/상단은 유지하며 옛 생성본도 중복 없이 변환한다. 통로에 걸린 소품을 옮긴다. |
| Deepwood3·Ember Caldera2 | 귀환 접근을 가로지르던 동쪽 오두막 각2채를 남쪽180stud로 옮긴다. 기존 DW3 서쪽 보정은 유지한다. |
| Gloamwood·Haunted Graveyard | 지면 검출 목록에 LateTrail 바닥을 포함해 길 그림을 실제 연결로 높이에 맞춘다. 대체되어 숨겨진 옛 나무/묘비/기둥/아치의 물리 판정도 정리한다. |
| Dawnspire | 대장간 길 위의 창고를 로비 원점 기준(12,0,24)→(16,0,34)로 옮긴다. 거점 창고의 기존 오프셋은 유지한다. |
| 공통 | 도로의 바닥 검사를2stud 간격으로 촘촘히 하고, 경사로 측면과 몸체가 겹치는 길 그림은 만들지 않는다. 새 `CampaignRouteClearance`가 생성·캐시 재호출 때 대체 프록시를 정리하고, 이동 소품은 목표/스폰·직선 진행 동선과 도로를 피한 같은 지역의 평평한 바닥으로만 옮긴다. Art 캐시6·DeepwoodPlaces 캐시3으로 교체한다. |

## 검증 기록

- 기존0.81.2 고정 파일에 동일 물리 검사: **길 충돌물63개(숨은24개 포함), 바닥 불일치85표본**. [baseline.log](baseline.log) / [baseline.json](baseline.json). 경사 바닥 아래에 그려진 길과 옛 포켓 경사로도 포함하므로63개를 전부 진행 차단 결함이라고 세지 않는다.
- `python3 tools/prepare-map-traversal-native.py`가 [물리 검사](../../../tools/audit-map-traversal.luau)·[기존 전체 경로 검사](../../../tools/audit-campaign-routes.luau)·[신규 캐시/외형 동기화 회귀](../../../tests/campaign-route-clearance-native.luau)를 묶는다. `run-in-roblox --place <격리 rbxlx> --script /tmp/tlt-map-traversal-native.luau`로 실행한다.
- 중간 후보에서 EC-02 오두막 보정을 공통 index2에 적용해 사이드 캠프까지 옮긴 회귀를 발견했다. [candidate-camp-regression.log](candidate-camp-regression.log)의 에픽 연결로2곳/귀환2곳 Lodge 벽 침범으로 검사 실패. 최종 구현은 `EC-02` 안정ID에만 보정하며 사이드 지역은 원래 배치를 유지한다.
- 순수 진행/퀘스트/리스폰/본편 이관: `lua tests/deepwood-progress.spec.lua`, `lua tests/deepwood-quests.spec.lua`, `lua tests/story-respawn.spec.lua`, `lua tests/campaign-reorder.spec.lua` → **570+31+28+1,871=2,500 PASS**.
- 최종 후보/고정 빌드의 수치·실행 종료·해시는 마감 기록에 추가한다. 빌드 입력은 소스와 VERSION을 커밋해 고정한다. `git diff --check`로 작업 범위 문법 외 형식을 검사한다.

## 한계·인계

검증은 격리된 로컬 Studio 엔진의 실제 인스턴스/물리 쿼리·길찾기다. 실제 계정의 사람 조작·네트워크/스트리밍·모바일/패드·4인+AI·FPS와 최종 미술/카메라 관찰은 미실행이다. 길 그림의 조각 수가 늘었으므로 실제 기기 렌더 비용은 후속 성능 수용에 포함한다. 남은 비충돌 메시 경계 후보를 일괄 제거하지 않으며, 게시 클라이언트 수용과 부모 티켓 Done을 대신하지 않는다. 게임 Place 게시·릴리스 태그·라이브 저장/TD 운영 변경 없음. 다음 QA는 고정 파일의 대표 개선 지점과 제보 위치를 실제 기기에서 보행/회피로 확인한다.

## 후보 수용·Studio 소스 반영

최종 후보에서 **도로3,703조각/34,041몸체·바닥 표본, 목표/스폰360개, 로비 길100표본의 충돌/바닥 이상0**. 시설/NPC/훈련 적12곳 접근 성공. 메인/사이드/연결로/귀환305구간은 **300 Success·5 SamePoint·NoPath0**. 실제 재배치 소품26개, 이 중 나무22개는 외형과 충돌체가 함께 이동함을 검사했다. 캐시 재호출5에픽·85대체 프록시 비충돌·스토리/스폰 불변·옛 용광로 벽 복구를 포함한 **511검사 PASS / 프로세스 종료0**. 남은 비충돌 시각 경계 후보32개 고유경로는 포탈·수목·병합 메시이며 이번 검사에서 모두의 시각 통행 수용을 확정하지 않는다.

현재 TLT Studio70829337938054 Edit에서 변경7모듈의 원본이 HEAD와 일치함을 확인한 뒤 문법 검사/동기화하고 신규 `CampaignRouteClearance`1개를 추가했다. 원본7개는 `ServerStorage.TLTBeforeAllMapTraversal20261107`에 보존했다. 기존 편집 월드/다른 Studio/게시/계정 저장은 변경하지 않았다. 버전 MICRO 증가0.81.3.

소스 고정 후 `python3 tools/build-game.py --source HEAD --record docs/evidence/all-map-traversal-20261107/build.json`으로 단일 파일을 생성하고, 같은 고정 파일에서 전체 묶음과 이전 DW4 도로573검사를 실행한다. 해당 실행 결과·산출물 해시는 후속 기록을 따른다.

## 고정 빌드 마감

소스 `f07ea16056bd41ec75461aa28c3dc6ca20057bc4` / **0.81.3** 단일 파일 빌드 성공. [build.json](build.json)의 산출물 SHA256을 다시 계산해 일치를 확인했다. 입력 LFS 포인터0개이며 이번 변경의 이미지/모델 원본 추가·LFS 전송은 없다. 소스 커밋은 `origin/main` 푸시 후 원격 해시로 확인했다.

같은 고정 파일의 전체 묶음 재실행은 **프로세스 종료0 / MAP_TRAVERSAL_PASS true / 캐시·외형·복구511 PASS / 기존 DW4 도로573 PASS**. 도로34,041표본·목표/스폰360개·로비 길100표본의 몸체 충돌/바닥 이상0, 시설 접근12개 성공,305동선(300 Success·5 SamePoint) 통과를 재확인했다. [native-final.log](native-final.log) / [물리 원본](traversal-final.json) / [동선 원본](routes-final.json) / [집계](summary.json). 경사 지면/나무 등 직선 Blockcast 접촉은 별도 원본에 남기며 우회 경로가 있는 의도된 소품까지 모두 제거하지 않는다. 기존 자산203785492 타입 경고1개는 검증 실패와 구분한다.

모든 게임/검사 소스는 위 소스 커밋에 고정되어 있으며 이 마감 기록은 후속 증거 커밋이다. Roblox 미게시·릴리스 태그 없음. 실제 사용자 제보 지점/기기/사람 조작 수용은 여전히 후속이다.
