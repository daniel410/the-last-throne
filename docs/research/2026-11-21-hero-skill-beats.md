# 영웅 연속 명중과 다음 착탄의 가독성

TLT-033/057/059 · 2026-11-21 · 기준 0.115.22

0.115.20에서 조준 전환, 도끼 회수, 연쇄 번개의 경로를 검증했다. 이번 검토는 그 변경을 포함하는 0.115.22에서 같은 기술의 연속 명중과 산개 착탄 표시를 재현했다. 정지 연출은 기술 1회당 첫 명중에만 걸렸다. Shrapnel Toss의 세 원이 시전과 동시에 표시됐으며, 회피 후에도 각 예약 시간이 끝날 때까지 남았다. [이전 조준·연쇄 검증](../evidence/hero-skill-direction-20261121/README.md)

| 공식 사례 | 관찰 | TLT 적용 |
| --- | --- | --- |
| Diablo IV · 2021년 12월 개발자 업데이트 | 무기 궤적과 타격 영역의 시간을 맞추고 몬스터 예고에 시각 우선순위를 둔다. [Blizzard](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 산개 범위는 다음 확정 예정 위치 한 곳에만 표시한다. 착탄과 남은 범위를 구별할 수 있도록 확정 시 기존 준비선을 지운다. |
| World of Warcraft Legion 7.3 · 2017년 8월 | 짧은 손목 동작과 힘을 싣는 직선 시전을 구분하면서 기존 주문 행동의 반응성을 유지했다. [Blizzard](https://wow-site-bwa-production-eks-prod-use1-01.worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) | Molten Line의 연속 방출과 Frost Ring의 일회 방출에 서로 다른 정지 길이를 부여한다. 따로 날아가는 투사체에는 기존 시전과 비행 타임라인을 적용한다. |
| Lost Ark 글로벌 Aeromancer · 2023년 8월 | Downward Strike는 두 번째 내려치기에 더 큰 힘을 싣고, Tornado Dance는 회전에서 강한 휘두름으로 전환한다. [Amazon Games](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-aeromancer) | Blade Storm과 Mountain Collapse의 초반 박자를 짧게 유지하고, 마지막 타격은 무기에 따라 길이를 다르게 잡는다. Grand Volley는 마지막 발사 뒤 짧게 멈췄다가 회수한다. |
| GDC Animation Bootcamp · 2014년 | Mariel Cartwright가 타격 순간의 짧은 정지를 무게를 전달하는 수단으로 설명한다. [발표 자료](https://media.gdcvault.com/gdcchina14/presentations/833784_MarielCartwright_PowerfulAndEffective_EN.pdf) | 확인된 명중 뒤 본인 리그의 시각 시간만 잠시 늦춘다. 다음 타격과 남은 회수 구간을 기준으로 상한을 둔다. |
| Roblox Creator Hub | 겹치는 반투명 객체가 화면에서 같은 픽셀을 반복 처리할 수 있다. Studio 기기 시뮬레이터는 실제 기기의 성능 측정을 대체하지 못한다. [렌더링 최적화](https://create.roblox.com/docs/performance-optimization/improve) · [기기 설계](https://create.roblox.com/docs/performance-optimization/design) | 원형 선분 1개 세트만 활성화하고, 삭제 시 예산을 즉시 반환한다. 실제 기기에서는 적 예고 인지와 프레임 시간을 확인한다. |

비교는 위 공식 설명과 프로젝트의 Studio 재현을 바탕으로 했다. 참고 게임의 실기기 프레임을 계측하지 않았다. 대표 타격 길이, 다음 예정 좌표, 취소와 중복 이벤트를 같은 시험으로 전후 비교한다. [결과와 재현 명령](../evidence/hero-skill-beats-20261121/README.md)
