# TLT-064 · HG-05 비교 카메라 정정

2026-11-18 UTC. MAP/ART/환경 모델링 순차 검토. 맵 품질 개선 작업의 검증 보완이며 생산 구현 완료가 아니다. G5 미완료.

## 확인한 문제
기존 벽측 도관 실험의 카메라 origin(-270,197,-17330), aim(-285,190,-17359)를 원본 장면에 적용하면 서쪽 ShieldBeam 중심(-254.85,192,-17309.40)의 전방 깊이가 **-23.6478stud**다. 중심이 카메라 뒤에 있어 기존 before 이미지의 광선 부재를 가림 증거로 사용할 수 없다. 긴 광선 전체가 시야 밖이라는 판정은 하지 않았다.

기존 QA 파일이 다시 열린 Edit Studio 5d648f96에서 읽기 전용으로 검사했다. 현재 장면에는 원본 ActiveThroneConduit/BrokenThroneConduit가 있으며 후보 하우징은 없다. 따라서 지난 실행 당시 후보의 가림 원인을 재현했다고 볼 수 없다. 현재 카메라도 당시 저장 좌표와 달랐다. 검사 중 장면·카메라·사용자 Studio를 변경하지 않았다.

## 검사 결과와 한계
camera-audit.luau는 실제 생성된 두 ShieldBeam의 중심과 과거 카메라 LookVector 내적을 계산한다. 서쪽 중심 음수 assertion 통과. 동쪽 중심도 -445.6100이나 원래 서쪽 비교 구도이므로 동쪽 화면 결함으로 해석하지 않는다. correctedOrigin/ correctedAim은 다음 촬영의 중심 정렬 시작점이며 실제 캡처·시야 수용은 미검증이다.

segment-audit.luau는 같은 카메라→aim 선분과 9,450 BasePart의 방향성 경계 상자 교차를 검사했다. 불투명도 기준 Transparency<0.95에서 교차0. Mesh 실제 표면·Terrain·전체 영상 영역 검사가 아니다. ShieldBeam은 CanQuery=false이므로 일반 raycast만으로 가시성을 판정할 수 없다. 지형 절삭이나 소품 이동을 정당화하는 결과가 아니다. 원문 MCP 결과는 JSON으로 보존했다.

## 연구와 적용
2026-11-18 공식 본문 확인. 직접 플레이·최신 라이브 패치 평가는 아니다.
- [Diablo IV 2022 환경 제작](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022): 재료·건축·지역 역사에 따른 설득력. TLT 적용 가설은 장치 중심을 볼 수 있는 구도에서 지지 구조를 평가하는 것.
- [WoW Retail Dragonflight 알파 Azure Span 소개](https://news.blizzard.com/en-us/article/23823432/world-of-warcraft-news-and-development-updates): 큰 고도 차와 지역 변화. 지형 고도 조정 전 카메라 구도 검증을 우선한다는 것은 TLT 해석이다.
- [Lost Ark 글로벌 Voldis 제작기, 2024-02-02](https://www.playlostark.com/en-us/news/articles/creating-voldis): 탑의 높이로 지역 주제를 전달. TLT는 서/동 방어 장치의 기능을 읽히게 하는 실루엣을 검토한다.

추가 원시도형·저상 도관 후보는 만들지 않았다. 기존 서사·보상·저장·TD 계약 변경 없음. 생산 소스/VERSION/빌드/게시/태그 없음.

## 다음 담당과 수용
MAP/ENG/QA: 최신 고정 빌드의 정상 HG-05 플레이에서 실제 서/동 장치를 조작하고 귀환 화면을 촬영한다. 목표 중심의 카메라 전방 깊이>0을 먼저 확인한 뒤 동일 카메라 전후·전체 화면 가림을 비교한다. 확장 도관과 본편 장치는 별개이므로 각각 검증한다. 실제 R15/상태 복원/전투·회피/게시 클라이언트/실기기/다인 성능/사용자 미술 수용은 이번에도 미검증이다.
