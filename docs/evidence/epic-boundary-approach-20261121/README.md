# 다섯 에픽 도보 경계의 접근·귀환 비교

2026-11-21 UTC · TLT-061, TLT-065, TLT-062, TLT-063, TLT-064 · G5 진행 중

[서사와 환경 아트 제작표](../../research/2026-11-21-epic-boundary-approach.md) · [고정 빌드](build.json) · [동일 카메라 비교](comparison.jpg) · [Studio 측정](studio-results.json)

Deepwood 출구의 흙턱에 긴 뿌리와 갈래를 매입했다. Gloamwood 바람길에서는 압설을 셰일 발치와 포갰다. Frozen Vale 해빙로에서 Ember Caldera의 큰 현무암 노두를 앞당기고 밝은 절리면을 두껍게 했다. Haunted Graveyard 쪽 관리로는 세 절단석이 이어지는 낮은 기단으로 만들었다. Studio의 기본 입체와 기존 지역 팔레트를 재사용했다.

## 재현 조건

기준 빌드는 [0.115.10](../runtime-errors-20261120/build.json)이고 후보 빌드는 소스 `208ee49c`에서 고정한 0.115.11이다. 각 로컬 Place를 별도 Studio 세션에서 실행한다. 두 빌드 모두 다섯 지역을 생성해 네 연결로를 검사한다. 자동 R15는 챕터 접근 조건을 설정한 채 양쪽 구역 중심 사이를 이동한다. 화면은 거리와 조명을 고정해 길어깨 쪽으로 향한 카메라 9개로 캡처했다.

```sh
python3 docs/evidence/epic-boundary-approach-20261121/prepare-studio.py --output "$audit"
run-in-roblox --place "$baseline_place" --script "$audit" > "$baseline_log" 2>&1
run-in-roblox --place "$candidate_place" --script "$audit" > "$candidate_log" 2>&1
python3 docs/evidence/epic-boundary-approach-20261121/compare.py "$baseline_log" "$candidate_log"
```

## 검증 결과

- 두 빌드의 네 연결로에서 바닥 변환과 크기가 일치했고, 지형 생성 재호출 후 연결로 수는 4개였다. R15는 기준·후보 각각 8방향에 모두 도착했다. 점프와 서버 위치 보정은 0회였다.
- 길어깨는 72부품을 유지했다. 도로 중앙선에서 장식까지의 최소 이격은 32.48→32.82스터드, 최대 노출은 5.53→6.43스터드다. 모든 부품이 바닥 경계에 들어오며 충돌·터치·쿼리가 비활성이다. 하부는 바닥에 0.2스터드를 넘게 매입했고 상부 현무암 절리 6개는 아래 몸체와 0.09스터드 겹친다.
- Lua 검사는 에픽 지도 105,907건, 캠페인 내비게이션 8,791건, 스토리 소품 4,264건, 전투 경로 77,381건을 통과했다.
- Deepwood 전진 화면에서는 두 작은 노출점이 더 긴 뿌리 윤곽으로 이어진다. Gloamwood 야간 귀환 화면에서는 뿌리와 흙턱의 대비가 여전히 낮다.
- Gloamwood 전진에서 눈과 셰일의 겹친 면이 넓어졌다. Haunted Graveyard 경계에서 가공석 줄의 이음새가 좁아졌고, 전후 차이는 가까운 시점에서 읽힌다.
- Frozen Vale의 중간 접근에서 노두가 뒤편 둔덕 앞에 별도 윤곽을 만든다. 최초 접근과 Ember Caldera 귀환에서는 노두가 작게 보이고 절리의 명도 차가 약하다.

## 남은 수용

환경 아트와 QA는 모바일 실제 입력에서 Deepwood 야간 귀환과 해빙로 노두의 최초 발견 시점을 확인한다. 직접 입력, 전투 카메라, 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 사용자 미술 수용은 미검증이다.
