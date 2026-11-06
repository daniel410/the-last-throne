# 나이트 기본 공격·마법사 스킬 효과음 복구

2026-11-06 · TLT-005/027/032/050/057/084 · ENG → QA · 0.78.3 · 로컬 수정/미게시

사용자가 나이트 기본 공격의 금속 충돌음과 마법사 스킬음을 이전으로 돌리도록 요청했다. `git show 88230ce^:src/client/K0HitEffects.luau`에서0.76.0 이전의 실제 설정을 확인하고 복구했다. 새 음원 조사/선정이 아닌 사용자 지정 회귀 수정이다.

- 나이트 **기본 공격만**: `rbxasset://sounds/action_jump_land.mp3`, 음량0.15·속도1.35·감쇠8~70stud. 새 휘두르기 발동음은 제거하고 피해 확정 시 기존 명중음만 재생한다. 기사 스킬은 이번 복구 대상이 아니다.
- 마법사 **32개 스킬/궁극기**: `rbxasset://sounds/impact_water.mp3`, 음량0.12·속도1.25·감쇠8~70stud. 새 원소/시전 발동음을 제거하고 기존 공통 명중음으로 복구한다. 피해가 없는 스킬은 이전처럼 명중음을 내지 않는다. 마법사 기본 공격은 유지한다.
- `CombatAudioCatalog.get`에서 해당 범위만 우선 처리하고 `K0CombatAudio`가 복구 프로필의 고정 피치/감쇠를 적용한다. 다른 영웅/스킬·포션·음원 제한/정리·피해/MP/쿨다운/진행/저장은 유지한다.

## 검증

| 명령/조건 | 결과 |
| --- | --- |
| `python3 tools/assemble-combat-audio-test.py` → `run-in-roblox --place /tmp/tlt-audio-empty.rbxlx --script /tmp/tlt-combat-audio-native.luau` | 별도 빈 로컬 Studio에서 **824개 PASS**.128개 기술·199발동의 복구 대상 무음/비대상 발동·기본기·속도·중복·취소/사망·소리 상한/정리, 실제 Sound의 복구ID/음량/고정속도/70stud 확인. [결과](native.json) |
| 동일 fixture의 기존 Store12개 디코딩 회귀 |12/12 Success·IsLoaded=true·양수 길이. 선택 목록 외203785492 타입 경고가 이전과 동일하게 발생했으나 검사에는 영향 없음 |
| `lua tests/pixelfx.spec.lua` |634개 PASS |
| `luau-compile` 런타임2파일/fixture1파일 |PASS |
| `git diff --check` |PASS |

테스트는 개별 엔진 재생 설정·발동/명중 경로 확인이며 실제 전투 청취/사용자 수용은 아니다. 기존 사용자의 Blender 미커밋 파일은 보존했다. 게시·태그·TD 수정 없음. 다음 QA는 나이트 기본 명중과 Mage 기본/공통/전직/궁극기, 방패 기술·물약의 보존 여부를 실제 게임에서 청취한다. 부모 티켓 상태는 유지한다. 단일 빌드0.78.3 성공. 소스 `901348cf37d4e4a4c1dba25c69747ec69b049b56`, SHA-256 `14f4eeed213620c256b8b088740ce3facd5654bd315e22f4bce9770ad014de88`, 13,286,454bytes. [빌드 기록](build.json). 산출물 XML에서 복구2분기·고정피치·기존 포션ID 보존을 확인했다. 소스 커밋 origin/main 푸시 성공.
