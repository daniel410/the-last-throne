# 다섯 에픽 2장 사건 입구의 Studio 비교

2026-11-25 Toronto · TLT-061/DW-02 · TLT-065/GW-02 · TLT-062/FV-02 · TLT-063/EC-02 · TLT-064/HG-02 · G5 진행 중

공통 아치 다섯 개를 사건의 역할이 드러나도록 바꿨다. Deepwood 응급처치소에는 빗물이 한쪽으로 흐르는 처마와 석재 기단, Gloamwood의 구조길에는 층리 셰일과 노출 뿌리, Frozen Vale의 저장고에는 압설과 석재 문틀을 배치했다. Ember Caldera 냉각 전망대에는 화물선과 냉각 설비를 향한 낮은 현무암 받침과 철제 안내틀, Haunted Graveyard의 출발길에는 꺼진 등잔을 담은 양면 석회암 벽감을 만들었다. 기존 55부품에서 73부품으로 늘었으며 편집 원본은 런타임 Luau 조립체다. [공식 사례와 제작표](../../research/2026-11-25-epic-second-chapter-entry-silhouettes.md) · [조형 원본](../../../src/server/World/EpicSecondChapterEntrances.luau)

## 검증

- 지도 내비게이션·전투 동선·사건 정적 검사 187,336건과 후보 Place의 역할·로딩 검사 336건을 통과했다. 두 Place의 SHA-256을 빌드 기록과 대조하고 후보에 탑재된 조형 및 통합 모듈이 고정 소스와 일치함을 확인했다. [정적 검사 및 패키지 확인](static-results.txt)
- Studio에서 양쪽 빌드 각각 5곳의 32스터드 입구를 점프를 끈 R15로 왕복했다. 도착 오차는 기준 최대 2.22, 후보 최대 2.49스터드였으며 수용 기준은 2.5스터드 미만이다. 바닥과 몸체는 빌드마다 325표본을 검사했고 최대 바닥 오차는 0.08스터드였다. 지정한 다섯 곳의 피벗·표지판·통과선·사건 및 단계 좌표와 나머지 77개 사건 입구의 측정값이 일치했다. 새 구조물의 표지판 본체·이름표 가림은 양방향 시선 540개에서 0건이었다. [Studio 측정](studio-results.json)
- Studio 캠페인 회귀는 전후 각각 9,310건을 통과했다. 각 빌드의 사건 82개, 단계 246개 및 바닥·이동 3,981표본에서 차단은 0건이었다. [캠페인 측정](studio-results.json)
- 고정 카메라 10쌍에서 Deepwood의 처마 경사, Frozen Vale의 압설과 문틀, Ember Caldera의 개방된 전망, Haunted Graveyard의 쌍 벽감이 두 방향에서 구별됐다. Gloamwood는 중앙 전망이 열렸으며 뿌리와 셰일이 귀환에서 더 잘 보인다. 야간 접근에서는 두 재질의 대비가 낮다. 기준 카메라를 호출하는 첫 두 차례의 Studio 플러그인 연결 오류는 해당 격리 실행만 정리하고 재시도해 복구했다. [전후 비교판](comparison.jpg)

- 후보의 Luau 전체 컴파일과 영구 지형 충돌 감사 25,298건을 통과했다. 82개 입구의 중앙 관통을 4×5×4스터드 몸체로 점검했다. 대상 입구의 영구 충돌 부품은 45개에서 39개로 줄었다. [충돌 감사](scenery-results.json)

## 남은 수용

후보는 미게시다. 키보드·게임패드 직접 조작으로 최초 발견과 조사, 게시 클라이언트, 터치 실기기, 파티 스트리밍, 전투 카메라 및 사용자 미술 수용은 미검증이다. 다음 환경 아트·QA는 Gloamwood의 실제 와이드 카메라에서 야간 접근 시 선반과 구조 단서의 우선순위를 확인한다.

## 재현

저장소 루트에서 빌드 기록에 고정된 두 Place를 준비한다. [기준 0.115.120](../hero-weapon-releases-20261125/build.json) · [후보 0.115.121](build.json)

```sh
evidence=docs/evidence/epic-second-chapter-entry-silhouettes-20261125
work=$(mktemp -d)
python3 "$evidence/prepare-studio.py" "$work/audit.luau"
for tag in before after; do
    case "$tag" in
        before) version=0.115.120; source=9302c46d ;;
        after) version=0.115.121; source=b2a15c9c ;;
    esac
    mkdir "$work/$tag-source"
    git archive "$source" src tests tools | tar -x -C "$work/$tag-source"
    (cd "$work/$tag-source" && python3 tools/prepare-campaign-expansion-native.py)
    cp /tmp/tlt-campaign-expansion-native.luau "$work/$tag-regression.luau"
    place="$PWD/builds/$version/TheLastThrone-$version.rbxlx"
    run-in-roblox --place "$place" --script "$work/audit.luau" > "$work/$tag-audit.log" 2>&1
    run-in-roblox --place "$place" --script "$work/$tag-regression.luau" > "$work/$tag-regression.log" 2>&1
done
python3 "$evidence/compare.py" "$work" 0.115.120 0.115.121
```

영구 충돌 감사에는 후보 소스에서 `python3 tools/prepare-scenery-collision-native.py`를 실행해 생성한 `/tmp/tlt-scenery-collision-native.luau`를 같은 후보 Place에 적용한다.
