# 다섯 에픽 6장 지물 검증

2026-11-20 UTC · TLT-061/DW-06 · TLT-065/GW-06 · TLT-062/FV-06 · TLT-063/EC-06 · TLT-064/HG-06 · G5 진행 중

[공식 RPG 사례와 제작표](../../research/2026-11-20-epic-sixth-chapter-landmarks.md) · [0.114.15 기준 빌드](../epic-fifth-chapter-landmarks-20261120/build.json) · [0.114.16 고정 빌드](build.json)

## 재현

각 빌드 기록의 소스 커밋을 사용한다. 아래 명령은 격리된 로컬 Place를 Studio에서 한 번씩 연다. 카메라 증거는 지역별 조명을 합성한 고정 레이캐스트 화면이며 프롬프트와 이름표를 숨긴다.

```sh
evidence=docs/evidence/epic-sixth-chapter-landmarks-20261120
cat "$evidence/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    "$evidence/walk-approaches.luau" > /tmp/tlt-epic-sixth-review.luau
run-in-roblox --place "$baseline_place" --script /tmp/tlt-epic-sixth-review.luau > /tmp/tlt-epic-sixth-before.log 2>&1
run-in-roblox --place "$candidate_place" --script /tmp/tlt-epic-sixth-review.luau > /tmp/tlt-epic-sixth-after.log 2>&1
python3 tools/prepare-campaign-expansion-native.py
run-in-roblox --place "$candidate_place" --script /tmp/tlt-campaign-expansion-native.luau > /tmp/tlt-epic-sixth-regression.log 2>&1
python3 "$evidence/compare.py" /tmp/tlt-epic-sixth-before.log /tmp/tlt-epic-sixth-after.log /tmp/tlt-epic-sixth-regression.log
```

지물 중심과 바운딩 박스 외곽 네 점의 바닥 높이, 모델과 조사 또는 집결 노드의 위치, 조립체와 경로의 이격을 확인한다. DW·FV·EC·HG는 사건의 인접 목표 사이를 표본화한다. GW는 본선 Finn 집결점 양쪽을 표본화한다. R15는 각 접근의 마지막 32스터드를 점프 없이 왕복한다.

## 결과

- 신규 5개·50부품이 모두 Atomic 조립체로 생성됐다. 부품은 고정·비충돌·비터치·비쿼리다. 접지 레이캐스트 25곳의 높이 오차는 0스터드다. 기존 지물 30개의 부품 수, 바운딩 박스, 모델 피벗과 상호작용 앵커를 대조했다.
- 조립체와 보행 표본의 최소 이격은 DW 7.28, GW 7.16, FV 6.69, EC 4.81, HG 8.19스터드다. 첫 후보에서 GW 끌것이 접근 화면 가장자리까지 밀리고 바닥과 목재의 대비가 약했다. 본선 합류점까지의 측면 오프셋을 12→10스터드로 줄이고 노출된 목재를 밝혔다. 고정 카메라에서 Finn과 끌것을 구분할 수 있다. [전후 10쌍](comparison.jpg)
- Lua 서사 1,060건과 전투 경로 77,381건이 통과했다. 확장 리뷰 3,492건은 같은 41행에서 간헐적으로 실패했다. 반복 5회 중 기준 3회, 후보 4회가 통과했다. 별도의 `campaign-expansion.spec.lua`는 기준과 후보에서 모두 첫 에픽 골드 단언에서 실패했다.
- 기준 및 후보 빌드에서 R15 다섯 구간을 모두 왕복했다. 고정 빌드의 Studio 확장 회귀 9,193건이 통과했다. 사건 82곳, 단계 246개, 바닥과 보행 표본 3,968개에서 차단은 0건이었다. [측정 데이터](studio-results.json)

다음 담당은 QA와 환경 아트다. 실제 입력에서 GW의 야간 끌것과 HG의 어두운 난간 상단이 처음 보이는 거리, FV 관리로와 EC 관측소의 조사 목표 판독을 확인한다. 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 전투 카메라와 사용자 미술 수용은 미검증이다.
