# 엘프 활·시위·화살 당김과 발사 개선

2026-10-31 · TLT-005/032/033/055/057/084 부분 구현 · ART/ENG → QA/DES

사용자 요청과 이어진 “승인 묻지 말고 계속” 지시에 따라 제작·검증·빌드 마감을 진행했다. [조사/판단](../../research/2026-10-31-elf-bow-draw-release.md). TD의 기존 나무 활·PBR 정체성을 유지하면서 시위/화살/손의 연결과 당김→앵커→발사→후속 자세를 개선했다. 새 체형·완성 엘프 영웅 외형을 제작한 결과와 구분한다.

## 실제 Blender MCP 제작

[원본 메시 조사](01-inspect-result.json) 뒤 [Blender MCP 내부 API](02-author.mcp.json)로 `TLT_Elf_Bow_Authoring` 장면, 왼손 무기 소켓의 R15 리그, 활 DrawFlex·화살 DrawToAnchor·위/아래 시위 Shape Key와 `Elf_Draw_Anchor_Release` Action을 만들었다. 관절/시위 제어 **25 F-curve·250 keyframe**, 별도4 Shape Key 곡선이 있다. 별도 Python 실행 파일은 사용하지 않았다. 안전 모드가 드라이버를 거부해 이를 비활성화하지 않고 실제 키프레임으로 바꿨다.

[편집 가능한 Blender 원본](../../../assets/animations/elf-bow-v1/elf-bow-refined.blend) · [활 전용 정적 검토 GLB](../../../assets/animations/elf-bow-v1/elf-bow-refined.glb) · [추출 곡선/독립 샘플](../../../assets/animations/elf-bow-v1/clip.json) · [저장 결과](05-save-result.json). GLB에는 활·화살·시위2가닥과 엘프 리그만 포함하며 다른 무기 Action/바닥은 제외했다. 전체 동작 편집 원본은 Blender 파일이다.

활의 작은 높이 압축3.5%·깊이 변화15%는 원본 메시의 제한된 외곽 변형이며 독립 림 관절의 물리 시뮬레이션이 아니다. 새 메시 업로드 없이 Roblox의 원본 MeshPart/PBR과 같은 변형 비율을 사용한다. 기존에 당겨진 시위 메시를 숨기고 활 끝 Attachment2개와 하나의 노크를 Beam2개로 연결했다. 화살은 원본 파생본의 길이를2.70studs로 정리하고 노크 brace0.35·당김0.86을 공유한다. TD 원본 파일·UV·자산ID는 변경하지 않았다.

## 게임 적용

`K0BowMotion`은 Blender 곡선을 절대 서버 시각으로 평가한다. 기본/조준/다중 사격은 기존 windup에 맞추고 연사는 서버 확인 횟수/시각 사이에 다시 당긴다. R15 오른손 타깃을 화살 뒤쪽으로 옮기고 팔꿈치 Pole을 추가했다. 발사 뒤 IK를 해제해 오른손이 앞으로 튀는 시위를 따라가지 않고 뒤쪽 후속 자세로 이어진다. 활/화살 방향은 캐릭터 전방으로 맞추며 이동용 하체는 기존 Animator에 맡긴다. R6는 관절 곡선 폴백이며 R15와 같은 손가락 접촉을 보장하는 검사는 아니다.

장전 화살과 비행 화살은 같은 원본 메시/PBR·크기를 사용한다. 비행체는 비충돌·비쿼리 로컬 연출이며 발사와 피해는 기존 서버 결과만 사용한다. 피해/사거리/쿨다운/공격 시간·저장/상품은 이 작업에서 변경하지 않았다. 방어·회피·사망은 당김을 취소하고 장비 해제는 새 시위/화살도 숨긴다. 손상된 시위 구성은 장비 수명 검사에서 감지해 다시 만든다.

## 검증

`node docs/evidence/melee-blender-0411/build-probe.mjs /private/tmp/tlt-elf-bow-qa` 후 `run-in-roblox --place …/tlt-k0-qa-empty.rbxlx --script …/source-probe.luau`로 실제 R6/R15와 TD 무기, 생산용 모듈을 실행했다.

| 검사 | 최종 결과 |
| --- | --- |
| 기본기 기하/타격 시각/연격·30/144Hz 회귀 | 3,204개 통과 |
| 기사·드워프 Blender 독립 샘플 대조 | 2,772개 통과 |
| 드워프4동작의 기술 선택/회복/클래스 분리 | 1,642개 통과 |
| 엘프 Blender129시점 대조·기본/조준/연사/다중 사격·시위와 노크 정렬·FPS 독립·취소·재장착·비행체 동일성/중복 방지 | 4,844개 통과 |

합계 **12,462개 통과**. 엘프 각도 최대 오차0.00001550도 미만, 시위와 화살 뒤쪽의 전방 운동학상 최대 접점 오차 약3.63e-7studs다. [원시 로그](native.log)·[구조화 결과](native-results.json)·[모듈/입력 해시](probe-source-manifest.json).

첫 검증에서 Blender 커스텀 속성의 정수 플래그로 시위 샘플이 계단화되는 문제를 찾아 float형/곡선 플래그를 수정했다. Vector3의2.7 비교는 float 정밀도 허용치로 바꿨다. 수동 FK가 연결된 Part의 CFrame을 쓰며 조립체까지 이동시키던 검증 장면은 연결을 끊고 개별 FK만 적용하도록 고쳤다. 이는 런타임에 물리 루트를 움직이는 수정이 아니다. 다른 동시 네이티브 검사가 사용한50312포트 충돌은 재시도했고 실제 통과 로그와 구분한다. 원시 실패 로그도 보존했다.

![Blender 엘프 활 준비·당김·앵커·발사 후속 자세](blender-frames.png)

Blender 몸체는 관절 편집용 프록시다. 네이티브 검사는 합성 서버 시각과 수동 FK를 사용한다. 실제 IK 솔버로 다양한 체형의 손/손가락이 맞는지, 정상 전투 입력·이동·관전자/지연·모바일/패드·PBR 화면·미술 최종 수용은 남아 있다. 새 Roblox 게시/업로드 성공으로 보고하지 않는다. 앞선 게시 작업의 Studio 창 제어 문제도 미해결 상태다. 상위 티켓은 In Progress이며 다음 담당은 QA/DES다.
