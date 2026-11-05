# DEX 속도 상한 상향

2026-11-04 · TLT-015/027/050/052/084 · ENG → QA · 로컬 수정·미게시.

사용자 후속 요청으로 네 영웅의 DEX 기본 공격속도 상한을+50%→+80%(1.8배), 이동속도 상한을+20%→+40%(1.4배)로 수정했다. 포인트당 공속0.5%·이속0.1%와 나머지 스탯/저장/판정/스킬 쿨다운 계약은 유지한다. +100%가 기본속도의2배이며, +80%는 동작 시간이 기존의1/1.8이다.

현재 합법 투자 예산316P에서 공속 상한은160P에 도달한다. 이속은400P에 상한에 도달하므로 현행 최대316P에서는+31.6%다. 테스트는316P의 실제 결과와 예산을 넘는 합성400P의 계산 상한을 구분한다. 투자 계수나316P 예산을 임의로 높이지 않았다. 영어 스탯 안내와 현재 상세 사양/결정표도 갱신했다. 이전 [첫 적용 증거](hero-stat-effects-20261104/README.md)의50%/20%는 당시 검사값이다.

검증:

- `lua tests/hero-stat-effects.spec.lua`:528 PASS. 네 영웅·레벨 경계·독립 효과·새 상한·316P 실제 결과·원본 정의 보존.
- `lua tests/skill-stat-preview.spec.lua`:1,392 PASS. 피해·숙련·장비·미리보기 회귀.
- `python3 tests/prepare-hero-stat-probe.py --output-dir /tmp/tlt-stat-cap-probe` 후 `run-in-roblox --place /tmp/tlt-stat-cap-probe/tlt-k0-qa-empty.rbxlx --script /tmp/tlt-stat-cap-probe/source-probe.luau`:106 PASS. 미게시 PlaceId0·합성 상태/실제 Humanoid에서1.8배 기본 공격 판정/포즈 일치,1.4배 이동/스프린트/공격·방어 이동 및 정상/초과 이동 검증.
- `git diff --cached --check`:PASS.

기존 미커밋 작업은 보존하고 이번 변경 파일만 선별한다. 게임 빌드·버전 생성·태그·게시는 하지 않았다. 실제 Player 입력/네트워크/기기/다인·UI 화면·밸런스 수용은 미검증이다. 다음 QA/PLAN은 높은 공속의 입력 감각·처치 시간 및 이동속도에 따른 맵/적 추적 밸런스를 확인한다. 부모 티켓은 완료 처리하지 않는다.
