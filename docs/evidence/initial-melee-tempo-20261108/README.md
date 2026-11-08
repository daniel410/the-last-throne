# 기사·드워프 초기 공속 조정

2026-11-08 · TLT-005/013/014/015/027/054/055/057/084 · ENG/ART → QA/DES · 0.86.5 · Studio 적용·미게시

사용자가 Diablo III 초기 무기와 비교한 뒤 기사 평균0.70초·드워프0.80초 안을 적용하도록 지시했다. [기존 조사](../../research/2026-11-08-attack-speed-dexterity-diablo-warcraft.md). 이 값은 우리 게임용 승인 조정값이며 Diablo의 모든 기술 속도를 그대로 이식한 수치가 아니다. 기존 사용자3D/장비 컨셉/삭제 파일을 보존했다. 부모 티켓의 실전 밸런스/기기/최종 미술 수용은 남는다.

## 적용

| 대상 | 이전 주기 | 현재 주기 | 현재 접촉 시각 | 현재 한 방 계수 |
| --- | --- | --- | --- | --- |
| 기사1타 | 0.42초 | **0.588초** | 0.224초 | 1.05 |
| 기사2타 | 0.46초 | **0.644초** | 0.252초 | 1.26 |
| 기사3타 | 0.62초 | **0.868초** | 0.364초 | 1.68 |
| 기사 평균 | 0.50초 | **0.70초** | — | — |
| 드워프 | 0.65초 | **0.80초** | 약0.41905초 | 약1.428571 |

기사는 세 타의 기존 리듬을 유지하면서 준비/active/회복·피해에1.4배를 적용했다. 드워프는 원래0.42초 저작 기준에0.80/0.42배를 적용해0.86.4의0.65초보다 다시 느려졌다. 기존 리타이밍이 서버 접촉과 실제 칼/도끼 경로를 같은 비율로 늘린다. 원본 Mixamo/Blender 저작·장비·소켓은 바꾸지 않았다.

같은 비율로 한 방 피해를 올려 이상적인 지속 기본 피해를 유지했다. 공격력100·정상 상태의 반올림 피해는 기사105/126/168, 드워프143이다. 기사 총399/2.1초=190DPS이며 드워프143/0.8초=178.75DPS다. 초기 접촉/막타/폭딜·카운터/적중 효과·방어/회피 빈도까지 같다는 뜻은 아니다.

민첩 투자당 기본 공속+0.5%/최대100%, 이속+0.1%/최대30%와 투자분 기준 계산은 유지했다. 최대 배율에서는 기사 평균0.35초·드워프0.40초다. 기사 자세 피해12/14/24·드워프12/타격은 유지하므로 초당 자세 피해는 줄어든다. 사거리/각/표적 수, 스킬 피해/쿨다운/MP와 이동·성장·저장을 변경하지 않았다.

## 스킬 재사용 경로 분리

기사 고급 스킬은 기본 공격 곡선을 자체 기술 시각으로 다시 재생한다. 기본 주기를 늘리면 기존 팔로스루의 절대0.10초 상한만 남아 일부 연속 기술의 궤적이 달라질 수 있었다. `AdvancedSkillMotion`에서 이 소스 시각 상한에도 저작 시간 대비 기본 주기 배율을 적용해 기술의 기존 동작을 유지했다. 기술 자체를 느리게 만들거나 쿨다운/피해를 변경하지 않는다. 방패 강타의 bracing도 기존 정규화 경로를 유지한다.

## 검증

[정본 결과](results.json)·[입력 해시](test-inputs.json). **18묶음·283,209 native 검사 통과**. 검사 수는 원시 JSON 합과 별도 문자열 투척460검사를 합산했다. 정적 검사와 실제 기기 수용을 구분한다.

- [모션/스킬 통합](motion-native.log): 기본기의 새 시간 매핑과 Blender 독립 평가를 비교하고, R6/R15·도끼날/팜·검/방패 간섭·연격/취소·2배 공속·종료 손/손목/무기 복귀·엘프/화살통 회귀를 확인했다.
- 새 `MELEE_SKILL_TEMPO_ISOLATION_NATIVE`는 고정0.86.4 소스 커밋 `0814db02429275d093f2b9770ad8dcab5ee059f8`의 Config/AdvancedMotion을 테스트 복제 폴더에서 사용한다. 클래스별32스킬 정의와 두 리그·81시점의 실제 동작을 현재와 대조했다. 유효 포즈10,206개, 관절 각도 차이 최대0도, 방패 CFrame 원소 허용오차0.00002 이내. 기본 속도 변경이 스킬 속도 변경으로 번지지 않음을157,682검사했다. inverse 곱의 부동소수점 오차를 회전 차이로 오인하지 않도록 방패는 원래 행렬 원소를 직접 비교한다.
- [실제 서버 템포/피해](server-tempo-native.log): 기사3타+드워프1타 ×DEX0/40/100/200/300/316 ×30/60/144Hz ×공격력100/337/969의216경우·10,993검사. 실제 `startAttack/processCombatSamples/acceptAction/stepPlayer`에서 늦어진 접촉 전 피해0, 도래 프레임의1회 피해, 중복 방지, 새 주기 전 재공격 금지, 연격1→2→3→1/드워프 반복, 버퍼, DEX와 자세 피해 보존을 확인했다. 신원만 trusted context mock이며 피해/판정/이동 함수는 원문이다. 실제 플레이어/RemoteEvent 수송 검사는 아니다.
- [변경 직전0.86.4와 피해 비교](damage-comparison.json): 실제 새 서버 HP 감소량에 같은 정상 상태의 이전 공식/반올림을 대조했다.216표본에서 지속 기본 DPS 최대 차이는약0.18860%로1% 이내다. 모든 적/조건부 효과·실제 처치시간이 동일하다는 결과가 아니다.
- [기존 서버 선택14경우](selected-basics-native.log): 기사6개/드워프2개 사거리 경우·선택 표적 회전/공격·드워프 접촉/중복·버퍼/벽/늦은 표본의57검사. 전체 구형 K0 서버 시험을 통과했다고 보고하지 않는다. 선택 필터와 전체 현재 소스의 격리 Place는 `tools/prepare-dwarf-tempo-tests.py`로 재현한다. 도구/기존 테스트 파일의 dwarf 이름은 시작 당시 이름이며 현재 두 클래스를 검사한다.

