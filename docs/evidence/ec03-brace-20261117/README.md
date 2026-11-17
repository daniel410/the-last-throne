# TLT-063 · EC-03 구조 지지대 소스 개선

2026-11-17 UTC. 제작 스킬의 리서치·환경 아트·환경 모델링·맵 구현 역할을 순차 수행. G5 미완료. 전체 광산 재구성이나 최고 품질 달성으로 판정하지 않는다.

## 변경과 제작 근거

EC-03은 광산 지지→Magma Worm 저지→광부/Orik 구조 순서다. `StoryQuestGeometry.MineBrace`의 단순 목제 받침을 철제 바닥판·목제 쐐기·결속 띠/리벳·나사산·압력판·갈라진 상부 보로 재구성했다. 손잡이 BraceHandle, 로컬 원점, 기존 4×3.75×2stud 범위와 StoryPropAssignments의 supports/operate 연결을 유지한다. 위치·목표·보상·저장·상태 전환은 변경하지 않았다. 7→27파트(+20/생성 인스턴스), 신규 메시/텍스처/스크립트0. 장식은 충돌/터치/쿼리 비활성이다. 기기 성능은 측정하지 않았다.

원본/파생: 저장소 자체 네이티브 제작물 StoryQuestGeometry의 MineBrace를 Derived 처리. 외부 자산/TD 원본 변경 없음. 이전 형상은 Git 기준 e1bfe0a6의 같은 파일에서 복원 가능하다. Blender를 사용하지 않았다. 대형 광산 시설과의 공간 연결은 이전 접근 검토에서 요구한 실제 Play 대조 전이므로 이번 범위에 포함하지 않았다.

## 조사와 적용 해석

과거 공식 사례를 2026-11-17 재확인했으며 현행 패치 규칙은 비교하지 않았다.

- [Diablo IV 개발판 2022 환경 아트](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022): 재료와 건축물 구성의 설득력, 게임 카메라에 따른 디테일 조절을 설명한다. 적용 해석은 하중 전달이 읽히는 받침과 결속 구조다.
- [WoW Retail The War Within 지역 소개](https://news.blizzard.com/en-us/article/24125258/explore-the-zones-and-dungeons-of-the-war-within): Ringing Deeps는 원료 채굴·용해와 고장 난 설비 복구를 지역 사건에 연결한다. 적용 해석은 화산 장식보다 실제 구조 장치의 기능을 드러내는 것이다.
- [Lost Ark 글로벌 Elgacia 2023](https://www.playlostark.com/en-gb/news/articles/elgacia-release-notes): 도시·정원·성산을 구분한 장소 서사를 설명한다. 적용 해석은 사건별 소품 구분이며 이 문서가 지지대 설계 기법을 설명한다는 주장은 아니다.

## 검증·재현·한계

기존 0.111.30 기반 로컬 XML 복사본 `/tmp/tlt-brace-review.rbxlx`에서 Script/LocalScript를 비활성화했다. 자체 Studio `32e42554-f714-4569-b1bc-0e61146549f4`, Edit/PlaceId0/플레이어0 조건에서 [verify.luau](verify.luau)를 실행했다. 해당 스크립트는 후보 소스를 내장하고 복제 모듈에서 실제 StoryProps.build를 호출한다. 기존 사용자 Studio는 수정하지 않았다.

[엔진 결과](results.json): 후보 구문 컴파일·양수 크기/실제 bounding box·장식 물리·손잡이/압력판 존재 확인, 나머지54종의 전체 geometry JSON 일치 통과. 자산별 검증이며 전 지역 이동 sweep 또는 실제 Play 수용이 아니다.

[비교 화면](comparison.jpg): 왼쪽 이전/오른쪽 후보. 동일 프레임, 서로 다른 표시 위치. 촬영용 Slate 평면 위에 배치했다. 첫 기존 조명이 너무 어두워 검사 전용 ClockTime12/Brightness2/Ambient155로 촬영했다. 실제 EC 조명/카메라·HUD·개인 NPC·상호작용 상태 화면이 아니다. 크랙/철제 받침은 구분되나 실제 전투 거리에서 세부 식별 가능 여부는 미검증이다.

게임 빌드/버전 증가/Roblox 게시/릴리스 태그 없음. 런타임 소스 후보를 커밋한 상태다. 다음 담당 ENG/ART/QA: 최신 고정 빌드에 통합 후 EC-03 실제 Play supports→miners 개인 투영/상호작용 전후와 영웅/HUD를 대조하고, 광산 입구와 구조 지점의 공간 연결을 제작한다. 게시 클라이언트·실기기·다인·성능·사용자 미술 수용은 남아 있다. 작은 외곽 소품의 추가 증량을 반복하지 않는다.
