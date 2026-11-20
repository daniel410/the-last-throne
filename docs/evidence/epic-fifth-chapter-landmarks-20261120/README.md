# 다섯 에픽 5장 지물 검증

2026-11-20 UTC · TLT-061/DW-05 · TLT-065/GW-05 · TLT-062/FV-05 · TLT-063/EC-05 · TLT-064/HG-05 · G5 진행 중

[공식 RPG 사례와 장별 제작표](../../research/2026-11-20-epic-fifth-chapter-landmarks.md) · [0.114.14 기준 빌드](../shield-axe-impact-20261120/build.json) · [후보 빌드](build.json)

## 재현

저장소 루트에서 기준과 후보를 각 기록의 소스 커밋으로 빌드한다. 별도 Studio 인스턴스에서 같은 카메라와 지역 조명을 적용한다. 프롬프트와 이름표는 화면 캡처에서 숨긴다.

```sh
evidence=docs/evidence/epic-fifth-chapter-landmarks-20261120
cat "$evidence/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    "$evidence/walk-approaches.luau" > /tmp/tlt-epic-fifth-review.luau
run-in-roblox --place "$baseline_place" --script /tmp/tlt-epic-fifth-review.luau > /tmp/tlt-epic-fifth-before.log 2>&1
run-in-roblox --place "$candidate_place" --script /tmp/tlt-epic-fifth-review.luau > /tmp/tlt-epic-fifth-after.log 2>&1
python3 tools/prepare-campaign-expansion-native.py
run-in-roblox --place "$candidate_place" --script /tmp/tlt-campaign-expansion-native.luau > /tmp/tlt-epic-fifth-regression.log 2>&1
python3 "$evidence/compare.py" /tmp/tlt-epic-fifth-before.log /tmp/tlt-epic-fifth-after.log /tmp/tlt-epic-fifth-regression.log
```

`baseline_place`와 `candidate_place`에 각 빌드의 Place 경로를 지정한다. 모델 중심과 외곽 네 점에서 지면까지 레이캐스트하고, 기존 조사 노드와 모델 피벗을 대조한다. 조사점 앞뒤를 약 1스터드 간격으로 표본화하고 해당 사건의 표시 단계별 인물 자세를 조회해 조립체 외곽과의 거리를 확인한다. R15는 점프 없이 마지막 32스터드를 왕복한다.

## Studio 결과

- 네이티브 조립체 5개·57부품을 확인했다. 모델은 Atomic 스트리밍 모드를 사용하고 모든 부품은 고정·비충돌·비터치·비쿼리다. 지면 표본 25곳의 최대 높이 오차는 0스터드다. 기준 지물 25개와 조사 앵커는 기록상 동일했고 캐시에서 지물을 재사용했다.
- 조사선 이격은 DW 7.97, GW 7.05, FV 4.25, EC 6.82, HG 7.17스터드다. EC 시험실의 표시 단계별 인물 자세와는 최소 6.82스터드 떨어졌다.
- FV의 첫 배치는 양쪽 시점 모두 얼음 기둥에 가렸다. 조사선 반대쪽으로 이동해 동일 카메라에서 접근과 귀환 시 차륜을 확인했다. GW 야간에는 석축 상단이 바닥과 분리되어 보인다. EC 포집함은 조작대 곁에서 보이고 HG 도관의 금속 피복은 석조보다 어둡다. [전후 10쌍](comparison.jpg)
- 기준과 후보에서 다섯 지점을 점프 없이 R15로 왕복했다. Lua 캠페인 검사는 서사 1,060건, 진행 4,493건, 전투 경로 77,381건, 확장 사건 3,492건을 통과했다.
- 격리 Studio에서 전체 에픽 생성과 확장 회귀 9,193건을 통과했다. 사건 82곳, 단계 246개, 바닥·동선 표본 3,968개에서 차단은 0건이었다. 고정 커밋의 0.114.15 빌드와 Studio 검토 파일의 바이너리 일치를 확인했다. [측정 데이터](studio-results.json)

다음 담당은 QA와 환경 아트다. 실제 플레이 입력으로 FV 차륜의 최초 발견과 조사 프롬프트를 확인하고, GW 석축과 HG 금속 피복을 터치 기기에서 판독한다. 게시 클라이언트, 멀티플레이 스트리밍, 전투 카메라와 사용자 미술 수용은 미검증이다.
