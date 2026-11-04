# 네 클래스 옆 낙법 구르기

2026-11-03 · TLT-005/028/032/033/084 · ENG/3D → QA · 로컬 구현, 미게시

최신 사용자 요청은 기사·드워프에 이어 마법사·엘프까지 포함한다. 네 클래스 모두 양손을 선택한 옆 방향으로 뻗고 몸을 수평으로 던진 뒤, 지면 가까이에서 어깨·등을 한 바퀴 굴리고 일어난다. 두 발이 머리 위로 올라가는 기존 수레바퀴 회전은 사용하지 않는다.

`K0SideDiveMotion`이 서버 승인 시각을 샘플링한다. 행동 전반26%에서 몸을 수평으로 낮추고36~82%에서 몸의 길이 축으로1회 회전,84~100%에서 일어난다. 접촉 시 팔꿈치·무릎을 접는다. 루트 관절의 시각 높이는 주로 -1.15스터드이며 물리 루트·피격 위치·서버 이동은 유지한다. R6/R15 어깨 축을 보정하고 엘프의 이전 활 당김 IK를 회피 진입 시 끈다. 기존 Backstep·더블탭0.30초·좌우 선택·옆 이동14스터드/0.55초·행동0.65초·무적0.08~0.28초와 자원/쿨다운 계약은 변경하지 않는다.

[기존 조사](../../research/2026-11-02-dodge-double-tap.md)의 입력/서버 권위 원칙을 재사용한다. 이번은 사용자 지시의 회전축·자세 결함 수정이며 타 게임의 애니메이션을 복제하지 않았다. [함께 갱신한 조사](../../research/2026-11-03-epic-map-and-breakfall.md)를 참조한다.

검증은 실제 Roblox 엔진의 격리 모듈 QA Place에서 수행했다. `K0SwordVisual`은 기존 미커밋 도끼/R6 공격 변경을 제외한 이번 커밋 대상 소스를 사용했다. 모듈 시험 모형이므로 배포 빌드/VERSION 증가·릴리스·게시를 수행하지 않는다.

- `rojo build /tmp/tlt-side-breakfall-qa.project.json -o /tmp/tlt-side-breakfall-qa-v4.rbxlx`
- `run-in-roblox --place /tmp/tlt-side-breakfall-qa-v4.rbxlx --script tests/side-breakfall-native.luau`: **13,600 PASS**. R6/R15×4클래스×좌우×30/60/144Hz, 양손 같은 방향 뻗기·회전 중 몸 길이 축 수평/발이 뒤따름·낮은 자세·연속성·1회전·착지/Idle 복귀·물리 루트 불변. [로그](pose-native.log).
- 같은 Place + `tests/dodge-double-tap-native.luau`: **11,544 PASS**. 실제 서버 함수의 더블탭·거리/속도·벽/낭떠러지·무적·스킬 중단·행동/사망 제한과 전신 관절. [로그](combat-native.log).
- `lua tests/skill-action-interrupt.spec.lua`: **1,221 PASS**. `lua tests/k0-rules.spec.lua`: **125 PASS**. `git diff --check`: PASS.
- 기존 `rbxassetid://203785492` 자산 유형 경고는 회피 검사와 별개다. 초기 QA 준비 중 누락된 미커밋 공격 모듈 의존성을 발견해 QA의 공격 모듈을 HEAD로 격리했다. 또한 `PivotTo`와 물리 루트 위치를 혼동한 검사 기준을 실제 시작 루트 CFrame으로 교정했다. 최종 검증은 위 성공 로그다.

`tlt-epic-art-candidate.rbxlx` / Battle / PlaceId0의 Edit 모듈에 적용 전 문맥을 대조해 관련5모듈(지도 포함)을 반영했고 Source 재읽기로 일치 여부를 확인했다. 다른 공격 소스 변경을 덮어쓰지 않았다. 로비는 현재 Play 세션으로 교체되어 실행을 중단하지 않았으며, 소스 저장소에는 동일 코드가 연결돼 있다. 실제 키보드/패드/터치 입력·장착 무기의 지면 접촉·경사/단차·실기기/다인 성능·최종 모션 미술 수용은 미검증이다. QA가 다음 Play에서 네 클래스 좌우 회피를 확인한다. 상위 티켓은 수용 완료로 변경하지 않는다.
