# TLT-063 · 광산 구조 접근 가독성

2026-11-17 확인. 게임 규칙이나 현행 패치 비교가 아닌 과거 공식 환경 설계 사례다.

- Diablo IV 개발판, 2022-03-29 [환경 아트 보고](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022): 본문에서 전투·동선·서사 의도 및 게임 카메라에 맞춰 디테일을 가감하는 방식을 확인했다. 적용 해석: 넓은 외곽 촬영보다 접근 시 목표와 시설이 함께 읽히는지 우선 측정한다.
- WoW Retail Shadowlands, 2020 [Revendreth](https://worldofwarcraft.blizzard.com/en-us/news/23391567): 이번 직접 요청403. 본문/이미지 재확인 불가. 기존 조사 범위를 넘는 신규 관찰·기법은 주장하지 않는다.
- Lost Ark 글로벌, 2023-06-13 [Elgacia](https://www.playlostark.com/en-gb/news/articles/elgacia-release-notes): 공식 본문에서 Ereonnor·Hestera Garden·Mount Phylantos의 서사 장소 구분을 재확인했다. 적용 해석: EC-03의 구조 시설과 단순 바위 배경 사이 공간 위계를 강화한다. 문서가 특정 카메라 기법을 설명한 것은 아니다.

| epicId/storyId·원천 | 사건·지역 | 표현·위치·상태 | 최소 실험·판정 |
| --- | --- | --- | --- |
| EmberCaldera/EC-03, EmberCalderaContent의 supports/miners | 균열 지지대 보강→벌레 저지→광부 구조 | 기존 지지대/광산/구조 위치의 접근 관계 검토. 공통 배경·개인 상태 변경 없음 | 안내 폴리라인20stud 앞/줌24/30도에서 목표 중심과 주변 시설 확인. 실제 Play 투영과 대조 후 제작 |

대안: 외곽 지형 증량은 직전 작업과 반복되고 목표 가독성 근거가 약해 보류. 이번에는 원본 TD/Blender 변경 없이 검토 도구를 채택했다. 런타임 비용0, 로컬 검토 비용만 발생한다. 새 지형/서사/보상/규칙 도입 없음. 화면 중심/충돌 ray만으로 목표 식별성을 보장할 수 없으므로 실제 Play와 사용자 수용을 다음 게이트로 남긴다. [측정·화면·다음 담당](../evidence/ec03-approach-review-20261117/README.md).
