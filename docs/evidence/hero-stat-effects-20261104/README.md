# 네 영웅 스탯 적용 수정·검토

2026-11-04 · TLT-015/027/028/050/052/084 · ENG / 로컬 구현·검증, 미게시.

사용자는 엘프의 STR 공격력·DEX 공속/이속·VIT HP·INT MP 적용을 수정하고 다른 영웅도 검토하도록 요청했다. [변경 근거·비교 조사](../../research/2026-11-04-stat-effects.md).

## 변경과 검토 결과

| 영웅 | 물리 피해 | 마법 피해·MP | DEX |
| --- | --- | --- | --- |
| Knight | 기존 STR 유지, Paladin의 현행 물리 기술 포함 | 기존 MP 없음 유지 | 기본 공격속도·이동속도 연결 |
| Dwarf | 기존 STR 유지, Gunner 총/폭탄/포격 포함 | 기존 MP 없음 유지 | 동일 |
| Elf | 물리 활·물리 기술 DEX→STR | 기존 INT 마법 피해, Magic Archer 첫 전직 이후 MP 유지 | 피해 증가를 제거하고 속도로 연결 |
| Mage | 물리 power 계산 STR, 실제 기본 지팡이·주문은 기존 INT 마법 power 참조 | INT 마법 피해·MP 유지 | 기본 지팡이 공격속도·이동속도 연결 |

공통 투자당 STR 물리+2, INT 마법+2/해금된 MP+3, VIT HP+10·4당 방어+1. DEX 시험값: 기본 공격속도+0.5%(최대50%), 이동속도+0.1%(최대20%). 표시용 초기 스탯은 재합산하지 않는다.316/79 예산·저장 배분·영수증/재시도·전직·레벨업 규칙은 유지한다. 기존 엘프 DEX 집중 배분의 한 발 피해는 감소하고 속도 이득을 받는다. 저장 포인트의 자동 이관·환불·리셋은 하지 않았다.

서버는 기본 공격 정의 사본의 준비/활성/회복/타격 지연을 같은 비율로 단축한다. 확정한 공격속도를 행동 시작에 복제하고 클라이언트 활/검/도끼/지팡이 포즈와 PixelFX 방출 시간도 같은 비율로 평가한다. 행동 도중 성장 갱신이 와도 시작 때의 공격속도를 유지한다. 서버 이동속도/스프린트 시작·종료/만료/공격·방어 중 이동/확정 투자 갱신/이동 허용 예산에 이동 배율을 적용한다. 회피 거리/시간/무적·방어 판정창·스킬 시전/다단 간격/쿨다운은 그대로다. 스탯 안내와 피해 참조 툴팁을 갱신하고 전투 능력치 미리보기에 기본 공속·이속 배율을 추가했다. UI 원본 프레임/버튼/아이콘은 기존 것을 사용한다.

## 검증

| 명령·조건 | 결과 |
| --- | --- |
| `lua tests/hero-stat-effects.spec.lua` |524 PASS: 네 영웅×Lv2/20/40/60/80×독립 스탯, 자원 자격, 상한, 원본 보존 |
| `lua tests/hero-progression.spec.lua` |656 PASS: 성장·포인트·저장 재시도 회귀 |
| `lua tests/skill-stat-preview.spec.lua` |1,392 PASS: 모든 클래스/계열 기술의 피해 참조·숙련·장비·미리보기 |
| `lua tests/advanced-skills.spec.lua` |1,435 PASS: 전직·스킬·MP 해금 |
| `lua tests/equipment-impact.spec.lua` |44 PASS |
| `lua tests/k0-rules.spec.lua` |125 PASS |
| `lua tests/auto-target.spec.lua` |215 PASS |
| `lua tests/pixelfx.spec.lua` |634 PASS: 효과 데이터·재생 규칙, 엔진 렌더 검증 아님 |
| `python3 tests/prepare-hero-stat-probe.py --output-dir /tmp/tlt-stat-probe` 후 `run-in-roblox --place /tmp/tlt-stat-probe/tlt-k0-qa-empty.rbxlx --script /tmp/tlt-stat-probe/source-probe.luau` |106 PASS: 실제 서버 startAttack/setPlayerState/checkMovement와 native Humanoid, 네 영웅 기본속도·최대공속 포즈 일치, 정상 이동/초과 이동 차단 |
| `git diff --cached --check` |PASS |

엔진 검사는 미게시 PlaceId0·합성 플레이어 상태·실제 Humanoid/벡터/포즈 계산이다. 서버 원본의 마지막 return만 교체해 내부 진입점을 호출했다. 기존 source-probe는 src/loading 경로와 200KB 초과 적 모션3개 때문에 준비/Source 주입이 실패했으며, 이번 전용 준비기로 비관련 경로/대형 적 클립만 제외해 해결했다. 검증한 전투/영웅 모션 원본은 대체하지 않았다. 최종 검사에서 기존 미커밋 드워프 모션 변경은 인덱스의 이번 커밋 후보 소스로 교체해 분리 검증했다. `results.json`은 해당 후보 소스 해시를 남긴다. 테스트 중 기존 공통 자산 `203785492`의 asset type 경고가 있었으며 스탯 검사는 통과했다. 자산 렌더 수용으로 해석하지 않는다.

## 미검증·다음 담당

게임 빌드/버전 예약·태그·Roblox 게시는 수행하지 않았다. 실제 Player 입력·네트워크 지연·다인/AI·실계정 재접속·터치/패드·추가된 능력치 행의 실제 화면/스크롤·실기기 성능·밸런스/사용자 수용은 미검증이다. 다음 QA/PLAN: 같은 레벨·장비·총 예산에서 STR/DEX/혼합의 한 발 피해·60초 DPS·이동/공격 감각을 비교하고 시험 계수/상한을 수용한다. 부모 티켓은 완료 처리하지 않는다.
