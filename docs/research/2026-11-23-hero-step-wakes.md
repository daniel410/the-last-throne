# 이동 공격의 출발과 타격을 읽는 법

2026-11-23 · TLT-033/057/059 · 기준 0.115.57

기존 이동 공격 개선은 Breaker Charge, Iron Shoulder, Gliding Shot, Frost Step에 적용했다. 이번에는 연속 전투 중 전진 방패와 후퇴 사격, 출발점에 남는 화염을 구별하는 데 초점을 맞췄다. Blast Step, Retreating Fire, Ember Step의 기존 아이콘 획은 공격 펄스의 원점과 방향으로 그려져 이동 경로를 나타내기 어려웠다. 벽에 막혀도 같은 획이 발생했다. Ember Step의 펄스는 같은 모양의 화염 띠를 세 겹 그렸다. [직전 이동 공격 검증](../evidence/hero-movement-skills-20261122/README.md)

| 공식 사례 | 확인한 내용 | 적용 |
| --- | --- | --- |
| Diablo IV · 2021년 12월 개발자 업데이트 | 애니메이션과 공격 효과를 맞추고, 확정된 타격 방향에 따라 피격 효과를 배치한다. 화면에서 적 예고와 다양한 강도의 기술이 우선순위를 갖는다. | 이동 잔상은 시전 승인 패킷의 실제 이동 양 끝을 사용한다. 공격과 명중은 기존 펄스에 맞춘다. [전투 VFX 개발자 글](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) |
| World of Warcraft Retail · Legion 7.3 · 2017년 8월 | 시전자 애니메이션 개편 설명에서 즉각적인 입력 반응과 동작의 무게 사이를 조정했다고 설명한다. | 기존 시전 시간 안에서 후퇴를 잡는 뒷무릎, 방패 뒤의 진입, 지팡이를 지키는 손과 화염을 내보내는 손을 구분한다. [전투 애니메이션 개발자 글](https://worldofwarcraft.blizzard.com/en-us/news/20946579/73-%ED%8C%A8%EC%B9%98-%EC%8B%A0%EA%B7%9C-%EC%A0%84%ED%88%AC-%EC%95%A0%EB%8B%88%EB%A9%94%EC%9D%B4%EC%85%98-%EC%9D%B4%EB%B2%88%EC%97%94-%EB%A7%88%EB%B2%95%EC%9E%85%EB%8B%88%EB%8B%A4) |
| Lost Ark 글로벌 · Reaper Academy 2022년 11월 및 Ends of the Abyss | Spirit Catch는 찌르기, 이동, 마지막 타격 순으로 이어진다. Sharpshooter의 Moving Slash 기록에서는 사용 뒤 이동 준비를 빠르게 조정했다. | TLT의 기존 이동과 발사 순서를 사용한다. 이동 방향과 사격 방향이 반대인 두 기술은 발밑 자국과 무기 방출이 별도의 방향을 표시한다. [Reaper Academy](https://www.playlostark.com/en-us/news/articles/reaper-academy) · [Ends of the Abyss](https://www.playlostark.com/en-us/game/releases/ends-of-the-abyss) |
| Roblox Creator Hub · 2026-11-23 조회 | Beam은 양쪽 Attachment와 곡률을 사용할 수 있다. 입자와 투명 레이어는 렌더링 비용이 누적될 수 있다. | 네 기술 모두 곡선 두 개와 0.22초 수명을 쓴다. 기존 장식 예산을 공유하며 추가 조명·입자·겹친 발광 띠를 피한다. [Beam](https://create.roblox.com/docs/reference/engine/classes/Beam) · [렌더링 성능](https://create.roblox.com/docs/performance-optimization/improve) |

공식 문서와 안내를 비교했다. 후보의 몸짓은 기존 리그와 무기를 사용한다. 공격 판정이나 이동을 지연시키는 방식은 입력 반응과 전투 계약에 영향을 주므로 이번 범위에서 제외했다. 얇은 잔상은 낮은 그래픽 설정이나 밝은 바닥에서 약하게 보일 수 있다. 같은 카메라에서 개방 지면·벽 앞·낭떠러지 앞을 비교하고, 네 명이 동시에 공격할 때 적 예고와 이동 방향을 읽을 수 있는지 확인한다.
