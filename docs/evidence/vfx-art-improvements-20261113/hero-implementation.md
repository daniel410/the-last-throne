# 영웅 VFX 아트 지적 개선 구현

TLT-033/054/055/056/057 · ART/ENG · 사용자 ‘우선·후속 모두 개선’ 지시 · 2026-11-13

담당 파일은 `HeroVFX.luau`, `HeroVFXSurfaces.luau`, `SkillVFXProfiles.luau`, `AdvancedSkillVisual.luau`, 새 `tests/vfx-art-hero-fixes-native.luau`다. root 소유의 순수 `CombatVFXPalette`를 표시 경로에서 사용한다. Git·버전·게시·Studio 실행은 root 통합 담당이다. 별도 사용자 변경인 K0SwordVisual/ElfQuiverVisual/ElfBowGeometry는 편집하지 않았다.

## 지적별 구현

| 지적 | 구현 |
| --- | --- |
| HV-A01 | 전방 Warcry 채움은 좁은 전방 압력 띠로, Rooting Fan은 지면 분기뿌리로 교체. Full disc/VineSurface 제거. 실제 cone 경계는 AdvancedSkillVisual에 보존. |
| HV-A02 | 산탄5개 경로를 유지하고, 큰 삼각 화살촉/ArrowEdge 대신 작은 Metal 탄체와 가는 탄흔을 사용한다. |
| HV-A03 | 짧은 Metal 포탄 본체·주황 nose·짧은 하강 꼬리로 바꾸고 기존16stud 세로 레이저를 제거했다. 궁극기는 장식 포탄3개로 초점을 만든다. |
| HV-A04 | 지면을 따라 자라는 굵기가 다른 뿌리·옆 분기·짧은 가시를 사용한다. 큰 공중 스프링·중복 직립 helix·물리 화살 겹침을 제거했다. |
| HV-A05 | WaterVolume·물마루·흰 SteamJet 대신 짧고 낮은 알파의 상승 기체와 가느다란 곡선을 사용한다. |
| HV-A06 | 수직 판4개 대신 가늘어지는 굽은 화염 혀3개와 상승 불꽃을 사용한다. 열린 중앙과 범위를 유지한다. |
| HV-A07 | Slate 암석 콜라·뜨거운 MoltenSeam·짧은 분출3개를 사용한다. 서버 element=earth를 유지한다. |
| HV-A08 | 궁극기8개의 generic 장식을 각각의 signature 주 형상으로 대체했다. 실제 펄스·준비·범위를 유지한다. |
| HV-S01 | CombatVFXPalette.get을 skill/contact에 공유해 dwarf+steel의 따뜻한 axe 색을 양쪽에 적용했다. |
| HV-L01 | 검기의 폭·불투명도·소재를 정리했다. SmoothPlastic 채움과 별도 edge, 얇은 삼각면으로 발광 판/분할 과장을 줄인다. |

공통 ART-03/04 연계: 기본 Knight는 짧은 교차 절삭, Dwarf는 무거운 하강 절삭과 작은 암석 파편, Elf는 축방향 관통 잔상, Mage는 짧은 비전 별광이다. 기본/물리 contact의 범용 원형 ContactPressure를 제거했다. 물/중력의 물결·성속성 금빛·불/얼음/대지 파편 구별은 유지한다. Gunner 탄흔은 Dwarf 도끼 절삭으로 오분류하지 않는다.

## 22개 개선 대상 기술 추적

