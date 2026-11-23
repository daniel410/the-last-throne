# 다섯 에픽 6장 통합 검증

2026-11-23 Toronto · TLT-061/DW-06 · TLT-065/GW-06 · TLT-062/FV-06 · TLT-063/EC-06 · TLT-064/HG-06 · G5 진행 중

[공식 사례와 제작표](../../research/2026-11-22-epic-sixth-chapter-recovery-surfaces.md) · [직전 0.115.51 비교](../epic-sixth-chapter-recovery-20261122/README.md) · [고정 빌드 기록](build.json)

다섯 에픽의 6장 지물을 본편 0.115.52 이후 소스에 통합했다. 환경 3D는 Gloamwood 끌것의 삼베 손잡이를 러너 위로 띄우고 가로축 결속을 드러냈다. Ember Caldera는 차열벽 앞의 마모 디딤턱과 내화벽돌 모서리를 조형했다. Haunted Graveyard는 난간 양단의 석회석 챔퍼와 철 지주의 고정 칼라를 더했다. Deepwood는 피난로 배수구의 토사와 마모 끝돌, Frozen Vale은 요새 관리로의 압설 경계와 노출된 석축을 통합했다. 기존 Roblox 원생 형상과 배치 Kit를 사용했다.

## Studio 결과

[접근·귀환 비교판](comparison.jpg) · [배치 및 보행 측정](studio-results.json)

| 구간 | 동일 카메라에서 관찰한 변화 |
| --- | --- |
| Deepwood | 귀환 사선에서 뒤쪽 뿌리 아래로 배수구 출구와 마모 끝돌이 드러난다. |
| Gloamwood | 야간 접근에서 들어 올린 견인 손잡이의 빈 공간이 두 러너 사이에 보인다. 귀환 사선에서는 삼베 줄의 대비가 여전히 낮다. |
| Frozen Vale | 압설과 석축의 경계가 귀환 근경에서 갈린다. 접근에서 플랜지가 먼저 보인다. |
| Ember Caldera | 귀환 쪽에서 차열벽 옆 디딤턱이 밝게 분리된다. 접근에서 발판의 변화는 작다. |
| Haunted Graveyard | 접근과 귀환 모두 석회석 단부가 밝게 갈린다. 철 지주의 칼라는 귀환 근경에서 더 잘 보인다. |

- 같은 카메라 10쌍을 비교했다. 두 빌드 모두 점프를 끈 R15 자동 보행으로 조사점까지 32스터드 접근 후 원위치로 돌아오는 다섯 구간을 통과했다. 수평 도착 오차는 후보 최대 1.69스터드, 기준 최대 2.34스터드다.
- 변경 대상 5개는 72→90부품이다. 주변 지물 30개는 측정값이 같았다. 조사 위치·피벗·수평 외곽·비충돌 속성이 유지됐으며, 바닥 25점 최대 높이 오차는 0, 최소 동선 이격은 4.81스터드였다.
- 캠페인 회귀는 두 빌드 각각 9,310건을 통과했다. 사건 82곳, 진행 단계 246개, 바닥 및 동선 표본 3,981개에서 차단 0건이었다. 캠페인 부품 수는 56,623→56,641로 6장 모델의 증분과 일치했다.

## 정적 검사와 남은 수용

Luau 모듈 구문과 Lua 회귀 4종을 통과했다. 에픽 지도 105,907건, 스토리 소품 4,264건, 난이도별 진도 4,269건, 캠페인 전투 동선 77,381건이다.

환경 아트와 QA의 다음 확인 항목은 Gloamwood 야간의 실제 입력 귀환 시 견인 줄, Ember Caldera 최초 접근의 발판 판독이다. 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 전투 카메라와 사용자 미술 수용은 미검증이다.

## 재현

기준 Place는 0.115.52 `b8003486`, 후보 Place는 0.115.53 `26e5d209`다. 두 빌드의 SHA-256과 6장 모듈의 탑재 소스를 각각 빌드 기록과 해당 Git 커밋에 대조했다.

1. 기록의 소스 커밋에서 `python3 tools/build-game.py --source HEAD --record <build.json>`으로 Place를 생성한다.
2. [6장 카메라](../epic-sixth-chapter-landmarks-20261120/camera-setup.luau), [공통 화면 캡처](../epic-approach-readability-20261118/capture-approaches.luau), [6장 보행](../epic-sixth-chapter-landmarks-20261120/walk-approaches.luau)을 순서대로 연결한다. `python3 tools/prepare-campaign-expansion-native.py`로 캠페인 회귀 스크립트를 준비한다.
3. 각각의 Place에서 장면과 캠페인 스크립트를 `run-in-roblox --place <Place> --script <스크립트>`로 순차 실행한다.
4. 두 빌드의 장면 및 캠페인 로그를 [비교 도구](../epic-sixth-chapter-fixtures-20261121/compare.py)에 전달한다. `--baseline-version 0.115.52 --expected-regression 82 246 3981 9310 --verify-footprint` 옵션을 적용하고 `--output-dir`에 이 증거 경로를 지정한다.
