# 다섯 에픽 3장 구조길의 바닥 접점과 귀환 시야

2026-11-25 Toronto · TLT-061/DW-03 · TLT-065/GW-03 · TLT-062/FV-03 · TLT-063/EC-03 · TLT-064/HG-03 · G5 진행 중

[공식 사례와 제작표](../../research/2026-11-25-epic-third-chapter-route-profiles.md) · [기준 0.115.113](../hero-burst-contact-20261125/build.json) · [후보 0.115.114](build.json)

## 구현과 정적 검증

Deepwood의 다짐흙과 석재 관측 받침, Frozen Vale의 암반·청빙·압설층, Ember Caldera의 현무암 기단과 내화벽돌 받침, Haunted Graveyard의 석회암 경사 버팀을 조형했다. Gloamwood에서는 회수 등불 선반을 지도 차양 반대편으로 옮기고 작은 고정 등갓을 달았다. 발광 재질을 사용하며 추가 동적 광원은 0개다.

- 고정 비충돌 조형 57부품으로 기준 대비 13부품이 늘었다. 바닥 405표본과 사건 보행선 이격을 계산했다. 정적 최소 이격은 6.33스터드다.
- 지도 105,907건, 전투 동선 77,381건, 사건 확장 4,048건, 단일 Place 역할·로딩 336건을 통과했다. 양쪽 고정 Place 해시와 탑재 조형 모듈의 소스 바이트가 빌드 기록 및 고정 커밋과 일치했다. [정적 결과](static-results.txt)

## Studio

- 격리 Place에서 이전 단계와 다음 단계 쪽으로 각 8·16·24·32스터드 거리, 지면 위 5.5스터드 높이에서 선반 본체 앞 5곳을 검사했다. 차양 부품만 질의 대상으로 두었으며 검사 뒤 원래 물리 속성을 복원했다. 기준에서는 접근 20개 중 0개, 귀환 20개 중 7개가 차양에 막혔다. 후보에서는 양방향 40개 모두 차양에 막히지 않았다.
- 지역 조명이 적용된 동일 접근·귀환 화면 10쌍을 캡처했다. Gloamwood에서는 조사점을 기준으로 카메라를 고정했고, 양방향에서 선반의 발광 창이 차양 옆에 분리되어 보였다. Frozen Vale과 Ember Caldera의 바닥층은 더 넓게 읽힌다. Deepwood 관측 홈과 Haunted Graveyard 버팀의 차이는 고정 카메라 거리에서 작다. 캡처 시 상호작용 UI는 숨겼다. [전후 화면](comparison.jpg)
- 기존 조사점 5개와 다른 조형 60개의 조사점·피벗·외곽 치수·부품 수가 일치했다. 새 외곽은 검사한 다른 퀘스트 지물과 겹치지 않았다. 실제 바닥 25점의 오차는 0스터드, 보행선과 외곽의 최소 이격은 6.19스터드였다. 점프를 끈 R15가 양쪽에서 다섯 조사점 앞 16스터드를 왕복했고, 후보 최대 도착 오차는 1.79스터드였다.
- 캠페인 회귀는 양쪽 각각 9,310건을 통과했다. 사건 82개와 단계 246개를 검사했고 바닥·보행 표본 3,981개에서 차단은 0건이었다. [Studio 측정](studio-results.json)

후보는 미게시다. 실제 입력에서 최초 발견과 상호작용 흐름, 게시 클라이언트, 터치 실기기, 파티 스트리밍, 전투 카메라, 사용자 미술 수용은 미검증이다. 환경 아트와 QA는 다음에 GW-03 이동 화면에서 선반과 지도 차양의 우선순위를 확인하고, GW-04 야간 방향판의 대비를 평가한다.

## 재현

저장소 루트에서 기준과 후보 Place를 각 빌드 기록의 고정 소스로 준비한다. 이 변경은 사건 데이터와 검증 실행기의 입력을 수정하지 않았으므로 동일한 캠페인 감사 스크립트를 사용한다.

```sh
evidence=docs/evidence/epic-third-chapter-route-profiles-20261125
work=$(mktemp -d)
python3 "$evidence/prepare-studio.py" "$work/audit.luau"
python3 tools/prepare-campaign-expansion-native.py
cp /tmp/tlt-campaign-expansion-native.luau "$work/regression.luau"
for tag in before after; do
    version=0.115.113
    if test "$tag" = after; then version=0.115.114; fi
    place="$PWD/builds/$version/TheLastThrone-$version.rbxlx"
    run-in-roblox --place "$place" --script "$work/audit.luau" > "$work/$tag-audit.log" 2>&1
    run-in-roblox --place "$place" --script "$work/regression.luau" > "$work/$tag-regression.log" 2>&1
done
python3 "$evidence/compare.py" "$work"
```