```sh
python3 tools/prepare-mixamo-dwarf-tests.py /tmp/tlt-initial-tempo-motion
run-in-roblox --place /tmp/tlt-initial-tempo-motion/tlt-k0-qa-empty.rbxlx --script /tmp/tlt-initial-tempo-motion/source-probe.luau
python3 tools/prepare-dwarf-tempo-tests.py /tmp/tlt-initial-tempo-server
run-in-roblox --place /tmp/tlt-initial-tempo-server/tlt-dwarf-tempo-empty.rbxlx --script tests/dwarf-basic-tempo-native.luau
run-in-roblox --place /tmp/tlt-initial-tempo-server/tlt-dwarf-tempo-empty.rbxlx --script /tmp/tlt-initial-tempo-server/server-probe.luau
```

run-in-roblox의 같은 로컬 포트를 동시에 사용하면 연결 실패하므로 위 엔진 명령은 순서대로 실행한다. 최종 로그는 단독 재실행의 성공 결과다. 스킬 baseline 소스는 긴 문자열로 주입해 JSON Unicode 이스케이프를 Luau 코드로 오인하지 않는다. 기존203785492 자산 유형 경고는 assertion 결과와 구분한다.

실제 PC/터치/패드 조작·길게 누르기의 입력 주기/네트워크·여러 체형/최종 스킨·적 처치시간/자세 붕괴/기술 혼합·4인+AI·사용자 무게감 수용은 미검증이다. 다음 담당 QA/DES는 느려진 첫 타격과 커진 한 방, 후기DEX의 실제 연속 입력을 확인한다.

## Studio·복구

실제 TLT Place70829337938054의 Edit에서 기존 원문 정확 비교 후 Config/AdvancedMotion 두 소스를 적용하고 새 원문 일치와 복제 Config require로0.588/0.644/0.868·평균0.70·드워프0.80초 및 피해 계수를 확인했다. [Studio 기록](studio-source-readback.json). 글로벌 require 캐시는 새 설정 검증에 사용하지 않았다. TD Studio/운영 코드는 변경하지 않았다.

직전0.86.4로 복구할 때 이 작업의 Config/AdvancedMotion만 역적용한다. 드워프 종료 자세 수정과 기존 민첩/저장 데이터는 유지한다. 연구 산술은 작성 당시 기준으로 보존하며 현재 값은 Config와 이 기록을 따른다. 일반 빌드이며 Roblox 게시/릴리스 태그는 수행하지 않는다.

## 고정 빌드·마감

`0.86.5`의 소스 커밋은 `b7e67eeb70a2f14b598d28563c78950e10923a6b`다. `python3 tools/build-game.py --source b7e67eeb --record docs/evidence/initial-melee-tempo-20261108/build.json`으로 `builds/0.86.5/TheLastThrone-0.86.5.rbxlx` 단일 빌드에 성공했다. SHA256은 `a55f5dfbae63ede0d25401c37dfd26f467b92869bcb73573cab4a63246ea9fe5`다. [빌드/LFS 입력 기록](build.json).

동일 파일에 `run-in-roblox --place builds/0.86.5/TheLastThrone-0.86.5.rbxlx --script /tmp/tlt-initial-tempo-pinned.luau`를 실행해18묶음·**283,209검사 재통과**했다. pinned 스크립트는 위 모션/스킬 대조+현재 커밋의 서버 템포+기존 서버14경우를 순서대로 연결한다. 런타임 모듈을 바꾸지 않았고 private API/기준 버전은 테스트 복제 모듈에만 넣었다. [정본 결과](pinned-results.json)·[원시 로그](pinned-native.log).

소스 커밋의 origin/main 푸시 성공을 확인했다. 새 LFS 자산은 없고 빌드 입력은 도구가 검증했다. 공유 작업공간의 별도 미커밋 전투 효과 작업은 이 빌드에 넣지 않았다. 일반 빌드이며 Roblox 게시/릴리스 태그는 수행하지 않았다.
