# 다섯 에픽 4장 복구 설비와 귀환 지물

2026-11-22 UTC · TLT-061/DW-04 · TLT-065/GW-04 · TLT-062/FV-04 · TLT-063/EC-04 · TLT-064/HG-04 · G5 진행 중

환경 아트가 기존 화면과 RPG 사례를 비교하고, 환경 3D가 기존 장식 모델 다섯 개를 다시 조형했다. [공식 출처와 장별 제작표](../../research/2026-11-22-epic-fourth-chapter-working-surfaces.md)

| 에픽 | 맵에 반영한 변경 |
| --- | --- |
| Deepwood | 망루의 케이블을 굵게 하고 철제 받침 신발, 고정판과 고리를 석축에 연결했다. |
| Gloamwood | 뿌리에 들린 셰일 단면을 넓히고 등불 소켓의 밝은 파단면을 몸통에서 분리했다. |
| Frozen Vale | 설원 중계축의 끝면, 석재 받침 어깨와 압설 경계를 구분했다. |
| Ember Caldera | 냉각관 파단 테두리와 내부 그림자를 조형하고 광물 침전 자국을 받침으로 이었다. |
| Haunted Graveyard | 집결로 턱의 마모 석회석 덮개를 여러 단으로 나눠 입구를 낮추고 귀환 쪽 모서리를 깎았다. |

## 검증 결과

- [동일 카메라 10쌍](comparison.jpg)에서 Deepwood 케이블의 하단 철판과 Frozen Vale 축 받침의 변화를 귀환 사선에서 확인했다. Gloamwood의 파손 목재가 뿌리에서 조금 더 분리되지만 야간 원경 대비는 여전히 낮다. Ember Caldera 관의 안쪽은 가까운 귀환 시점에서 더 뚜렷하고, Haunted Graveyard의 낮아진 끝돌과 상부 줄눈은 귀환에서 잘 보인다.
- 다섯 지물은 81→91부품이다. 조사 앵커·피벗·수평 외곽, 주변 지물 30개, 장식의 비충돌 속성이 일치했다. 바닥 표본 25점의 높이 오차는 0, 보행선 최소 이격은 3.67스터드, Haunted Graveyard 집결 인물 최소 이격은 7.76스터드였다. 양쪽 빌드 모두 점프를 끈 R15 자동 접근·귀환 5구간을 통과했다. [Studio 측정](studio-results.json)
- 양쪽 Place에서 Studio 캠페인 회귀가 각각 9,310건을 통과했다. 82개 사건과 246개 단계, 바닥·동선 표본 3,981개에서 차단 0건을 확인했다. [Studio 측정](studio-results.json)
- Lua에서 에픽 지도 105,907건, 스토리 소품 4,264건, 난이도 진행 4,269건, 전투 경로 77,381건을 통과했다. 변경한 모델 모듈은 구문 검사와 Studio 생성에 통과했다.

다음 담당인 환경 아트와 QA는 실제 입력에서 Gloamwood 야간 최초 발견, Ember Caldera 조사 중 냉각관 시야, Haunted Graveyard 집결 뒤 귀환을 확인한다. 게시 클라이언트·실기기·멀티플레이 스트리밍·전투 카메라·사용자 미술 수용은 미검증이다. 0.115.49는 로컬 후보 빌드다.

## 빌드와 재현

기준은 0.115.48의 `4b19de4d`, 후보는 0.115.49의 `78861886`이다. Rojo 7.7.1과 `tools/build-game.py`로 고정 소스마다 Place를 만들었다. 기준의 SHA-256은 기존 0.115.48 Place와 일치했다. [후보 빌드](build.json)

1. 각 고정 소스에서 `python3 tools/build-game.py --source HEAD --record <build.json>`으로 Place를 만든다.
2. [초기 4장 카메라](../epic-fourth-chapter-landmarks-20261120/camera-setup.luau), [공통 화면 캡처](../epic-approach-readability-20261118/capture-approaches.luau), [4장 R15 자동 보행](../epic-fourth-chapter-landmarks-20261120/walk-approaches.luau)을 이 순서로 이어 붙인다.
3. 각 고정 소스에서 `python3 tools/prepare-campaign-expansion-native.py`로 캠페인 스크립트를 생성하고 빌드별로 복사한다. 각 Place에서 `run-in-roblox --place <Place> --script <스크립트>`로 비교와 캠페인 검증을 순차 실행한다.
4. 기존 4장 비교 도구로 비교판과 측정값을 생성한다.

   ```sh
   qa=docs/evidence/epic-fourth-chapter-working-surfaces-20261122
   python3 docs/evidence/epic-fourth-chapter-repair-20261121/compare.py \
       "$logs/before.log" "$logs/after.log" "$logs/baseline-campaign.log" "$logs/candidate-campaign.log" \
       --baseline-version 0.115.48 --expected-regression 82 246 3981 9310 --output-dir "$qa"
   ```
