# 다섯 에픽 6장 설비의 접근과 귀환 검증

2026-11-21 UTC · TLT-061/DW-06 · TLT-065/GW-06 · TLT-062/FV-06 · TLT-063/EC-06 · TLT-064/HG-06 · G5 진행 중

[환경 아트·3D 리뷰와 제작표](../../research/2026-11-21-epic-service-return-profiles.md) · [0.115.18 고정 빌드 기록](build.json) · [Studio 전후 비교판](comparison.jpg) · [Studio 측정값](studio-results.json)

## 장면 확인

| 구간 | Studio 접근·귀환 화면 |
| --- | --- |
| Deepwood | 접근에서 짧아진 석재 상판 아래로 어두운 유수 홈이 더 보인다. 퇴적 사면은 귀환 측면에서 일부 뿌리에 가린다. |
| Gloamwood | 접근 화면을 확대하면 러너 앞단을 잇는 견인 줄이 조금 더 보인다. 일반 크기 야간 화면과 귀환 화면에서는 대비가 낮다. |
| Frozen Vale | 접근에서 관의 막음판을 구분할 수 있다. 귀환에서도 관이 석축 위로 드러나고 양끝의 플랜지가 윤곽을 만든다. |
| Ember Caldera | 내화벽돌 마루에 이음이 보이고, 낮은 마모석이 차열벽 발치를 따라 이어진다. 최초 접근에서는 발치의 대비가 낮다. |
| Haunted Graveyard | 귀환 측면에서 마모된 윗면과 아래로 굽은 끝이 읽힌다. 최초 접근에서 난간의 끝 굴곡은 작게 보인다. |

## 검증 조건과 결과

- 기준 0.115.17은 `64f90576`에서 빌드했다. 기준과 후보 Place XML에 포함된 6장 설비 모듈 소스가 각 빌드 커밋과 일치했다. 동일한 카메라와 지역 조명을 사용해 10쌍을 비교했다.
- 다섯 조립체의 부품은 62개에서 72개로 늘었다. 다섯 조사 위치와 조립체 피벗, 보행선 최소 이격 4.81스터드가 일치했다. 바닥 25점의 높이 오차는 0스터드였으며 기존 다른 30개 조립체의 측정값이 일치했다. 모든 부품은 고정 상태이고 충돌·터치·쿼리를 끈 상태다.
- 기준과 후보의 R15는 점프를 끄고 다섯 구간에서 각각 32스터드 접근과 귀환을 완료했다. 후보 최종 수평 오차는 최대 2.22스터드로 허용 범위 2.5스터드 이내였다.
- Studio 확장 회귀 9,193건이 통과했다. 사건 82곳의 246단계와 바닥·경로 3,968표본에서 차단은 0건이었다. Lua 에픽 내비게이션 105,907건, 스토리 소품 4,264건, 전투 경로 77,381건이 통과했다. 별도로 실행한 Lua 세 테스트는 기준과 후보에서 각각 같은 단언에 실패했다. `campaign-expansion.spec.lua`의 첫 본편 Gold, `story-continuation.spec.lua`의 `StoryLocked`, `late-epics.spec.lua`의 `DW-01:exp_1` 가용성이다.

## 재현

```sh
prior=docs/evidence/epic-sixth-chapter-landmarks-20261120
evidence=docs/evidence/epic-sixth-chapter-return-20261121
audit=$(mktemp -t tlt-sixth-return)
cat "$prior/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    "$prior/walk-approaches.luau" > "$audit"
run-in-roblox --place "$baseline_place" --script "$audit" > "$baseline_log" 2>&1
run-in-roblox --place "$candidate_place" --script "$audit" > "$candidate_log" 2>&1
python3 tools/prepare-campaign-expansion-native.py
run-in-roblox --place "$candidate_place" --script /tmp/tlt-campaign-expansion-native.luau > "$regression_log" 2>&1
python3 docs/evidence/epic-sixth-chapter-fixtures-20261121/compare.py \
    "$baseline_log" "$candidate_log" "$regression_log" \
    --baseline-version 0.115.17 --output-dir "$evidence" \
    --allow-unchanged-summary ScoutExtractionSkid
```

환경 아트와 QA는 실제 모바일 조작에서 Gloamwood 견인 줄의 최초 발견과 Frozen Vale 관리로의 귀환 시야를 확인한다. 실제 입력, 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 전투 카메라 및 사용자 미술 수용은 미검증이다.
