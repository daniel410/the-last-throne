# 다섯 에픽 경계의 지형 실루엣 비교

2026-11-21 UTC · TLT-061, TLT-065, TLT-062, TLT-063, TLT-064 · G5 진행 중

[서사와 환경 아트 제작표](../../research/2026-11-21-epic-boundary-silhouettes.md) · [고정 빌드](build.json) · [동일 카메라 비교](comparison.jpg) · [Studio 측정](studio-results.json)

| 경계 | 실제 맵에 배치한 모델 |
| --- | --- |
| DW-07 → GW-01 | 화물 문서에서 Rootway로 이어지는 흙턱의 심재를 넓혔다. 뿌리 한 갈래를 귀환 쪽 셰일 둔덕에 매입했다. |
| GW-07 → FV-01 | 피난처로 이어지는 바람길에서 검은 셰일 발치의 압설을 두껍고 길게 만들었다. |
| FV-07 → EC-01 | 화물 승강기로 향하는 해빙로의 첫 현무암을 앞당겼다. 노두 세 덩이의 몸체와 절리면 폭을 넓혔다. |
| EC-07 → HG-01 | 피난처 관리로가 시작되는 곳의 가공석 가운데 돌을 넓히고 양 끝의 마모된 높이를 낮췄다. |

## 재현 조건

[0.115.13](../hero-contact-direction-20261121/build.json)과 0.115.14의 고정 Place를 별도 Studio 세션에서 실행했다. 두 Place에서 다섯 에픽을 생성하고 챕터 접근 조건이 열린 R15를 상대 구역 중심까지 자동 이동시켰다. 9개 장면은 이전 검증과 같은 위치·각도·조명에서 400 × 225로 샘플링했다.

```sh
audit_dir=docs/evidence/epic-boundary-approach-20261121
output_dir=docs/evidence/epic-boundary-silhouettes-20261121
python3 "$audit_dir/prepare-studio.py" --output "$audit"
run-in-roblox --place "$baseline_place" --script "$audit" > "$baseline_log" 2>&1
run-in-roblox --place "$candidate_place" --script "$audit" > "$candidate_log" 2>&1
python3 "$audit_dir/compare.py" "$baseline_log" "$candidate_log" \
  --baseline-version 0.115.13 --candidate-version 0.115.14 --output-dir "$output_dir"
```

## 검증 결과

- R15가 두 빌드에서 각각 네 경계의 8방향을 모두 통과했다. 점프와 서버 위치 보정은 0회였다. 지형 생성 재호출 후 연결로는 4개였고, 도로 바닥의 변환과 크기는 기준과 일치했다.
- 길어깨 장식은 72부품이다. 도로 중앙선에서 장식까지 최소 이격은 32.82 → 32.90스터드, 바닥 위 최대 높이는 6.43 → 6.47스터드다. 부품 경계가 도로 폭과 길이 안에 들어왔고 충돌·터치·쿼리가 비활성이다. 하부 부품은 바닥에 0.2스터드를 넘게 매입했고 현무암 절리 6개는 몸체에 0.09스터드 겹친다.
- Lua 검사에서 에픽 지도 105,907건, 캠페인 내비게이션 8,791건, 스토리 소품 4,264건, 전투 경로 77,381건을 통과했다.
- Deepwood 주간 전진에서 심재 면이 길게 보인다. 야간 귀환에서 셰일 둔덕 옆에 옮긴 뿌리가 옅게 드러난다. Gloamwood 전진에서 셰일 위 압설 면이 넓어졌고, 반대편 원경의 변화는 작다.
- Frozen Vale 첫 접근에서 앞당긴 노두가 커졌으나 배후 능선과 일부 겹친다. 중간 접근에서는 현무암과 절리의 면이 분명해진다. Ember Caldera 귀환에서는 전경 랜턴이 시선을 먼저 잡는다.
- Haunted Graveyard 진입에서 가공석 가운데 돌과 마모된 끝돌이 구분된다. 야간 귀환에서는 높이 차가 작게 읽힌다.

환경 아트와 QA의 다음 확인은 모바일 실제 조작에서 Deepwood 야간 귀환 뿌리와 Frozen Vale 첫 노두의 발견 시점이다. 실제 입력, 전투 카메라, 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 사용자 미술 수용은 미검증이다.
