# TLT-065 · Gloamwood 전투 가독성

2026-11-20 · Gloamwood에서 어두운 몬스터가 배경에 묻힌다는 플레이 피드백을 받았다. 현재 지역은 자정에 푸른 색 보정과 안개를 사용한다. 표적을 잡으면 금색 표시가 붙으므로 먼저 적을 찾아야 하는 순간의 가독성을 개선한다.

| 공식 사례에서 확인한 내용 | 적용 판단 |
| --- | --- |
| Diablo IV 시각 접근성 옵션으로 적의 윤곽선과 색을 지정할 수 있다. [Blizzard](https://news.blizzard.com/en-gb/article/23954932/combatting-demons-with-accessibility-in-diablo-iv) | 옅은 윤곽으로 어두운 배경에서 적의 형태를 드러낸다. |
| World of Warcraft의 Midnight 이름표는 위험 시전을 강조하고 선택하지 않은 적의 표시를 낮춘다. [Blizzard](https://worldofwarcraft.blizzard.com/en-gb/news/24244455/midnight-pre-expansion-content-update-notes) | 선택·도발·중력 상태의 전투 표시가 평상시 윤곽보다 우선한다. |
| Lost Ark 비디오 설정에서 밝기·그림자·FX를 조절할 수 있다. [Lost Ark 지원](https://help.playlostark.com/hc/en-us/articles/37754234136475-Accessibility-Options) | 먼저 해당 지역에서 그늘의 간접광을 보정한다. |
| Roblox의 `Ambient`는 그늘에 적용되며 `HighlightDepthMode.Occluded`는 가리는 형상 뒤의 표시를 숨긴다. [Lighting](https://create.roblox.com/docs/reference/engine/classes/Lighting) · [HighlightDepthMode](https://create.roblox.com/docs/reference/engine/enums/HighlightDepthMode) | 자정·안개를 유지하면서 그늘의 RGB를 `108,124,150` → `122,138,162`로 조정한다. 영웅 기준 48스터드 안에서 가까운 적 최대 10마리에게 은회색 윤곽을 적용한다. |

DES·QA 비교 장면은 실제 모형의 Webling처럼 낮은 적과 주변 수목이 들어오는 동일 카메라로 설정한다. 표적을 잡기 전 위치와 몸체를 구분할 수 있는지, 표적을 선택한 뒤 금색 표시가 유지되는지, 밀집 교전과 저화질에서 윤곽이 공격 예고와 겹치지 않는지 확인한다. 거리와 표시 개수는 첫 구현값이다. [검증](../evidence/gloamwood-enemy-visibility-20261120/README.md)