| 기술 | 연결 지적 | 구현 대응 |
| --- | --- | --- |
| `knight.steel_knight.warcry_assault` | HV-A01 | 전방 Warcry 채움은 좁은 전방 압력 띠로, Rooting Fan은 지면 분기뿌리로 교체. Full disc/VineSurface 제거. 실제 cone 경계는 AdvancedSkillVisual에 보존. |
| `knight.steel_knight.unyielding_front` | HV-A08 | FrontWall · 벌어진3개전방방벽/올라가는갈매기형강조 |
| `knight.paladin.oath_challenge` | HV-A01 | 전방 Warcry 채움은 좁은 전방 압력 띠로, Rooting Fan은 지면 분기뿌리로 교체. Full disc/VineSurface 제거. 실제 cone 경계는 AdvancedSkillVisual에 보존. |
| `knight.paladin.oath_of_dawn` | HV-A08 | DawnBlade · 금빛태양검/6상승광/작은열린인장 |
| `dwarf.iron_axe.mountain_collapse` | HV-A08 | MountainRidge · 솟는무거운암석능선/굵은균열 |
| `dwarf.gunner.shell_burst` | HV-A03 | 짧은 Metal 포탄 본체·주황 nose·짧은 하강 꼬리로 바꾸고 기존16stud 세로 레이저를 제거했다. 궁극기는 장식 포탄3개로 초점을 만든다. |
| `dwarf.gunner.scatter_shot` | HV-A02 | 산탄5개 경로를 유지하고, 큰 삼각 화살촉/ArrowEdge 대신 작은 Metal 탄체와 가는 탄흔을 사용한다. |
| `dwarf.gunner.field_mortar` | HV-A03 | 짧은 Metal 포탄 본체·주황 nose·짧은 하강 꼬리로 바꾸고 기존16stud 세로 레이저를 제거했다. 궁극기는 장식 포탄3개로 초점을 만든다. |
| `dwarf.gunner.siege_pattern` | HV-A03 | 짧은 Metal 포탄 본체·주황 nose·짧은 하강 꼬리로 바꾸고 기존16stud 세로 레이저를 제거했다. 궁극기는 장식 포탄3개로 초점을 만든다. |
| `dwarf.gunner.siege_barrage` | HV-A03, HV-A08 | SiegeShells · 3개Metal포탄/짧은꼬리/작은착탄강조 |
| `elf.marksman.grand_volley` | HV-A08 | VolleyCrown · 7갈래물리화살/3개강한선두촉/전방시위관 |
| `elf.magic_archer.vine_trap` | HV-A04 | 지면을 따라 자라는 굵기가 다른 뿌리·옆 분기·짧은 가시를 사용한다. 큰 공중 스프링·중복 직립 helix·물리 화살 겹침을 제거했다. |
| `elf.magic_archer.rooting_fan` | HV-A01, HV-A04 | 전방 Warcry 채움은 좁은 전방 압력 띠로, Rooting Fan은 지면 분기뿌리로 교체. Full disc/VineSurface 제거. 실제 cone 경계는 AdvancedSkillVisual에 보존. / 지면을 따라 자라는 굵기가 다른 뿌리·옆 분기·짧은 가시를 사용한다. 큰 공중 스프링·중복 직립 helix·물리 화살 겹침을 제거했다. |
| `elf.magic_archer.vine_burst` | HV-A04 | 지면을 따라 자라는 굵기가 다른 뿌리·옆 분기·짧은 가시를 사용한다. 큰 공중 스프링·중복 직립 helix·물리 화살 겹침을 제거했다. |
| `elf.magic_archer.spirit_arrowfall` | HV-A08 | SpiritCanopy · 공중가지3개/민트잎화살6개하강 |
| `mage.pyro.steam_burst` | HV-A05 | WaterVolume·물마루·흰 SteamJet 대신 짧고 낮은 알파의 상승 기체와 가느다란 곡선을 사용한다. |
| `mage.pyro.cinder_ring` | HV-A06 | 수직 판4개 대신 가늘어지는 굽은 화염 혀3개와 상승 불꽃을 사용한다. 열린 중앙과 범위를 유지한다. |
| `mage.pyro.ember_step` | HV-A06 | 수직 판4개 대신 가늘어지는 굽은 화염 혀3개와 상승 불꽃을 사용한다. 열린 중앙과 범위를 유지한다. |
| `mage.pyro.searing_ward` | HV-A06 | 수직 판4개 대신 가늘어지는 굽은 화염 혀3개와 상승 불꽃을 사용한다. 열린 중앙과 범위를 유지한다. |
| `mage.pyro.lava_eruption` | HV-A07 | Slate 암석 콜라·뜨거운 MoltenSeam·짧은 분출3개를 사용한다. 서버 element=earth를 유지한다. |
| `mage.pyro.caldera_s_judgment` | HV-A07, HV-A08 | CalderaVents · 3개용암분출/뜨거운5균열/Slate콜라 |
| `mage.cryo.eternal_tempest` | HV-A08 | FrostFunnel · 3회전냉기팔/부유결정6개/작은지면결정 |

## 8궁극기 주 형상

| 기술 | Signature |
| --- | --- |
| `knight.steel_knight.unyielding_front` | FrontWall · 벌어진3개전방방벽/올라가는갈매기형강조 |
| `knight.paladin.oath_of_dawn` | DawnBlade · 금빛태양검/6상승광/작은열린인장 |
| `dwarf.iron_axe.mountain_collapse` | MountainRidge · 솟는무거운암석능선/굵은균열 |
| `dwarf.gunner.siege_barrage` | SiegeShells · 3개Metal포탄/짧은꼬리/작은착탄강조 |
| `elf.marksman.grand_volley` | VolleyCrown · 7갈래물리화살/3개강한선두촉/전방시위관 |
| `elf.magic_archer.spirit_arrowfall` | SpiritCanopy · 공중가지3개/민트잎화살6개하강 |
| `mage.pyro.caldera_s_judgment` | CalderaVents · 3개용암분출/뜨거운5균열/Slate콜라 |
| `mage.cryo.eternal_tempest` | FrostFunnel · 3회전냉기팔/부유결정6개/작은지면결정 |

