# 네 영웅의 강타와 파티 피격 가독성

TLT-033/057/059 · 2026-11-21 · 비교 기준 0.115.24

이전 후보에서 연속 명중, 산개 착탄, 발사·조준 방향을 검증했다. 이번에는 한 적에게 강타 직후 약타가 오면 약타의 피격 자세가 앞의 강타를 덮는 경우를 재현했다. Vanguard Strike, Stonebound Leap, Fan Break, Stone Lance를 대표 사례로 삼았다. 각 기술은 전진 찌르기, 착지 강타, 밀어내는 산개 화살, 무거운 투사체라는 서로 다른 움직임이 있다. [이전 후보 검증](../evidence/hero-skill-beats-20261121/README.md)

| 공식 사례 | 확인한 표현 | TLT 적용 |
| --- | --- | --- |
| Diablo IV · 2021년 12월 개발자 업데이트 | 타격 영역과 동작을 맞추고 주문·근접 공격의 진행 방향을 몬스터 피격에 전달한다. 적 예고에는 전투 중 높은 시각 우선순위를 준다. [Blizzard](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 서버가 전달하는 명중 방향을 기준으로 전진, 하향 압축, 바깥쪽 산개, 하향 파쇄를 구분한다. |
| World of Warcraft Retail · The War Within 11.2 | Spell Density 개편은 전투 판단에 덜 중요한 주문 표현을 줄여 조우 가독성을 높인다. Legion 7.3의 개발 설명은 무거운 주문의 직선적인 팔 움직임과 짧은 손목 시전도 구분한다. [11.2 업데이트](https://news.blizzard.com/en-us/article/24226698/ghosts-of-k-aresh-content-update-notes) · [Legion 7.3 시전 애니메이션](https://wow-site-bwa-production-eks-prod-use1-01.worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) | Stone Lance에는 낮게 모아 전방으로 미는 팔 동작을 주고, 아군도 두 획으로 핵심 방향을 읽을 수 있게 한다. |
| Lost Ark 글로벌 · Destroyer 2022년 5월 / Gunner 2021년 8월 | Jumping Smash는 도약에서 내려치기로 이어지고, Deadeye의 Hour of Judgment는 부채꼴 발사 뒤 명중 파편이 생긴다. [Destroyer](https://www.playlostark.com/en-gb/news/articles/lost-ark-academy-destroyer-class) · [Gunner](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) | Stonebound Leap은 공중에서 두 무릎을 접고 착지하며, Fan Break는 앞다리로 버틴 뒤 들어온 방향을 따라 짧게 퍼지는 획을 남긴다. |
| Roblox Creator Hub · 하드웨어 검증 | 기기 시뮬레이션과 실제 모바일의 프레임 시간, 열, 입력 지연이 다르다. 실제 기기에서 연속 세션과 MicroProfiler 캡처를 권장한다. [하드웨어 검증](https://create.roblox.com/docs/performance-optimization/test-on-hardware) | Studio는 화면 겹침, 동작 및 효과 수를 비교하고, 프레임 시간과 터치 중 예고 인지는 게시된 후보를 실기기에서 확인한다. |

선행 강타의 자세가 처음 정점에 이르는 동안 더 약한 타격이 강타를 덮지 않도록 약 44~64ms의 표시 구간을 둔다. 짧은 자세 우선순위는 피격 렌더링에만 적용한다. 확인된 피해 표시, 발사·착탄 시점, 피해 판정과 적 상태는 기존 제품 계약을 따른다. 표본에서 강타·약타 수신 순서를 뒤집고, 다음 타격이 늦게 들어오면 자연스럽게 방향을 바꿀 수 있는지 본다.

조사는 공식 문서와 기술 설명에 기반한다. 참고 게임의 프레임 시간과 실시간 플레이를 측정한 결과는 없다. [TLT 전후 증거와 QA 인계](../evidence/hero-force-feedback-20261121/README.md)
