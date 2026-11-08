# Skills 최대 Lv9 · 0.81.4

2026-11-07 · TLT-027/028/052/057/084 · ENG/QA · 로컬 구현·Studio 소스 적용 / 미게시.

사용자 요청을 스킬 최대 레벨9로 해석해 Lv4 상한을 확장했다. `HeroProgression.maxSkillLevel=9`, 저장 숙련은0~8이며 기본 Lv1에서1SP마다1레벨이다. 기존 투자·총79SP·해금/전직·계수/효과 공식·장착은 보존한다. Skills 분모/강화 버튼/최대 안내와 오류도 공통 상한을 사용한다. [비교 조사](../../research/2026-11-07-skill-level9.md).

## 검증

- `lua tests/hero-progression.spec.lua`: **3711 PASS**. 네 클래스/8계열 학습 가능 기술 Lv9·초과/위조 거부·SP 부족·복사/로드 검증·실제 계정 규칙/AccountStore 메모리 어댑터의 저장 응답 유실/동일 영수증 복구를 포함한다.
- `lua tests/advanced-skills.spec.lua`: **1435 PASS**.
- `lua tests/skill-stat-preview.spec.lua`: **1392 PASS**.
- TLT Studio `70829337938054` Edit에3개 소스 적용. Luau3개 문법·Lv9/SP 경계 실행 통과. `HeroProgression`/`HeroSkillTree`는 기존 HEAD 일치 확인. `HeroGrowthGui`는 기존 Studio 전용 레이아웃 차이를 발견하여 오류 문구만 수정해 보존했다. 백업 `ServerStorage.TLTBeforeSkillLevel920261107`.
- `git diff --check`: PASS. 기존 사용자 월드/자산 미커밋 변경은 작업에 포함하지 않는다.

## 호환·인계

스키마3의 기존0~3 투자는 그대로 읽고0~8로 허용 범위를 넓힌다. 구버전 서버는4 이상 숙련을 거부하므로 실제 배포 때 로비/배틀을 함께 갱신해야 하며, 높은 숙련 데이터를 구버전으로 롤백하면 로드 거부된다. 데이터를 낮추거나 신규 프로필로 덮어쓰지 않는다.

실제 DataStore·재접속·정상 UI 조작·실기기/다인·높은 숙련의 최종 전투 밸런스는 미검증이다. 다음 QA는 Lv4 보유 영웅의 기존 투자 유지 및1SP씩 Lv9까지 강화/버튼 비활성을 확인한다. 부모 티켓 In Progress 유지. 게시/릴리스 태그 없음.

고정 소스 빌드는 구현 커밋 후 `python3 tools/build-game.py --source HEAD --record docs/evidence/skill-level9-20261107/build.json`으로 기록한다.

빌드 번호 충돌: 작업 중 다른 변경의0.81.3 빌드가 존재하여 첫 빌드 명령은 덮어쓰기 방지로 종료1. 산출물은 변경하지 않았고 새 번호0.81.4로 고정한다.
