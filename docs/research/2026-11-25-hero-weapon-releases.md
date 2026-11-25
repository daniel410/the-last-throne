# 무기별 방출과 타격의 구분

2026-11-25 확인 · TLT-033/057/059 · PC/터치·파티 전투

기준 0.115.117은 직전 반격·관통·뿌리·연쇄 개선을 포함한다. Oathbreaker Strike는 전용 피격 효과가 있지만 방출은 공용 내리베기와 겹쳤다. Gunner Shot은 포구 탄선과 별도 섬광이 중복됐고, Spark Volley는 전기 주문이 일반 연사와 같은 몸짓을 사용했다. Mana Bolt의 일반 전투 경로는 서버가 전달한 구간을 타원형 주문체로 날리고 종료 지점에서 별도 공용 섬광을 만들었다.

| 공식 자료 | 관찰 | TLT 적용 |
| --- | --- | --- |
| [Diablo IV 2021년 12월 개발자 업데이트](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 개발자가 공격 방향과 맞는 피격, 애니메이션과 판정 영역의 동기화, 위험 신호의 우선순위를 설명한다. | 성기사 검격의 낙하 방향과 앞발 하중을 맞추고 명중은 기존 서버 피드백으로 읽는다. 총과 화살은 발사 소켓과 서버가 확정한 끝점을 연결한다. |
| [World of Warcraft Retail Legion 7.3 전투 애니메이션](https://news.blizzard.com/en-us/article/20946579/patch-7-3-new-combat-animations-its-magic) · [The War Within 11.2 업데이트](https://news.blizzard.com/en-us/article/24226698/ghosts-of-k-aresh-content-update-notes) | 시전 준비의 몸짓과 방출 시간을 함께 설계하며, 11.2는 전투 정보를 전달하는 효과를 우선하도록 Spell Density를 개편했다. | 마법을 지팡이 곁에 모으고 끝으로 밀어 내보낸다. 아군 총격은 포구 섬광을 생략하고 탄선만 사용한다. |
| [Lost Ark 글로벌 Gunner 직업 소개, 2021-08-24](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) · [The Art of War 업데이트](https://www.playlostark.com/en-us/news/articles/the-art-of-war-release-notes) | Deadeye의 Spiral Flame은 강한 한 발이고 Bursting Flare는 세 발 중 마지막에 별도 타격을 준다. Sharpshooter의 Arrow Wave는 화살이 원소 효과를 운반한다. Paladin의 Executor’s Sword에는 지면을 향한 내리치기가 있다. | 드워프는 왼손으로 한 발의 반동을 받는다. 엘프의 전기 화살은 첫째·둘째 획 방향과 셋째 발의 디딤을 구분한다. 기사의 금빛은 검이 내려오는 호를 따라 붙인다. |
| [Roblox Creator Hub 실기기 가이드](https://create.roblox.com/docs/videos/hardware-testing-guide) | 프레임 시간과 스파이크는 대상 기기에서 MicroProfiler로 관찰한다. | Studio에서 Beam·추가 표면·광원·입자 요청을 전후 계수한다. 실기기 프레임 시간은 게시 시험에서 별도 측정한다. |

공식 개발 설명과 패치·직업 소개를 비교했다. 외부 게임의 기술 수치나 자산은 적용하지 않았다. 검격 위치와 폭을 늘리면 근접 표적이 가리거나 적 예고 위를 지날 수 있다. 짧은 방출, 월드 깊이를 쓰는 효과, 아군 화면의 간소화로 시험한다. 같은 카메라·조명 전후 화면, 네 기술 동시 VFX 계수, 근접 엄폐, R6·R15 자세, Spark Volley 중복 펄스, Mana Bolt 실제 투사체 수명과 끝점에서 수용을 확인한다. 게시 클라이언트와 실기기 가독성은 QA·ART 확인 범위다.
