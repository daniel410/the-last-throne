# 다섯 에픽 5장 사건 입구의 Studio 비교

2026-11-25 Toronto · TLT-061/DW-05 · TLT-065/GW-05 · TLT-062/FV-05 · TLT-063/EC-05 · TLT-064/HG-05 · G5 진행 중

Deepwood 감옥 구조로에는 차폐벽과 차륜 마모가 남은 돌턱, Gloamwood 사냥 분지에는 셰일 절리와 낮은 후퇴 둑, Frozen Vale 보급로에는 압설이 쌓인 석문과 윈치 고정철을 배치했다. Ember Caldera 회랑은 현무암과 내화벽돌 위 마른 회수 수로, Haunted Graveyard 회랑은 석회암 버팀벽과 방어 도관 고정틀로 입구의 용도를 드러낸다. Deepwood 조형은 표지판 옆 공간을 확보하도록 진입 방향으로 4.65스터드 옮겼다. [공식 사례와 제작표](../../research/2026-11-25-epic-fifth-chapter-entry-silhouettes.md) · [조형 원본](../../../src/server/World/EpicFifthChapterEntrances.luau)

## 검증

- 지도 내비게이션·전투 동선·사건 정적 검사 187,336건과 후보 Place의 역할·로딩 336건을 통과했다. 두 Place의 SHA-256을 빌드 기록과 대조했고 후보 통합 및 입구 모듈의 소스가 Place와 바이트 단위로 일치했다. [정적 검사 및 패키지 확인](static-results.txt)
- 대상 입구는 Roblox 네이티브 55부품에서 74부품으로 바뀌었다. 영구 충돌 부품은 45개에서 37개로 줄었다. 기존 피벗, 표지판, 통과선, 사건과 단계 위치, 비대상 입구 77개의 계측값이 일치했다. [Studio 측정](studio-results.json)
- 각 빌드에서 점프를 끈 R15로 다섯 입구의 32스터드 경로를 왕복했다. 도착 허용 범위에 처음 들어온 표본의 최대 수평 오차는 기준 2.454, 후보 2.496스터드였고 두 빌드 모두 2.5스터드 미만이었다. 빌드마다 바닥과 몸체 325표본에서 바닥 오차와 입구 충돌이 0이었다. 입구 조형을 향한 표지판·이름표 540광선의 가림도 빌드마다 0건이었다. [Studio 측정](studio-results.json)
- 캠페인 회귀는 빌드마다 9,310건을 통과했다. 두 빌드가 사건 82개와 단계 246개를 전개했으며 바닥과 보행 3,981표본에서 차단이 0건이었다. 처음 기준 실행 때 다른 프로젝트가 Studio 실행기 포트를 사용 중이어서 해당 실행이 끝난 뒤 재시도했다. [Studio 측정](studio-results.json)
- 후보에서 전체 Luau를 컴파일하고 영구 충돌 검사 25,268건을 통과했다. 사건 입구 82개에 4×5×4스터드 몸체를 통과시켰다. [충돌 감사](scenery-results.json)
- 고정 시점 11쌍에서 Deepwood의 목제 차폐, Ember Caldera의 열린 수로와 Haunted Graveyard의 돌벽·철제 버팀이 드러났다. Gloamwood의 밝은 절리는 보이지만 접근에서 낮은 둑과 표지는 야간 대비가 약하다. Frozen Vale 원거리 진입 컷에는 기존 눈 둔덕 위로 석문 상단만 보였다. 통로 중앙의 16스터드 시점 한 쌍을 추가해 문틀과 윈치 고정철, 표지판 사이 시야를 확인했다. 화면에는 이름표 UI를 숨겼으며 시야 검사는 별도 광선으로 수행했다. 보충 촬영은 Studio 플러그인 시작 실패 뒤 고정 Place에서 재실행했다. [전후 비교판](comparison.jpg)

## 남은 수용

환경 아트와 QA가 직접 조작으로 Gloamwood 야간 첫 발견, Frozen Vale 귀환 표지, 다섯 사건의 입구에서 첫 조사 지점까지의 안내를 확인한다. 게시 클라이언트, 터치 실기기, 파티 스트리밍, 전투 카메라, 사용자 미술 수용은 미검증이다.

## 재현

저장소 루트에서 기록에 고정된 두 Place를 준비한다. [기준 0.115.127](../hero-forward-impact-20261125/build.json) · [후보 0.115.128](build.json)

```sh
evidence=docs/evidence/epic-fifth-chapter-entry-silhouettes-20261125
work=$(mktemp -d)
python3 "$evidence/prepare-studio.py" "$work/audit.luau"
python3 "$evidence/prepare-studio.py" "$work/near.luau" --near-snow
for tag in before after; do
    case "$tag" in
        before) record=docs/evidence/hero-forward-impact-20261125/build.json ;;
        after) record="$evidence/build.json" ;;
    esac
    source=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["sourceCommit"])' "$record")
    place=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["outputs"][0]["path"])' "$record")
    mkdir "$work/$tag-source"
    git archive "$source" src tests tools | tar -x -C "$work/$tag-source"
    (cd "$work/$tag-source" && python3 tools/prepare-campaign-expansion-native.py)
    cp /tmp/tlt-campaign-expansion-native.luau "$work/$tag-regression.luau"
    run-in-roblox --place "$PWD/$place" --script "$work/audit.luau" > "$work/$tag-audit.log" 2>&1
    run-in-roblox --place "$PWD/$place" --script "$work/$tag-regression.luau" > "$work/$tag-regression.log" 2>&1
    run-in-roblox --place "$PWD/$place" --script "$work/near.luau" > "$work/$tag-near.log" 2>&1
done
python3 "$evidence/compare.py" "$work" 0.115.127 0.115.128
```

영구 충돌 감사는 후보 고정 소스에서 `python3 tools/prepare-scenery-collision-native.py`로 준비하고 생성된 `/tmp/tlt-scenery-collision-native.luau`를 같은 후보 Place에서 실행한다.
