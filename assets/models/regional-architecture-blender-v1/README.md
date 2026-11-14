# 지역별 스토리 건축 · Blender MCP 원본

2026-11-13 · TLT-062/063/064/065/concept-map · ART/ENG

실제 Blender MCP, Blender5.2.0 LTS의 새 `TLT_Regional_Story_Architecture_20261113` 장면에서34종·1480파트를 직접 조형했다. 기존 `TLT_Deepwood_ElderGrove_v1` 및 기존 장면/선택을 유지한다. Standard/sRGB/Look None/Exposure0/Gamma1/Curves Off를 적용했고 셰이더 색에는 sRGB를 선형 변환해 입력한다.

- [전체 편집/교환 원본 GLB](RegionalStoryArchitecture.glb), [정확한 기본형/CFrame/sRGB/고체 JSON](kit.json), [재현 제작 소스](../../../tools/build-regional-architecture-blender.py), [Blender 실행/내보내기 실측](blender-export.log), [기하/GLB 검증](validation.json).
- 렌더: [Gloamwood](GW-kit.png) · [Frozen Vale](FV-kit.png) · [Ember Caldera](EC-kit.png) · [Haunted Graveyard](HG-kit.png).

GW7종은 뿌리 침식된 감시성채 아치·부서진 탑·작은 캔버스 피난처·석조 로프 받침·거미줄·매달린 화물 수레다. FV10종은 설원 구조소·피난처·쌍봉화·신호 기록고·썰매 창고·쌍잠금 문·거울 정자·선택3장소다. EC10종은 화물 승강기·작업장·보강 광산·쌍펌프·설계고·시험로·용광로·선택3장소다. HG7종은 관리인 문·동맹 쉼터·지하 통로·권양기 문·쌍장치·왕릉·빈 결속대다. 심장/NPC/상호작용은 기존 서버 스토리 장면이 담당하며 장식 원본으로 중복 생성하지 않는다.

런타임은 GLB 메시 업로드 대신 `RegionalArchitectureTemplates`와 `RegionalArchitecture`에서 같은 기본형·CFrame·색·고체 속성을 재구성한다. GLB는 지역별1000, 구조물별65/75의 전시 배치가 있으며 JSON의 CFrame은 모델별 로컬 좌표다. 원통 분할과 재질 표현은 Blender/Roblox에서 차이가 있다. `.blend` 전체 사용자 파일 저장·외부 생성기/유료 크레딧·외부 자산 업로드·TD 운영 자산 변경은 수행하지 않았다.
