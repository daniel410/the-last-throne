# 영웅 기술의 일반 명중과 적 준비 차단

2026-11-23 · TLT-033/057/059 · 조사 기준 0.115.67

직선 공격의 반동, 표식, 감속 및 자세 붕괴는 최근 후보에서 각각 화면에 드러난다. 일반 적의 공격 준비나 Shaman 계열의 지원 시전을 취소한 타격은 적의 상태와 예고를 바꿨지만 영웅 기술의 명중 획은 일반 적중과 같았다. 이번에는 협동 교전에서 이 차이를 한눈에 확인할 수 있는지 살폈다. 아래 관찰은 공식 개발자 글과 서비스 설명을 읽은 결과다.

| 공식 사례 | 관찰과 TLT 적용 |
| --- | --- |
| Diablo IV, 2021년 12월 개발자 업데이트 | 피격 위치와 공격 방향을 연결하고 명암이 다른 배경에서도 기술을 읽도록 강조점을 조절한다. TLT는 서버 피격 방향을 기준으로 적의 진입면에서 차단 획이 바깥으로 열리게 했다. [Blizzard](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) |
| World of Warcraft Retail, Legion 7.3과 The War Within 11.2 | Legion은 무게감 있는 자세를 만들면서 발사 타이밍의 일관성을 맞췄다. 11.2 Spell Density는 조우 판단에 기여하는 효과를 우선했다. TLT는 기존 발동 박자에 네 기술의 준비·회수 자세를 얹고, 차단 명중에는 190ms 동안 주 획 두 개를 사용했다. [Legion 애니메이션](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) · [11.2 변경점](https://news.blizzard.com/en-gb/article/24226698/ghosts-of-karesh-content-update-notes) |
| Lost Ark 글로벌, Destroyer Academy와 Gunner 소개 | Destroyer는 무기 회전과 큰 내리치기를 발동 단계별로 구분한다. Sharpshooter도 Arrow Shower의 낙하와 Arrow Wave의 진행 경로가 다르다. TLT는 Mountain Sweep의 낮은 축과 피격선, Precision Volley의 세 차례 시위 회수를 각각 살렸다. [Destroyer](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-destroyer-class) · [Sharpshooter](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) |
| Roblox Creator Hub | Beam의 끝점·폭·곡선을 제어할 수 있으며 겹치는 반투명 표면은 렌더링 비용을 늘린다. 차단 명중은 Beam 두 개로 처리하고 기존 예산에 포함했다. [Beam](https://create.roblox.com/docs/reference/engine/classes/Beam) · [렌더링 비용](https://create.roblox.com/docs/performance-optimization/improve) |

일반 명중과 차단 성공을 비교하는 기준은 같은 기술, 같은 피격면, 같은 카메라다. 차단 플래그에는 서버의 기존 일반 준비·지원 시전 취소 결과를 사용한다. 사망·흡수·이미 발동한 공격에서 차단이 보이면 실패다. 자세 붕괴와 표식이 일어난 타격은 기존 상태의 획이 우선한다. 네 영웅이 함께 공격하는 장면에서는 적의 붉은 예고선과 피해 숫자의 판독이 다음 수용 조건이다. [구현과 검증](../evidence/hero-windup-interrupt-20261123/README.md)
