# 방향성 어깨 구르기 회피

2026-11-03 · TLT-005/028/032/033/084 · 로컬 구현·미게시 · ENG/3D → QA

사용자 지정 영상과 다른 RPG 비교 요청에 따라 `K0SideDiveMotion`의 기존 옆으로 길게 눕는 회전을 방향성 어깨 구르기로 교체했다. 선택한 좌우로 몸을 돌림 → 낮게 접어 한 바퀴 → 후반에 펴고 정면 복귀다. 네 클래스가 기존 `K0SwordVisual` 연결을 그대로 사용한다. [조사·근거·한계](../../research/2026-11-03-side-shoulder-roll.md).

이번 변경은 모션 모듈·두 native 검사·이 증거/조사만 포함한다. 기존 미커밋 `K0SwordVisual`/드워프 공격/DodgeRules/맵/이동 작업은 보존하고 커밋에 포함하지 않는다. QA fixture의 Visual과 MeleeMotion은 HEAD 소스로 격리했고 변경 모션은 작업 소스를 사용했다. 전체 게임 빌드 대신 모듈 QA Place를 사용하므로 VERSION0.68.1·릴리스 태그·게시 상태는 변경하지 않았다.

검증:

- `rojo build /tmp/tlt-shoulder-roll-qa.project.json -o /tmp/tlt-shoulder-roll-qa.rbxlx`: 성공. 게임 시작 스크립트 없는 격리 모형.
- `run-in-roblox --place /tmp/tlt-shoulder-roll-qa.rbxlx --script tests/side-breakfall-native.luau`: **12,576 PASS**. R6/R15×4클래스×좌우×30/60/144Hz. 낮은 자세·이동 방향의 회전 평면·관절 연속성·접힌 무릎/엉덩이·중간 역전 자세·음수 시각/종료/Idle 복귀·물리 루트 불변. [로그](pose-native.log).
- 같은 Place + `tests/dodge-double-tap-native.luau`: **11,544 PASS**. 실제 서버 승인/중복 입력·거리/이동·벽/낭떠러지·무적 만료·스킬 중단·사망 제한·native 전신 관절. [로그](combat-native.log). 첫 실행은 이전 모션 전용인 “몸 길이 축이 수평” 기대값에서 실패했다. 새 방향성 구르기 기대값으로 교정한 뒤 전부 재실행했다.
- `lua tests/k0-rules.spec.lua`: **125 PASS**.
- `lua tests/skill-action-interrupt.spec.lua`: 기존 클라이언트 함수 구간을 추출하는127행에서 실패(`extract`19행). 이번 작업은 해당 클라이언트/서버 입력 소스를 변경하지 않았다. 스킬 중단의 native 서버 검증은 위에서 통과했으며 Lua 전체 검사는 통과로 보고하지 않는다.
- `git diff --check`: PASS.
- 기존 `rbxassetid://203785492` 자산 유형 경고가 남는다. 검사 실패와 구분한다.

[자세 비교](pose-review.png)는 실제 native FK [표본](poses.json)을 Blender의 몸체 박스로 시각화했다. 상단R6/하단R15·0/16/32/45/64/82/100%다. 지면을 기준으로 보는 하단R15에서 접기/회전/일어서기 흐름을 검토했다. 게임 캐릭터의 TD 외형/장비나 실제 플레이 화면을 대신하지 않는다.

열린 Studio의 진행 중 세션·소스는 덮어쓰지 않았다. 다음 QA/사용자 Play에서 실제 키보드/패드/터치 좌우·경사·단차·장착 무기 접촉·연속 회피·다인/실기기 성능·최종 미술을 확인해야 한다. 상위 티켓은 수용 완료로 변경하지 않는다.
