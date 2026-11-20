# 다섯 에픽 세 번째 장의 지물 검증

2026-11-20 UTC · TLT-061/DW-03 · TLT-065/GW-03 · TLT-062/FV-03 · TLT-063/EC-03 · TLT-064/HG-03 · G5 진행 중

[공식 RPG 사례와 장별 제작표](../../research/2026-11-20-epic-third-chapter-landmarks.md) · [0.114.9 기준 빌드](../melee-impact-20261120/build.json) · [0.114.11 후보 빌드](build.json)

## 재현

0.114.10 소스 `24da21e4`에서 모델 다섯 개를 추가했다. 해당 Place SHA-256은 `788b5a9837fac9041863e0938f45cf4f40be2e353d0391bd63e5a4e9a6418d54`다. 0.114.11은 DW 기록대의 여유 폭을 늘리고 FV 난간 받침과 EC 점검구를 교량 및 다음 조사선에서 떨어진 편으로 옮겼다.

```sh
evidence=docs/evidence/epic-third-chapter-landmarks-20261120
cat "$evidence/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    "$evidence/walk-approaches.luau" > /tmp/tlt-epic-third-review.luau
run-in-roblox --place builds/0.114.9/TheLastThrone-0.114.9.rbxlx --script /tmp/tlt-epic-third-review.luau > /tmp/tlt-epic-third-before.log 2>&1
run-in-roblox --place builds/0.114.11/TheLastThrone-0.114.11.rbxlx --script /tmp/tlt-epic-third-review.luau > /tmp/tlt-epic-third-after.log 2>&1
python3 tools/prepare-campaign-expansion-native.py
run-in-roblox --place builds/0.114.11/TheLastThrone-0.114.11.rbxlx --script /tmp/tlt-campaign-expansion-native.luau > /tmp/tlt-epic-third-regression.log 2>&1
python3 "$evidence/compare.py" /tmp/tlt-epic-third-before.log /tmp/tlt-epic-third-after.log /tmp/tlt-epic-third-regression.log
```

촬영 중 두 빌드에 동일한 지역 조명과 카메라를 적용하고 이름표와 프롬프트를 숨긴다. 동선 이격은 현재 조사점과 앞뒤 단계를 연결한 선분을 약 1스터드 간격으로 표본화해 모델의 회전된 외곽 상자까지 측정한다. R15는 점프를 끄고 접근 시작점에서 조사 지점까지 이동한 다음 돌아온다.

## 결과와 인계

- 지물 5개와 부품 60개가 생성됐다. 새 모델 중심과 외곽의 바닥 표본 25곳에서 높이 오차는 0스터드였다. 부품은 고정·비충돌·비터치·비쿼리이며 에픽 캐시가 같은 모델을 재사용한다. 새 모델의 보행선 이격은 DW 4.90, GW 7.32, FV 9.53, EC 7.44, HG 6.41스터드다. 기존 지물 15개의 피벗, 크기, 부품 수와 조사 앵커는 기준과 일치했다. 기준과 후보 모두 다섯 구간에서 약 32스터드를 점프 없이 R15로 왕복했다. [Studio 측정](studio-results.json)
- 화면에서 DW의 닳은 상판과 주춧돌이 구분되고, EC의 점검구와 내화 벽돌 홈은 선로 옆에 드러난다. GW는 셰일이 보이고 목재 표식은 야간 정면에서 대비가 낮다. HG의 밝은 문턱은 관리 통로를 암시하고, 문설주는 옆에서 더 분명하다. FV의 측면에서는 난간 고정부와 압설·암빙이 보인다. FV의 접근 고정 카메라는 기존 교량 구조에 가려졌다. [동일 카메라 전후 10쌍](comparison.jpg)
- Studio 캠페인 회귀 9,193건을 통과했다. 사건 82곳과 활동 단계 246개를 확인했고, 바닥·동선 표본 3,968개에서 차단은 0건이었다. [Studio 측정](studio-results.json)
- Lua 회귀 `campaign-context-review` 1,060건, `campaign-mode-progress` 4,493건, `campaign-expansion-review` 3,492건, `campaign-combat-routes` 77,381건을 통과했다.
- 다음 담당은 환경 아트와 QA다. 실제 R15 입력으로 FV 교량이 열리기 전과 후의 접근 시야, GW 야간의 귀환 표식 발견, 기존 조사 프롬프트 조작을 확인한다. 전투 카메라, 게시 클라이언트, 실기기, 멀티플레이 스트리밍과 사용자 미술 수용은 미검증이다.
