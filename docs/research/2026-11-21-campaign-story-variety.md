# 본편의 반복 동선과 서사

2026-11-21 · TLT-050/061~065 · G5 · 기획·ENG → QA

기준 0.115.28의 본편 35장을 실제 `CampaignContent` 조합으로 검토했다. 1차 개선 뒤에도 확장 사건 70개 중 62개가 세 번의 방문이나 조작을 요구했다. DW-01은 길을 확인한 뒤 다시 세 개의 경유점을 방문했다. DW-03과 HG-02는 이야기와 관계가 다른 거점인데 준비물 조사 뒤 전망을 확인하는 순서가 같았다. GW-04/05는 모두 수색과 복구를 반복했고, EC-06은 모형 시험 직후 같은 정보를 새 점검 절차에서 다시 읽게 했다. 다섯 에픽 완료 카드에서는 챕터 결과, 지역 결과, 다음 목적이 같은 사실을 반복했다.

## 공식 사례와 적용

2026-11-21에 1차 조사에서 사용한 공식 설명을 확인했다. 아래는 공개 당시 설계에 관한 관찰이다.

- **Diablo IV Strongholds**는 탈환 이후 마을과 주민이 돌아오는 결과를 보여준다. TLT는 에픽 결과에 교전 목록을 요약하는 대신 주민이 다시 이용할 수 있게 된 길, 보호 시설과 작업장을 보여준다. [Blizzard의 2022년 공개 자료](https://news.blizzard.com/en-us/article/23816540/all-hell-breaks-loose-in-2023diablo-iv-is-coming)
- **World of Warcraft Retail Dragonflight**는 탐사대의 등반, Iskaara의 요리, Dragonbane Keep의 공성처럼 장소의 사정에 따라 역할을 바꾼다. TLT에서는 DW의 수색, GW의 퇴로 확보, FV의 수호수 진정, EC의 부하 시험, HG의 동맹 진입과 봉쇄를 각 장의 행동에 연결한다. [Blizzard의 주요 진영 소개](https://news.blizzard.com/en-us/article/23823105/dragonflight-major-factions-overview)
- **Lost Ark 글로벌 Chaos Gate**의 2023년 개편에서는 보스 처치를 다음 교전에 영향을 주는 버프와 연결한다. TLT에 적용할 부분은 성과의 즉시 활용이다. 우회로를 확보한 뒤 후위 교전으로, 실제 압력을 확인한 뒤 부하 시험으로 이어진다. [Amazon Games의 개편 기록](https://www.playlostark.com/en-us/news/articles/chaos-gate-revamp)
- **Roblox Creator Hub**는 퀘스트의 행동과 수량을 별개의 구성 요소로 설명한다. 주요 단서·조작이 한 곳에 이미 있는 사건은 한 번이면 충분하도록 작성하고, 실제 선택이 있는 FV-04와 EC-05의 조작은 유지한다. [Roblox 퀘스트 설계 가이드](https://create.roblox.com/docs/production/game-design/introduction-to-quest-design)

## 적용과 수용

기존 지물과 서버 판정 경로를 사용해 13개 사건을 한 번의 조작이나 본선 도착으로 진행한다. 현재 동선의 목표를 바꾸고, 각 에픽 결말의 단계에서 장면의 결과와 다음에 처음 알게 되는 정보를 각각 작성했다. 비용은 11장 현장 행동의 거리·가독성 QA와 이전 중간 저장의 재개 점검이다. 선택지를 늘리거나 새 강제 전투를 넣는 대안은 추가 조작과 보상 검증이 필요하므로 이 작업 범위에서 제외했다.

QA는 같은 난이도와 영웅으로 두 후보를 비교해 달라진 장의 강제 방문·조작 횟수, 이전 저장에서 다시 걸은 거리, 각 지역의 기억나는 행동을 확인한다. PC·터치·패드에서 목표를 찾을 수 있고 솔로·4인에서 같은 동선으로 진행해야 한다. 구현과 결과는 [검증 기록](../evidence/campaign-story-variety-20261121/README.md)에 연결한다.
