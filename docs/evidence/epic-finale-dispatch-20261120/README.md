# 에픽 결말 재검토와 대용광로 선적대

2026-11-20 · TLT-061/DW-07 · TLT-065/GW-07 · TLT-062/FV-07 · TLT-063/EC-07 · TLT-064/HG-07 · G5 진행 중

[공식 RPG 사례와 제작표](../../research/2026-11-20-epic-finale-dispatch.md) · [0.114.21 기준 빌드](../hero-skill-impact-20261120/build.json) · [0.114.22 후보 빌드](build.json) · [Studio 전후 비교](comparison.jpg) · [카메라 가림 진단](camera-diagnosis.jpg) · [Studio 측정](studio-results.json)

## 형상과 카메라

- EC-07 선적대의 두 긴 철판을 가로 회전축을 가진 원통 롤러 세 개씩으로 교체했다. 롤러는 현무암 받침에 반쯤 매립하고 앞쪽 경사판과 뒤쪽 정지턱 사이에 배치했다. 철제 롤러의 반복과 두 열 사이의 빈 공간은 Crownheart 운반대가 출하됐다는 장면을 뒷받침한다.
- 기존 목표 측 캡처에서 밝은 삼각형의 원인은 Suri의 메시 내부에 놓인 카메라였다. 해당 카메라의 하단 표본 27개를 모두 Suri가 가렸다. 좌우 4스터드 이격 및 중간·근접 시점에서 각각 27개, 뒤쪽 오프숄더 시점에서 24개가 보였다. 오프숄더의 가림 3개도 Suri였다. 비교판의 목표 측 카메라는 왼쪽 이격점을 사용했다.
- Deepwood 적재로, Gloamwood의 첫눈과 셰일, Frozen Vale 재회 지점의 고임목, Haunted Graveyard 왕릉 보호턱은 기존 형태를 검토했다. 이번 모델 변경 범위는 Ember Caldera였다.

## 검증 결과

- Luau 554개 컴파일과 에픽 단독·전체 생성 및 재사용을 확인했다. 비교 대상 15개 중 기존 지물 14개의 측정값이 일치했다. EC 선적대는 11→15부품, 접지 5개 표본의 높이 오차 0이며 피벗과 조사 위치, 외곽 크기가 일치했다. 새 실린더 6개의 가로축, 걸침, 높이, 시각 장식의 물리 속성을 확인했다.
- 두 빌드에서 각각 Original 38,205개와 Easy 39,504개 동선 표본의 차단이 0이었고, R15 접근·귀환 각 23쌍을 통과했다. 결말 고정 시점 13곳을 촬영했고, 선적대 3곳의 전후 화면을 기록했다.
- Lua 회귀는 에픽 지도 105,907건, 전투 경로 77,381건, 내비게이션 8,791건, 이야기 소품 문맥 4,229건을 통과했다.

- Studio 이야기 소품 검사 11,547건을 통과했다. 제련소 재가동 표시의 적용과 미완료 상태에서의 원래 색 복귀를 확인했다. HG 상태 검사 45건에서 포털 폐쇄, 왕좌 복원, 미완료 영웅으로 전환 시 표시 복귀를 확인했다.

## 재현

각 소스 스냅샷에서 해당 Place와 일치하는 감사 스크립트를 준비한다. 기준 소스에서는 아래 검증 파일을 현재 QA 커밋에서 가져오고, 그대로 부모 증거 폴더 옆에 둔다. 후보에서만 `--candidate`를 붙여 롤러 형태 검사를 실행한다.

```sh
python3 docs/evidence/epic-finale-dispatch-20261120/prepare-studio.py --output "$audit"
run-in-roblox --place "$place" --script "$audit" > "$log" 2>&1
python3 docs/evidence/epic-finale-dispatch-20261120/compare.py "$baseline_log" "$candidate_log"
```

상태 검사는 별도 격리 Place에서 `tests/story-props-native.luau`를 실행한다. 왕좌 복원 검사는 `CampaignWorld.create()`로 맵을 만든 뒤 `tests/late-epics-presentation-native.luau`를 실행한다.

보행은 Studio의 R15 Humanoid 자동 이동이다. 전후 화면은 이름표와 프롬프트를 숨긴 고정 카메라 결과다. 다음 담당은 환경 아트와 QA이며, 재가동 뒤 EC 출하 기록과 Suri 조사, FV 마지막 거울 뒤 Ivo 조사, HG 복원 뒤 귀환을 실제 입력으로 확인한다. 게시 클라이언트·실기기·멀티플레이 스트리밍·전투 카메라·사용자 미술 수용은 미검증이다.
