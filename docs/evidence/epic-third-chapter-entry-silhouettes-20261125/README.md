# 에픽 3장 사건 입구 구조 · 0.115.117

2026-11-25 Toronto · TLT-061~065 · G5 진행 중

다섯 3장 사건의 공통 아치를 목제 관측틀, 등갓을 단 비대칭 뿌리, 압설 지붕의 방풍문, 현무암 위 철골 갱구, 석회암 측문으로 교체했다. 새 조립체는 72부품으로 기존보다 17개 늘었다. 주요 지지부와 상부 구조는 영구 충돌을 적용한다. Z축 입구 3곳은 새 구조를 피벗에서 진입 방향으로 3.9스터드 옮겨 기존 표지판 공간을 확보했다. [제작표와 RPG 사례](../../research/2026-11-25-epic-third-chapter-entry-silhouettes.md)

## 검증

- 기준 0.115.116의 소스는 `e209c82d`, 후보 0.115.117의 소스는 `4a6a9f5a`다. 두 Place의 SHA-256과 후보 조형 모듈 및 통합 모듈의 탑재 바이트를 확인했다. 지도·전투·사건 정적 187,336건, 패키지 336건, 인접 3장 구조길 바닥 405표본을 통과했다. [고정 빌드](build.json) · [정적 검사](static-results.txt)

- Studio 영구 지형 충돌 감사 25,320건과 전체 Luau 소스 컴파일을 통과했다. 82개 사건 입구의 중앙 통과를 4×5×4스터드 몸체로 검사했다. [충돌 감사](scenery-results.json)

- 동일 접근·귀환 카메라에서 다섯 입구를 각각 두 방향으로 비교했다. Frozen Vale과 Ember Caldera는 이전 화면 밖으로 잘리던 지지부까지 들어오며, Haunted Graveyard의 밝은 문설주가 안개 속에서 읽힌다. Gloamwood의 등갓은 양쪽에서 보이지만 밤의 뿌리 상부 대비는 낮다. Deepwood의 기존 표지판이 고정 화면에서 새 목재 기둥 가까이에 투영된다. [전후 비교](comparison.jpg)
- 두 빌드의 77개 다른 입구와 대상 다섯 곳의 피벗, 표지판, 길 표식, 목표·단계 좌표가 일치했다. 두 빌드에서 각각 입구 바닥·몸체 325표본이 통과했고 최대 바닥 오차는 0.08스터드였다. 양쪽에서 점프를 끈 R15가 다섯 곳을 32스터드씩 왕복했다. 도착 오차는 기준 최대 1.68, 후보 최대 2.49스터드였으며 수용 기준은 2.5스터드다. [Studio 측정](studio-results.json)
- 캠페인 회귀는 두 빌드에서 각각 9,310건을 통과했다. 사건 82개, 단계 246개와 바닥·보행 3,981표본에서 차단은 0건이었다. 로컬 Studio 실행기가 후보 첫 두 세션에서 시작 시간 초과를 냈다. 이번 감사에서 생성한 세션만 정리하고 재실행해 화면, 보행, 회귀 검증을 마쳤다.

후보는 미게시다. 실제 입력의 최초 발견·조사, 게시 클라이언트, 터치 실기기, 파티 스트리밍, 전투 카메라, 사용자 미술 수용은 미검증이다. 다음 환경 아트·QA는 실제 전진·복귀 중 Deepwood 표지판과 Gloamwood 입구·조사 등불의 우선순위를 확인한다.

## 재현

저장소 루트에서 두 빌드 기록의 고정 Place를 준비한다. [기준 빌드](../hero-guard-chain-20261125/build.json) · [후보 빌드](build.json)

```sh
evidence=docs/evidence/epic-third-chapter-entry-silhouettes-20261125
work=$(mktemp -d)
python3 "$evidence/prepare-studio.py" "$work/audit.luau"
for tag in before after; do
    case "$tag" in
        before) version=0.115.116; source=e209c82d ;;
        after) version=0.115.117; source=4a6a9f5a ;;
    esac
    mkdir "$work/$tag-source"
    git archive "$source" src tests tools | tar -x -C "$work/$tag-source"
    (cd "$work/$tag-source" && python3 tools/prepare-campaign-expansion-native.py)
    cp /tmp/tlt-campaign-expansion-native.luau "$work/$tag-regression.luau"
    place="$PWD/builds/$version/TheLastThrone-$version.rbxlx"
    run-in-roblox --place "$place" --script "$work/audit.luau" > "$work/$tag-audit.log" 2>&1
    run-in-roblox --place "$place" --script "$work/$tag-regression.luau" > "$work/$tag-regression.log" 2>&1
done
python3 "$evidence/compare.py" "$work" 0.115.116 0.115.117
```

충돌 감사는 후보 소스에서 `python3 tools/prepare-scenery-collision-native.py`를 실행하고, 후보 Place에 `/tmp/tlt-scenery-collision-native.luau`를 같은 방식으로 적용한다.
