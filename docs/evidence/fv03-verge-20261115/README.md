# FV-03 설목 군집과 길목 시야 개선

2026-11-15 · TLT-062 · 환경 아트/모델링/맵 구현 → QA · 로컬 구현·미게시

작은 설목2열의 반복을 TD 원본의 높이·방향이 다른 군집으로 대체한다. 새 나무 종류·외부 메시·텍스처·Blender 원본을 만들지 않는다. [조사와 채택/보류](../../research/2026-11-15-fv03-snow-verge.md) · [빌드](build.json) · [엔진 결과](native.log) · [정적 검사](static.log).

| epicId/storyId·원천 | 사건과 공간 목적 | 변경/상태 | 검증 장면 |
| --- | --- | --- | --- |
| FrozenVale/FV-03, 현재 줄거리 FV-03·맵 명세 협곡 항목·CampaignContent | 협곡지기 구조→횡단로/양안 봉화 복구. 요새 경보/폭풍은 아직 남는다. | 열린 전투/신호 공간과 대비되는 가장자리 설목 군집. 개인 진행과 무관한 정적 식생이며 복구 완료/폭풍 해제를 선행 표시하지 않는다. | 가까운 접근 화면과 조감, 줄기/잎 충돌·실제 발밑 바닥·봉화선, 기존/Easy 전 지역 경로와 FV-03 R15 접근/왕복. |

`FrozenRavineVegetation`가 기존 TD `SnowTree`를 직접 재사용하고 크기/회전/배치만 파생한다. 원천 파일/권한은 `DeepwoodEnvironment`가 가리키는 `assets/shared/td-deepwood-environment/manifest.json`, 실제 템플릿은 `ServerStorage.TDMapModels.SnowTree`다. 최대18모델/54파트, 유한 후보 탐색이며 per-frame 루프/입자/조명/새 업로드는 없다. 큰 얼음/대표 건축과 목표·퀘스트·보상/저장·도보 연결은 유지한다. 다른 구역의 식생 분기는 바꾸지 않는다. FV-03 미술 생성 순서가 달라져 같은 구역의 랜덤 소형 바닥 장식도 달라질 수 있다.

첫0.108.2 후보는 실제 빙하 경사/예약 때문에1개만 배치돼 군집 수용 검사에 실패했다. [실패 로그](0.108.2-attempt.log)·[당시 고정 빌드](0.108.2-build.json)를 보존한다. 전투/신호/평탄 발밑 기준을 완화하지 않고 군집 주변의 유한 후보를 추가 탐색하도록 수정해0.108.3으로 다시 동결했다. 첫 실패는 최종 통과 검사에 합산하지 않는다.

## 재현과 비교 조건

```bash
python3 tools/build-game.py --source c1efbc86 --record /tmp/fv03-verge-build.json
python3 tools/prepare-fv03-verge-native.py
run-in-roblox --place builds/0.109.1/TheLastThrone-0.109.1.rbxlx --script /tmp/tlt-fv03-verge-native.luau
```

소스를 주입하지 않고 변경2모듈의 바이트 일치·전체 Luau 컴파일부터 확인한다. 실제 검사에서는 다른 실행이50312포트를 사용 중이어서 기존 별도 포트 실행기 `/tmp/tlt-run-in-roblox-50314`를 사용했다. 다른 Studio/Play를 종료하거나 수정하지 않는다. 기존/Easy의 GW/FV/EC/HG4지역 sweep에서 차단/바닥/보정/안내/단차 실패0을 요구한다. 대표물·생활 구성·양수 고체 충돌·FV-03 지형도 함께 검증한다.

FV-03 신규 검사는 원본 MeshId/TextureID 보존, 선언/실제 접지, 유한 예산·크기/군집 다양성, 줄기 고체/잎 비충돌, 봉화선 시야를 실제 엔진에서 확인한다. FV-03 R15 보행은 별도 fresh 장면에서 전후 캡처 뒤 실행한다. 물리 Run/Stop 뒤 장면 복원 간섭을 화면 비교에 섞지 않는다.

| 화면 | 변경 전0.108.1 | 변경 후0.109.1 |
| --- | --- | --- |
| 근접 접근 | [before](before-approach.png) | [after](after-approach.png) |
| 조감 | [before](before-overview.png) | [after](after-overview.png) |

동일 카메라/미복구 FrozenVale 조명을 사용한 Studio Edit 화면이며 실제 전투 클라이언트 캡처나 사용자 미술 수용이 아니다. 이전 실제 수치는15나무/45파트였다. 원본 이미지/3D 파일을 바꾸지 않았고 비교 캡처4장은 LFS로 저장한다. 개발 보고와 게임 미술 수용을 구별한다.

## 남은 수용

게시 클라이언트·실계정/재접속/실제 스트리밍, PC/터치/패드 전투/회피·카메라 자유 조작, 1~4인+AI 프레임/메모리, 군집 미술/길 이해도 사용자 수용은 미검증이다. 큰 평지·각진 지역 경계는 여전히 남으며 최고 품질 달성 또는 G5 완료로 처리하지 않는다. 다음 QA/DES는 실제 전투 카메라의 가림·신호 식별성과 자유 조작/기기 성능을 확인한 뒤 다른 스토리로 확대한다. Roblox 게시/릴리스 태그 없음.

최종 빌드는 동시 진행된 난이도별 진행 변경을 병합한 **0.109.1**, 소스 `c1efbc862fb92a8bd8ad154e88ff1e85f202a863`이다. 실제 설목12개/5군집/6높이/36파트, 신규255검사를 통과했고 원본15개/45파트 대비 파트20%를 줄였다. 두 경로의 차단/바닥/보정/안내/단차0, 실제 FV-03 봉화 왕복/스폰 접근4조건도 모두 도착·점프0/보정0이었다. [전체 구조화 결과](results.json)·[FV 실제 보행](walk.log)·[입력 해시](inputs.json)·[카메라/이미지 해시](captures.json)를 따른다. 원경 전체의 색상/음영 차이를 식생 변경의 효과로 단정하지 않는다.

별도 포트 실행기의 후속 시도도 장면 참조 오류로 끝나 [실행기 오류](runner-attempt.log)를 보존했다. 최종 고정 파일을 `RobloxStudio -localPlaceFile ... -task EditFile`로 직접 열어 해당 Studio ID의 `execute_luau`로 생성된 검사 스크립트를 실행했다. 긴 호출의 응답은 시간초과였으나 엔진 검사는 계속 진행돼 마지막 통과 결과까지 완료됐으며, 종료 후 해당 장면의 `_G.VergeMessages`에서 잘림 없는 원문 로그를 회수했다. API 시간초과를 엔진 통과로 대체하지 않았다. 별도 fresh Edit 장면에서 비교 화면을 찍고 FV 보행 검사를 마지막으로 실행했다.
