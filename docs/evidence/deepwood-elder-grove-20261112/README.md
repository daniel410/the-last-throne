# DW-03 거목 중심 장면 제작

2026-11-12 · TLT-061/elder-grove · 모델링/ENG → Roblox 자산 수입 권한 대기

사용자는 [Diablo·WoW·Roblox 제작 조사](../../research/2026-11-12-deepwood-concept-map.md)에 이어 실제 작업을 요청했다. [콘셉트 DW-03](../../../assets/concepts/2026-11-12-deepwood-epic-stories-v1/DW-03.png)을 기준으로 [실제 Blender 후보 패키지](../../../assets/models/deepwood-elder-grove-v1/README.md)를 제작했다. **게임 맵 개선 전체 완료는 아니다.**

## 이번 변경

기본형 건물 한 채를 빈 곳에 놓던 단계에서, 거목·뿌리·거목 아래 보급 천막·광장·돌길·아치·식생·생활 소품을 한 장면으로 제작했다. Blender MCP의 직접 메시 조형과 UV·공통 텍스처를 사용했다. 실제 모델은34메시/53810삼각형이며 최대 컴포넌트7014삼각형, 내장 텍스처1024×1024 한 장이다. 외부 생성기/타 게임 자산은 사용하지 않았다.

로컬 검수 월드의 실제 바닥을 읽어 기준점(-280,18.08,-1728)을 정했다. 에린(-242,18,-1648), 셀레네(-341,18,-1549), 지도 목표(-156,18,-1678)와 기존 스토리 순서/보상은 이동·변경하지 않았다. 천막 정면의 뿌리를 양쪽으로 벌려 진입 공간을 만들었다. 실제 길찾기와 보행 PASS를 뜻하지 않는다.

수관/천막/광장/길의 크기와 관계를 Blender 조감도·근접·측면에서 검토했다. 기존 목조 건물보다 거목 중심 구도를 명시했지만, 원본 콘셉트의 회화적 재질·숲 밀도·지형 높낮이를 모두 재현한 최종본은 아니다. 수입 후 실제 지역과 전투 카메라에서 반복 조정해야 한다.

## 검증 결과

| 구분 | 수행 조건·결과 |
| --- | --- |
| Blender MCP | Blender5.2.0LTS, 새 씬 `TLT_Deepwood_ElderGrove_v1`, 기존 씬 보존. `blender-session.json` |
| 색상 | Standard/sRGB/None/Exposure0/Gamma1/Curves Off 실측 |
| GLB 구조 | 실제34메시/53810삼각형, UV/노멀 포함, 공통 재질1/내장 이미지1, 외부 URI0, 퇴화 삼각형0. 모델 폴더 `validation.json` |
| 렌더 | 모델 폴더의 전체/근접/측면 PNG는 **Blender 렌더**이며 Studio 화면이 아님 |
| 검수 도구 | `prepare-deepwood-elder-grove-review.py`의 생성 Luau를 로컬 Studio Edit에서 `loadstring`으로 컴파일. 실행/배치/소스 주입은 안 함 |
| 실제 수입 | **실패/차단:** 아래 인증 오류. Roblox assetId 없음 |
| 게임 빌드 | 생성하지 않음. VERSION과 기존 게임 소스/프로젝트 참조 유지 |

기하/UV 검사 명령은 `python3 tools/validate-deepwood-elder-grove.py`, 검수 스크립트 생성은 `python3 tools/prepare-deepwood-elder-grove-review.py`다. 생성 도구는 실제 MeshPart·텍스처·단위/방향을 확인한 후 새 검수 후보만 배치하도록 준비했다. 전체34개 모델을 기본형으로 바꾸는 우회는 없다. 실제 수입 결과를 보지 못해 이 검수 코드의 엔진 실행은 미검증이다.

## 실제 차단과 필요한 조치

사용자 로그인 Studio 계정 ID는9156786071로 읽었다. 로컬 파일에 연결된 Studio MCP에서 `/assets/v1/assets`로 GLB Model 수입을 시도했으나, **파일 전송 전 Open Cloud 토큰 획득 단계**에서 다음 오류를 받았다.

> Could not acquire an Open Cloud access token: Scope 'asset:read' has not been granted.

이는 제작 작업의 재승인 요청이나 SKILL.md의 별도 승인 규칙 때문이 아니다. **Roblox Studio MCP 도구가 요구하는 실제 연결 권한**이다. Studio의 Assistant → MCP Permissions에서 `asset:read`·`asset:write`를 부여해야 수입 요청을 진행할 수 있다. API 키/쿠키/비밀을 요청하거나, 다른 자격증명/수입 경로로 거부를 우회하지 않았다. 사용자에게 해당 권한 요청을 보냈다. 사용자의 후속 지시로 Studio 전체 종료·재시작 후 재시도했지만 같은 권한 오류가 발생했다. 파일 전송·assetId 생성·게임 수입 성공으로 보고하지 않는다.

## 전체 종료·재시작 후 재시도

사용자 요청에 따라 열린4개 로컬 문서를 복구용 사본으로 보존하고 원래 파일 바이트를 복원했다. 남은 파일 대화상자가 일반 종료에 반응하지 않아, 정상 종료 요청 후에도 남은 프로세스는 저장 보존을 확인한 뒤 종료했다. Studio 프로세스7개가 모두 사라진 것을 확인한 다음,0.104.21 고정 빌드의 로컬 사본 `TLT-Elder-Grove-Review.rbxlx`만 다시 열었다. 프로세스와 MCP 연결 모두1개인 상태에서 같은 계정/GLB로 자산 수입을 재시도했다. 결과는 여전히 토큰 획득 단계의 `asset:read` 미부여였다. 재시작으로 권한 문제가 해소되지 않았으며 파일 업로드·자산 생성은 발생하지 않았다. 상세는 `restart-retry.json`이다. 기존 게임/TD 빌드 원본은 재시작 후에도 보존 전 SHA256과 일치함을 확인했다.

## 남은 작업과 다음 담당

1. 사용자: MCP 자산 읽기/쓰기 권한 활성화 여부 전달.
2. ENG: 준비한 GLB 수입 → 실제 Model/Mesh/Image/SurfaceAppearance ID와 개인 소유·Experience 권한/로드 확인 → 검수 후보 실행.
3. 모델링/DES/ENG: 기존 거목/일반 나무·옛 건물과 겹침 정리, 실제 지형/길/소품/조명 연결. 작은 나무를 포함한 물리 형상과 전투/목표 공간을 검토. 해당 경계가 검증되기 전에는 기존 `DeepwoodConceptArt`를 새 후보로 대체하지 않는다.
4. QA: 스토리/보상 불변·재입장·충돌/지면·보행/회피·길찾기·스트리밍·실제 클라이언트/실기기 성능을 검사하고, 실제 Studio 화면을 콘셉트와 비교한다.
5. 사용자: 실제 게임에 연결된 화면의 미술 수용. Blender 렌더만으로 최종 완료 처리하지 않는다.

미검증은 실제 자산 수입/권한, Roblox 색·재질·조명, 맵 연결과 충돌/경로, 게시 클라이언트·실기기/협동·최종 미술 수용이다. TD 운영·저장·게임 게시·VERSION·릴리스 태그는 변경하지 않았다. TLT-061/G5/G7을 완료 처리하지 않는다.
