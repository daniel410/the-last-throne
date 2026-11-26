# League of Throne을 참고한 조작 튜토리얼

2026-11-26 · TLT-005 / TLT-051 연계 · Research → ENG·QA

League of Throne 로컬 소스 0.22.3의 `game/shared/PracticeLessons.luau`, `game/server/Practice.luau`, `game/client/Tutorial.luau`를 읽었다. 연습 코스는 이동 표식으로 시작해 기본 공격과 스킬의 명중을 판정하고, 현재 단계와 입력별 조작을 보여준다. 일반 경기 안내는 앞서 수행한 행동도 인정한다. 이 원리를 The Last Throne의 기존 Training 입구에 적용했다.

- Diablo IV의 2023년 베타는 프롤로그부터 1장으로 이어지는 구성이다. TLT에서는 조작 연습을 기존 허브에서 선택할 수 있게 해 플레이어가 본편 시작 시점을 고른다. [Blizzard](https://news.blizzard.com/en-us/article/23916442/your-guide-to-the-diablo-iv-open-beta)
- World of Warcraft의 Exile's Reach는 첫 여정에서 실제 캐릭터 기술과 능력을 단계적으로 소개한다. TLT에서도 훈련 전용 조작 대신 선택한 영웅의 기본 공격과 영웅 스킬을 사용한다. [Blizzard](https://worldofwarcraft.blizzard.com/en-gb/news/24137818)
- 글로벌 Lost Ark의 2021년 베타 프롤로그는 클래스 배경을 소개하면서 조작 교육을 짧게 다듬었다. TLT의 이번 연습은 표식, 기본 공격, 스킬, 회피 네 가지 행동으로 구성했다. [Lost Ark](https://www.playlostark.com/en-us/news/articles/october-team-update)

기존 훈련장과 몬스터, TD 공통 HUD 아트를 사용한다. 이동과 회피는 서버에서 관찰하고, 공격과 스킬은 훈련 적에게 실제로 피해가 들어갔을 때 인정한다. 사망과 같은 세션 내 재입장에서는 영웅별 달성 상태가 이어진다. 과제 완료에는 별도 보상이나 본편 선행 조건을 부여하지 않는다.

QA는 첫 입장부터 네 단계 완료와 허브 복귀까지 걸린 시간, 훈련 적을 발견하기까지 걸린 시간, 사망 후 남은 목표와 입력별 문구 전환을 확인한다. TLT-051의 Dawnspire DS-01~04와 보상 수용은 별도 범위다.
