# 다섯 에픽 5장 이동로와 작업 시설 검증

2026-11-24 Toronto · TLT-061/DW-05 · TLT-065/GW-05 · TLT-062/FV-05 · TLT-063/EC-05 · TLT-064/HG-05 · G5 진행 중

[공식 RPG 사례와 에픽별 제작표](../../research/2026-11-24-epic-fifth-chapter-route-infrastructure.md) · [기준 0.115.99](../hero-weighted-releases-20261124/build.json) · [후보 0.115.100](build.json) · [동일 카메라 비교판](comparison.jpg) · [Studio 측정](studio-results.json)

기존 5장 대표 지물을 검토하고 다섯 개의 별도 사건에서 두 번째 단계의 길가 시설을 조형했다. Roblox 기본 부품, 지역 팔레트, 기존 사건의 배치 도구를 사용했다. 새 구조는 사건 시작 전에도 존재할 수 있는 고정 환경이다.

| 에픽 | 작업 지점과 변경 |
| --- | --- |
| Deepwood | Prison Escape Yard에서 흙턱과 냇돌에 고정한 목재 바퀴 멈춤턱을 배치했다. |
| Gloamwood | Venomcoil Trail Shelf의 분지 가장자리에 무너진 셰일 층과 밝은 파단면을 배치했다. |
| Frozen Vale | Old Supply Tunnel에 압설과 해빙 홈, 사선 버팀재가 있는 난간 받침을 배치했다. |
| Ember Caldera | Ancestral Circuit Gallery에 현무암 바닥, 내화벽돌, 퇴적물이 있는 비상 회수 수로를 배치했다. |
| Haunted Graveyard | Throne Shield Connection의 서쪽 회랑에 석회암 조적과 철제 도관 관통부를 배치했다. |

## 정적 검증

기준과 후보 Place의 SHA-256이 각각의 빌드 기록과 일치했다. Lua 검사에서 지도 105,907건, 전투 동선 77,381건, 사건 검토 4,048건을 통과했다.

## Studio 비교와 회귀

- 5개 조립체에 고정 장식 부품 43개를 추가했다. 충돌·터치·쿼리를 끄고 조립체 단위로 스트리밍하도록 구성했다. 기단의 중심·모서리 25점에서 바닥 오차는 0스터드였고 해당 사건의 전체 연결선과 최소 5.45스터드 떨어졌다. 기존 지물 50개의 조사점, 피벗 위치, 외곽 치수 및 부품 수가 일치했다.
- 기준과 후보 양쪽에서 캠페인 검사 9,310건을 통과했다. 사건 82개와 단계 246개를 전개했으며 바닥·보행 표본 3,981개에서 차단은 0건이었다. 전체 부품 순증 43개는 새 조립체의 부품 수와 일치했다.
- 첫 Frozen Vale 귀환 카메라는 터널 외벽에 가려져 실제 3단계 방향의 통로 안쪽으로 옮겼다. 후보 캠페인 회귀는 첫 Studio 실행 시간 초과 뒤 후보 소스를 고정한 테스트로 별도 재실행했다.

- 양쪽에서 점프를 끈 R15가 다섯 조사 지점 앞 16스터드를 각각 왕복했다. 후보의 최대 수평 도착 오차는 2.32스터드였다.
- 같은 카메라 10쌍에서 Deepwood의 멈춤목과 Frozen Vale의 난간 지주를 기존 조사 표식과 구별할 수 있었다. Ember Caldera 수로는 접근에서 내화턱과 개구, 귀환에서 뒷면 지지부가 드러났다. Gloamwood 셰일의 접근 명암은 낮았으며, Haunted Graveyard 철제 관통부 내부는 귀환 사선에서 더 뚜렷했다.

## 남은 수용

환경 아트와 QA가 실제 입력에서 각 시설의 최초 발견 거리와 상호작용 가시성을 확인한다. Gloamwood의 낮은 접근 대비와 Haunted Graveyard 기존 방어선이 관통부 앞을 가로지르는 순간을 우선 본다. Roblox 게시 클라이언트, 터치 실기기, 파티 스트리밍, 전투 중 카메라, 사용자 미술 수용은 미검증이다.

## 재현

각 빌드 기록의 고정 소스로 Place를 준비하고 파일 해시를 확인한다. 각 고정 소스에서 `python3 tools/prepare-campaign-expansion-native.py`를 실행하고 출력 파일을 아래 작업 폴더에 `0.115.99-expansion.luau`, `0.115.100-expansion.luau`로 각각 복사한다. 두 빌드에서 카메라·R15 검사와 캠페인 회귀를 순차 실행한다. 카메라 컷에는 지역 조명을 적용하고 HUD를 숨긴다. 자동 보행은 점프를 끈 R15를 사용한다.

```sh
evidence=docs/evidence/epic-fifth-chapter-route-infrastructure-20261124
work=$(mktemp -d)
cat "$evidence/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    docs/evidence/epic-second-chapter-landmarks-20261120/walk-approaches.luau > "$work/audit.luau"
for version in 0.115.99 0.115.100; do
    place="$PWD/builds/$version/TheLastThrone-$version.rbxlx"
    run-in-roblox --place "$place" --script "$work/audit.luau" > "$work/$version-audit.log" 2>&1
    run-in-roblox --place "$place" --script "$work/$version-expansion.luau" > "$work/$version-expansion.log" 2>&1
done
python3 "$evidence/compare.py" "$work/0.115.99-audit.log" "$work/0.115.100-audit.log" \
    "$work/0.115.99-expansion.log" "$work/0.115.100-expansion.log"
```
