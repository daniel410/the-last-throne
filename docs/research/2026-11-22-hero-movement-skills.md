# 이동 공격의 준비 자세와 명중 연출

TLT-033/057/059 · 2026-11-22 · 기준 0.115.43

기준 후보는 강타의 타격 방향과 겹치는 피격 자세를 개선했다. 이동 기술을 이어서 검토했다. Breaker Charge는 두 타가 같은 높이의 방패 고리를 공유했다. Iron Shoulder는 어깨 양옆에 대칭인 효과를 그렸다. Gliding Shot은 공통 전진 사격 자세를 사용했다. Frost Step의 출발점은 확인할 수 있었지만 이동 방향은 큰 서리 고리에 묻혔다.

| 공식 사례 | 관찰과 TLT 적용 |
| --- | --- |
| Diablo IV · 2021년 12월 개발자 업데이트 | 공격 애니메이션과 명중 방향을 맞추고 위험 예고가 먼저 읽히도록 효과의 강도를 조절했다. TLT에서는 서버 확정 순간의 두 짧은 획으로 네 기술의 명중 방향을 표현하고 기존 피해 영역 경계를 유지한다. [개발자 업데이트](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) |
| World of Warcraft · Legion 7.3 | 주문 준비에서 힘을 모으는 방향을 캐릭터 동작으로 보여 주고 방출 몸짓을 기술에 맞춰 구분했다. TLT의 Frost Step은 지팡이를 몸 쪽에 두고 빈손으로 출발점을 향해 서리를 쓸어낸다. [시전 애니메이션 개발 노트](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) |
| Lost Ark 글로벌 · Destroyer 출시 및 2025년 4월 Sharpshooter | Power Shoulder는 몸을 낮춘 상태에서 앞쪽에 무기를 두고 돌진한다. Lock-On은 전진과 발사가 한 기술 안에서 이어진다. TLT에는 왼쪽 어깨 중심의 충격과 마지막 발을 딛고 시위를 놓는 한 발을 적용했다. [Destroyer 기술 설명](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-destroyer-class) · [2025년 4월 업데이트](https://www.playlostark.com/en-us/news/articles/april-2025-update-release-notes) |
| Roblox Creator Hub | 겹치는 입자와 화면 갱신은 클라이언트 부담을 높일 수 있다. TLT는 기존 효과 예산과 시간을 사용한다. 아군 방패 면과 어깨 장식 면은 생략하고 서버가 이동을 막았으면 서리 이동 흔적을 표시하지 않는다. [성능 개선](https://create.roblox.com/docs/performance-optimization/improve) · [하드웨어 검증 설계](https://create.roblox.com/docs/performance-optimization/design) |

기존 기술과 소켓을 바탕으로 자세와 좌표를 조정했다. 피해·보호막·범위·이동과 펄스 일정의 판정은 기존 서버 경로가 담당한다. 재현 조건과 수용 범위는 [검증 기록](../evidence/hero-movement-skills-20261122/README.md)에 있다.
