# 다섯 에픽 7장 접근 지형과 시설 검증

2026-11-21 UTC · TLT-061/DW-07 · TLT-065/GW-07 · TLT-062/FV-07 · TLT-063/EC-07 · TLT-064/HG-07 · G5 진행 중

[이전 화면 검토 및 제작표](../../research/2026-11-21-epic-finale-route-profiles.md) · [고정 빌드](build.json) · [Studio 전후 비교판](comparison.jpg) · [Studio 측정값](studio-results.json)

| 에픽 | 실제 맵에 반영한 변경 | 부품 |
| --- | --- | ---: |
| Deepwood | 적재장 앞 흙을 경사로 깎고, 두 바퀴홈의 폭을 넓혀 석재 받침과 철제 마모판에 이어지게 했다. | 15 → 16 |
| Gloamwood | 바람이 드러낸 낮은 셰일 단면을 두껍게 하고, 밝은 하층과 짙은 절리, 바람그늘의 눈을 나눴다. | 9 → 9 |
| Frozen Vale | 고임목의 철제 정지면을 1.52×1.04에서 1.87×1.46스터드로 넓혔다. | 13 → 13 |
| Ember Caldera | 축경 지름을 .53에서 .72스터드로 키우고 바깥 단부에 마모색을 적용했다. | 27 → 27 |
| Haunted Graveyard | 귀환 보호턱의 철제 버팀을 .51에서 .67스터드로 키우고, 끝의 받침과 함께 석재 위에서 읽히게 했다. | 13 → 13 |

## 화면과 검증 결과

- 고정 카메라 13쌍을 비교했다. DW의 앞쪽 직각 턱이 흙 경사로 바뀌고 GW 하층은 야간 접근에서 위층과 구분된다. FV의 정지면과 EC의 축경은 근경에서 확인되며 중간 거리에서는 작다. HG 버팀은 목표 쪽 시야에서 두꺼워졌고 사선 야간에서는 대비가 낮다.
- Studio에서 Luau 565개를 컴파일했고 단독 및 전체 생성의 모델 측정이 일치했다. 부품 77→78개, 다섯 조사·접지 위치와 바닥 표본 25점 일치, 기존 지물 10개 일치, 전체 외곽 차이 최대 .00011스터드였다. 부품은 고정·비충돌·비터치·비쿼리다.
- Original 38,184개와 Easy 39,483개 보행 표본에서 차단 0건이었다. 두 빌드 각각 점프를 끈 R15 자동 접근·귀환 23쌍이 도착했다.
- 롤러 6개와 축경 12개의 공선·겹침·지름을 확인했다. Suri 양옆과 중간 접근에서 선적대 시야 표본 각각 27/27개, 어깨너머 24/27개였다. Suri 중심에서는 캐릭터 모델이 27개 모두 가린다. 기준과 후보 결과가 같았다.
- Lua 에픽 지도 105,907건, 도보 내비게이션 8,791건, 이야기 소품 문맥 4,264건, 전투 경로 77,381건이 통과했다.

## 검증 재현

기준은 0.115.21, 후보는 0.115.22다. 두 빌드에서 기존 도보·시야 감사를 실행한다. 후보에는 변경한 축경을 검증하는 스크립트를 추가한다.

```sh
audit_dir=docs/evidence/epic-finale-route-profiles-20261121
python3 docs/evidence/epic-finale-dispatch-20261120/prepare-studio.py --output "$audit" --candidate
run-in-roblox --place "$baseline_place" --script "$audit" > "$baseline_log" 2>&1
{
    printf '\ndo\n'
    cat "$audit_dir/check-journals.luau"
    printf '\nend\n'
} >> "$audit"
run-in-roblox --place "$candidate_place" --script "$audit" > "$candidate_log" 2>&1
python3 "$audit_dir/compare.py" "$baseline_log" "$candidate_log"
```

다음 담당은 환경 아트·QA다. 실제 조작에서 GW 야간 최초 발견 위치, FV의 재회 접근, Suri 확인 후 옆으로 움직일 때 보이는 EC 선적대, 왕릉 복원 뒤 HG 귀환을 확인한다. 게시 클라이언트·실기기·멀티플레이 스트리밍·전투 카메라·사용자 미술 수용은 미검증이다.
