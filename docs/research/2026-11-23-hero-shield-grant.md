# 보호막 공격의 시전·명중 가독성

2026-11-23 · TLT-033/057/059 · 기준 0.115.53

| 공식 사례 | 관찰 | TLT 적용 |
| --- | --- | --- |
| Diablo IV, 2021년 12월 개발자 업데이트 | 플레이어 기술, 적 예고, 피해 범위, 캐릭터 상태의 시각적 우선순위를 따로 설계했다. 피격 효과의 방향을 무기와 주문 흐름에 맞췄다. | 보호막 적용은 수혜자의 몸 가까이 표시하고, 적에게는 검·도끼·화살·얼음에 맞는 짧은 명중 획을 쓴다. [Blizzard](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) |
| World of Warcraft, Legion 7.3 전투 애니메이션 소개 | 새 주문 애니메이션에서 반응성과 무게감의 균형을 목표로 삼고, 마법사·사제·주술사별 시전 동작을 소개했다. | Ice Ward는 지팡이와 유도 손을 몸 안으로 모았다가 손바닥을 밖으로 밀어낸다. 기존 시전·발사 구간에 자세를 맞춘다. [Blizzard](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) |
| Lost Ark 글로벌, Glaivier 및 Artist 출시 가이드 | Dragonscale Defense는 전방 방어 뒤 찌르기로 이어진다. Artist의 Door of Illusion은 이용한 파티원에게 보호막을 부여하고 Efflorescence는 적 피해와 주변 아군 보호를 한 기술에서 함께 처리한다. | Guardian Counter의 방패 자세와 검격을 구분하고, 피해와 보호막의 시각적 기준점을 각각 적과 실제 수혜자에게 둔다. [Glaivier](https://www.playlostark.com/en-gb/news/articles/lost-ark-academy-glaivier) · [Artist](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-artist) |
| Roblox Creator Hub | Beam의 두 Attachment 축으로 곡률을 제어하며, Studio는 독립 서버·클라이언트 시험을 제공한다. | 수혜자당 곡선 2개를 기존 효과 예산 안에서 렌더링한다. Studio 장면, 게시된 Roblox Player, 실기기는 각각 검증한다. [Beam](https://create.roblox.com/docs/effects/beams) · [Studio 테스트 모드](https://create.roblox.com/docs/studio/testing-modes) |

0.115.53은 보호막을 시전 시작에 적용하지만 공격형 기술의 공통 원은 명중 시간에 시전자 주변에 표시했다. 다른 파티원이 보호받았는지 원의 위치로 판별하기 어려웠다. 13개 기술의 서버 승인 이벤트에 실제 수혜 모델을 전달하고, 적 명중과 별개로 방패·성광·돌·깃·잎·얼음·불·비전 형상을 짧게 표시한다. 공격형 기술 네 개는 R15 화면과 R6/R15 자세 검사로 비교한다. 본인 표시를 먼저 시도하며 같은 수혜자에게 여러 효과가 도착하면 최신 획만 표시한다.
