# TLT-033/057 · 원소 구별과 금빛 성속성

2026-11-12 · 0.104.21 · 로컬 구현/격리 엔진 검사 완료. 전체 티켓 Done·게시·실기기·최종 미술 수용과 구별한다.

## 적용 내용과 근거

사용자의 불·물·바람·번개·얼음·땅 속성 구별과 금빛 성속성 지시를 반영했다. [정본 미술 기준](../../production/element-vfx.md), [WoW 조사](../../research/2026-11-12-wow-vfx.md), [기존 Diablo/RPG 조사](../../research/2026-11-12-combat-vfx-game-references.md)를 사용했다. 신규 외부 자산/업로드 없이 기존 엔진 텍스처와 절차적 면/입자를 사용한다.

- Fire: 공통 구형 투사체를3개 화염 혀로 교체하고, 투사체 끝에 불꽃을 집중한다. 불티/불기둥은 좁은 위쪽 방출과 적색으로 소멸하는 색 변화를 사용한다.
- Water: 큐브 파편을 둥근 Glass 물방울로 바꾸고, 바깥으로 흐르는 물마루4개와 옅은 포말4개를 추가했다. 기존 물결·물방울의 방사/포물선 움직임은 유지한다.
- Wind: 전용 `WindLanceVisual`의 회전 기류·넓은 공기 리본·명중 돌풍을 보존하고 실제 인스턴스/회전 움직임을 확인했다. 이번에 새 바람 렌더러를 만들지 않았다.
- Lightning: 보라 계열을 청색 방전으로 바꾸고 짧은 옆 분기를 추가했다. Hero 장식의 선/면은0.16초에 소멸하며 불필요한 반복 깜박임을 만들지 않는다. 기본 렌더러/서버 타격 시점은 유지한다.
- Ice: 얼음창/파편을 Ice 쐐기로 바꾸고, Frost Ring 외 다른 냉기 광역에도 분리된 얼음 경계를 사용해 물과 공유하던 원반을 제거했다.
- Earth: 돌창/파편을 Slate 쐐기로 바꿨다. 기존 갈색 바위의 지면 상승/균열을 보존한다.
- Holy: 성속성 방패가 공통 청색 방패 키로 덮이는 `PixelFXCatalog` 경로를 수정했다. 성기사13기술의 주색·선·Flare·시전/명중 강조빛·기존 K0 명중 표현까지 따뜻한 금빛을 사용한다. 물리 방패의 청색은 유지한다.

변경 범위는 `HeroVFX`, `AdvancedSkillVisual`, `K0HitEffects`, 순수 표시 조회 `PixelFXCatalog`다. 서버 기술 정의/피해/상태/MP/재사용/해금/보호막 수치·TD 운영 Place/코드·재화·저장은 변경하지 않았다.

## 실제 적용 화면

![속성별 개선 후](elements.png)

[8장면 전후 비교](comparison.png): Fire/Water/Wind/Lightning/Ice/Earth/Holy Gold/Holy Seal 순서, 왼쪽0.104.20·오른쪽 개선안. `tools/capture-element-vfx-review.luau`에서 생산 `AdvancedSkillVisual.play`의 전체 합성 효과를 호출했다. 물은 Tidal Ring, 바람은 Wind Lance, 성속성은 Shield Verdict와 Dawn Burst다. 비교마다 같은 회색 모형·바닥·48도 카메라를 사용했다. 번개0.1초, 다른 기술0.14초에 생성된 인스턴스를 복제/동결하고 텍스처 디코드 후320×240으로 캡처했다. 입자는 불0.22초/그 외0.07초 별도 재방출 후 동결했으므로 동작 타이밍/첫 로드 지연 증거가 아니다. [메타데이터/로그 해시](captures.json).

관찰: 불은 뾰족한 화염/적색 불꽃, 물은 매끈한 물결과 물방울, 바람은 축을 감는 기류, 번개는 꺾인 방전, 얼음은 창/결정, 땅은 갈색 바위, 성속성은 금빛 방패/인장으로 구별된다. 이는 격리 화면의 디자인 관찰이다. 실제 TD 영웅/장비·동시 교전·조명에서의 최종 식별 수용은 남아 있다.

## 검증

- [CPU/컴파일](source-checks.log): PixelFX634 + SkillEffects15,938 = **16,572 PASS**, 변경 모듈/검사/캡처 도구 Luau 컴파일 PASS.
- [실제 엔진](native.log): **9,348 PASS**. 새 속성84 + WoW231 + style-fit58 + curated182 + PixelFX1690 + HeroVFX6519 + WindLance128 + individual297 + flourish57 + K0Hit102. 각10개 요약 모두 PASS다.
- 새 검사는 성기사13기술 전체의 키/시전/명중 금빛, 물과 얼음의 재질/형상 차이, 물마루/포말, 물방울 이동, 돌창/바위 상승, 번개 분기/짧은 소멸, 실제 바람 나선 회전을 확인한다. 기존128기술·4기본 공격·시전/취소/예산·기존 냉기/폭탄/치유·비전 방어 회귀를 포함한다.
- `python3 tools/prepare-hero-vfx-native.py --output /tmp/tlt-elements-after`로 Client/Shared만 포함한 PlaceId/GameId0·실제 플레이어0 Place를 생성했다. 각 suite를 `local function test() ... end; test()` 범위로 감싸 실행했다. [입력 SHA256](inputs.json). 계정/저장/서버 gameplay를 실행하지 않는다.
- 전역 표면160/터치80, Beam240/터치144 등의 기존 제한·거리 컬링·만료/취소 경로를 사용한다. 생성 수가 바뀌었으므로 성능 향상을 주장하지 않는다. 로그의 PC Lua update 측정은 GPU·실기기 수용이 아니다.

## 빌드·인계

0.104.21 고정 소스 `dec8ee1d0da56fb768ea1f8211cc61520690d6c6`의 단일 빌드를 완료했다. [빌드 기록](build.json), [XML 소스/파일 SHA256 대조](build-checks.log). 관련6개 생산 모듈이 고정 커밋과 일치한다. Roblox 게시·릴리스 태그는 생성하지 않았다.

미검증: 게시 RPG 클라이언트·실제 영웅/장비·밝고 어두운 지역/전체 카메라·4인+AI·실기기/GPU·사용자 최종 미술 수용. 기존 폭탄 PNG의 Experience 권한 제한은 [이전 증거](../curated-vfx-20261112/README.md)에 남아 있으며 이번에 해결한 것으로 보고하지 않는다.

다음 ART/QA: 실제 영웅으로7속성 식별, 위험 바닥/목표 가림, 흑백/색각 조건의 형상 구별, 같은 기기의 다인 프레임 시간을 비교한다. 조건이 충족돼야 TLT-033/057의 미술 수용을 갱신한다.
