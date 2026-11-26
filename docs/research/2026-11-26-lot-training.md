# League of Throne을 참고한 조작 튜토리얼

2026-11-26 · TLT-005 / TLT-051 연계 · Research → ENG·QA

League of Throne 로컬 소스 0.22.3의 `game/shared/PracticeLessons.luau`, `game/server/Practice.luau`, `game/client/Tutorial.luau`를 읽었다. 연습 코스는 이동 표식으로 시작해 기본 공격과 스킬의 명중을 판정하고, 현재 단계와 입력별 조작을 보여준다. 일반 경기 안내는 앞서 수행한 행동도 인정한다. 이 원리를 The Last Throne의 기존 Training 입구에 적용했다.

- Diablo IV의 2023년 베타는 프롤로그부터 1장으로 이어지는 구성이다. TLT에서는 조작 연습을 기존 허브에서 선택할 수 있게 해 플레이어가 본편 시작 시점을 고른다. [Blizzard](https://news.blizzard.com/en-us/article/23916442/your-guide-to-the-diablo-iv-open-beta)
- World of Warcraft의 Exile's Reach는 첫 여정에서 실제 캐릭터 기술과 능력을 단계적으로 소개한다. TLT에서도 훈련 전용 조작 대신 선택한 영웅의 기본 공격과 영웅 스킬을 사용한다. [Blizzard](https://worldofwarcraft.blizzard.com/en-gb/news/24137818)
- 글로벌 Lost Ark의 2021년 베타 프롤로그는 클래스 배경을 소개하면서 조작 교육을 짧게 다듬었다. TLT의 이번 연습은 표식, 기본 공격, 스킬, 회피 네 가지 행동으로 구성했다. [Lost Ark](https://www.playlostark.com/en-us/news/articles/october-team-update)

기존 훈련장과 몬스터, TD 공통 HUD 아트를 사용한다. 이동과 회피는 서버에서 관찰하고, 공격과 스킬은 훈련 적에게 실제로 피해가 들어갔을 때 인정한다. 사망과 같은 세션 내 재입장에서는 영웅별 달성 상태가 이어진다. 과제 완료에는 별도 보상이나 본편 선행 조건을 부여하지 않는다.

QA는 첫 입장부터 네 단계 완료와 허브 복귀까지 걸린 시간, 훈련 적을 발견하기까지 걸린 시간, 사망 후 남은 목표와 입력별 문구 전환을 확인한다. TLT-051의 Dawnspire DS-01~04와 보상 수용은 별도 범위다.

## 스킬과 무기 강화 연습 확장

LoT 연습 코스는 조작을 장으로 나누고 기술 습득과 명중을 각각 목표로 제시한다. TLT의 영웅은 시작 기술을 바로 사용할 수 있으므로 전투 기초와 영웅 스킬을 각각 3단계로 나누고, 스킬 장은 시전 승인 → 명중 → 기본 공격 후속타로 구성했다. 시전 시 나타나는 재사용 대기와 사거리·엄폐에 따른 빗나감을 단계별로 설명한다.

Lost Ark의 Training Area는 장비 강화 안내를 다시 열어 연습할 수 있게 구성했다. TLT에서는 Dawnspire 대장간의 Enhance 화면에 별도 +1 연습을 두고 장비 선택 → 미리보기 → 확인 → 결과를 한 번씩 누르게 했다. 표시 비용·성공률·공격력 계산은 TLT 강화 규칙에서 읽는다. 연습 장비와 단계는 화면에서만 관리한다. [Lost Ark Academy 강화 안내](https://www.playlostark.com/en-gb/news/articles/lost-ark-academy-progression)
