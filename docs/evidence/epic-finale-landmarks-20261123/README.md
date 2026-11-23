# 다섯 에픽 7장 결말 지물의 조형 검증

2026-11-23 Toronto · TLT-061/DW-07 · TLT-065/GW-07 · TLT-062/FV-07 · TLT-063/EC-07 · TLT-064/HG-07 · G5 진행 중

[환경 아트 제작표와 공식 사례](../../research/2026-11-23-epic-finale-landmarks.md) · [런타임 모델 소스](../../../src/server/World/EpicFinaleScenery.luau) · [고정 빌드](build.json) · [Studio 조형 측정](studio-models.json)

| 결말 구간 | 구현 | 부품 |
| --- | --- | ---: |
| Deepwood | 적재장 바퀴홈에서 고임목까지 석재 접합면을 잇고 귀환 쪽 적재석 끝을 경사지게 다듬었다. | 16 → 21 |
| Gloamwood | 낮은 셰일층의 단면을 출구를 등지는 사선에서도 볼 수 있게 바람그늘 쪽에 드러냈다. | 9 → 10 |
| Frozen Vale | 썰매 정지판과 압설 사이에 양쪽 고임목 단면을 더했다. | 13 → 15 |
| Ember Caldera | 빈 선적대 앞뒤에 롤러 방향을 따라 철제 측판을 배치했다. | 27 → 31 |
| Haunted Graveyard | 왕릉 귀환 보호턱의 끝돌을 깎고 철제 버팀 아래 석재 받침을 드러냈다. | 13 → 16 |

## 확인한 범위

- 기준 0.115.55와 후보 0.115.56 Place의 SHA-256을 확인하고, 두 파일에 포함된 7장 모듈을 각각의 고정 커밋과 바이트 단위로 대조했다.
- Roblox Studio Edit의 격리 모델에서 두 모듈을 기존 Kit 형상 생성기 및 팔레트와 함께 실행했다. 다섯 지물의 조형 외곽 중심, 크기 및 배치 반경 차이는 모두 0이다. 조사 목표 ID와 로컬 피벗이 일치했다. 93부품 모두 고정·비충돌·비터치·비쿼리이며, Ember Caldera의 롤러 6개와 축경 12개를 확인했다. 모델은 Workspace에 추가하지 않았다.
- 후속 실행에서도 모델 구문 검사와 Lua 회귀 4종을 통과했다. 에픽 지도 105,907건, 도보 내비게이션 8,791건, 스토리 소품 문맥 4,264건, 전투 경로 77,381건이다.

## 재현과 수용

격리 Studio 측정을 재현하려면 빌드 기록의 기준과 후보에서 7장 모듈을 읽고 각 모듈 본문을 즉시 호출하는 함수로 감싸 `prior`와 `candidate`에 바인딩한다. `local Kit = {}`와 [EpicEnvironmentKit](../../../src/server/World/EpicEnvironmentKit.luau)의 `local C=Color3.fromRGB`부터 `Kit.beam` 끝까지의 코드를 이어 붙인다. 마지막으로 [측정 코드](check-models.luau)를 붙여 Studio Edit에서 실행한다.

후속 실행에서 기준 Place를 열자 새 Studio 창이 로그인 화면에서 대기했다. 후보 Place의 `run-in-roblox` 실행도 Studio 연결 시간 초과로 종료됐다. 고정 Place 두 파일의 SHA-256을 확인하고 각 소스에 맞는 감사 스크립트를 생성했다. 인자를 뒤바꾼 경우에는 스크립트 생성 전에 거부한다. 다른 빌드에 같은 버전 번호가 붙을 수 있으므로 [빌드 기록](build.json)의 해시로 비교 대상을 확인한다.

Studio에 로그인된 환경에서는 [감사 도구](audit.py)로 동일 카메라 18쌍, 전체 맵 배치와 R15 접근·귀환을 검증한다. 기존 13개 시점에 각 모델의 실제 피벗을 기준으로 반사한 [후면 사선](rear-cameras.luau) 다섯 개를 추가했다. 기존 감사에서 사용한 Suri 좌우·중앙 시야와 롤러 및 축경 검사를 이어서 실행한다. `audit_dir`에는 현재 증거 폴더, `out`에는 감사 로그를 저장할 별도 디렉터리를 지정한다. 비교 결과는 `out`에 기록된다.

```sh
python3 "$audit_dir/audit.py" "$out" prepare "$baseline_place" "$candidate_place"
run-in-roblox --place "$baseline_place" --script "$out/baseline.luau" > "$out/baseline.log" 2>&1
run-in-roblox --place "$candidate_place" --script "$out/candidate.luau" > "$out/candidate.log" 2>&1
python3 "$audit_dir/audit.py" "$out" compare
```

