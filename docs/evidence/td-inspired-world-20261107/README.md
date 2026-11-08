# TD 원본 맵을 참고한 TLT 3D 지역 개선

2026-11-07 · TLT-050/057/061~065/084/087 · DES/ART/ENG → QA · 0.83.2 · 로컬 구현·미게시

사용자는 TD 맵들을 참고해 TLT 맵들을 개선하도록 요청했다. [프로젝트 제작 스킬](../../../skills/the-last-throne-production/SKILL.md)을 적용했다. 이번 작업은 실제3D월드 구성과 그 지도 도면을 변경한다. 이전 에픽 확장 계획의 새 스토리·보상·영역·시간 가설 전체를 구현한 것은 아니다. [TD 원천·비교와 적용 판단](../../research/2026-11-07-td-world-composition.md).

## 변경

- **44개 지역에 서로 다른 구성 프로필과 주 랜드마크1개**를 배치했다. 실제 TD `ForestLandmark`/`SnowLandmark`/`VolcanoLandmark`/`CemeteryLandmark`와 보조 절벽·설송을 사용한다. 모델143개가 새 구성에 참여한다. 주연은 비대칭 위치, 낮은 보조군, 열린 전투 전경으로 구분한다.
- **Deepwood:** 같은 회랑/높은 나무벽 반복을 줄이고 거목 거점·감시탑·점령 요새·뿌리/제단 실루엣을 구별한다. 폭포/협곡은 Elder Tree Outpost와 Waterfall Quarry에 유지해 지역 특성으로 삼는다.
- **Gloamwood:** 반복된 양쪽 거목·고밀도 나무벽을 줄인다. 원형은 TD 숲을 사용하고 큰 수관의 어두운 파생 재질과 가지 주변 거미줄을 결합한다. 실제 기존 스토리/거미줄 구조 목표는 유지한다.
- **Frozen Vale:** 반복된 primitive 설송을 TD `SnowTree` 원본으로 교체한다. Blizzard Gate/Wolf Ravine/후반 성문·궁전은 빙문 랜드마크와 낮은 눈 지형으로 구분한다. 모든 장에 같은 성채/수로를 넣지 않는다.
- **Ember Caldera:** TD 현무암/용광로 실루엣과 낮은 암반 군을 사용하고 기존 Forge City/광산/수로/Great Furnace를 유지한다. 용암 골짜기에 랜드마크가 묻히지 않도록 실제 지면을 검사해 배치한다.
- **Haunted Graveyard:** 전 지역에 같은 대성당을 반복하는 대신 초반 폐예배당, 피난처·이름의 정원·종탑, 후반 왕릉/성채를 구분한다. 녹색 풀 상면이 강한 보조 섬은 복제 인스턴스의 재질만 회색 석조로 파생한다.
- TD 절벽 원본은 아래로 좁아지는 부유섬이므로 **몸체를 지면 아래 묻어 낮은 지형**으로 사용한다. 회전 후 전체 footprint를 스토리 목표/활동·스폰·연결로·이웃 지역과 대조한다. 장식은 Anchored·CanCollide/CanQuery/CanTouch=false, 기존 거리별 표시 예산에 참여한다. 데이터·보상·전투 수치·목표/체크포인트 좌표는 변경하지 않는다.
- 실제 변경 월드에서 **지도/미니맵 도면을 재생성**했다. 큰 지도의 랜드마크 이름도 TD 주연 모델의 실제 위치에 투영한다. 탐험·잠금·파티 표식·체크포인트 이동 자격을 유지한다.

## TD 원본과 시각 비교

현재 TD 원본 파일 두 개와 RPG pinned 사본은 바이트 단위로 일치한다. [경로·SHA-256·범위](td-sources.json). TD 파일이나 원본 모델·운영 게임·게시 권한을 변경하지 않았으며 새 외부 업로드도 없다.

동일한 로컬 전체 생성 월드·ClockTime14/동일 광량·같은 카메라에서 촬영했다. 화면은 실제 Studio3D뷰포트이며 생성 컨셉 그림이나 게임 플레이/실기기 수용 증거가 아니다. [카메라·이미지 해시·전후 수량](comparison.json).

| 대표 지역 | 변경 전 | 최종 변경 후 |
| --- | --- | --- |
| Deepwood 거점 | [before](before-DW-03.jpg) | [after](after-DW-03.jpg) |
| Gloamwood 뿌리길 | [before](before-GW-04.jpg) | [after](after-GW-04.jpg) |
| Frozen Vale 협곡 | [before](before-FV-03.jpg) | [after](after-FV-03.jpg) |
| Ember Caldera 용광로 | [before](before-EC-07.jpg) | [after](after-EC-07.jpg) |
| Haunted Graveyard 입구 | [before](before-HG-01.jpg) | [after](after-HG-01.jpg) |

