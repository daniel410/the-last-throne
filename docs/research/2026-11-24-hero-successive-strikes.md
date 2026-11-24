# 네 영웅의 연속 타격과 회수 비교

2026-11-24 · TLT-033/057/059 · 기준 빌드 0.115.76

| 공식 자료 | 관찰 | TLT에 적용한 판단 |
| --- | --- | --- |
| [Diablo IV 2021년 12월 개발자 업데이트](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 회전 베기의 피해 영역과 무기 VFX를 시간에 따라 움직인다. 타격 효과 방향과 위험 예고의 판독을 함께 다룬다. | Twin Cyclone의 각 서버 타격에 기울기가 다른 검호 하나를 묶는다. Cinder Ring은 기존 반경 안에서 화염 높이로 순서를 구분한다. |
| [World of Warcraft Retail Legion 7.3 전투 애니메이션](https://worldofwarcraft.blizzard.com/ko-kr/news/20946579/patch-73-new-combat-animations-its-magic) | 준비 동작에서 땅이나 공기에서 힘을 끌어모으는 방향을 보여주고 시전 자세에 도달하는 시간을 조정했다. | 마법사의 낮은 긁기, 몸 앞 가로 휘젓기, 마지막 들어 올리기를 손·몸통·앞발에 나누어 배치한다. |
| [Lost Ark 글로벌 Destroyer](https://www.playlostark.com/en-gb/news/articles/lost-ark-academy-destroyer-class) · [Sharpshooter와 Deadeye](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) · [Sorceress](https://www.playlostark.com/en-us/game/releases/darkness-unleashed) | Earth Eater는 무기 높이를 타마다 올린 뒤 내려찍는다. Arrow Wave는 투사체를 중심으로 진행하고 Bursting Flare는 마지막 발의 결과가 다르다. Inferno에는 준비와 화염 기둥이 연결되는 변형이 있다. | 반환 도끼의 손과 잔광이 같은 위치에 닿게 하고, Echo Arrows는 화살 한 발당 잔광 하나의 기울기와 마지막 발의 회수만 달리한다. Cinder Ring의 마지막 화염이 가장 높다. |
| [Roblox Effects](https://create.roblox.com/docs/effects) · [렌더링 성능](https://create.roblox.com/docs/performance-optimization/improve) | Beam으로 두 부착점과 곡률을 지정할 수 있다. 반투명 오브젝트의 중첩은 렌더링 부담을 늘린다. | 기존 Beam과 곡률 계산을 사용한다. 겹쳐 보이는 회전 검호 한 겹과 Cinder Ring의 범용 화염선을 제거하고 아군은 간소화된 경계를 쓴다. |

Studio에서 같은 카메라의 첫·마지막 타격, 낮은 아군 효과에서의 방향·도착점·반경, 네 영웅의 붉은 적 예고 및 피해 숫자 회귀를 확인한다. 물리 기기의 프레임 시간과 플레이어의 타격감 판단은 실제 교전에서 측정한다.
