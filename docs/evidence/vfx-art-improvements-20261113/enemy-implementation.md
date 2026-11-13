# 몬스터 ART 리뷰5항목 구현

TLT-033/057/061~065/084 · ART/ENG · 2026-11-13 사용자 ‘우선·후속 모두 개선’ 승인 범위. 원천은 [전수 ART 리뷰](../vfx-art-review-20261113/enemy-review.md), [원소 동작 조사](../../research/2026-11-13-roblox-element-motion.md), [몬스터 미술 조사](../../research/2026-11-12-monster-spell-art-review.md)다. 최신성 재확인과 전체 통합은 root 담당이다.

## 구현 대응

| 요구 | 적용 | 생산 파일 |
| --- | --- | --- |
| EN-ART-01 · 방어 여부 비색상 단서 | unblockable의 기존 `WarningEdge` 최대4개에20px BillboardGui 이중 빗금을 표시한다. 실제 경계 Part의 위치/크기/색/수명·지면 추종은 유지하며 추가 BasePart는0개다. `AlwaysOnTop=false`, world offset0이며 ring은 외곽선만 선택한다. 방어 가능은 기존 연속선이다. 최초 SurfaceGui의 미세 쌍대시는 원본640이미지에서 line/cone 가독성 수용에 실패하여 대체했다 | `EnemyPatternEffects` |
| EN-ART-02 · 불 투사체 종별/보스 위계 | Imp=작은 쐐기 불씨, MagmaImp=두 갈래 화염, VolcanoShaman=분기한 부채형 화염, KingVolcanoShaman=솟는3갈래 분출, InfernoOverlord=열린 왕관형 화염으로 구별한다. 각 style의 꼬리 폭/길이·국소 halo 크기를 나누고 선택한 화염 혀는 더 읽히게 한다. Meteor/Magma의 기존 바위 머리와 승인 색·재질은 유지한다 | `EnemySpellProfiles`의 표시 전용fireStyle, `EnemySpellVFX`, `EnemySpellArt` |
| EN-ART-03 · 눈/모래 형상 분리 | 눈은6주축+6옆 분기의 결정으로, 모래/먼지는 거친 재질의5개 작은 쐐기 입자 뭉치로 바꾼다. 같은6갈래 별에 색만 바꾸던 구조를 제거한다. 실제 피해 element는 유지한다 | `EnemySpellVFX` |
| EN-ART-04 · 고리 위험띠 면적 읽힘 | 위험띠 중간에 낮은 방사 균열8개를 두고, 충격 흐름은 띠 안쪽에서 바깥으로 진행한다. 기존6개 원소 분출은 띠 내부의 두 반경에 나눠 외곽에만 몰리지 않게 한다. 중앙 flare·새 피해·원반 채우기는 추가하지 않는다 | `EnemySpellVFX`, `EnemySpellArt` |
| EN-ART-05 · 마법 접촉 형상 분리 | arcane=교차 룬 궤도/각진 룬 파편, soul=상승 리본/빛조각, shadow=안으로 모이는 틈/파편, web=얇게 뻗는 실/교차 격자로 일반 원형 충격파를 대체한다. 불/얼음/흙/물리의 기존 단서는 유지한다 | `EnemySpellVFX`, `EnemySpellArt` |

현행 보스 공격에 실제web element가 없어 보류한 `BossHeroImpact`의 web 라이브러리 분기는 변경하지 않았다. 새 web 접촉은 실제 Webling/Silkweaver·WidowQueen의 표시 경로인 `EnemySpellVFX` family에 적용하며 새 보스/상태 이상을 만들지 않는다.

## 보존 범위와 비용

서버 `EnemyPatterns`·피해/범위/속도/펄스/준비/회수·블록 가능 여부·MP·저장·재화·TD 운영 코드를 변경하지 않는다. 전역 후처리/카메라 효과/새 외부 이미지·모델/업로드가 없다. 모티프35·종50·공격146의 식별자와 기존 `motif/ornament` 조합도 유지한다.

