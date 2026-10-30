# Deepwood 보스 호위·증원 확대

2026-10-29 · TLT-014/027/041/050/052/061/084 · PLAN/ENG → QA. 사용자 후속 지시: 보스전에 몬스터 수를 늘려 난이도를 높인다.

## 근거와 판단

[Blizzard의 Diablo IV 개발 설명(2020-02)](https://news.blizzard.com/en-us/article/23308274/diablo-iv-quarterly-updatefebruary-2020)은 군집·근접·장거리·대형 적의 역할 조합으로 위치 선정과 광역 공격 판단을 만든다고 설명한다. 개발 당시 설계 설명이며 현재 보스의 정확한 증원 수나 난이도 수치를 조사한 것은 아니다. 이 원리를 기존 TD Goblin/Orc/Shaman 모델과 실제 전투 행동에 맞춰 적용한다. 현재 Shaman은 긴 도달거리 공격을 사용하며 새 회복/부활/원거리 투사체 능력이 추가됐다는 뜻이 아니다.

기존 보스는 Orc Warlord1+HP50% Shaman1, King Shaman1+첫 피격 Goblin2, Goblin King1+Goblin2, King Ogre1, Enraged Warlord1+Orc2로 최대2/3/3/1/3마리였다. 보스 단독 압박과 일부 소수 호위로 구성돼 있어 사용자가 요청한 다수 전투를 충분히 만들지 못했다.

## 채택한 시험 수치

| 보스 | 시작 구성(보스 포함) | 체력 구간별 증원 | 총 출현 |
| --- | --- | --- | --- |
| Orc Warlord | 보스1·Orc2·Shaman1 =4 | 50% Orc2·Shaman1 |7 |
| King Shaman | 보스1·Goblin2·Shaman1 =4 | 70% Orc2·Shaman1 /35% Goblin2·Shaman1 |10 |
| Goblin King | 보스1·Goblin4·Shaman1 =6 | 50% Goblin2·Shaman1 |9 |
| King Ogre | 보스1·Orc2·Goblin2 =5 | 50% Orc2·Shaman1 |8 |
| Enraged Warlord | 보스1·Orc4·Shaman1 =6 | 60% Orc2·Shaman1 /30% Goblin2·Orc1 |12 |

총 출현 수는 한 번의 시도 전체이며, 앞선 적이 살아 있으면 누적된다. 인원수에 따라 이 수를 추가 증식하지 않는다. 기존 보스 HP의1~4인 계수는 유지한다. 보스/기존 적의 HP·공격력과 승인 초회 퀘스트 XP/Coins는 바꾸지 않는다. 더 많은 정상 처치에 따른 기존 처치 XP/Coins는 증가하므로 성장 속도는 후속 플레이에서 관찰한다.

시작 호위는 약1~1.72초, 증원은 약1.43~1.79초 준비한 뒤 공격한다. 증원은 중심에서22studs, Shaman은27studs 반경에 나눠 배치하고 영어 안내를 보낸다. 타이머 무한 소환은 없으며 각 체력 구간은 시도당 한 번만 발생한다. 큰 피해로 구간을 건너면 일반 보스는 해당 증원을 모두 생성한다. King Shaman은 기존70% 방패/35% 최종 국면 피해 제한을 유지해 국면과 증원이 함께 진행된다. 보스만 죽이고 호위를 남기면 목표는 완료되지 않는다. 전멸/이탈 시 기존8초 비참여 정리와 재시작 경로를 사용한다.

변경 파일은 `DeepwoodBossEncounters`·`DeepwoodContent`·서버 `DeepwoodService`·보스 데이터 검사·서버 native 회귀다. 최소 검증은 다섯 초기/전체 수·체력 구간 단발성·증원 공격 준비·보스 선사망 시 미완료·전 호위 처치 후 완료·초회 보상 불변이다. 실제 솔로 네 클래스/4인·모바일 프레임·정상 성장 상태의 전멸률/소요 시간은 QA 후속이며, 숫자 확대로 재미/최종 난이도가 수용됐다고 판단하지 않는다.
