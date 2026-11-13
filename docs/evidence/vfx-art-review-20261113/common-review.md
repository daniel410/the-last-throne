# 공통·지원·환경 VFX ART 리뷰

TLT-033/057/084 · ART/DES · 기준0.104.25 / `974c2553639691eea8141c2302a09b2d257f4850`.

공통55효과군 소스와 최신31장면을 검토했다. 31장면은 [4개 시트](common/sheet-01.png)와 개별 PNG를 직접 열람하고 [진단](common/states.json)과 대조했다. 나머지24효과군은 소스 검토이며 현행 화면/동작은 미검증이다. **전체 미술 수용은 보류**한다. 게임 코드·서버 정의·VERSION·운영 Place를 변경하지 않았다.

## 범위와 판정 단위

[기계 판독 인벤토리](common-review.json)의55행은 **효과군/표시경로**다. 영웅128스킬이나 자산 수를 뜻하지 않는다. 영웅 스킬 전용은 영웅 리뷰, 몬스터 패턴/예고/상태는 적 리뷰에서 다룬다. 여기서는 겹치기 쉬운 기본무기·시전 준비·확정 명중·지원·레벨업·화면/카메라·환경 표시를 별도로 검토한다.

| 범위 | 효과군 | 현행 직접 확인/관찰 한계 |
| --- | ---: | --- |
| 확정 명중 합성 |13| 기본4 + Mage 원소6 + Dwarf2 + Elf Storm Arrow1. `K0HitEffects.show`→PixelFX/기하/legacy 전체합성31장 중13장 |
| 지팡이 준비광 |7| Arcane/Water/Wind/Fire/Frost/Earth/Lightning. `K0MageFocus.render` 실제 emitter/light/보석색7장 |
| 지원 Pixel accent |3| Heal/Protect/Cleanse. 전체 Selene지원과 구분해 독립3장 |
| 레벨업 |1| TD 파생 `HeroLevelUpEffect.play`1장. 순수 시각 모듈만 격리 로드 |
| 기본무기 |6| Knight/Dwarf/Mage Trail + Elf Arrow의 생산 Trail4장. Axe/Arcane 투사체는 소스 검토/현행 시각 미검증 |
| Selene 전체지원 |3| `bind/play/update`3장. 필수 Bone/파트를 갖춘 단순 모형이며 실제 TD 외형·손소켓 검증은 아님 |
| 피격/공통동작·카메라·세계 표시 |15| 피격 베일/몸 반응·HitStop·죽음 카메라·Block/Dodge/Sprint/Death·왕좌 복원·길안내·퀘스트 강조·월드 상태색·지역등/화로·장식 거리 예산. 소스 검토, 현행 실플레이 화면 미검증 |
| 지역 조명/후처리 |7| Lobby/Deepwood/FrozenVale/EmberCaldera/Gloamwood/HauntedGraveyard + Frozen복원. 소스 검토, 실제 지역의 VFX 전체합성 미검증 |

Block/Dodge/Sprint/Death는 독립 신규 입자 오라가 필수라는 뜻이 아니다. 현재 별도 입자/화면효과 호출 대신 포즈·모션·카메라를 주로 쓰는 경로임을 구분했다. 기본무기 Trail도 임시 회전/직선 이동으로 잔상 렌더를 볼 수 있을 뿐 실제 TD 무기/공격 클립의 접촉 정렬까지 통과시킬 수 없다.

## 우선 검토 사항

### ART-COMMON-01 · P1 · 고급 원소의 합성 명중에서 클래스 기본색으로 복귀

소스 확인: `K0HitEffects`의 전체 스킬 palette 확장은 Knight/Dwarf만 처리한다. Mage 고급 원소/새 공통 Water/Wind와 Elf 번개는 legacy flash/highlight/sparks에서 Mage 보라/Elf 녹색 기본값을 사용한다. 같은 이벤트의 `HeroVFX.contact`와 `PixelFX.hit`는 실제 원소색을 사용해 값이 서로 다르다. 카탈로그를 순수 조회한 영향 후보는 **Mage28 + Elf2 =30기술**이며 전체ID는 JSON에 기록했다. 이 수가30기술 모두의 화면을 직접 봤다는 뜻은 아니다.

