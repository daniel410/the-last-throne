# 기사·드워프 타격 연출 조정

2026-11-20 · TLT-005/033/057/084 · ART·ENG · 로컬 빌드 0.114.9

[기존 연출 검토와 Diablo IV·WoW·Lost Ark 비교](../../research/2026-11-20-melee-impact.md)를 바탕으로 기술별 준비, 타격, 반동을 조정했다. 애니메이션은 기존 리그와 검·방패·도끼 소켓을 사용하고, 시각 효과는 기존 클라이언트 렌더러의 팔레트와 회수 경로를 사용한다. 피해·범위·타격 시각·자원과 TD 운영 코드는 소스 비교에서 동일하다.

| 기술 | 변경 |
| --- | --- |
| Oathblade · Oathbound Assault | 연격의 다음 준비 자세와 후속 동작이 내려베기와 올려베기 곡선을 번갈아 사용한다. 정면 접촉과 서버 타격 간격을 유지한다. |
| Sunward Cross | 확정 타격마다 금빛 검호 하나를 그린다. 첫 타는 하강하고 다음 타는 상승한다. 주날과 반투명 면이 같은 중심 곡선을 따라간다. [첫 타](001-knight.paladin.sunward_cross.png) · [두 번째 타](002-knight.paladin.sunward_cross.png) |
| Shield Breaker · Shield Verdict · 돌진기 | 방패 강타는 준비 중 방패를 당기고 체중을 낮춘다. 이동이 있는 기술은 타격 뒤 상체의 체중 이동에 전진·후퇴 방향을 반영한다. |
| Armor Splitter · Crag Cleave · Hooking Chop | Armor Splitter는 좁은 내리찍기, Crag Cleave는 옆으로 흐르는 도끼 궤적, Hooking Chop은 그 반대 방향의 궤적을 사용한다. 빛나는 날과 면이 함께 움직인다. [Armor Splitter](003-dwarf.iron_axe.armor_splitter.png) · [Crag Cleave](004-dwarf.iron_axe.crag_cleave.png) |
| 대지 강타 · Gunner | Stonebound Leap은 도끼를 들어 준비하고 대지 강타는 접촉 뒤 상체가 낮아진다. Quickfire는 반동을 짧게 회수하고 Scatter Shot·Piercing Round·Blast Step·Siege Barrage는 기술별로 반동 크기와 회수 시간을 조정했다. |

## 검증

- [빌드 기록](build.json) · [산출물과 모듈 해시](provenance.json). 소스 `7a4b516fc4defe0e9d28c19ff10d3f7c3de3aa94`에서 단일 Place를 빌드했다. 클라이언트 변경 모듈 3개와 전투 정의 모듈 3개의 실제 빌드 소스가 해당 커밋과 일치한다.
- [고정 빌드의 Studio 엔진 로그](native.log). 8개 검사 묶음 통과. R6·R15의 기사·드워프 140동작과 204타격 경계, 기술 종료 복귀, 교대 검격의 접촉 후 자세 차이, 산탄 반동, 전방 찌르기와 총구 방향, 스킬 128종 VFX와 회수, 투사체 타이밍을 검사했다. 게시 및 릴리스 태그 작업은 수행하지 않았다.
- [전후 화면 조건](manifest.json). PlaceId 0에서 기존 월드 지형과 기본판을 치운 검토 스테이지를 사용했다. 런타임 모듈은 0.114.9 빌드에서 가져왔으며 비교 전에는 부모 커밋의 HeroVFX만 별도로 로드했다. 동일 카메라·낮 조명·펄스 후 0.10초에 정지한 장면이다. 화면에서 Sunward Cross의 두 검호는 기울기가 다르다. 도끼는 Crag Cleave의 바깥쪽 이동이 보이며 Armor Splitter의 변화는 이 각도에서 작다. 입자는 캡처에서 다시 방출했다. 기본판이 카메라를 가린 첫 캡처는 제외했다.

다음 담당은 ART·QA와 사용자다. 게시 테스트 클라이언트에서 실제 입력으로 연격 타이밍과 도끼·포격 반동을 보고, 밤·4인 교전·터치 기기의 이펙트 가독성과 프레임 성능을 확인한다. 실제 플레이 감각과 사용자 수용은 미검증이다.
