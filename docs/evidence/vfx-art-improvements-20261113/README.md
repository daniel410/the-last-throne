# VFX 아트 리뷰 우선·후속 개선

TLT-033/054/055/056/057/084 · 2026-11-13 · 사용자 지시: “우선, 후속 모두 개선해줘”. [이전 전체 리뷰](../vfx-art-review-20261113/README.md)의23개 발견을 대상으로 구현·화면·남은 수용을 나눠 기록한다.

**수정 가능한22개 항목의 구현을 반영했다. 실제 지역·다인·실기기·사용자 수용을 요구한 ART-COMMON-08은 증거를 보완하되 완료로 닫지 않는다.** 서버 스킬 정의·피해·보상·소유·범위·TD 운영은 변경하지 않았다. 참고 원칙은 [Diablo/WoW 우선·Roblox 보완 조사](../../research/2026-11-13-vfx-art-followthrough.md)에 기록했다.

## 고정 소스와 빌드

- 최종 소스 `c1b578d470a26536bd1a22895f265b91d3c16669`, 빌드 **0.104.28**. 최초 구현 `7a80c50d`/0.104.26의 화면을 ART가 재검토한 뒤 뿌리·궁극기 초점·방어 불가 표식·단독 Heal을 추가 보정했다. 최초 증거는 `initial-*`/기존 장면 폴더로 보존한다. 별도0.104.27 변경은 최종 소스에 포함되지만 최초26의 결과에 소급하지 않는다.
- `tools/prepare-vfx-art-improvements.py --source c1b578d4 --output /tmp/tlt-vfx-art-final-tests`로 커밋에서 QA 장소를 재구성했다. PlaceId/GameId0·플레이어0을 검사하고 모든 게임 BaseScript를 비활성화한 후 시각 모듈만 호출했다.
- `python3 tools/build-game.py --source c1b578d4 --record docs/evidence/vfx-art-improvements-20261113/build.json`: 성공. 생성된 XML의 변경 생산 모듈15개가 커밋 원문과 일치했다. [빌드·SHA](build.json), [검증 집계](validation.json), [고정 입력 해시](inputs.json), [출처](provenance.json).
- 게시·릴리스 태그 없음. 별도 사용자 작업의 미커밋 장비/동작 변경을 보존했다.

## 반영 범위

| 담당 | 주요 변화 | 대응·상세 |
| --- | --- | --- |
| 영웅 | 전방 의미, 산탄/포탄, 뿌리·증기·화염·용암, 궁극기8개 고유 초점, 물리 접촉/검기 면 | [HV-A01~08·HV-S01·HV-L01](hero-implementation.md) |
| 공통 |128기술의 준비/시전/접촉 공통 팔레트, 국소 명중광·겹침 감소, 상승 Heal/외향 Cleanse, 월드 깊이 길안내 | [공통8항목과 지원 구현](common-implementation.md) |
| 몬스터 | 방어 불가 비색상 단서, 불5종 위계, 눈/모래 형상 분리, 고리 위험띠·속성별 접촉 | [EN-ART-01~05](enemy-implementation.md) |

개별 상태 정본은 [requirements.json](requirements.json)이다. 구현 완료와 실제 미술 수용 완료는 다른 상태다. 기존 리뷰에서 유지 후보였던 효과를 일괄 교체하지 않았다. 비활성 web 보스 분기는 새 활성 콘텐츠로 만들지 않았다.

## 검사 결과

- **Studio 격리 엔진17묶음·95,423항목 PASS.** 신규 팔레트562/영웅2,225/적15,916/지원127, 기존 속성·흐름·예산·정리·128기술·50종146공격 회귀 포함. [native.log](native.log).
- **길안내 회귀 PASS.** 월드 가림·거리·직접 방향·고저차·스트리밍 바닥 fallback·설정·훈련/사망. [nav.log](nav.log).
- **CPU16,456항목 PASS.** PixelFX634 + SkillEffects15,822. [cpu.log](cpu.log). 렌더·GPU·기기 성능 검사가 아니다.
- Lua update P95는 격리 PC 측정이며 GPU/모바일 프레임 성능을 의미하지 않는다.

## 화면과 담당 ART 재검토