직접 비교 후 초기 배치에서 떠 보이던 절벽, 화산 고지 아래 묻힌 랜드마크, Gloamwood의 원색 수관을 수정했다. 최종 사진은 그 수정을 포함하고 TD 메시 PreloadAsync 후 촬영했다. 높은 전체 카메라에서 지역별 원형과 밀도 차이를 확인한 범위이며 사람의 최종 미술 수용으로 선언하지 않는다.

전체 생성 파츠는 **69,387 →43,302개(-37.59%)**, MeshPart 인스턴스는 **9,743 →6,127개(-37.11%)**다. 장식 감소와 TD 메시 교체를 합한 전체 정적 수량이며 모바일 FPS나 동시에 스트리밍되는 수량을 뜻하지 않는다. 삼각형/GPU/메모리/4인+AI 수용은 별도다.

## 검증

| 조건/명령 | 결과 |
| --- | --- |
| `run-in-roblox --place <현재 소스 폐기용 fixture> --script tests/td-scenic-composition-native.luau` |44지역 프로필·주연1개·TD 원본·장식 물리/쿼리 제외·회전 bounds와 목표/활동/스폰 여유·거리 예산·반복 생성/스폰 보존 검사. **1,254검사 PASS**. [결과](td_scenic_qa.json) |
| `python3 tools/prepare-map-traversal-native.py` → `run-in-roblox --place /tmp/tlt-td-world-final.rbxlx --script /tmp/tlt-map-traversal-native.luau` | **PASS·CLI종료0**.44지역·360앵커, 길34,041표본/거점100표본, 장애물0·바닥/앵커 문제0.47장(35메인+12사이드)·43연결·10귀환의 이동/전투/복귀 검사. [바닥·충돌](map_traversal.json), [전체 동선](campaign_routes.json) |
| 같은 실행의 기존 충돌 정리·감시탑 회귀 | **511 /573검사 PASS**. [정리](campaign_clearance_native.json), [감시탑](deepwood_watchtower_road.json) |
| `tools/export-cartography-native.luau` → `python3 tools/compile-cartography.py --log <추출 로그>` | 실제 변경 월드44지역 도면 재생성. [최종 도면 추출 통계](survey.json) |
| 네이티브 지도 회귀·빌드 고정 소스 검사 | **5,810 /416검사 PASS**. 실제 TD 주연 모델 위치로 지도 이름 투영·44지역·원형 미니맵·0.6배 HUD·5에픽/사이드·모바일 가로/세로·확대/FIT. [도면/미니맵](cartography_qa.json), [지도 회귀](deepwood_atlas_native.json) |
| `git diff --check` | PASS |

이동 검사는 실제 엔진 Pathfinding/충돌·바닥 표본의 오프라인 감사이며 사람의 조작·전투 난도·공개 계정/기기 시험과 다르다. 최초 이동 감사 실행은 앞선 폐기 Studio 세션의 종료 직전 CLI 포트가 점유되어 실패했고 세션 종료 후 동일 명령 재실행을 통과했다. 기존203785492 asset-type 경고는 결과에 영향이 없다.

## 미검증·다음 담당

실제 PC/모바일의 낮은 영웅 카메라·전투/VFX·입력·4인+AI·프레임 시간·게시 자산 권한은 미검증이다. 높은 카메라에서는 기존 지역 사이 공백/수평 전투장·일부 반복 석조가 여전히 보이며 이 작업이 전체 월드 지형/건축의 최종 미술 완성이나 스토리 확장 완료를 뜻하지 않는다. 기존 계정 진행·아이템/경제·서버 전투 규칙은 유지하고 부모 티켓은 In Progress로 둔다. 다음 담당은 QA/사용자의 대표5지역 실플레이 시각·길찾기/성능 수용이다. 실제 Studio 작업 중 장면에 일부 모듈을 혼합 적용하거나 Roblox 게시·릴리스 태그를 만들지 않았다.

## 고정 소스 빌드·마감

**0.83.2 성공** · 입력 소스 `08b78698007d5bc5cb6c0eb7a55c06e9848d1b91` · 산출물 `builds/0.83.2/TheLastThrone-0.83.2.rbxlx` · SHA-256 `2f8b3b659c2631e5999d4e6af5fb3ad3be0ee4949234585b8958e64e13110267` ·15,001,764bytes. [빌드](build.json), [고정 빌드 검사](committed-build-checks.json).

빌드 산출물의 변경5개 핵심 모듈이 입력 소스와 동일함을 확인하고, 같은 파일에서 랜드마크1,254·지도/미니맵5,810·전체 지도416 = **7,480네이티브 검사 PASS·CLI종료0**를 재실행했다. 이미지10개는 native JPEG바이트를 보존하며 확장자도jpg로 정리했다. Git LFS로 전송하며 Roblox 자산을 새로 업로드하거나 Place를 게시하지 않는다.
