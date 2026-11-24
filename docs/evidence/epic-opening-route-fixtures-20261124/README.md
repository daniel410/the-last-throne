# 다섯 에픽 1장 두 번째 사건의 지형·지물 검증

2026-11-24 Toronto · TLT-061/DW-01 · TLT-065/GW-01 · TLT-062/FV-01 · TLT-063/EC-01 · TLT-064/HG-01 · G5 진행 중

[공식 RPG 사례와 제작표](../../research/2026-11-24-epic-opening-route-fixtures.md) · [기준 0.115.91](../hero-ground-beats-20261124/build.json) · [후보 0.115.92](build.json) · [Studio 비교판](comparison.jpg) · [측정 결과](studio-results.json)

| 에픽 | 현장 조형 | 보행선 최소 이격 |
| --- | --- | --- |
| Deepwood | 얕은 건널목 접근의 젖은 퇴적, 강돌, 닳은 목말뚝 | 6.44스터드 |
| Gloamwood | 낮은 정찰길의 낙엽층과 노출 셰일 턱, 뿌리 | 6.83스터드 |
| Frozen Vale | 피난로의 얼음 기초, 횡목 방풍판, 바람 그늘의 압설 | 8.51스터드 |
| Ember Caldera | 승강기 작업로의 현무암 기초, 고정 레일, 볼트 | 7.73스터드 |
| Haunted Graveyard | 대기 터의 석조 기단, 빗물턱, 보수한 철물과 목제 난간 | 7.96스터드 |

## 검증

- 기존 사건 단계 앵커에서 좌우 10~12스터드에 조립체를 배치했다. 다섯 조립체의 부품 40개가 고정·비충돌·비터치·비쿼리였고, 중앙과 모서리 25점에서 실제 바닥 높이 오차는 0스터드였다.
- 양쪽 Place의 SHA-256을 빌드 기록과 대조했다. Lua 에픽 내비게이션 105,907건, 이야기 소품 4,264건, 전투 동선 77,381건, 사건 검토 4,048건을 통과했다.

- 기준·후보의 고정 카메라 10쌍을 검토했다. Deepwood에서는 목말뚝과 퇴적층이 두 방향에서 구별된다. Gloamwood의 셰일 윤곽은 보이지만 야간 귀환에서 낙엽과 뿌리가 어둡다. Frozen Vale의 방풍판과 Haunted Graveyard의 난간은 귀환 사선에서 드러나며 먼 접근 카메라에서는 기존 절벽 또는 석축에 가려진다. Ember Caldera의 레일은 화산 조명 아래 인접 지면과 대비가 낮다.
- 기존 현장 조립체 40개의 외곽, 피벗과 조사점 측정이 일치했다. 점프를 끈 R15는 두 빌드에서 다섯 구간을 왕복했고, 후보의 최대 수평 도착 오차는 2.34스터드였다.
- Studio 캠페인 회귀는 기준과 후보에서 각각 9,310건을 통과했다. 사건 82개, 단계 246개, 바닥·동선 표본 3,981개에서 차단은 0건이다. 캠페인 전체 부품은 57,185개에서 57,225개로 늘었다.
- 별도 Lua 확장 테스트의 기존 첫 본편 Gold 합산 단언은 기준과 후보에서 같은 줄에서 실패했다. Studio의 기준 확장 회귀는 도구 포트 충돌 후 독립 실행했다.

## 남은 수용

환경 아트와 QA가 실제 입력으로 Frozen Vale 방풍판과 Haunted Graveyard 난간이 처음 드러나는 지점, Gloamwood와 Ember Caldera의 재질 대비를 확인한다. 게시 클라이언트, 터치 실기기, 파티 스트리밍, 전투 카메라 및 사용자 미술 수용은 미검증이다.

## 재현

두 Place를 각 기록의 고정 커밋에서 빌드하고 SHA-256을 확인한다. 각 고정 커밋에서 `python3 tools/prepare-campaign-expansion-native.py`를 실행하고 출력 파일을 작업 폴더의 버전별 확장 회귀 스크립트로 복사한다. 지물 감사에서 지역별 조명을 적용하고 HUD와 프롬프트를 숨긴 상태로 같은 두 카메라를 촬영한다. R15는 점프를 끄고 각 조사 단계의 마지막 16스터드를 왕복한다.

```sh
evidence=docs/evidence/epic-opening-route-fixtures-20261124
work=$(mktemp -d)
cat "$evidence/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    docs/evidence/epic-second-chapter-landmarks-20261120/walk-approaches.luau > "$work/audit.luau"
for version in 0.115.91 0.115.92; do
    place="$PWD/builds/$version/TheLastThrone-$version.rbxlx"
    run-in-roblox --place "$place" --script "$work/audit.luau" > "$work/$version-audit.log" 2>&1
    run-in-roblox --place "$place" --script "$work/$version-expansion.luau" > "$work/$version-expansion.log" 2>&1
done
python3 "$evidence/compare.py" "$work/0.115.91-audit.log" "$work/0.115.92-audit.log" \
    "$work/0.115.91-expansion.log" "$work/0.115.92-expansion.log"
```