현재 화면 확인: [Fire05](common/005-Fire_Hit_Composite.png)·[Frost07](common/007-Frost_Hit_Composite.png)·[Lightning08](common/008-Lightning_Hit_Composite.png)·[Earth09](common/009-Earth_Hit_Composite.png)의 타깃 몸이 보라색으로 강조되고 원소 접촉층에 분홍/보라 섬광이 섞인다. [ElfStormArrow31](common/031-Elf_Storm_Arrow_Hit_Composite.png)은 청색 접촉띠와 녹색 몸/파편이 함께 보인다. 해당 Frame은 진단에서 IsLoaded=true다. 3D Highlight/파편의 다른 색도 실제로 보여 외부 텍스처 미로드만의 문제로 볼 수 없다.

필요한 조치: 표시 palette 조회를 원소 정본과 일치시키고 Fire/Frost/Lightning/Earth/Wind/Water의 준비→시전→명중 전체합성을 비교한다. 서버 원소/피해 정의를 바꾸는 수정이 아니다. 30기술 중5대표에서 직접 확인한 영향이며 나머지25기술도 같은 화면을 봤다고 확대하지 않는다.

### ART-COMMON-02 · P1 · 번개 지팡이 준비광은 보라 계열

소스 확인: `K0MageMotion`은 실제 기술의 `d.element`를 전달하지만 `K0MageFocus.colors.lightning`은 RGB197/180/255다. [Lightning19](common/019-Lightning_Staff_Focus.png)의 보석과 얼굴 옆 준비광은 실제로 보라 계열이며 [Arcane13](common/013-Arcane_Staff_Focus.png)과 유사하다.19의 보석 진단은 약RGB189/175/239로 기록됐다. 다른 준비광은 Water청색/Wind민트/Fire주황/Frost옅은청색/Earth황토로 구별된다. 번개는 준비·발사·명중을 청색 정본으로 연결해야 한다.

### ART-COMMON-03 · P2 · 명중 층 중복과 다인 가림 가설

한 명중이 PixelFX atlas + HeroVFX 접촉 기하 + legacy Flash/Highlight/ContactRay/SkillImpact/ImpactSpark/숫자를 동시에 만든다. [기본4명중](common/sheet-01.png)에서 모두 몸통을 감싸는 열린 원형 띠가 주 실루엣이며 색 차이가 강하다. 물리 검/도끼/화살도 작은 보호막처럼 읽힐 여지가 있어 방향성 타격과 공통 원형의 비중을 비교할 필요가 있다. 실제4인+AI에서 목표/위험을 가렸다는 증거는 없다. 접촉 방향/원소 실루엣/결과 숫자의 위계를 정한 A/B가 필요하며 단일 밝은 섬광만으로 다인 가림 실패를 확정하지 않는다.

### ART-COMMON-04 · P2 · 드워프 시전/접촉의 온색·냉색 차이

`HeroVFX.skill`은 dwarf+steel을 axe주황으로 바꾸지만 `contact`는 steel청색을 유지한다. [Overhead11](common/011-Dwarf_Overhead_Contact.png)/[ArmorSplitter12](common/012-Dwarf_Armor_Splitter_Contact.png)에는 노란 세로 타격선 밖에 옅은 청색 접촉띠가 함께 보인다. 의도한 금속 보색일 수 있어 원소 오해 결함으로 단정하지 않는다. 시전과 명중을 실제 도끼/모션과 붙여 놓고 무게감과 냉기/번개 오해 여부를 판단한다.

### ART-COMMON-05 · P2 · 치유 입자의 인지성

직접 연 기존 `vfx-style-fit-20261112/heal.png`에서는 회색 몸 옆의 민트 파편이 매우 작게 보인다. 현재 CuratedVFX/PixelFX 소스 SHA가 해당 기록의 입력과 동일함을 확인했다. 그러나 이것은 단독 accent 스틸이며 현재 전체 Selene 링크/+HP가 함께 나오는 지원이 실패했다는 증거는 아니다. `selene-motion-20261101/healing.png`의 이전 TD Selene 화면에서는 시전자·연결선·수신자 링·+12 HP가 각각 읽힌다. 현재 [단독 Heal20](common/020-Heal_Pixel_Accent.png)은 이 초기 스틸에서도 거의 읽히지 않지만, 입자 IsLoaded가 없어 로드/방향/시점/크기의 원인을 분리하지 못했다. [FullHeal28](common/028-Selene_Full_Heal.png)은 연결선·수신자 링·+12HP가 보여 전체지원의 인과는 읽힌다. 단독Protect21도 Frame IsLoaded=true인 초기 atlas 스틸에서는 거의 읽히지 않으나 FullProtect의 구형 외피는 별도로 확인된다. 초기 한 프레임을 전체 효과 재생 실패로 판정하지 않는다.

### ART-COMMON-06 · P2 · 전체지원의 현재 외형/소켓/가림

