# TLT-063 · 광산 작업 공간 조사

2026-11-17 확인. 질문은 평면 입구를 운반 궤도와 연결된 구조 공간으로 읽히게 할 수 있는가다. 리서치·환경 아트·환경 모델링·맵 구현 역할을 순차 적용했다.

- [Diablo IV 개발판 2022 환경 아트](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022): 재료와 건축물 구성으로 설득력 있는 환경을 만든다는 공식 설명을 재확인했다. 적용 해석: 별도 표식 대신 기존 궤도·입구·하중 보를 하나의 작업 공간으로 연결한다.
- [WoW Retail The War Within 지역 소개](https://news.blizzard.com/en-us/article/24125258/explore-the-zones-and-dungeons-of-the-war-within): Ringing Deeps의 산업·설비와 사건 연결을 참고한다. 적용 해석: 화산 장식보다 채굴 시설의 공간 기능을 강조한다. 현행 패치 수치 비교는 아니다.
- [Lost Ark 글로벌 Elgacia, 2023](https://www.playlostark.com/en-gb/news/articles/elgacia-release-notes): 도시·정원·성산의 구분된 장소 서사를 확인했다. 적용 해석: EC-03은 다른 화산 구역과 달리 구조 광산이라는 장소 정체성을 유지한다. 이 자료가 목조 보강 공법을 설명하는 것은 아니다.

우리 게임의 차이: 개인 구조 상태와 공유 시설이 분리되며 현재 목표 위치를 임의 이동할 수 없다. 기존 계약 충돌 없이 영구 보강 틀을 기존 bbox 안에 연결하는 최소 실험을 채택했다. 비용은 추가11 BasePart, 위험은 앞쪽 보에 의한 화면 가림이다. 장식 물리·bbox와 기존 형상을 격리 엔진에서 확인하고 실제 Play 카메라·NPC/HUD 수용을 후속으로 남긴다. [구현·비교·결과](../evidence/ec03-working-bay-20261117/README.md).
