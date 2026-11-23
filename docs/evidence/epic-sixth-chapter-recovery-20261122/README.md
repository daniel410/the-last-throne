# 다섯 에픽 6장 구조·귀환 지물 검증

2026-11-22 Toronto · TLT-061/DW-06 · TLT-065/GW-06 · TLT-062/FV-06 · TLT-063/EC-06 · TLT-064/HG-06 · G5 진행 중

[공식 사례와 제작표](../../research/2026-11-22-epic-sixth-chapter-recovery-surfaces.md) · [후보 고정 빌드](build.json) · [동일 카메라 비교판](comparison.jpg) · [Studio 측정](studio-results.json)

## Studio 장면

| 구간 | 같은 카메라에서 확인한 변화 |
| --- | --- |
| Deepwood | 귀환 쪽 뿌리가 짧아져 배수구 입구의 토사와 마모 끝돌이 드러났다. |
| Gloamwood | 야간 접근에서 정찰대 오른쪽의 견인 가로축이 끌것 앞단을 잇는다. 귀환에서는 줄의 대비가 여전히 낮다. |
| Frozen Vale | 압설과 석축의 경계는 귀환 근경에서 구분된다. 관과 플랜지는 두 방향에서 기존 윤곽을 유지한다. |
| Ember Caldera | 귀환에서 차열벽 윗면의 모서리가 드러난다. 최초 접근에서는 발치 변화가 작다. |
| Haunted Graveyard | 귀환에서 밝은 석회석 단부와 어두운 철 받침이 구분된다. 첫 진입에서 세부 판독은 제한적이다. |

- 두 빌드는 각각 동일한 접근·귀환 카메라 10장과 점프를 끈 R15 자동 왕복 다섯 구간을 통과했다. 접근선은 구간별 32스터드였으며 후보의 최대 도착 오차는 2.48스터드로 허용치 2.50스터드 이내다.
- 대상 모델은 72→84부품이다. 주변 지물 30개, 조사 위치, 피벗, 수평 외곽 및 비충돌 속성이 일치했다. 바닥 25점의 높이 오차는 0, 보행선 최소 이격은 4.81스터드였다.
- Studio 캠페인 회귀는 두 빌드 각각 9,310건을 통과했다. 사건 82곳, 진행 단계 246개, 바닥 및 동선 표본 3,981개에서 차단은 0건이었다. 전체 캠페인 부품 수는 56,623→56,635로 모델 변경량과 일치했다.

자동화 중 동시 Studio 플러그인 실행이 확인되어 후보 장면을 다시 촬영했다. 후보 재촬영과 캠페인 회귀에는 각각 전용 포트와 대상 Place 사본의 검증용 StringValue를 사용했다. 빌드 기록의 SHA-256은 원본 후보에 해당한다.

환경 아트와 QA는 실제 조작으로 Gloamwood 야간 최초 발견과 Haunted Graveyard 왕릉 귀환을 확인한다. 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 전투 카메라와 사용자 미술 수용은 미검증이다.

## 정적 검증

- Lua에서 에픽 지도 105,907건, 스토리 소품 4,264건, 난이도별 캠페인 진행 4,269건, 전투 경로 77,381건을 통과했다. 모델 모듈 구문도 검사했다.
- 별도의 `difficulty-level-free.spec.lua`는 두 소스에서 동일하게 구형 진행 데이터의 `Incompatible` 단언으로 중단됐다.

## 재현

기준은 0.115.49의 `78861886`, 후보는 0.115.51의 `b468944b`다. 두 Place에 포함된 6장 지물 모듈과 해당 Git 소스를 대조했다. Rojo 7.7.1에서 저장소의 빌드 도구를 사용한다.

1. 각 소스 커밋에서 `python3 tools/build-game.py --source HEAD --record <build.json>`으로 Place를 만든다.
2. [6장 카메라](../epic-sixth-chapter-landmarks-20261120/camera-setup.luau), [공통 화면 캡처](../epic-approach-readability-20261118/capture-approaches.luau), [6장 R15 보행](../epic-sixth-chapter-landmarks-20261120/walk-approaches.luau)을 순서대로 연결한다.
3. `python3 tools/prepare-campaign-expansion-native.py`로 캠페인 검증 스크립트를 생성한다. 각 Place에 대해 장면과 캠페인 스크립트를 `run-in-roblox --place <Place> --script <스크립트>`로 순차 실행하고 네 로그를 보존한다.
4. 아래 명령으로 비교판과 측정값을 생성한다.

   ```sh
   qa=docs/evidence/epic-sixth-chapter-recovery-20261122
   python3 docs/evidence/epic-sixth-chapter-fixtures-20261121/compare.py \
       "$logs/before.log" "$logs/after.log" "$logs/after-campaign.log" \
       --baseline-regression "$logs/before-campaign.log" --baseline-version 0.115.49 \
       --expected-regression 82 246 3981 9310 --verify-footprint --output-dir "$qa"
   ```
