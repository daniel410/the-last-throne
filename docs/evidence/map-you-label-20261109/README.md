# 상세 지도 YOU 표시 · 0.89.2

2026-11-09 · TLT-028/050/057/084 · UI 구현·로컬 엔진 검증 / 미게시

사용자 요청에 따라 상세 모험 지도의 현재 위치 화살표 옆에 영어 `YOU`를 표시했다. 기존 `Map.Center` 영어 문자열과 TD 공통 지도 색/이름표 스타일을 재사용한다. `DeepwoodMapCanvas`의 상세 지도에서만 생성하며, 기존 미니맵의 YOU/조작/배치는 유지한다. 글자는 화살표와 같은 투영 좌표를 따라가되 회전하지 않고, 지도 아래쪽에서는 화살표 위로 이동한다. 위치 정보가 없거나 지도 범위를 벗어나면 함께 숨긴다. 로비에서 모험 지도를 열었다고 플레이어가 그 지역에 있다고 표시하지 않는다.

변경: `src/client/DeepwoodMapCanvas.luau`, 기존 `tests/cartography-native.luau`, `VERSION`. 스토리·위치/이동·보상/저장·지도 도안·서버 권한 변경 없음. 제작 스킬/승인 TD 공통 룩앤필을 유지한 작은 표시 개선이다.

검증은 실제 Roblox GUI를 생성하는 기존 cartography 검사를 확장했다.44지역의 실제 좌표에서 YOU 표시·이동 좌표 일치·방향 화살표와 독립된 글자 회전·위치 없음의 두 표식 숨김을 검사한다. 기존44지역/2,201도형/2,745도로, 에픽 선택·체크포인트·세 화면 크기 및 미니맵 검사를 포함해 **6,803 PASS**.

첫 후보 실행은 기존 미니맵 검사의 `지역 중심 = 확장 포함 지도 중심` 가정에서 실패했다. 확장 날개가 비대칭이므로 이 가정이 맞지 않아, 제품을 바꾸지 않고 CampaignAreas.extent의 실제 정사각 투영 기대값으로 검증을 수정했다. 후보 재실행은 통과했다. 고정 빌드/원본 일치 확인은 아래 마감 기록을 따른다.

실제 게시 클라이언트·사람의 시각/조작 수용·터치/패드 실기기는 미검증이다. 다음 QA/사용자는 상세 지도에서 이동·회전·에픽 전환·리스폰 시 표시를 확인한다. 기존 사용자 자산/다른 작업은 보존하며 부모 티켓은 완료 처리하지 않는다. Roblox 게시/릴리스 태그는 생성하지 않는다.

## 고정 빌드 마감

소스 `d553bc02a2996b8b0f011c784a4635ba9f6f2884`를 origin/main에 푸시하고 `python3 tools/build-game.py --source HEAD --record docs/evidence/map-you-label-20261109/build.json`으로 **0.89.2 빌드 성공**. `builds/0.89.2/TheLastThrone-0.89.2.rbxlx`, 15,999,214 bytes, SHA256 `08436fe0e95cb70ef3cb891b42878f94117d0857e17619c2f04170a1b1338286` 재확인. 신규 LFS 자산 없음.

`run-in-roblox --place builds/0.89.2/TheLastThrone-0.89.2.rbxlx --script /tmp/tlt-map-you-native.luau`에서 변경 MapCanvas 원문 일치를 확인한 뒤 기존 지도 검사를 실행해 **6,803 PASS**. 검증 스크립트는 MapCanvas.Source 원문 assert와 `tests/cartography-native.luau`를 연결하며 Unicode 원문은 `json.dumps(..., ensure_ascii=False)`로 보존한다. [엔진 로그](native.log)·[집계](native.json). 첫 검증 스크립트의 JSON ASCII escape는 Luau에서 해석할 수 없어 실제 실행 전에 실패했으며, 검증 스크립트 인코딩만 바로잡아 같은 고정 파일로 재실행했다. 게임 파일 재생성 없음.

`python3 tests/single-build.spec.py --artifact builds/0.89.2/TheLastThrone-0.89.2.rbxlx` 역할10·도착 로딩192·프로젝트/별칭·실제 파일 계약 PASS. [로그](single-build.log). 실제 게시/기기 수용과 부모 티켓 완료는 후속이며, 증거는 별도 커밋으로 origin/main에 푸시한다.
