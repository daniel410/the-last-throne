# 스킬 아이콘/VFX 독립 아트 리뷰 — 초기

TLT-033/057/059 · ART/디자인 · 2026-11-15 · 기준 `2aa4ffb7` / `0.111.2`

**128종의 아이콘 의미와 현재 엔진 화면을 대조했다. 현 상태를 전체 아트 수용으로 통과시키지 않는다.** 68종은 주 형상/위계 개선, 39종은 정지 화면의 기본 형상 유지 후보, 21종은 반복/이동/귀환의 연속 화면 확인이 우선이다. 각 판정은 [128개 개별 관측·권장안·아이콘/화면 해시](art-review-initial.json)에 있다. `retain_static`도 최종 사용자 미술 수용을 의미하지 않는다.

## 확인한 증거와 한계

[아이콘 원본/의미](../../../assets/ui/hero-skill-icons-v2/prompts.json)의128종을 원본 PNG에서 유래한 클래스별32개 미리보기4장으로 직접 열람했다. Ice Shard·Glacial Spike·Ice Ward·Molten Line·Returning Echo·Spirit Arrowfall의 원본 PNG는 별도로 크게 열었다. [실제 엔진 전수 화면](../skill-icon-vfx-20261115/skills/manifest.json)의8개 contact sheet와 [전후12장](../skill-icon-vfx-20261115/comparison-sheet.png)을 실제 이미지로 열어 대조했다. 아이콘128개·개별 화면128개의 SHA256도 기존 목록과 일치한다.

화면은 회색 모형·첫 확정 펄스0.10초 정지 컷이다. 주 형상과 화면 안의 위계는 관측했으나 실제 Player/원본 장착 무기·연속 동작/일반 맵·다인·기기에서 검증한 것은 아니다. 특히 기본 Axe Throw는 `K0SwordVisual`의 실제 장착 무기 복제 경로를 별도로 사용하므로 **격리 컷의 삼각 촉만 보고 실제 플레이에서 도끼가 없다고 결론내리지 않는다.** Advanced 투척의 공통 `ProjectileSurface`가 삼각 면인 것은 소스에서 확인했다.

서버 카탈로그의 실제 `form/element/pulses/move/shield/returning/crosscut`와 `SkillPresentation`, `HeroVFX`/`SkillIconVFX` 분기를 읽었다. 바닥 선의 정확한 범위를 바꾸는 제안이 아니다. 원본 아이콘의 배경 남색이나 청색 하이라이트를 전투 속성으로 복제하지 않는다. 금빛 성속성·청색 번개와 서버 판정은 유지한다.

## 공통 판단

새 얇은 선은 일부 모티프를 보탰지만 기존의 큰 원·나선·길쭉한 쐐기를 주제로 남겼다. Water Ball이 물고리, Ice Shard가 긴 얼음창, Ice Ward가 Frost Ring과 같은 외곽 결정, Molten Line이 공중 불창으로 읽히는 사례는 아이콘 의미와 실제 기술 특성에 맞지 않는다. 반대로 Whirlwind/Twin Cyclone/Blade Storm의 주 검호, 단발/부채꼴/화살비, Wind Lance, Arcane Ward처럼 이미 읽히는 형태는 무조건 다시 만들 필요가 없다.

아이콘을 월드에 크게 붙이는 방식보다 **기술마다 읽히는 주 형상 하나와 짧은 보조 단서 한두 개**에 면·두께·명암을 배정한다. 캐릭터/위험 바닥을 가리는 체적을 늘리지 않고 중복 장식 원과 긴 잔광을 먼저 줄인다. 형상의 존재/Beam 수 검사는 이 위계의 아트 수용을 증명하지 않는다.

## 엔지니어링 핸드오프 — 우선10묶음

