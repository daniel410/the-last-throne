# Frozen Vale 로컬 구현

2026-10-31 · TLT-062/057/084 · ENG/ART/QA · 0.50.0 로컬 시험판, 미게시

## 구현 범위

- Deepwood 완료 저장에서 FV-01로 이어지는7본편·7체크포인트·3선택 지역·4선택 퀘스트. 서버 목표/거리/선행·유한 교전/개인 저장·재시도·재접속 목적지, 지도/미니맵/저널·로비 진행 안내를 연결했다.
- 최신 승인에 맞춰 주민 구조→피난처/등불 연결→수호수 진정→화산 도시 운반대 단서로 구성한다. 기존 FV-01~07·Q1~4 안정ID와 고정2158XP/3360Gold를 유지한다. 선택 퀘스트 고정 보상0은 확정되지 않은 예산을 새로 배정하지 않기 위한 시험값이며 처치 보상은 별도다. Lv20 도달과 실제 난이도는 자동 수용하지 않는다.
- 설원 지속 지반·넓은 눈길·빙하/협곡/피난처/기록실/성문/거울 궁전·겨울 조명·NPC5명을 연결했다. 피난처 계정 창고·동료 편성 게시판은 기존 서버 계약을 사용한다. 현재 전체AI1명 상한과4인 정원을 유지한다.
- TD 현재 런타임의 설원10종을 별도 폴더로 추출했다. [원본/해시/삼각형/권한 범위](../../../assets/shared/td-frozen-vale/manifest.json). 기존 Roblox MeshId/텍스처와10개 GLB를 고정했고 TD 소스/게시/상품은 변경하지 않았다. 신규 생성/외부 애니메이션 업로드는 없다.
- Blender MCP에서 대기·보행·일반2·강공격2·스턴,10종70클립/350 Action을 제작했다. 네발3종의 네 다리, 나머지 종의 해부학적 회전축·무기 끝 소켓과 궤적을 기존 모션 런타임에 연결한다. 공격 접촉은 서버 시간의.62표본에 대응한다. [Blender 편집 원본](../../../assets/animations/frozen-vale-v1/frozen-vale-motion.blend).
- 설원 보스는10%HP에서 진정시키고 죽이지 않는다. 중복 피해/완료 보상은 배제하며 진행 저장은 기존 계정 큐를 사용한다. 실제 신원/프로필을 대신한 테스트 객체로 검증한 경로는 실계정 수용과 구분한다.

## 재현과 검증

`python3 tools/prepare-frozen-vale-assets.py` → 해당 manifest를 INPUT 상수로 전달해 `tools/author-frozen-vale-motion.py`를 Blender MCP에서 실행 → scene의 frozen_export/frozen_sockets를 각각 clips.json/sockets.json으로 수신 → `python3 tools/export-frozen-vale-motion.py`. 별도 Blender 프로세스/애니메이션 에셋 업로드는 사용하지 않았다.

별도 장면 `TLT_FrozenVale_Monsters_v1`에 제작했다. NLA는 Idle0/Walk140/Attack280/AttackAlt420/Heavy560/HeavyAlt700/Stunned840,각120프레임이다. 종별 `_Root`와 자식의 숨김을 해제해 검토한다. 기존 Deepwood 장면·원본 파일은 보존했다.

검사 결과는 final-validation.json과 native.log에 기록한다. Studio는 별도 미게시 로컬 fixture이며 운영 Battle/TD Place에는 적용/게시하지 않았다. 검증 중 가상 플레이어가 Players 목록에 포함되지 않아 여행 자동 감지 시험이 실패했고, 명시적 서버 상호작용 API로 해당 fixture만 수정했다. 해당 실패는 실제 플레이 이동 실패로 분류하지 않는다.

## 남은 수용과 다음 담당

미검증: 실제 플레이어의 정상 전투 완주/Lv20 성장, PC·모바일·패드 입력/작은 화면,4인+AI 성능/경사 IK/네트워크 지연,실계정 저장 장애·게시 Experience의 Mesh/텍스처 권한,최종 미술/난이도 수용. 맵과 일부 상호작용 소품은 네이티브 파트 시험 미술이며 최종 환경 자산은 아니다. 강체 분할의 팔꿈치/손목 한계와 현재 근접/부채꼴 기반 시전 판정도 남아 있다.

TLT-062/057/084 부모 작업은 In Progress로 유지한다. 다음 담당은 QA/DES이며 위 조건을 실제 기기/정상 플레이로 수용한다. 커밋/푸시·고정 빌드 해시는 build.json에 기록한다. 일반 로컬 빌드이므로 Roblox 게시/릴리스 태그는 없다.
