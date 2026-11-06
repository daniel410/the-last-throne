# 무료 Creator Store 전투 효과음 적용

2026-11-05 · TLT-005/027/032/050/057/084 · ENG → QA · 0.76.0 · 로컬 구현/미게시

## 변경과 근거

사용자 요청으로 무료 Store 음원12개를 적용했다. [자산·출처](../../../assets/audio/combat-store-v1/README.md) · [비교 조사/판단](../../research/2026-11-05-combat-store-audio.md).

- `CombatAudioCatalog`: 기존 스킬 프레젠테이션을 사용해4클래스 기본기와128개 기술/궁극기의16분류·발동/접촉 음원을 연결한다. 도끼·방패·대지·지팡이 기본기는 해당 무기 접촉으로 구분한다.
- `K0CombatAudio`: `K0State/AttackStartedAt/AttackSeq`의 서버 승인 상태를 읽어 첫 접촉/속사·다단 발동 시점에 한 번씩 재생한다. 취소·사망 상태와 늦은 과거 발동은 재생하지 않는다. 기본 공격속도를 반영한다.
- `K0SwordVisual.renderCharacter`에 발동 관찰을 연결하고 `K0HitEffects.show`의 착지/물 기본 음원을 Store 명중음으로 교체한다. `BattleController`에서 비동기 프리로드한다. 별도 RemoteEvent/클라이언트 피해 판정은 추가하지 않는다.
- 공간 감쇠8~80stud·발동8/명중8·같은 음원/8stud 셀70ms 내 접촉 합치기·±2%피치·Ended/짧은 수명 정리를 적용한다. 명중음 발신 파트는 시각FX와 독립돼 시각FX 수명에 잘리지 않는다. 음원별 짧은 최대 수명은 긴 잔향을 제한한다.

## 검증

| 명령/조건 | 결과 |
| --- | --- |
| `python3 tools/assemble-combat-audio-test.py` → `run-in-roblox --place /tmp/tlt-audio-empty.rbxlx --script /tmp/tlt-combat-audio-native.luau` | 빈 로컬 Studio의 실제 소스 팩토리·실제 Instance 실행. **818검사 PASS**,128스킬/199발동,4클래스 기본기·공격속도·중복·취소/사망·늦은 발동·거리·NaN·층별음원상한·수명정리. [구조화 결과](native.json)/[원본 로그](native.log) |
| 동일 엔진검사, 실제12개 Sound를 로컬 Part에 연결해 `ContentProvider:PreloadAsync` |12/12 `Success`, `IsLoaded=true`, 길이0.37525~2.46221초. Volume0 디코딩 검사이며 실제 청취 아님 |
| `lua tests/pixelfx.spec.lua` |634 PASS. 스킬 분류/발동/취소/기존FX 회귀 |
| `lua tests/skill-effects.spec.lua` |11,978 PASS. 기존116개 확장 시전/발동·효과 기하/취소/예산 |
| `luau-compile` 변경 런타임5파일+fixture2파일 |PASS |
| `python3 -m py_compile tools/assemble-combat-audio-test.py`, `git diff --check` |PASS |

초기 run-in-roblox의 `--place` 생략은 도구 미구현 오류로 실패해 빈 로컬 Place를 명시해 재실행했다. 연결 목록의 이름 없는 Studio는 Place 미오픈이라 검색하지 못해 열린 TD Studio에서 **Store 읽기 검색/분리된 비부모 Sound의 fetch 검사만** 수행했다. TD 게임 트리/소스/저장/게시를 수정하지 않았다. 비부모 Sound는 fetch Success여도 IsLoaded=false여서 최종 근거는 별도 빈 로컬 Place의 위 디코딩 검사다. 원본 로그의203785492 타입 불일치 경고는 선택12개에 포함되지 않은 로컬 Studio 환경 경고이며12개 개별 로드는 모두 성공했다.

`tests/k0-hit-effects-native.luau`는 독립 발신 파트에서 새 명중음을 확인하도록 갱신했으나 전체 게임 통합 fixture 자체는 이번에 실행하지 않았다. 기존 사용자 Blender/검토 산출물은 변경/스테이징하지 않는다.

## 미검증·다음 담당

게시·릴리스 태그·라이브 DataStore 변경 없음. 실제 게임 입력→서버→네트워크→소리의 통합 플레이, RPG의 각 게시 테스트 Experience 권한, 실기기 성능/청취·4인+AI·음량/잔향 수용은 QA 후속이다. 인물 신음·적 패턴 음원·포션·배경음악은 이번 변경 범위 밖이다. 부모 티켓은 In Progress를 유지한다. 빌드 소스/해시/결과는 `build.json`에 후속 기록한다.