| ID / 우선 | 대상·현재 분기 | 관측·개선 방향 | 재리뷰 조건 |
| --- | --- | --- | --- |
| ART-01 / P1 | `dwarf.iron_axe.returning_echo/breaker_throw/crosscut_axe/twin_axe_path`, `dwarf_braced_throw`; `HeroVFX`의 `shape==axe` 및 공통 `ProjectileSurface` | 긴 삼각 촉이 도끼 머리/손잡이를 대신한다. TD 장착 원본 복제부터 사용하고 누락 시 짧은 손잡이+넓은 도끼 머리의 명확한 대체 형상을 쓴다. 기본 throw의 기존 실제 복제와 중복 생성하지 않는다. | 같은 원본 도끼가 회전하고, 귀환2펄스의 축이 뒤집힌다. Crosscut 실제18도 축·Twin의 확정2펄스를 보존한다. |
| ART-02 / P1 | `mage.common.mana_bolt`, `mage.pyro.ember_lance/flame_dart/magma_spear/stone_lance`, `mage.cryo.frost_lance/ice_shard/shatter_dart/glacial_spike`; fire/arcane/frost/stone 공통 체적 | 현재 얼음4종은 거의 같은 `.85×.85×distance` 긴 쐐기, 불3종도 같은 불꼬리다. Ice Shard=짧고 넓은 결정, Frost Lance=가는 긴 창, Shatter Dart=작은 짧은 침+파편, Glacial Spike=길고 두꺼운 주 결정+측면 결정. Flame Dart는 작게, Magma Spear는 어두운 외피와 용융심을 분리한다. | 같은 카메라/목표 거리에서 색을 가려도 짧고 넓음/길고 가늠/무거운 결정의 위계가 읽힌다. 사거리·피해·서버 중심은 유지한다. |
| ART-03 / P1 | `mage.pyro.molten_line`, `mage.cryo.thunder_spear/lightning_line`; fire/Lightning 공통 분기 | Molten Line은 지면 균열의 좁은 면+짧은 밝은3마디가 주제여야 한다. 공중 FlameWake/불창을 제거한다. Thunder Spear는 거의 곧은 밝은 창+짧은2분기, Lightning Line은 낮고 곧은 통로+직각 분기. Chain만 확정 노드 간 지그재그를 유지한다. | 공중 불창·연쇄·긴 지면 통로를 동일 축/거리에서 구별한다. 빈 Chain에 새 방전을 만들지 않는다. |
| ART-04 / P1 | `mage.common.water_ball/gravity`, `mage.pyro.steam_burst`, `mage_tidal_ring`; water/gravity/steam | Water Ball은 납작한 도넛 대신 둥근 공중 구체와 방울3개, Tidal Ring은 지면 물마루다. Gravity는 넓은 다각 나선보다 조밀하고 어두운 핵/안쪽 수렴 궤도·작은 돌조각에 집중한다. Steam은 짧고 둥근 옅은 상승 덩어리다. | 물 공/지면 물결/중력핵/짧은 증기를 형상으로 구별하고 중앙 바닥·적을 가리지 않는다. |
| ART-05 / P1 | `mage.cryo.ice_ward`, `mage.pyro.searing_ward`, 보호 기사/드워프/엘프; frost/guard 공유 분기 | Ice Ward는 Frost Ring과 같은 외곽8결정이 아니라 몸을 감싼 낮은3면/돔·보석이 중심이다. Searing Ward는 내부 보호와 바깥 화염 왕관을 나눈다. Iron Shoulder는 기사 연 방패 대신 강철 어깨 가드/따뜻한 진행 선. 동료 보호는 작은 보조 방패를 읽히게 한다. | 보호기와 공격 광역이 정지 화면에서도 구별된다. 몸과 시야는 보이며 보호 수명/발동은 서버 상태를 따른다. |
| ART-06 / P1 | `elf.magic_archer.elemental_arrow/bloom_shot/vine_trap/rooting_fan/warden_arrow/vine_burst/elemental_pierce/echo_arrows/gliding_shot`; Nature `arrow/vine`, Icon leaf | 가는 잎 윤곽/초록 점만 보여 자연 구속·꽃잎 파열의 차이가 약하다. 작은 실제 잎 면/굵은 줄기와 자연 보석을 국소 배치한다. Bloom=5잎 파열, Trap=땅의 굵은 고리, Burst=중앙에서 펴지는 큰3잎으로 구분한다. | 실제 합성에서 색/텍스처 잡광이 잎 면을 가리지 않는다. 앞쪽 부채의 뒤에 원형 채움을 추가하지 않는다. Echo의3확정 펄스와 이동은 연속 시점으로 확인한다. |
| ART-07 / P1 | 궁극기8종, 특히 `grand_volley/spirit_arrowfall/caldera_s_judgment/eternal_tempest`; signature 분기 | 고유 분기는 있으나 현재 넓은 범위·카메라에서 근처의 주 초점이 작다. 주변 원을 늘리기보다 앞의 활 왕관/목표의 자연 문장·큰 하강 화살/어두운 분화구·굵은3분출/열린 폭풍 눈·2~3층 띠를 선명하게 만든다. Oath의3방패와 문장은 이미 맞는 방향이며 면 위계만 강화한다. | 게임 거리와 기술 중심 카메라 두 구도에서 고유 초점을 판별한다. 일반 기술과 다른 위계가 보이면서 실제 위험 바닥을 가리지 않는다. 단순 줌만으로 개선 완료를 주장하지 않는다. |
| ART-08 / P2 | Dwarf ground/ridge, `mage.pyro.earth_rise/lava_eruption/cinder_ring/ember_step`, `mage.cryo.frost_ring/frost_step/froststorm`; earth/lava/frost 공통 분기 | 네 갈색 상자·외곽8결정·다중 원의 반복을 줄인다. Earth Rise=높이가 다른3기둥, Lava=어두운 현무암+3상승줄기, Frost Ring=지면 파동/얼음 이빨, Froststorm=올라가는 층별 기류/하강 결정, Step=서버 출발점의 짧은 잔흔이다. | 지형 상승/폭발/보호/이동 출발 흔적이 색 없이도 다르다. Step의 원점과 성장 결정의 밑동/하강 궤적은 회귀 확인한다. |
| ART-09 / P2 | Marksman·Gunner·rain 계열의 단발/연사/관통/부채/유탄; arrow/bullet/rain/blast 분기 | 기본 방향은 대체로 맞다. 과녁·파쇄·감속 틱은 작고 총탄은 긴 레이저처럼 보인다. 짧은 금속 탄환/총구광과 국소 과녁/관통/낮은 물리 감속 단서를 강화한다. | 세 연사/네 포격/세 Spirit 에코/후퇴/곡사/구름은 실제 확정 순서를 여러 상대시점에서 확인한다. 임의의 동시 탄체/피해 펄스·얼음/덩굴 감속을 추가하지 않는다. |
| ART-10 / P2 | Knight/Dwarf melee, taunt, oath, spinning; slash/spin/warcry/holy + Icon cues | 주 검호는 상당수 읽힌다. 중복 장식 원은 줄이고 도발의 머리 높이 호·작은 서약/판금 파쇄·보호 단서를 구별한다. Provoke는 피해0이므로 폭발처럼 읽히는 강한 바닥 원/명중광을 피한다. | Whirlwind/Twin/BladeStorm, 낮은 sweep/세로 cleave/전방 thrust의 구별을 보존한다. 피해 없는 도발에 새 피해 섬광/폭발/타격을 추가하지 않는다. |

