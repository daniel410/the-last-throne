# 다섯 에픽 첫 사건의 접근면 검증

2026-11-20 UTC · TLT-061~064 · Gloamwood TLT-065/concept-map · G5 진행 중

[공식 RPG 사례와 장별 제작표](../../research/2026-11-20-epic-opening-readability.md) · [0.114.5 기준 빌드](../epic-opening-landmarks-20261120/build.json) · [후보 빌드](build.json)

## 재현

로컬 Studio에서 같은 월드와 지역 조명으로 각 사건의 접근·측면을 촬영한다. 접근 카메라는 기존 사건 앵커에서 직전 단계 쪽으로 26스터드, 카메라 높이는 바닥에서 7스터드다. 이름표와 프롬프트는 촬영 중 숨긴다.

```sh
evidence=docs/evidence/epic-opening-readability-20261120
cat docs/evidence/epic-opening-landmarks-20261120/camera-setup.luau \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    > /tmp/tlt-open-refine-capture.luau
run-in-roblox --place builds/0.114.5/TheLastThrone-0.114.5.rbxlx --script /tmp/tlt-open-refine-capture.luau > /tmp/tlt-open-refine-before.log 2>&1
run-in-roblox --place builds/0.114.6/TheLastThrone-0.114.6.rbxlx --script /tmp/tlt-open-refine-capture.luau > /tmp/tlt-open-refine-after.log 2>&1
python3 tools/prepare-campaign-expansion-native.py
run-in-roblox --place builds/0.114.6/TheLastThrone-0.114.6.rbxlx --script /tmp/tlt-campaign-expansion-native.luau > /tmp/tlt-open-refine-regression.log 2>&1
python3 "$evidence/compare.py" /tmp/tlt-open-refine-before.log /tmp/tlt-open-refine-after.log /tmp/tlt-open-refine-regression.log
```

## Studio 결과와 인계

- 다섯 모델은 33 → 41부품이다. 조사 앵커와 모델 피벗, 단계 ID를 기준 빌드와 비교했다. 주변 대표 퀘스트 모델 5개는 앵커·피벗·크기·부품 수가 기준과 같았다. 로드된 모델은 에픽 생성 캐시에서 재사용됐고, 장식 부품은 고정·비충돌·비터치·비쿼리였다. 변경 모델 중심과 외곽의 바닥 표본 25곳에서 높이 오차는 0스터드였다. [측정](studio-results.json)
- 동일 카메라 10쌍에서 DW는 약품 상자 뒤에 씻긴 돌과 목재 끝단이 구분되고, GW는 측면 심재와 정면 셰일 면이 더 잘 보인다. FV는 정면에서 암빙과 압설의 경계가 드러나며 일부 눈 표면은 주변 설면과 섞인다. EC의 선로형 마모면은 접근 화면에서 식별되며 측면 변화는 작다. HG는 측면에서 석조 상단이 드러나지만 정면 대비는 여전히 낮다. [Studio 전후 화면](comparison.jpg)
- 고정 소스 대조와 Luau 컴파일을 포함한 Studio 회귀 9,193건을 통과했다. 사건 82곳·활동 단계 246개 및 바닥·동선 표본 3,968개에서 차단은 0건이었다. Lua 회귀 `campaign-context-review` 1,060건, `campaign-expansion-review` 3,492건, `campaign-mode-progress` 4,493건, `campaign-combat-routes` 77,381건을 통과했다.
- 다음 담당은 환경 아트와 QA다. FV 오름길과 GW·HG 야간 분기에서 플레이어 최초 발견과 조사 입력을 확인한다. 실제 R15 입력, 전투 카메라, 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 사용자 미술 수용 및 G5는 미검증이다.
