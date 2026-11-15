# TLT-064 · HG-03 묘역 군집

2026-11-15 공식 본문 재확인. 맵/환경 아트/환경3D/리서치 역할 순차 수행.

- [Diablo IV March 2022 환경 제작](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022): 지역의 역사·용도를 재질/건축/소품으로 전달하며 카메라 판독에 따라 디테일을 조절한다. 이 자료는 출시 전 개발 방향이며 현행 시즌 수치가 아니다.
- [WoW Retail Dragonflight Azure Span 소개](https://news.blizzard.com/en-us/article/23823429/dragonflight-zone-preview-the-azure-span): 생물군계·고저차와 거주민의 생활 문화를 연결한다. 현재 패치의 플레이 검증으로 간주하지 않는다.
- TLT 차이: 자유 카메라/근접 회피/PC·터치·패드와 기존 TD 미술을 유지한다. 타 게임 자산이나 레벨 구조를 복제하지 않는다. Roblox의 기존 ModelStreamingMode.Atomic과 EpicDetailSolid 충돌 계약을 사용한다.

해석/최소 실험: HG-03의 일렬/무작위 무덤을 최대4개의 작은 묘역으로 묶고 낮은 석축(3~5stud)을 배경에 둔다. Lumi가 안내하는 관리 통로의 빈 공간과 주변 묘역의 밀도를 구분하는 가설이다. 사건 진행 전에 개방/파괴 상태를 표현하지 않는다. 큰 지형 변경은 이번 실험에 포함하지 않는다.

비용/위험: 새 메시/텍스처 없음. 기존 EpicArchitecture.grave와 EpicEnvironmentKit.part 파생. 군집별 모델 단위 이동으로 무덤 간 관계를 유지하며, 낮은 벽의 충돌과 접지는 실제 Studio에서 검사한다. 최대12무덤+12벽. 안전 예약34stud, 군집간80stud, 5지점 높이차0.65stud 이하. 모든 후처리 이후 통행/시각 상태를 검사해야 한다.

수용: 최소3묘역/묘역당3무덤, 원본 루트 랜덤 소비 보존, 인접 지역의 기존 생성 유지. 기존/Easy 양쪽 HG 경로의 차단/바닥/보정/안내/단차0. 같은 Edit 카메라 전후 비교. 게시·실기기·사용자 미술 수용은 별도. 구현/실측은 [증거](../evidence/hg03-burial-plots-20261115/README.md)에 기록한다.