## 제작·검증 제안

새 PNG나 외부3D는 필수가 아니다. 기존 TD 도끼 원본과 `HeroVFXSurfaces`의 부피/삼각면·리본으로 위 주 형상을 만들 수 있다. 기존 이미지 원본은 보존한다. 글로벌/개별 장식 예산 안에서 불필요한 원·긴 잔광·중복 면을 먼저 줄인 뒤 필요한 면에 재배정한다. 고품질과 저품질에서는 주 형상을 우선 보존하는 것이 좋다.

후속 아트 재리뷰는 같은 전체 구도·기술 중심 구도, 시전/확정 직후/중간/소멸 전의 여러 시점에서 한다. 가능한 장착 원본/실제 합성 경로를 사용하고, source hash와 상대 시점·조명을 남긴다. 엔진 회귀와 아트 관측을 별도로 보고한다. 게시·실기기·다인·사용자 미술 수용은 여전히 별도다.

기존 [Diablo IV/WoW/Roblox 비교 조사](../../research/2026-11-15-skill-icon-vfx.md)의 가독성·직업/기술 정체성 원칙을 재사용한다. 이번 보고는 기존 자료의 역사적 원칙과 우리 소스/화면의 관측이며 참고 게임의 현행 수치·패치를 새로 검증한 보고가 아니다.

다음 담당: ENG가 우선1묶음의 주 형상을 실제 합성 경로에 구현하고 ART가 전후 화면을 다시 판정한다. 본 초기 리뷰 문서 작성과 실제 VFX 개선/사용자 미술 수용 완료를 구분한다.
