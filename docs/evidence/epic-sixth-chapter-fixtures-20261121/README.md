# 다섯 에픽 6장 지형과 설비

2026-11-21 UTC · TLT-061/DW-06 · TLT-065/GW-06 · TLT-062/FV-06 · TLT-063/EC-06 · TLT-064/HG-06 · G5 진행 중

[공식 RPG 사례와 제작표](../../research/2026-11-21-epic-sixth-chapter-fixtures.md) · [0.115.16 고정 빌드](build.json)

| 구간 | 실제 맵에 적용한 조형 |
| --- | --- |
| Deepwood · 피난로 | 물이 지나간 어두운 바닥을 넓히고 상류·하류 양단에 비스듬한 석재 입구를 만들었다. |
| Gloamwood · 정찰대 합류 | 목재 러너와 굽은 앞단의 두께를 키우고 널 사이에 틈과 견인 줄을 표현했다. |
| Frozen Vale · 요새 관리로 | 눈 덮인 석축 옆의 비활성 관 양단에 플랜지와 막음판을 조립했다. |
| Ember Caldera · 열 회로 관측소 | 현무암 받침 위에 노출된 내화벽돌 상단과 금속 차열판 고정대를 추가했다. |
| Haunted Graveyard · 왕릉 전실 | 마모된 밝은 덮개, 철제 난간 몸체와 두 버팀대를 석재 받침에 연결했다. |

## 재현 조건

기준 0.115.15는 `04b5ce36`의 빌드이며 Place SHA-256은 `239b4a3236705ed5cc1b18637e4511c30b52ef2f06c4d213a00eee99a74355f0`이다. 기준과 후보 Place의 개선 모듈 소스가 각각 해당 커밋과 일치하는지 확인했다. Studio에서 다섯 에픽을 생성하고 앞서 사용한 카메라 위치와 지역 조명을 기준과 후보에 각각 적용한다. 화면에서는 상호작용 프롬프트와 이름표를 껐다.

```sh
prior=docs/evidence/epic-sixth-chapter-landmarks-20261120
evidence=docs/evidence/epic-sixth-chapter-fixtures-20261121
audit=$(mktemp -t tlt-sixth-fixtures)
cat "$prior/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    "$prior/walk-approaches.luau" > "$audit"
run-in-roblox --place "$baseline_place" --script "$audit" > "$baseline_log" 2>&1
run-in-roblox --place "$candidate_place" --script "$audit" > "$candidate_log" 2>&1
python3 tools/prepare-campaign-expansion-native.py
run-in-roblox --place "$candidate_place" --script /tmp/tlt-campaign-expansion-native.luau > "$regression_log" 2>&1
python3 "$evidence/compare.py" "$baseline_log" "$candidate_log" "$regression_log"
```

## 검증 결과

- Lua 에픽 내비게이션 105,907건, 스토리 소품 4,264건, 전투 경로 77,381건, 서사 전이 1,060건을 통과했다. `late-epics.spec.lua`는 기준과 후보 모두 `DW-01:exp_1` 가용성 단언에서 실패했다.
- 다섯 시설의 부품은 총 50개에서 62개로 늘었다. 기존 피벗과 조사 목표 좌표, 보행선 최소 이격 4.81스터드는 기준과 일치했다. 25개 바닥 표본의 높이 오차는 모두 0스터드다. 개선 조립체는 Atomic이며 부품을 고정하고 충돌·터치·쿼리를 껐다. 기존 30개 시설의 측정값과 앵커는 기준과 일치했다.
- 기준과 후보의 R15가 다섯 구간에서 각각 약 32스터드 접근 및 귀환을 마쳤다. 점프를 비활성화했으며 후보의 가장 큰 최종 수평 오차는 약 1.95스터드였다.
- 동일 접근·귀환 화면 10쌍에서 DW는 귀환 쪽 석재 입구와 어두운 배수 홈이 더 잘 구분됐다. GW 끌것은 양쪽에서 나무 윤곽이 밝아졌고 견인 줄은 어둡게 남았다. FV 관 끝은 접근 측면에서 작은 차이가 보이며 귀환 화면에서는 석축에 상당 부분 가려진다. EC 내화벽돌 상단과 HG 귀환 난간의 덮개가 분명해졌다. [Studio 전후 비교](comparison.jpg)

- Studio 확장 회귀 9,193건이 통과했다. 사건 82곳, 단계 246개, 바닥과 보행 표본 3,968개에서 차단은 0건이었다. [Studio 측정](studio-results.json)

다음 담당은 환경 아트와 QA다. 실제 입력에서 GW 야간 끌것의 최초 발견과 FV 관리로 귀환 시야를 확인한다. 실제 입력, 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 전투 카메라와 사용자 미술 수용은 미검증이다.
