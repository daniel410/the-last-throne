# Frozen Vale의 겹친 설면·기초 렌더 수정

2026-11-15 · TLT-062 · 환경 아트/맵 구현/ENG → QA · 로컬 구현·미게시

FV-03 근접/조감에서 보이던 짙은 청회색 사각형과 설면의 각진 경계를 조사했다. 실제 엔진에서 동일한 폭/깊이/회전의 `Support_FV-03`(Slate), `SnowGround`, `JourneyGround`가 높이92stud에 겹침을 확인했다. [변경 전 실제 속성](before-surfaces.json). 석재의RGB는 약74/102/128, 설면은222/236/242였다. 서로 다른 색의 불투명 면이 같은 높이에서 경쟁하던 명확한 렌더 결함이므로 별도 게임성 리서치는 추가하지 않았다.

## 변경과 범위

`FrozenSurfaceUnderlays`와 `CampaignSurfaceFinish`가 Frozen Vale10구역의 완전히 덮인 기초/옛 설면20개를 렌더에서 제외한다. 각 구역에 실제 불투명·고체 `JourneyGround`가 있고, 방향·윗면 높이와 전체 사각형 덮임이 맞는 경우만 적용한다. 하부 표면의 Transparency/그림자만 바꾸고 크기·CFrame·색/재질·충돌/쿼리/터치는 유지한다. 하부 표면은 새로운 보이지 않는 벽이 아니라 기존 평평한 중복 바닥이다.

덮는 바닥이 투명해지거나 작아져 완전히 덮지 못하면 저장해 둔 원래 표시 속성을 복원한다. 반복 호출도 안정적이어야 한다. 지역 높이/서버 Bounds·퀘스트·보상·저장·설목/빙하 원본·다른 지역 바닥은 변경하지 않는다. 신규 파트·메시·텍스처·조명·입자·프레임 루프는 없다. 네이티브 Terrain과 대표 보행면의 약한 재질 차나 실제 지역 외곽 전체를 이번 수정으로 모두 재제작했다고 보고하지 않는다.

## 비교 화면

0.109.1의 별도 QA 복사본 한 장면에서 카메라·FrozenVale 미복구 조명·지형/물리·스토리 상태를 고정하고, 최종 underlay 모듈만 후보 주입해 적용 전후를 촬영했다. 최종 고정 빌드의 무주입 검증과 후보 장면의 A/B 화면을 구별한다. 화면은 Studio Edit이며 실제 게시 클라이언트/전투 장면·사용자 수용이 아니다.

| 장면 | 적용 전 | 적용 후 |
| --- | --- | --- |
| FV-03 근접 | [before](before-approach.png) | [after](after-approach.png) |
| 설원 조감 | [before](before-overview.png) | [after](after-overview.png) |

캡처는 래스터 편집 없이 원본으로 보존하며 LFS 대상이다. 하부 Slate 판이 가리던 기존 Terrain 경계/굴곡도 보이게 됐지만 Terrain 자체를 다시 깎거나 움직이지 않았다.

## 고정 빌드 검증

빌드 **0.109.2**, 입력 소스 `ba41a009e4c6a7562c284a9c1f2830299dde6eff`. [빌드/LFS](build.json) · [정적 검사](static.log) · [전체 엔진 로그](native.log) · [구조화 결과](results.json) · [입력 해시](inputs.json).

```bash
python3 tools/build-game.py --source ba41a009 --record /tmp/fv-surface-build.json
python3 tools/prepare-fv-surface-native.py
```

생성된 `/tmp/tlt-fv-surface-native.luau`를 해당 고정 빌드의 격리 Studio에서 실행한다. 이번에는 다른 Studio와 파일을 혼동하지 않도록 `/tmp/tlt-fv-surface-fixed-unique.rbxlx` 복사본을 `RobloxStudio -localPlaceFile ... -task EditFile`로 직접 열고 Studio ID를 명시했다. 시작 직후 Play가 된 자체 QA 창만 Stop 후 사용하며 사용자/다른 작업의 Studio는 중지하지 않는다.

변경 모듈2개의 바이트 일치·전체 Luau 컴파일부터 확인하며 최종 검사에 소스를 주입하지 않는다. 새 검사는 전 맵 파트의 물리/표시 속성 반복 적용 불변, 덮는 바닥의 크기 부족/투명 상태에서 원래 표시 복구, 정상 덮임 재적용을 확인한다. 기존 미술/고체 충돌/교전 바닥/FV-03 지형·식생·두 경로 sweep/실제 FV03 보행도 함께 실행한다. 로그는 긴 줄이 잘리는 Studio stdout 대신 검사기의 `_G.SurfaceMessages` 원문에서 회수한다.

게시 클라이언트·실계정 재접속/스트리밍, PC/터치/패드 전투/회피·자유 카메라, 1~4인+AI 성능·미술 수용은 미검증이다. G5 전체 완료/최고 품질 달성으로 처리하지 않는다. 다음 QA/DES는 실제 클라이언트에서 표면 깜박임·먼 거리 LOD·경계와 길 가독성을 확인한다. Roblox 게시/릴리스 태그 없음. 별도 작업 트리에서 작업 파일만 커밋하며 기존 사용자 변경을 보존한다.

최종 결과: 하부20면 처리·전체 파트 물리 속성 불변/반복 표시 안정성과 덮임 실패 복구를 통과했다. 기존/Easy 두 sweep 모두 차단/바닥/보정/안내/단차0, 실제 FV03 봉화 왕복/스폰 접근4조건도 전부 도착·점프0/보정0이었다. 긴 MCP실행 응답은 타임아웃이었지만 엔진 검사는 종료까지 진행했고 마지막 `SURFACE_WALK_PASS`와 `_G.SurfaceMessages`의 원문을 회수했다. 타임아웃만으로 통과를 선언하지 않았다. 캡처·카메라 해시는 [기록](captures.json)에 보존한다.
