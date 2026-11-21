# 파티 접근 관리 비교

2026-11-20 · TLT-053 · 모집 목록을 확인한 뒤 아는 사람끼리 2~4인 플레이를 시작하는 흐름을 공식 문서에서 확인했다.

- Diablo IV의 Vessel of Hatred 출시 안내는 Party Finder에서 활동·목적·플레이 성향을 지정해 모집한다고 설명한다. 현재 임무와 난이도를 보고 방을 고르는 TLT 모집 흐름의 근거로 삼았다. [Blizzard 출시 안내](https://news.blizzard.com/en-us/article/24128995/delve-deeper-into-nahantu-with-mercenaries-dark-citadel-and-more).
- World of Warcraft의 Retail Shadowlands 교차 진영 안내는 파티장이 모집 대상의 진영을 제한할 수 있다고 설명한다. TLT에서는 모집 범위를 결정하는 권한을 파티장에게 부여하는 데 이 사례를 참고했다. [Blizzard 교차 진영 안내](https://worldofwarcraft.blizzard.com/en-us/news/23796742/).
- Lost Ark 글로벌 서비스의 Art of War와 Wield the Storm 업데이트는 비공개 Party Finder 모집과 비밀번호 즉시 참가 옵션을 각각 추가했다. TLT는 일반 모집과 같은 목록에서 잠금 여부를 표시하고 올바른 번호를 입력한 플레이어의 자리를 바로 확보한다. 숫자 네 자리와 추방 권한은 TLT 사용자 요청에 따른다. [Art of War](https://www.playlostark.com/en-us/news/articles/the-art-of-war-release-notes?tag=release-notes) · [Wield the Storm](https://www.playlostark.com/en-us/news/articles/august-2023-wield-the-storm-release-notes).
- Roblox의 MemoryStore SortedMap은 단일 키를 갱신한다. 파티 레코드에 잠금과 명단을 두고 서버가 같은 갱신에서 번호와 자리를 검증한다. 파티 권한 제거 후에는 해당 플레이어의 별도 인덱스를 같은 참가 토큰으로 해제한다. QA는 같은 로비와 두 로비를 오가는 올바른 번호·틀린 번호·추방 직후 참가를 확인한다. [Roblox Creator Hub](https://create.roblox.com/docs/cloud-services/memory-stores/sorted-map).
