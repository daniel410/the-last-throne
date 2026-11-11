# 엘프 기본 활 공격 시간 배분 수정

작업: TLT-054/057/084 · ENG → QA·사용자. 2026-11-11.

사용자 보고: 활을 집어 발사하는 동작은 너무 빨라 보이지 않고 발사 뒤 손을 내리는 동작은 느리다. 기본 공격이 장전·당김 전체를0.44초에 압축하고 발사 후0.76초를 사용하는 명확한 시간 배분 결함으로 처리했다. 별도 게임성 규칙을 도입하지 않아 신규 사례 조사는 생략했다.

| DEX0 기준 구간 | 이전 | 수정 |
| --- | --- | --- |
| 화살 장전·활 당김·조준 | 0.44초 | 0.78초 |
| 발사 후 active | 0.16초 | 0.16초 |
| recovery | 0.60초 | 0.26초 |
| 전체 공격 주기 | 1.20초 | 1.20초 |

`src/shared/K0Config.luau`의 엘프 기본 공격만 변경했다. `K0BowMotion`의 기존 절대 서버 시각 샘플링과 `CombatService`의 기존 DEX 환산이 같은 정의를 사용하므로 실제 화살 판정도 새 발사 시각으로 함께 이동한다. 첫 발의 선딜은0.34초 늘고 발사 후 손을 내리는 구간은0.34초 줄어든다. 화살/활/리그 원본·피해70%·사거리55·판정각45·공속 계수/상한·스킬은 유지한다. 원복은 해당 공격의 windup/recovery 두 값을 복원하면 된다.

## 검증

격리된 로컬 Roblox 엔진 Place에서 실제 모듈을 실행했다. [엔진 로그](native.log), [재현 입력 해시](source-manifest.json).

- `ELF_BASIC_TEMPO_NATIVE`: 12경우·861검사 통과. DEX0/100/200/316 ×30/60/144Hz. 실제 서버 시작/샘플링/피해 함수를 사용하고 영웅 신원만 대역으로 제공했다. 발사 전 피해0·서버 발사 시각과 nock 표시 일치·첫 도래 프레임 피해1회·반복 샘플 중복 없음·피해70·공격 주기 유지·주기 말 idle 복귀를 확인했다.
- `MIXAMO_ELF_NATIVE`: 986검사·32스킬 통과. R15 장전 곡선의 독립 Blender 기준값·공속2배·장전 취소·기존 스킬 모션 회귀.
- `K0_ELF_BOW_NATIVE`: 4,890검사 통과. R6/R15 소켓·시위/화살 정렬·발사 표시·FPS 독립성·다중 발사/이벤트 순서 회귀.
- `ELF_QUIVER_NATIVE`: 179검사 통과. 화살통과 장전 시각 회귀.
- `ELF_STRAIGHT_SHOT_NATIVE`: 554검사 통과. 선택 대상·방향 고정·중복 발사·이동 중 화살 직선 비행 회귀.
- 전체7,470검사 통과. Python 구문 검사와 `git diff --check` 통과.

```bash
python3 tools/prepare-elf-tempo-tests.py /tmp/tlt-elf-tempo-native
run-in-roblox --place /tmp/tlt-elf-tempo-native/tlt-k0-qa-empty.rbxlx --script /tmp/tlt-elf-tempo-native/source-probe.luau
```

기존 범용 `make_k0_source_probe.py`는 현재 `src/loading`을 처리하지 못해 준비 중 실패했다. 이를 변경하지 않고 모션용 자산 fixture를 재사용한 전용 준비 도구로 격리했다. 중간 재시도1회는 다른 작업의 실행 포트 점유로 시작하지 못했다([로그](retry-port-conflict.log)). 실행하지 못한 재시도를 검증 성공으로 포함하지 않는다.

## 미검증과 다음 담당

엔진 수치/포즈 검사와 실제 화면 감각의 수용은 다르다. 현재 사용 중인 Studio·게시 Experience는 수정하지 않았다. 게임 빌드·VERSION 증가·릴리스 태그·Roblox 게시를 수행하지 않았다. 실제 플레이어 입력/RemoteEvent 수송·게시 클라이언트·실기기·사용자 모션 감각 수용은 미검증이다. QA/사용자가 다음 통합 빌드에서 엘프로 단발/누른 채 연사·이동 사격·DEX0/공속2배를 비교한다. 부모 티켓/G4/G7은 완료 처리하지 않는다.
