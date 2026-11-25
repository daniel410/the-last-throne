# 다섯 에픽 4장 사건 입구의 Studio 비교

2026-11-25 Toronto · TLT-061/DW-04 · TLT-065/GW-04 · TLT-062/FV-04 · TLT-063/EC-04 · TLT-064/HG-04 · G5 진행 중

다섯 공통 입구를 사건에 필요한 시설과 지형으로 바꿨다. Deepwood의 망루 구조 뜰은 목제 신호 셔터와 석조 기단, Gloamwood의 피난처 복귀길은 뿌리와 밧줄 체결 흔적, Frozen Vale의 기록관은 압설 지붕과 판석 홈, Ember Caldera의 냉각수 점검로는 현무암과 열린 관 단면, Haunted Graveyard의 작업장은 석회암 받침과 철제 닻틀로 구분한다. 조형 원본은 지역 팔레트를 사용하는 Roblox 네이티브 Luau 조립체다. 대상 입구는 55부품에서 90부품으로 늘었고 영구 충돌 부품은 45개에서 48개가 됐다. DW·FV·EC는 Z축 입구 표지판과 간격을 확보하기 위해 조형만 피벗에서 진행 방향으로 4.65스터드 옮겼다. [공식 사례와 제작표](../../research/2026-11-25-epic-fourth-chapter-entry-silhouettes.md) · [조형 원본](../../../src/server/World/EpicFourthChapterEntrances.luau)

## 검증

- 지도 내비게이션·전투 동선·사건 정적 검사 187,336건과 후보 Place의 역할·로딩 검사 336건을 통과했다. 0.115.123과 0.115.124 Place의 SHA-256을 각각 빌드 기록과 대조했다. 후보에 탑재된 조형 및 통합 모듈은 고정 소스와 바이트 단위로 일치했다. [정적 검사 및 패키지 확인](static-results.txt)

- Studio에서 점프를 끈 R15가 빌드마다 다섯 입구의 32스터드 경로를 왕복했다. 도착 오차는 기준 최대 1.85, 후보 최대 2.21스터드였으며 수용선은 2.5스터드 미만이다. 빌드마다 바닥·몸체 325표본을 검사했고 최대 바닥 오차는 0이었다. 다섯 곳의 피벗·표지판·통과선·사건 및 단계 좌표와 나머지 77개 입구의 측정값이 일치했다. [Studio 측정](studio-results.json)
- 입구 구조물의 가림은 양방향 표지판·이름표 540광선과 Gloamwood 방향판 162광선에서 양쪽 빌드 모두 0건이었다. 캠페인도 기준·후보 각각 9,310건을 통과했고 사건 82개, 단계 246개 및 바닥·이동 3,981표본에서 차단 0건이었다. [Studio 측정](studio-results.json)
- 고정 카메라 10쌍에서 Ember Caldera의 열린 관 단면, Frozen Vale의 수평 석재와 판석 홈, Haunted Graveyard의 비스듬한 철제 빔이 양방향에서 구분됐다. Gloamwood의 뿌리 끝은 읽히지만 야간 밧줄 체결부는 대비가 낮다. Frozen Vale의 귀환 고정 카메라에서는 표지판과 기둥이 일부 겹쳐 보인다. 기준 카메라 실행 뒤 남은 격리 Studio 프로세스와 후보 실행기의 포트 충돌을 정리한 후 동일 Place에서 재실행했다. [전후 비교판](comparison.jpg)
- 후보의 Luau 전체 컴파일과 영구 지형 충돌 감사 25,294건을 통과했다. 사건 입구 82개를 4×5×4스터드 몸체로 통과 검사했다. [충돌 감사](scenery-results.json)

## 남은 수용

키보드·게임패드 직접 조작에서 입구 최초 발견과 조사, 게시 클라이언트, 터치 실기기, 파티 스트리밍, 전투 카메라와 사용자 미술 수용은 미검증이다. 다음 환경 아트·QA는 Gloamwood 귀환 시 뿌리와 기존 방향판의 우선순위를 확인한다.

## 재현

저장소 루트에서 빌드 기록에 고정된 두 Place를 준비한다. [기준 0.115.123](../hero-guard-waves-20261125/build.json) · [후보 0.115.124](build.json)

```sh
evidence=docs/evidence/epic-fourth-chapter-entry-silhouettes-20261125
work=$(mktemp -d)
python3 "$evidence/prepare-studio.py" "$work/audit.luau"
for tag in before after; do
    case "$tag" in
        before) record=docs/evidence/hero-guard-waves-20261125/build.json ;;
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
done
python3 "$evidence/compare.py" "$work" 0.115.123 0.115.124
```

영구 충돌 감사에는 후보 소스에서 `python3 tools/prepare-scenery-collision-native.py`를 실행해 생성한 `/tmp/tlt-scenery-collision-native.luau`를 같은 후보 Place에 적용한다.
