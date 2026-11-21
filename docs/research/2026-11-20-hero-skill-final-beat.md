# 영웅 연속기의 마지막 타격

2026-11-20 확인 · TLT-033/057/059

| 공식 사례 | 관찰 | TLT 적용 |
| --- | --- | --- |
| [Diablo IV 2021년 12월 분기 업데이트](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 휘두름 방향과 피해 발생 구간에 효과를 맞춘다. 적 예고와 플레이어 스킬의 화면 비중을 조절한다. | Blade Storm의 마지막 검호를 낮추고 Oathbound Assault의 빛과 면을 동일한 검호에 맞춘다. Siege Barrage의 불티는 바로 앞에서 내려온 포탄 위치에서 시작한다. |
| [World of Warcraft Ghosts of K'aresh](https://worldofwarcraft.blizzard.com/en-gb/news/24226698), [12.1.5 업데이트](https://worldofwarcraft.blizzard.com/en-us/news/24304162/) | Spell Density는 전투 판단에 필요한 효과를 우선한다. 12.1.5는 관찰자용 밀도 옵션을 일부 비전 주문에 확대했다. | 본인 화면에 마지막 박자의 강조를 적용하고 아군의 원형 경계는 12개 선분으로 표현한다. 적 예고와 피해 숫자가 보이는지 겹침 장면에서 확인한다. |
| [Lost Ark April 2025](https://www.playlostark.com/en-us/news/articles/april-2025-update-release-notes), [Destroyer 소개](https://www.playlostark.com/en-gb/news/articles/lost-ark-academy-destroyer-class), [Gunner 계열 소개](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) | Slayer의 Fatal Sword와 Volcanic Eruption은 마지막 베기와 폭발의 속도가 각각 조정됐다. Destroyer는 준비·전진·강타를 단계로 읽을 수 있다. Sharpshooter 소개에서 충전 단발과 곡사 화살비의 궤적이 구분된다. | Mountain Collapse는 두 번째 강타에서 양 무릎으로 충격을 받고, Grand Volley의 수평으로 넓어지는 마지막 발과 Spirit Arrowfall의 상향 발사 뒤 손 회수를 구분한다. |
| [Roblox Creator Hub 기기 검증 가이드](https://create.roblox.com/docs/videos/hardware-testing-guide) | Studio 기기 시뮬레이션은 조작과 UI 확인에 적합하다. 프레임 시간은 대상 기기에서 측정한다. | Studio에서 모션·효과·예산을 검증한다. 저사양 단말의 렌더링 시간은 실기기 QA 항목으로 관리한다. |

## 기존 구현과 이번 실험

[이전 낙하 검증](../evidence/hero-skill-landing-20261120/README.md)에서 착탄 전 하강과 서버 펄스를 연결했다. 0.115.0의 코드를 리뷰한 결과 Grand Volley와 Spirit Arrowfall은 각 펄스에 같은 크기의 왕관·수관을 생성했다. Siege Barrage는 포탄이 펄스마다 다른 방위에서 내려오지만 불티의 시작 위치는 고정돼 있었다. Oathbound Assault의 짝수 타격에서는 빛의 기울기와 면의 기울기가 달랐다.

전직 계열마다 공격 하나를 골라 마지막 펄스 후 최대 0.30초 동안 힘을 받는 몸동작을 추가했다. 화살의 회수는 확정 발사를 기준으로 샘플링한다. 마지막 효과는 확정 펄스에서 기존 요소의 폭·높이·방향을 바꾸거나 같은 예산 안에서 원형 물결을 교체한다. 강한 효과의 가독성은 먼저 피격 조건이 같은 Studio 화면에서 비교하고, 이어서 실제 4인 전투에서 적 예고를 알아차리는지 확인한다.