Protect는 Pixel accent3.8stud, ForceField4.5×5.6stud, 링/링크/문구가 함께 사용된다. [현재 full3지원](common/sheet-04.png)의 Protect29는 구형 외피로 구별되고 내부 몸통이 보인다. Heal28/Cleanse30은 링+연결선이라는 큰 형상이 같고 문구·미세입자/색 외 차이가 약하다. 다른 시점에서 상승/세척 흐름이 달라지는지 추가 관찰한 뒤 필요한 구별을 보강한다. 현재 TD Selene 손소켓 이탈/장비·다인 가림은 실제 자산 화면이 필요하다. 단순모형 full3지원은 생산 경로의 조형/색 합성 리뷰이며 실제 TD 외형/소켓 수용이 아니다.

### ART-COMMON-07 · P2 · 길안내와 위험 정보의 위계

`DeepwoodNavigation.GuideOverlay.AlwaysOnTop=true`는 소스 사실이다. 안내 화살이 실제 위험 바닥을 덮었는지는 미검증이다. 길안내ON/OFF 및 적/지형/위험예고와 겹치는 터치 카메라를 비교한 뒤 필요하면 조형·강도를 조정한다. 퀘스트 강조는 로비 조건으로 제한되므로 배틀 혼합 문제로 자동 확대하지 않는다.

### ART-COMMON-08 · P1 · 전체합성 미술 수용 증거의 공백

대부분 최신 VFX 증거는 중립 조명·단순 회색 모형·격리 스틸이다. 지역별 색보정/Bloom/Atmosphere, 실제 TD 캐릭터/무기/장비의 실루엣,4인+AI·예고/목표 가림, 실제 터치/GPU 수용을 대체하지 않는다. 이 공백이 남은 동안 ‘모든 VFX 최종 미술 승인’은 보류한다. 효과가 동작하고 예산 제한을 지킨다는 엔진 검사는 미술 수용과 별개다.

## 보존할 방향

- 기본무기 Trail24~27은 좁고 짧게 무기/화살 주변에 머물며 몸 전체를 광선으로 덮지 않는다. 실제 무기/클립 정렬은 별도다.
- FullProtect29는 내부 몸이 보이는 외피로, FullHeal28은 시전자-수신자 연결선/바닥링/+HP로 인과가 읽힌다.
- LevelUp23의 금빛 띠/작은 불빛은 모형 실루엣을 유지한다. 전체 상승 시퀀스나 다른 금빛 전투효과와의 구별은 이 초기 스틸로 판정하지 않는다.

## 캡처 조건·관찰 한계

최신31개 PNG·파일 해시는 [manifest](common/manifest.json), 실제 색·ImageLabel IsLoaded/입자Texture·원래 요청 시각과 실제 경과는 [states](common/states.json)에 있다. 개별55행의 판정·관찰·제약은 JSON에 기록했다.

[공통 캡처 도구](common-capture.luau)는 서버 계정/게임플레이가 없는 격리 fixture만 허용한다. 명중은 생산 `K0HitEffects.show`, 지팡이는 `K0MageFocus`, 지원은 PixelFX 및 전체 SelenePresentation, 레벨업은 TD 파생 생산 모듈을 호출한다. 지원의 현재 스킬 권리·서버 이벤트 전송·수신자 저장은 검사하지 않는다.

기본무기4 Trail은 Clone 시 궤적 이력이 사라지므로 실제 Trail 인스턴스를 움직이는 모형에서 직접 캡처한다. 임시 모형의 수동 변환이며 실제 공격 클립을 재생했다는 증거가 아니다. 나머지는 인스턴스를 복제/동결하고 입자를 재방출/동결한 스틸이다. 실제 시간·최초 로드·동시 교전 성능은 입증하지 않는다. ImageLabel의 assetID/IsLoaded와 입자 Texture를 로그에 기록하며 입자에는 IsLoaded API가 없어 별도 미확인으로 남긴다.

## 다음 담당과 수용 조건

1. ENG/DES: 고급 원소 명중·번개 Focus의 표시 팔레트 정합성 원형을 만들고 같은 환경에서 전후 비교한다.
2. ART/QA: 현재 TD 영웅/무기/적·6지역·위험 예고와 함께 준비/시전/명중/지원의 전체합성 관찰을 추가한다. 미술 위계를 해치지 않는지 먼저 판단한다.
3. QA: 실제4인+AI·터치/패드·기기 프레임 관측을 별도로 남긴다. 미확인 조건을 해당 티켓 Done으로 처리하지 않는다.
