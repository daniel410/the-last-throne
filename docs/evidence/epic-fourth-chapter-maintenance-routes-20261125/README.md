# 다섯 에픽 4장 복구 동선과 설비

2026-11-25 Toronto · TLT-061/DW-04 · TLT-065/GW-04 · TLT-062/FV-04 · TLT-063/EC-04 · TLT-064/HG-04 · G5 진행 중

[환경 아트 조사와 제작표](../../research/2026-11-25-epic-fourth-chapter-maintenance-routes.md) · [기준 0.115.105](../hero-mark-break-releases-20261125/build.json) · [후보 0.115.106](build.json)

## 구현과 정적 검증

- 기존 대표 지물과 다른 사건의 두 번째 단계에 지역별 흙·셰일·빙설·현무암·포석 기단과 조립체를 배치했다. 총 38부품을 기존 비충돌 장식 생성 경로에서 만든다.
- 고정 커밋에서 Place를 빌드했다. 기준과 후보의 Place SHA-256을 빌드 기록과 대조했고, 후보의 랜드마크 모듈 두 개가 커밋 소스와 바이트 단위로 일치함을 확인했다.
- 지형 바닥 405표본이 배치 피벗의 높이와 일치했다. 사건 입구부터 조사점과 마지막 지점까지 잇는 선분에서 새 조형의 보수적 외곽까지 최소 10.26스터드였다. Frozen Vale의 배치 방향을 반대로 바꿔 정적 이격을 7.25스터드에서 10.54스터드로 늘렸다.
- 지도·전투 동선·확장 사건 검사 187,336건과 빌드 역할·입장 구성 검사 336건을 통과했다. [정적 실행 결과](static-results.txt)

## Studio와 수용

직전 3장 후보 0.115.103의 기본 실행기 재시도와 이번 4장 후보의 별도 포트 실행은 Studio 시작 응답 시간 초과로 종료됐다. 두 실행 모두 감사 스크립트의 첫 출력 이전에 멈췄다. [실행 로그](studio-startup.txt)

다음 담당은 환경 아트와 QA다. 두 빌드에서 접근·귀환 카메라 10쌍과 R15 5개 구간 왕복을 확인한다. 특히 Gloamwood의 야간 목재 대비와 Ember Caldera의 배관·조사점 분리를 확인한다. 겹침 검사는 새 조립체와 기존 퀘스트 랜드마크의 높이·수평 바운딩 박스를 비교한다. 그 밖의 비충돌 장식의 시각 가림은 카메라에서 확인한다. Studio 카메라와 왕복, 물리적 겹침, 캠페인 엔진 회귀, 게시 클라이언트, 터치 실기기, 파티 스트리밍, 전투 카메라와 사용자 미술 수용은 미검증이다.

## 재현

```sh
e=docs/evidence/epic-fourth-chapter-maintenance-routes-20261125
work=$(mktemp -d)
lua "$e/check-geometry.lua"
for suite in epic-map-navigation campaign-combat-routes campaign-expansion-review; do
    lua "tests/$suite.spec.lua"
done
python3 tests/single-build.spec.py --artifact builds/0.115.106/TheLastThrone-0.115.106.rbxlx
python3 "$e/prepare-studio.py" "$work/audit.luau"
for version in 0.115.105 0.115.106; do
    run-in-roblox --place "$PWD/builds/$version/TheLastThrone-$version.rbxlx" \
        --script "$work/audit.luau" > "$work/$version-audit.log" 2>&1
done
```

캠페인 엔진 회귀는 각 빌드의 고정 소스에서 `python3 tools/prepare-campaign-expansion-native.py`로 스크립트를 준비한다. 해당 Place에서 별도로 실행해 사건·단계·표본 수, 차단 0건, 새 장식 38부품을 확인한다.
