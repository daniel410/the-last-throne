# 다섯 에픽 두 번째 장의 길목과 시설 검증

2026-11-20 UTC · TLT-061/DW-02 · TLT-065/GW-02 · TLT-062/FV-02 · TLT-063/EC-02 · TLT-064/HG-02 · G5 진행 중

[공식 RPG 사례와 장별 제작표](../../research/2026-11-20-epic-second-chapter-landmarks.md) · [0.114.6 기준 빌드](../epic-opening-readability-20261120/build.json) · [0.114.8 후보 빌드](build.json)

## 재현

0.114.7 소스 `d3132d4e`에서 다섯 지물을 먼저 배치했다. 해당 Place 파일의 SHA-256은 `f478e700bea321d4a055223c89dc4b37c4cbfced3d7cb79707323f162b333765`다. 0.114.8에서 DW-02·EC-02를 각각 반대편으로 옮겨 다음 조사 지점과 이어지는 도보선의 여유를 확보했다. 두 검증용 Place 파일은 각각의 빌드 기록에 고정된 소스에서 생성한다.

```sh
evidence=docs/evidence/epic-second-chapter-landmarks-20261120
cat "$evidence/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    "$evidence/walk-approaches.luau" > /tmp/tlt-second-chapter-final.luau
run-in-roblox --place builds/0.114.6/TheLastThrone-0.114.6.rbxlx --script /tmp/tlt-second-chapter-final.luau > /tmp/tlt-second-chapter-final-before.log 2>&1
run-in-roblox --place builds/0.114.8/TheLastThrone-0.114.8.rbxlx --script /tmp/tlt-second-chapter-final.luau > /tmp/tlt-second-chapter-final-after.log 2>&1
python3 tools/prepare-campaign-expansion-native.py
run-in-roblox --place builds/0.114.8/TheLastThrone-0.114.8.rbxlx --script /tmp/tlt-campaign-expansion-native.luau > /tmp/tlt-second-chapter-regression.log 2>&1
python3 "$evidence/compare.py" /tmp/tlt-second-chapter-final-before.log /tmp/tlt-second-chapter-final-after.log /tmp/tlt-second-chapter-regression.log
```

촬영 중 이름표와 프롬프트를 숨기고 지역 조명을 적용한다. 동선 이격은 직전·다음 단계와 현재 앵커를 이은 평면 선분을 최대 1스터드 간격으로 표본화해 모델의 회전된 외곽 상자까지 측정한다. R15는 점프를 끄고 조사 지점으로 이동한 뒤 시작 위치로 되돌아온다.

## Studio 결과와 인계

- 새 지물 5개·51부품을 확인했다. 중심과 외곽의 접지 표본 25곳에서 바닥 높이 오차는 0스터드였다. 모든 부품은 고정·비충돌·비터치·비쿼리이며 모델은 에픽 캐시에서 재사용된다. 기존 지물 10개의 피벗·크기·앵커·부품 수가 기준과 같았다.
- 모델의 외곽과 도보선 사이의 최단 거리는 DW 6.03, GW 6.07, FV 4.70, EC 6.17, HG 5.66스터드였다. 약 32스터드의 마지막 접근 구간 5곳에서 기준·후보 모두 점프 없는 R15 왕복을 통과했다. [Studio 측정](studio-results.json)
- 고정 카메라 10쌍에서 DW의 돌섶과 실트는 그늘에서 대비가 낮다. GW의 뿌리 윤곽은 보이고 셰일 하단은 어둡다. FV 턱은 설면·기존 등불과 구분된다. EC 현무암 받침과 녹슨 철 부재는 기존 경로 옆에서 드러난다. HG 벽감은 접근 화면에서 기존 표식 옆에 보이며 측면에서는 표식과 일부 겹친다. [Studio 전후 화면](comparison.jpg)
- Studio 캠페인 회귀 9,193건을 통과했다. 사건 82곳, 활동 단계 246개, 바닥·동선 표본 3,968개를 검사해 차단은 0건이었다. [Studio 측정](studio-results.json)
- Lua 회귀 `campaign-context-review` 1,060건, `campaign-mode-progress` 4,493건, `campaign-combat-routes` 77,381건이 통과했다. `campaign-expansion-review`는 기준·후보 각 5회 중 3회에서 3,492건을 통과했다. 양쪽에서 동일한 첫 키 비교 단언이 간헐적으로 실패했다.
- 다음 담당은 환경 아트와 QA다. DW 그늘과 GW·HG 야간에서 이동 중 처음 지물을 알아보는 시점과 기존 조사 프롬프트가 읽히는지 확인한다. 실제 플레이어 입력, 전투 카메라, 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 사용자 미술 수용과 G5는 미검증이다.
