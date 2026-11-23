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
- 모델 구문 검사와 Lua 회귀 4종을 통과했다. 에픽 지도 105,907건, 도보 내비게이션 8,791건, 스토리 소품 문맥 4,264건, 전투 경로 77,381건이다.

## 재현과 수용

격리 Studio 측정을 재현하려면 빌드 기록의 기준과 후보에서 7장 모듈을 읽고 각 모듈 본문을 즉시 호출하는 함수로 감싸 `prior`와 `candidate`에 바인딩한다. `local Kit = {}`와 [EpicEnvironmentKit](../../../src/server/World/EpicEnvironmentKit.luau)의 `local C=Color3.fromRGB`부터 `Kit.beam` 끝까지의 코드를 이어 붙인다. 마지막으로 [측정 코드](check-models.luau)를 붙여 Studio Edit에서 실행한다.

새 Studio 창의 로그인 대기로 두 Place를 사용한 전체 맵 감사가 시작되지 않았다. 실제 배치와 동일 카메라 비교, R15 왕복은 [기존 7장 감사 절차](../epic-finale-route-profiles-20261121/README.md)로 재개할 수 있다. 환경 아트와 QA는 이후 Gloamwood 야간의 최초 발견 시점과 Suri 양옆에서 선적대가 연결되어 보이는지 확인한다. 실제 입력, 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 전투 카메라 및 사용자 미술 수용은 미검증이다.
