# 다섯 에픽 3장 구조·정비 지물

2026-11-22 · TLT-061/DW-03 · TLT-065/GW-03 · TLT-062/FV-03 · TLT-063/EC-03 · TLT-064/HG-03 · G5 진행 중

[공식 RPG 사례와 제작표](../../research/2026-11-22-epic-third-chapter-rescue-surfaces.md) · [0.115.44 기준 빌드](../epic-opening-landmark-profiles-20261122/build.json) · [0.115.45 후보 빌드](build.json)

별도 브랜치의 3장 모델을 1장 개선 소스에 통합하고, 구조와 정비 과정이 읽히도록 다섯 지물의 접합부와 재료를 조형했다.

| 에픽 | 실제 배치 |
| --- | --- |
| Deepwood | 구조 명부대에 종이 받침턱을 고정하고, 하부 들보에서 주춧돌까지 버팀을 잇는다. |
| Gloamwood | 피난처 귀환 표식에 양면 목재를 쓰고, 넓은 뿌리 속목면과 깨진 셰일의 상하 경계를 드러냈다. |
| Frozen Vale | 협곡 난간 기둥 받침을 무광 암반에 얹고 옆 압설의 단면을 만들었다. |
| Ember Caldera | 광차선 아래 냉각 점검구에 내화벽과 문턱을 조형하고, 안쪽 벽을 도는 광물 침전 띠를 만들었다. |
| Haunted Graveyard | 관리 통로 문설주의 두 면에 석재 귀돌을 드러내고 귀환 면까지 이어지는 문턱을 조형했다. |

## 화면과 검증

- 같은 카메라 10쌍에서 Gloamwood 뿌리의 노출면이 야간 사선에서 읽히고, Frozen Vale의 무광 암반과 압설 경계가 뚜렷해졌다. Ember Caldera 점검구의 수위 자국은 가까운 접근에서 읽힌다. Haunted Graveyard의 귀환 쪽 귀돌은 밝아졌으며 멀리서는 어두운 지면과 대비가 작다. [Studio 비교판](comparison.jpg)
- 기준 0.115.44와 후보 0.115.45에서 다섯 지물의 부품은 60→90개, 0.115.42의 별도 후보 대비 81→90개다. 다섯 모델 외곽, 지면 기준점과 조사 앵커, 다른 지물 30개가 일치했다. 바닥 25점 오차는 0이고 보행선 최소 이격은 4.90스터드다. 기준·후보 각 다섯 구간에서 R15 자동 왕복을 통과했다. [Studio 측정](studio-results.json)
- Studio 캠페인 회귀는 기준·후보 각각 9,310건을 통과했다. 보행선 3,981표본 모두 차단 0건이었다. 후보의 첫 캠페인 실행은 Studio 세션 간 간섭으로 종료돼 같은 후보로 재실행했다. 재실행 중 외부 자산 한 건에 HTTP 502가 기록됐으며 전체 회귀는 통과했다. [Studio 측정](studio-results.json)
- Lua 에픽 지도 105,907건, 이야기 소품 4,264건, 난이도 진행 4,269건, 전투 경로 77,381건과 3장 모델 구문 검사를 통과했다.
- 기준 첫 실행에서 화면과 지물 측정이 완료된 뒤 Studio 세션 간 간섭으로 왕복이 중단됐다. 같은 기준 Place에서 지물 측정의 일치를 확인한 재실행의 왕복 결과를 결합했다. 기준 재실행의 백색 캡처는 제외했다.

다음 담당은 환경 아트·QA다. 실제 입력으로 GW 야간 피난처 표식의 최초 발견, FV 교량 복구 전후 난간 시야, HG 통로 개방 뒤 귀환 판독을 확인한다. 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 전투 카메라와 사용자 미술 수용은 미검증이다.

## 재현

Rojo 7.7.1로 각 고정 커밋의 Place를 준비한다. 비교 카메라는 지역 조명을 적용하고 HUD와 프롬프트를 숨긴다. 별도의 왕복은 점프를 끈 R15 스크립트 이동이다. 각 고정 소스에서 준비 스크립트를 실행해 해당 빌드의 캠페인 회귀 스크립트를 생성한다.

```sh
evidence=docs/evidence/epic-third-chapter-integrated-20261122
qa=$(mktemp -d)
cat "$evidence/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    docs/evidence/epic-third-chapter-landmarks-20261120/walk-approaches.luau > "$qa/audit.luau"
for entry in 0.115.44:ec4b73fd 0.115.45:ff8a0ddd; do
    version=${entry%:*}
    commit=${entry#*:}
    GIT_LFS_SKIP_SMUDGE=1 git worktree add --detach "$qa/$version" "$commit"
    rojo build "$qa/$version/default.project.json" -o "$qa/$version.rbxlx"
    (cd "$qa/$version" && python3 tools/prepare-campaign-expansion-native.py)
    cp /tmp/tlt-campaign-expansion-native.luau "$qa/$version-expansion.luau"
    run-in-roblox --place "$qa/$version.rbxlx" --script "$qa/audit.luau" > "$qa/$version-audit.log" 2>&1
    run-in-roblox --place "$qa/$version.rbxlx" --script "$qa/$version-expansion.luau" > "$qa/$version-expansion.log" 2>&1
done
python3 "$evidence/compare.py" --baseline-version 0.115.44 \
    "$qa/0.115.44-audit.log" "$qa/0.115.45-audit.log" \
    "$qa/0.115.44-expansion.log" "$qa/0.115.45-expansion.log"
```

기준 Place에서 캡처와 왕복을 별도 실행했다면 비교기에 `--baseline-walk`로 같은 Place의 왕복 로그를 전달한다. 카메라 설정과 지물 측정이 일치할 때만 결합한다.
