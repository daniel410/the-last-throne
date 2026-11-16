# Roblox VFX 제작자 사례의 직접 시각 관찰

TLT-033/057/059 · 2026-11-15 · ART 리서치 인계 · [구조화 기록](2026-11-15-roblox-vfx-artist-observations.json)

이번 조사의 권고는 **주 형상에 대비를 모으고, 연한 꼬리·작은 접촉·짧은 잔류를 나누는 것**이다. 검기·물방울·얼음·도끼·잎·궁극기 초점이 큰 원이나 흰 광량에 가려지면 사례의 화려함을 가져온 의미가 없다. 영웅128종뿐 아니라 적의 근접/마법, 지원 효과까지 이 원칙으로 다시 검수한다. 구현 완료나 사용자 미술 수용을 뜻하는 문서가 아니다.

## 우선 비교 기준과 열람 범위

게임성 우선 기준은 기존 [Diablo IV/스킬 아이콘 조사](2026-11-15-skill-icon-vfx.md)와 [Roblox RPG 비교](2026-11-13-roblox-rpg-vfx.md)를 재사용한다. Diablo IV의 [2021년 개발자 VFX 설명](https://news.blizzard.com/en-gb/article/23746639/diablo-iv-quarterly-updatedecember-2021)은 환경 안의 가독성과 시간/강도의 위계, [WoW Retail7.3의 전투 개선](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic)은 직업/기존 주문 정체성을 보존하는 비교 원리다. 개발 중 Diablo 자료와2017년 Retail 자료를 현행 시즌/Classic 규칙으로 설명하지 않는다. 기존 WoW 본문403 한계도 유지한다. 이번 ART 분담은 새 라이브 플레이나 해당 본문 재열람을 주장하지 않으며 공식 재확인은 총괄 담당이다.

서로 다른 작성자/포트폴리오8건의 공개 원문을 읽고 아래 명시한 이미지·영상 표본을 Chrome 스크린샷으로 직접 관찰했다. 검색 도구의 DevForum JS/robot 검증 화면은 본문 증거로 쓰지 않았다. Chrome에는 CAPTCHA가 나타나지 않았고 우회하지 않았다. DOM은 공개 게시일·media URL·재생시각을 읽는 데만 사용했다. 모델·스크립트·플러그인을 다운로드/설치/실행하거나 외부 자산을 복제하지 않았다. 외부 이미지/영상의 로컬 복사본도 만들지 않았다.

영상 표본은 재생기 시점이며 연속 프레임 측정이 아니다. 재생 중 스크린샷은 처리 사이에 시간이 진행하므로 근사치다. 쇼케이스·플러그인 미리보기를 직접 플레이, 무기 동기, 기기 성능이나 현재 유행의 증거로 일반화하지 않는다. 계정 동일성도 별도 감사하지 않았다.

## 제작자별 관찰

**CREATOR-01 — ImaginePowerq, [Crecent Sword Slash Effect](https://devforum.roblox.com/t/crecent-sword-slash-effect/1113871)**. 최초2021-03-16, 표시 수정2022-01-19. 제작자는 굵기/불투명도가 다른 선의 가장자리를 지우고 Polar Coordinates로 호 질감을 만든다고 설명한다. 실제 연 [작업 이미지](https://devforum-uploads.s3.dualstack.us-east-2.amazonaws.com/uploads/original/5X/7/7/e/2/77e251fc6d908b03d080975579c8592d3ddc3d17.png)는 길이/굵기가 다른 평행선과 흐려지는 끝을 보인다. [완성 스틸](https://devforum-uploads.s3.dualstack.us-east-2.amazonaws.com/uploads/original/5X/7/0/f/f/70ff8511bfa345886810dde228ddf18f37b850cd.jpeg)은 한쪽에 진한 호가 모이고 반대쪽은 연해진다. 회색 원형 면도 보이므로 완전 투명 처리 품질은 확정하지 않는다. 추론: 균일 원판보다 열린 끝과 다른 폭이 휘두름 축을 읽히게 할 수 있다. 적용: 기존 검기/Trail의 날·꼬리 감쇠. 비용: 낮음~중간의 곡률/폭 조정. 원본 메시/질감 복제와 스틸만으로 동작 PASS 선언은 거절한다. Gyazo 영상은 열지 않았다.

**CREATOR-02 — Loca1t, [Hit Effect Handler](https://devforum.roblox.com/t/hit-effect-handler-how-to-make-a-good-hit-effect-in-5-minutes-mesh-particles/1511337)**. 최초2021-10-16. 원문은 메시 폭발과 입자를 따로 만든 뒤 결합한다. 직접 연 [메시 스틸](https://devforum-uploads.s3.dualstack.us-east-2.amazonaws.com/uploads/original/4X/5/1/e/51ed86344df2adf778635ffb3d65b44954dccfc0.jpeg)은 양끝이 가늘어지는 길고 얇은 백색 조각이고, [입자 스틸](https://devforum-uploads.s3.dualstack.us-east-2.amazonaws.com/uploads/original/4X/3/b/b/3bb35679f2ee6dcb45f95966793b869df8063baa.jpeg)은 빈 중심 주위에 크기가 다른 뾰족한 백색 조각/가는 어두운 선이 방사한다. 추론: 중심과 방사 조각을 분리하면 몸통을 덜 가리는 접촉감을 만들 수 있다. 적용: 물리 명중과 적 주문 접촉의 짧은 중심/불균등 조각. 비용: 기존 조각 재사용은 낮음~중간. 공개 모듈 설치는 거절한다. 원문 결합 영상의0.15/0.50/0.58/1.04/1.62초 표본은 접촉 순간을 포착하지 못해 시간/팽창 판정에서 제외했다. 직접 mp4 탐색1회는 브라우저가 거절했으며 우회하지 않았다.

**CREATOR-03 — Yuruzuu, [Open Source VFX](https://devforum.roblox.com/t/yuruzuus-open-source-vfx/1840021)**. 최초2022-06-20, 표시 수정2025-07-29. 포럼9개 제목/링크 중 시각 판정은 두 예시에 한정한다. 포럼의 Lightning Blade가 연결한 실제 영상 제목은 [Aether Elemental Skill](https://www.youtube.com/watch?v=s-4izv9fdbE)이다.5/10/15초에서 보라-백색 핵·얇은 원/초승달 외곽·옅은 잔광이 보이지만 가까운 큰 링의 블룸은 캐릭터를 가린다. 정확한 업로드일은 미확인이다. [Healing VFX](https://www.youtube.com/watch?v=9t4vEJmvxPs)는2022-06-26 공개 표시이며1.31초에 몸 옆 소수의 초록 plus·수직 반짝임·작은 점이 보인다.5초 Breakdown은 이 층들을 떨어진 판 위에 나눈다(챕터는 Showcase0:00/Breakdown0:04). 추론: 기능 표식과 주변 입자를 따로 조절하는 제작 단위가 유용하다. 적용: 핵/잔류와 지원 수혜자 초점 분리. 비용: 중간, 다인전 누적은 별도 검증. 원작 캐릭터/고유 문양·백화·보라/초록을 우리 Holy에 복제하는 것은 거절한다. 다른7개는 실제 관찰 사례로 계산하지 않는다.

**CREATOR-04 — VibeStrider, [Dark magic missiles VFX showcase](https://devforum.roblox.com/t/dark-magic-missiles-vfx-showcase/1813413)**. 최초2022-05-27. 원문 영상의1.97/3.25/3.89/5.05/11.69초를 관찰했다.3.25/3.89초에는 작은 밝은 보라 단서와 검은 보라 연기·굽은 조각이 구분되고,5.05/11.69초에는 벽 근처 여러 검은 흔적이 남는다. 다시 시전되는 표본이므로 같은 흔적의 정확한 수명은 측정하지 않았다. 제작자는2022-05-28 답변에서 직접 그린 입자 중 하나에 noise/dissolve flipbook을 썼다고 설명한다. 추론: 위치를 읽히는 핵과 불규칙한 잔류를 분리할 수 있다. 적용: 적 spirit/shadow의 핵·연한 잔류·접촉 흔적. 비용: 기존 입자 조정은 낮음~중간, 새 flipbook은 별도 비용. 검은 구름을 모든 원소에 복제하거나 댓글의 Bezier 추정을 구현 사실로 취급하는 것은 거절한다.

**CREATOR-05 — [ExhaultedDev 포트폴리오](https://exhaulteddev.artstation.com/projects/wrq3Rg)**. 페이지 게시일 미표시. 직접 연결된 [Anime VFX Showcase](https://www.youtube.com/watch?v=Dy_OvTyvt1A)는 Bill Titanhelpdesk 채널,2025-03-21 공개 표시다. 두 계정이 같은 사람인지는 별도 확인하지 않았다.5/10/15/20/25초 표본을 관찰했다.5초의 보라 핵/얇은 곡선·연기층,15초의 전진축으로 길어진 핵/구체 외곽은 나뉜다.20초의 별도 방사 폭발·큰 바닥 링·앞쪽 구체는 비슷한 밝기로 겹쳐 국소 위치와 크기 위계가 흐려진다.10/25초는 여러 작업물이 놓인 미리보기다. 추론: 비행과 접촉을 따로 제작하되 둘의 대비를 동시에 최대화하지 않아야 한다. 적용: 적 주문 단계별 소멸, 궁극기의 아이콘 초점. 비용: 중간; 투명 면/입자 비용은 미측정. 상업 팩 도입·대형 링 복제·실전 성능 PASS 주장은 거절한다.

**CREATOR-06 — enderlinc, [Effects Commissioning](https://devforum.roblox.com/t/effects-commissioning/1213303)**. 최초2021-05-08, 표시 수정2021-05-09. [전체 예시](https://devforum-uploads.s3.dualstack.us-east-2.amazonaws.com/uploads/original/4X/5/0/b/50b14a4a85608f1985543e35bacdfb3d3a71ba7f.png)와 [Simple Fireball](https://devforum-uploads.s3.dualstack.us-east-2.amazonaws.com/uploads/original/4X/c/b/2/cb2e7bf6db314678e28d670da7299141c52d696d.jpeg)을 직접 열었다. 화염구는 노란 내부·주황 외피·찢긴 검은 띠가 나뉘며 띠의 틈 사이에도 구체가 읽힌다. 전체 예시는 코일/구체/가로 투사체/수직 분출을 구분하지만 가장 큰 흰 분출은 내부가 백화된다. 추론: 불투명/투명 면과 밀도 대비가 색 이외의 재질 단서다. 적용: 화염의 핵/외피와 용암의 암석/용융 이음. 비용: 기존 면/재질 대비는 낮음~중간. 검은 띠/노란 구체를 모든 원소에 쓰거나 정지 이미지에서 상승·회전 속도를 확정하는 것은 거절한다.

**CREATOR-07 — spiderman6dan, [Effects Creator](https://devforum.roblox.com/t/effects-creator-for-hire/720640)**. 최초2020-08-12. 공개2장 중 [구체](https://devforum-uploads.s3.dualstack.us-east-2.amazonaws.com/uploads/original/4X/f/6/4/f6458afe0d72f80268e6019ffc6741f76e2f6e21.png)는 강한 노란 중심/끊긴 띠, [소용돌이](https://devforum-uploads.s3.dualstack.us-east-2.amazonaws.com/uploads/original/4X/9/0/b/90b30d22da0b27d1fc7f48f831f38f4ec703902b.png)는 아래가 좁고 위가 넓은 층으로 보인다. 층 사이 큰 구멍으로 하늘/지면이 드러나지만 밝은 하늘의 상단 띠는 대비가 낮다. 추론: 층을 비워 기류와 몸/바닥을 함께 읽힐 수 있다. 적용: Tempest/Froststorm의 열린 높이층과 밝은 지역 대비. 비용: 기존 층 재배치는 낮음, 투명 층 증가는 중간 이상. 촘촘한 흰 고리·회전 속도/성능 단정은 거절한다. 글의 Sword slashes 제작 가능 문장을 실제 검격 관찰로 계산하지 않는다.

**CREATOR-08 — nix102on(HyperDev), [Show off your VFX designs](https://devforum.roblox.com/t/show-off-your-vfx-designs/4098665)**. 최초2025-11-26, 표시 수정2025-12-30. Sword Slash만 펼쳐25.15초 영상을 직접 재생했다. 약4.91초 재생/14.10초 정지/15.13초 재생 표본은 열린 C형 주황 검기·폭이 모이는 밝은 날·가늘어지는 끝·소량 청색 직선/점과 비어 있는 중심을 보인다. 표본별 방향이 바뀌지만 카메라/반복 방출이 있어 정확한 회전과 수명을 분리해 측정하지 않았다. 추론: 선명한 날·연한 꼬리·소수 보조 입자가 유효하다. 적용: 기존 구간 접선 연결과 무기 Trail 감쇠. 비용: 중간; 동일 인스턴스 수가 GPU PASS는 아니다. 외부 플러그인 설치·청색을 무관한 속성으로 복제·미리보기로 실제 무기 동기나 모바일 성능 통과는 거절한다.

## 구현에 넘기는12개 원칙

아래는 관찰에서 도출한 **우리 적용안**이다. 특히 전체 원소 운동표·예산 우선순위·타이밍 조건은 외부 모든 작품에서 직접 본 사실이 아니다. [현재 속성 계약](../production/element-vfx.md)과 새 아이콘 주 형상, 서버 권위를 먼저 지킨다. 비용은 작업 난이도 추정이며 제작자 비용/성능 측정이 아니다.

| ID/우선 | 적용·구현 위치 | 수용 기준 | 비용 |
| --- | --- | --- | --- |
| ART-R01/P0 | 영웅128·적·지원: `HeroVFX`/`AdvancedSkillVisual`/면에서 주 형상에 최대 대비, 내부 빈 공간 | 도끼/물방울/결정/잎/궁극기 초점이 장식보다 먼저 읽히고 몸/바닥이 남음 | 낮음~중간 |
| ART-R02/P0 | 영웅·적 마법: 곡면 Water, 각면 Ice, 암석 Earth, 빈 층 Wind 등 재질 구분 | 흑백/연속재생에서도 대표 형상이 다르고 Lightning 청색/Holy 금빛 유지 | 중간 |
| ART-R03/P0 | `HeroVFX.curve`, `HeroVFXSurfaces.ribbon`, `K0SwordVisual`/적 무기 Trail: 접선 연결·선명한 날·가는 꼬리 | 정면/측면30/60fps에서 이음새/끝 역전이 없고 실제 무기 형상이 남음 | 중간 |
| ART-R04/P0 | 영웅·`EnemySpellVFX.charge/projectile/impact/pulse`·지원 link: 시작/비행/접촉/수혜자 위치와 소멸 분리 | 이동/취소 시 명중점이 시전자에게 끌리지 않으며 서버 시간/이벤트/범위 불변 | 중간 |
| ART-R05/P1 | 투사체 본체를 먼저 읽히게 하고 꼬리 폭/광량 억제 | 물/불/도끼 및 IceShard/GlacialSpike가 낮/밤·상대시점·원거리에서 다름 | 낮음~중간 |
| ART-R06/P1 | `K0HitEffects`/적 접촉: 작은 중심+길이/굵기가 다른 방사 조각 | 연속 명중에도 몸/다음 예고가 남고 기존0.08초 중심광/0.23초 압력파 유지 | 낮음~중간 |
| ART-R07/P1 | 기존 원소 계약에 맞춰 불 상승/물 바깥 포말/얼음 하강·파쇄/땅 무거운 파편/바람 회전/영혼 옅은 상승·수렴 | 핵 소멸 뒤 잔류가 원소를 바꿔 보이지 않으며 독/영혼 프로필 의미 보존 | 중간 |
| ART-R08/P1 | `SelenePresentation`/지원: 수혜자 옆 Heal 잎/줄기, 열린 Protect 막, 짧은 Cleanse 흐름; link/focus 방출·잔류 | 얼굴/장비/적 예고가 남고 세 지원 효과가 색 없이도 다름. 초록 plus를 모든 Holy에 복제하지 않음 | 낮음~중간 |
| ART-R09/P0 | 실제 판정 경계 보존, 광역/궁극기 장식 내부 비우기 | unblockable 패턴·돌진0.45초·내부 안전 반경이 그대로 읽힘. 장식 크기가 범위 정본이 되지 않음 | 낮음~중간 |
| ART-R10/P0 | 원소색 핵·연한 꼬리, 흰 최대광은 작고 짧게 | 낮/밤·밝고 어두운 바닥·블룸 최소/현재 설정에서 본체와 몸이 남음 | 중간 |
| ART-R11/P1 | 기존 예산/원본 재사용; 원거리/포화에서 불티·외곽 띠부터 축소 | 본체·위험/지원 기능 표식은 남고 수명 뒤 레코드/Attachment/Trail/Beam 회수 | 중간 |
| ART-R12/P0 | 정지 전후와 연속 동작을 별도 증거로 검수 | 128전수 정지·대표 반복/귀환·cancel/빈 대상/포화를 분리하고 모형/수학 PASS를 게시/실기기/사용자 수용으로 확장하지 않음 | 중간~높음(검수) |

## 자산·실험·인계

권고안은 기존 Beam/Trail/절차형 면·승인 원본을 먼저 재사용한다. 이번 단계에 새 PNG/3D는 필수로 판단하지 않는다. 연속 곡선·폭/투명도·위치/수명·원소 운동·위계는 기존 구성에서 조정할 수 있다. 다만 외부 예시의 세밀한 찢긴 가장자리와 같은 품질을 절차형만으로 보장하지는 않는다. 실제 캡처에서 면의 단조로움이 필수 결함으로 남으면 자체 제작 소형 질감/flipbook을 별도 검토한다. 이번에는 생성·설치·업로드하지 않았다.

최소 실험은 영웅128종/모든 확정 반복 구간의 전수 회귀와 대표 검기·도끼·물·얼음4종·MoltenLine·기류·자연·8궁극기다. 적은 기본 근접/돌진 예고와 종별 Fire/Ice/spirit/shadow/poison의 시전·비행·접촉·취소, 지원은 이동 중 Heal/Protect/Cleanse·link/지팡이 focus와4수혜자 겹침을 포함한다. 같은 월드좌표/카메라의 낮/밤 전후, 측면/상대 시점, 실제 캐릭터/무기/지형 합성을 사용한다. 각 기술의 실제 초기·접촉·잔류·귀환 시점을 골라30/60fps 연속재생과 따로 비교한다. 임의 고정 프레임이 기술 시점을 대체하지 않는다.

정지 주 형상·곡선 접합·낮/밤 대비·위험 바닥 가림·서버 계약 불변·회수/포화가 검증 대상이다. 이전 [0.111.3 독립 ART 리뷰](../evidence/skill-icon-vfx-art-20261115/art-review-final.md)는 새 리서치 이전 기준으로 보존한다. 이번 문서로 초기 지적 전체나 G4를 닫지 않는다. 총괄 ENG가 채택/보류와 구현/엔진 회귀를 기록하고, ART는 새 동일조건 전후 및 연속재생을 받아 재리뷰한다. 게시 클라이언트·실기기·다인 전투·사용자 미술 수용은 QA/사용자 단계이며 현재 미검증이다.