기존 Spell Parts640/records64, Art Beam192(터치96)/예약 입자480(터치240)/빛6/광륜32 상수를 올리지 않았다. 새 ring 기하와 불 머리는 기존 예산 안에서 생성하며 접촉별 Beam은 공통 충격파를 대체한다. BillboardGui 이중 빗금은 기존 경계 Part를 adorn하므로 물리/쿼리/경계 Part 수를 늘리지 않는다. GUI 인스턴스/투명 면·CFrame 갱신 비용은 늘 수 있어 GPU/실기기 성능 향상을 주장하지 않는다.

## 검증과 실행 인계

`tests/vfx-art-enemy-fixes-native.luau`는 계정/저장 없는 PlaceId/GameId0에서 다음을 검사한다.

- 실제 정의의6shape×방어 여부12예고: unblockable당 최대4개의20px 이중 빗금과 occlusion/offset0/ring외곽, blockable에는 없음. 추가 world geometry 없음·기존 Part 비충돌·취소 정리.
- 불5종의 실제 머리 기하·비구형 중심·표시 style 고유성·일반/보스 국소 실루엣 위계.
- 눈의 결정 분기와 모래의 거친 입자 재질/기하 차이.
- 모든 고리12개를0/.12/.35/.6초에 샘플링: Part 전체 모서리와 곡선 Beam+폭, 보수적인 입자 방출 원뿔이 안전 중심을 침범하지 않음. 새 균열은 실제 바깥 경계 안에 있음.
- 비전/영혼/그림자/거미줄의 실제 접촉 형상과 영혼 상승·그림자 수렴·실 뻗음.
- 혼합 포화 후 기존 전체 예산과 완전 반환, `EnemyPatterns.profiles` 전체 JSON 불변.

변경4모듈+새 검사 Luau 컴파일 PASS, 변경 파일 공백 검사 PASS. root가 고정 소스 `7a80c50d2198b7233ea42330dc6c12dbde4a5944`의 계정/저장 없는 fixture에서 새 검사 **16,963 PASS**, 기존 `tests/monster-spell-vfx-native.luau` **66,027 PASS**(50종·146공격·40투사체)를 실행했고 전체17suite 실행은exit0이었다. 작성자가 직접 Studio/서버 게임을 실행하지 않았으며, 실행/로그의 정본은 root 통합 기록이다. 이는 시야 가림·실기기·최종 미술 수용이 아니다. 이후 ART 재검토에서 EN-ART-01 미세 쌍대시 가독성이 실패해 위20px 표식으로 재수정했다. 해당 추가 패치는 compile PASS이며, root가 최종 고정 `c1b578d470a26536bd1a22895f265b91d3c16669`/0.104.28에서 새 enemy 검사 **15,916 PASS**, 기존 monster 검사 **66,030 PASS**, 전체17suite **95,423 PASS**를 확인했다. 빌드와15모듈 원문 일치도 PASS다. 위 고정26 결과와 구분하며 예고12 재촬영의 시각 판정은 [재리뷰](enemy-after-review.md)에 별도 기록한다.

전후 비교 도구는 이전 리뷰의 `enemy-capture.luau`(60조합), `enemy-warning-capture.luau`(12예고), `enemy-ring-capture.luau`(고리12), `enemy-impact-capture.luau`(근접 접촉20)를 재사용할 수 있다. 초기 triptych의 가린 오른쪽impact는 다시 판정에 쓰지 않고 근접 도구로 비교한다. 구현 후에는 접촉 서명 수/기하가 바뀌므로 old20 자동 서명 선택이 모든 새 형상의 완전 수용을 의미하지 않는다.

## 남은 수용

최종28 예고12의640px fixture 가시성은 [재리뷰](enemy-after-review.md)에서 PASS로 확인했다. 새 경계 이중 빗금의 실제 카메라/낮은 그래픽·색 제거 가독성, 일반/보스 실제 캐스터를 포함한 투사체 위계, 실제 피해 영역·안전 중심·기울어진 눈/용암 바닥과의 조화, 명중 위치/모션 동기,4인+AI 가림·GPU/실기기·사용자 미술 수용은 root의 후속 QA로 남긴다. 그림/컴파일/엔진 구조 통과를 이 수용으로 대체하지 않는다.
