# 영웅 스킬 낙하·착탄 리듬 조사

TLT-033/057/059 · 2026-11-20 확인 · PC/터치/패드 · 솔로와 1~4인 전투

0.114.25 소스에서 준비선과 명중 표현을 검토했다. 기존 포탄과 화살비, 우박은 서버가 피해를 적용한 뒤에도 0.2~0.4초 동안 높은 곳에서 내려왔다. 화살비·우박·재비는 확인된 펄스에서 HeroVFX와 이전 지상 렌더러가 각각 낙하를 그렸다. 기사 직선 찌르기는 검 끝을 사용할 수 있는 상황에도 캐릭터 중심부터 효과를 그렸다. [이전 준비 동작 검증](../evidence/hero-skill-choreography-20261120/README.md) · [이전 명중 검증](../evidence/hero-skill-impact-20261120/README.md)

| 공식 자료에서 확인한 내용 | TLT 적용 |
| --- | --- |
| Diablo IV의 2021년 12월 개발자 업데이트는 여러 프레임에 걸친 공격 영역을 무기 궤적과 효과에 맞추며, 타격이 흐르는 방향도 표현한다고 설명한다. [Blizzard 개발자 업데이트](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 기존 서버 펄스를 기준으로 마지막 낙하 구간을 표시하고, 정해진 피해 위치에 착탄을 표시한다. Driving Thrust와 Vanguard Strike의 효과는 무기 소켓에 이어 붙인다. |
| World of Warcraft의 2017년 Legion 7.3 개발자 글은 시전 응답성을 유지하면서 주문을 모으는 동작과 실제 방출 모션에 직업·원소의 차이를 넣었다고 설명한다. [Blizzard 7.3 전투 애니메이션](https://news.blizzard.com/en-us/article/20946579/patch-7-3-new-combat-animations-its-magic) | 짧고 가파른 Hailfall 손 동작, 바깥으로 휘어지는 Ashfall 손 동작을 기존 지팡이 포즈에 더한다. 엘프는 Arrow Screen, Arrow Rain, Spirit Arrowfall의 상향 조준을 구분한다. |
| Lost Ark 글로벌 2026-03-10 패치 노트는 Artillerist의 Barrage: Steel Rain 준비 동작 속도를 조정했고, 같은 업데이트에서 Paladin의 Flash Thrust 등 개별 기술 효과를 손봤다고 기록한다. [Amazon Games 패치 노트](https://www.playlostark.com/en-us/game/releases/ends-of-the-abyss) | 포대 올리기, 반동, 다음 포격으로 복귀하는 자세를 구분하고, Siege Barrage의 큰 포탄과 착탄 불티를 분리한다. |
| Roblox 문서는 반투명 효과가 겹치면 같은 화면 픽셀이 반복 처리되고, 입자와 광원이 장면 비용을 높일 수 있다고 설명한다. [Creator Hub 성능 가이드](https://create.roblox.com/docs/performance-optimization/improve) | 낙하에는 소수의 형상·짧은 Beam만 사용한다. 아군과 터치의 개수를 낮추고, 피격 후 중복 낙하를 제거한다. |

기존 방식은 서버 확정 후에만 모델을 만들기 때문에 늦은 이벤트에도 구현이 단순하지만 피해 표시와 궤적의 순서를 뒤집는다. 시전 승인 시각에 맞춘 표현은 낙하와 착탄을 연결하는 대신 취소·낡은 시퀀스·늦은 이벤트를 처리해야 한다. 남은 시간이 짧거나 표시 예산이 찬 경우에는 착탄 확정 효과가 해당 펄스를 전달한다. 피해, 범위, 펄스, 상태이상은 기존 서버 판정을 따른다.

최소 실험은 낙하형 10개 기술의 펄스 시각·착지·중복·취소·산개 좌표와 두 찌르기의 검 끝 연결을 검사하는 것이다. 실제 저사양 기기에서 네 명이 동시에 기술을 쓰는 조건의 프레임 시간과 적 공격 예고 인지는 별도 수용 항목이다. 공식 자료는 개발 설명과 패치 노트이며 해당 게임의 실측 플레이 기록은 포함하지 않았다.