구현을 맡은 ART 담당3명이 해당 후이미지를 재검토한다. 본인 구현에 대한 담당 검토이며 독립 QA·사용자 수용을 뜻하지 않는다.

동일한 이전 검토 fixture를 사용하되 실제 히트 수를 임의로3개 만들지 않았다. 최초26에서 Hero 첫 박자35장·마지막 반복 박자13장, 공통31장, 예고12장, 적60/위험띠12/접촉20장, 실제 자산 문맥6장을 기록했다. 최종28에서 영웅11첫/9후속·예고12·지원4·실제 자산 문맥6장을 재촬영해 **총231장**을 확보했다. 최초26 화면에서 발견한 가시성 문제는 보류하고28에서 수정했다. 샘플 시각의 도형을 즉시 clone하고 입자를 다시 방출/정지한 정지화면이며 전체 시간 흐름·첫 로드 수용을 대신하지 않는다. 각 manifest에는 개별 PNG 해시가 있다.

- [영웅 첫 박자](hero/manifest.json) / [후속 박자](hero-last/manifest.json) / [공통](common/manifest.json) / [예고](warnings/manifest.json).
- 최종28: [영웅11첫](hero-final/manifest.json) / [9후속](hero-final-last/manifest.json) / [예고12](warnings-final/manifest.json) / [지원4](support-final/manifest.json) / [실제 자산6](support-context-final/manifest.json). [최종 캡처 출처·해시](final-capture-runs.json) / [최초 캡처 출처·해시](initial-capture-runs.json).
- [비교 페이지 목록·해시](comparisons.json). `make-comparisons.py`로 동일 ID의 이전/이후 PNG를 나란히 생성한다. 미술 비교이며 픽셀 회귀 임계치 검사가 아니다.
- 적 triptych의 접촉 위치는 모형 앞면으로 교정했다. 이전 triptych의 가려진 접촉을 개선 전의 효과 결함으로 해석하지 않는다. 접촉 비교는 별도 근접 장면을 사용한다.

최종 검증 재현: `python3 docs/evidence/vfx-art-improvements-20261113/verify-build.py --source c1b578d4 --version 0.104.28 --native docs/evidence/vfx-art-improvements-20261113/native.log --output /tmp/vfx-validation.json`.

실제 Selene 모델·Traveler 무기/방어구4슬롯을 착용한 stock R15로 Deepwood/HauntedGraveyard 조명×지원3종의6장면을 추가했다. 원본 장비와 연결선 양 끝을 같은 clone으로 보존했다. [최초 실제 자산 장면](support-context/manifest.json)·[슬롯/로드/합성 상태](support-context/state.json). 이는 실제 지역 맵이 아닌 합성 무대이며, 최초 로딩 오류 메시지가 있었으나 최종 preload callback은 모두 Success였다. 보호 atlas의 특정 정지 샘플에서 `loaded=false`인 것은 이 캡처만으로 최초 로드 실패/성공을 단정하지 않는다.

담당 ART 재검토: [영웅](hero-after-review.md) / [몬스터](enemy-after-review.md) / [공통·지원](common-after-review.md). 최초26에서 뿌리/궁극기 초점·방어 불가 단서·단독 Heal의 가시성을 보류한 기록을 남기고 최종28 장면을 추가 판정했다. 뿌리 대비·DawnBlade 겹침, 암석/용암/냉기 초점, 예고의 이중 빗금, 단독 Heal 가시성의 개선을 확인했다. Siege/Volley/Spirit 궁극기의 실전 위계는 여전히 보류다. 단순모형·표본 시점의 개선 확인과 실제 전투의 최종 수용은 구분한다.

## 남은 수용과 다음 담당

ART/QA는 실제 영웅/승인 장비·Selene 손소켓, 실제 지역·낮/밤/복원 조명, 위험 바닥과 길안내가 겹친 이동 교전,4인+AI에서 전체 시간을 확인해야 한다. 게시 클라이언트의 최초 로드·네트워크 확정 이벤트·터치/패드·GPU/실기기·사용자 최종 미술 수용은 **미검증**이다. 격리 R15/실제 자산 조명 장면이나 대규모 수치 PASS로 이 수용 조건을 닫지 않는다.