환경 아트와 QA는 Gloamwood 야간의 첫 발견 및 귀환 셰일 단면, Frozen Vale 표지 옆 고임목, Suri 양옆의 선적대, Haunted Graveyard 귀환 보호턱을 확인한다. 전체 맵 감사와 R15 왕복, 실제 입력, 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 전투 카메라 및 사용자 미술 수용은 미검증이다.

## 후면 감사 도구 확인

- 두 고정 Place 해시로 스크립트 생성을 확인했다. 합성 프레임으로 기존 13시점과 신규 18시점이 각각 처리되고 후면 프레임이 누락되면 비교가 실패함을 확인했다.
- Studio Edit에서는 기존 배치 기록의 피벗을 입력해 카메라 계산만 실행했다. 후면의 로컬 +Z는 DW 18.62스터드, GW·FV·EC·HG 각각 25.00스터드였다. 반사 좌표는 지물 단면을 보는 진단 시점이며 실제 보행 위치는 별도 확인한다.
- 이번에도 고정 Place 재오픈이 로그인 단계에서 대기했고 Mac 잠금 상태로 UI를 조작할 수 없었다. 두 고정 Place의 프레임 캡처와 R15 왕복은 미실행이다. 환경 아트·QA의 화면별 판정 기준은 [제작표](../../research/2026-11-23-epic-finale-landmarks.md#접근귀환-화면-수용-기준)에 기록했다.

## 조형 비교판

기준과 후보의 SHA-256을 다시 대조했다. 고정 커밋의 모듈과 공통 Kit로 Studio Edit에서 다섯 모델을 메모리에 생성하고, 실제 `BasePart`의 로컬 변환·크기·색·형상과 재질명을 [JSON](model-geometry.json)으로 추출했다. Studio의 격리 레이캐스트로 쐐기 형상 높이가 로컬 +Z 방향으로 증가하는 것을 확인했다. Blender Standard/sRGB에서 부품 색을 scene-linear로 변환해 접근·귀환 방향을 각각 고정하고 10쌍을 렌더했다. 조명과 재질은 비교판용이며 실제 지형·NPC·날씨·Roblox 재질 텍스처는 포함하지 않았다.

[기준과 후보 조형 비교판](model-comparison.jpg)

| 구간 | 모델에서 확인한 점 | 실제 맵에서 확인할 점 |
| --- | --- | --- |
| DW-07 | 바퀴홈 끝에서 고임목 받침으로 이어지는 밝은 경사석과 귀환 쪽 상판 단부가 보인다. | 접근 중 바퀴홈과 적재석이 한 방향으로 읽히는지 확인한다. |
| GW-07 | 뒤 사선에서 낮은 셰일 단면이 드러난다. 정면의 큰 평행 암층은 계단처럼 보일 수 있다. | 야간 첫 굽이에서 편측 눈과 암층의 경계가 분리되는지 확인한다. |
| FV-07 | 새 목재 단면이 고임목 윤곽에 주는 변화가 작다. | 표지와 고임목이 겹치기 전 양쪽 러너와 정지점을 구별할 수 있는지 확인한다. |
| EC-07 | 롤러 열의 양쪽에 가이드 끝이 보이고 중앙 빈 공간이 유지된다. | Suri 양옆에서 측판, 롤러 두 줄, 빈 중앙이 하나의 선적대로 읽히는지 확인한다. |
| HG-07 | 철 버팀 아래 받침은 접근 측, 끝돌 깎임은 귀환 측에서 드러난다. | 귀환 중 첫 회전에서는 끝돌, 목표 쪽 사선에서는 철제 받침을 본다. |

이 판독은 비교판의 거리와 조명에 한정한다. 맵 미술과 QA의 다음 확인 지점은 FV 표지 옆 실제 보행, GW 야간 첫 발견, EC의 Suri 좌우다. 고정 Place 전체 감사와 R15 왕복은 여전히 미검증이며 후보 병합과 사용자 미술 수용은 대기 중이다.

JSON을 다시 추출하려면 위 격리 측정 스크립트의 앞부분에 `local exportGeometry = true`를 추가한 뒤 반환값을 JSON으로 저장한다. 비교 프레임은 `blender -b --python render-models.py -- model-geometry.json /tmp/tlt-finale-frames`로 생성한다.

후속 0.115.59 후보의 실제 배치, 고정 카메라 18쌍, R15 왕복 23구간 증거는 [7장 북부 고갯길과 썰매 정지 지점](../epic-finale-shale-sled-20261123/README.md)에 있다.