궁극기는 서버 스킬 정의나 새 피해 펄스를 만들지 않는다. 장식 포탄/화살/분출의 수는 연출이며 실제 목표/피해의 정본이 아니다. 기존 AdvancedSkillVisual의 실제 범위/부채꼴 경계는 남기고 새 signature가 HeroVFX의 generic 장식을 대체한다.

## 검증

- `/tmp/td233-luau/luau-compile --null src/client/HeroVFX.luau src/client/HeroVFXSurfaces.luau src/client/SkillVFXProfiles.luau src/client/AdvancedSkillVisual.luau tests/vfx-art-hero-fixes-native.luau`: **컴파일 PASS**.
- 새 native 검사는 전방 부품 위치/원형 제거, 산탄5개/화살촉 제거, Metal 포탄의 하강/짧은 꼬리, 뿌리/가시, 증기의 단발 상승/물 덩어리 제거, 화염 혀, 용암/earth 유지, signature8개 고유성/기존 한도, 기본4개 접촉의 원형 제거, 드워프 팔레트 일치, 서버 정의128개 불변/전체 예산 회수를 검사한다.
- 고정7a80c50d/0.104.26의 root 통합 native17 suite는96,293 PASS다. 새 Hero2195·기존 Hero7334 등을 포함한다. [담당 ART 후이미지 판정](hero-after-review.md)은 이 엔진 통과와 별도로 뿌리/궁극기 가시성을 보류했으며 추가 보강은 새 고정 소스에서 검증해야 한다.
- 기존테스트의의미계약(예:OathOfDawn6상승광·비물리표면,8궁극기/128스킬·파편7/Beam48한도)을보존할수있게구현했다. CPU하네스의새Palette require등록은root가통합한다.

## 불변 계약·미검증·다음 담당

서버 피해/상태/범위/MP/쿨다운/해금/시전·펄스 순서/저장/재화·TD 운영 코드를 수정하지 않았다. 동시12/터치8, Beam240/터치144, 면160/터치80, 입자192/터치96, 파편48 제한을 유지한다. 신규 외부 자산/업로드 없음.

미검증: 새형상의실제애니/카메라전후,실제TD영웅/장비/소켓,밝고어두운지역·위험바닥·다인교전·터치/패드·실기기GPU·사용자최종미술수용. 이번 코드로22개 기술의 미술 수용 완료를 선언하지 않는다.

다음 root/QA: 고정입력fixture에서새native+기존회귀를실행하고기존review의같은조건으로전후캡처. ART는전방의미/산탄·포탄/뿌리·증기·화염·용암/궁극기초점/물리접촉을다시검토한다.

## 담당 아트 재검토 후 가시성 보강

`hero-after-review.md`의0.104.26 관찰에 따라 뿌리의 지면 몸통/민트 상승 가지끝과8개 궁극기 signature의 초점 위치·폭·대비만 추가 보강했다. 실제 범위/펄스/피해와 전역 한도는 유지한다. 변경은 `HeroVFX`와 전용 native 검사에 한정하며 별도 사용자 작업의 `AdvancedSkillVisual` 수명 변경을 보존했다. 컴파일 PASS이며 새 고정 소스에서의 엔진 실행/가시성은 root의 재검증이 필요하다.

### 최종 고정 소스 엔진 검증

`c1b578d470a26536bd1a22895f265b91d3c16669` / `0.104.28`의 root 통합 결과는 native17 suite **95,423 PASS**이며 새 Hero 검사 **2,225 PASS**를 포함한다. 전체 빌드와15개 모듈의 고정 소스 일치도 root가 확인했다. 이 결과는 실행/정리·계약 검사이고, 최종 선택 11개 첫 펄스/9개 후속 펄스는 담당 ART가 실제 열람해 [최종 재검토](hero-after-review.md#최종-010428-담당-art-재검토)에 기록했다. 뿌리 대비·DawnBlade 분리·암석/용암/냉기 초점 개선을 확인했고 새 큰 가시성 회귀는 관찰하지 않았다. SiegeShells·VolleyCrown·SpiritCanopy의 실전 주형상 위계와 전체 128개 실전/사용자 수용은 미검증이다.
