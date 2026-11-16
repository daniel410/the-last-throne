# TLT-063 · EC-01 화물 승강기 권양기

2026-11-16 UTC. 빌드 **0.111.1**, 입력 **e77945659bce3bf372de757de8814ead68587e9d**. build.json에 명령·산출물 SHA256 기록. 미게시·태그 없음·G5 미완료. [원고 연결 제작표·공식 리서치](../../research/2026-11-16-ec01-freight-headframe.md).

EC-01 기어 회수와 노동자 귀환의 중심 시설인 승강기를 개선했다. 기존 바닥 뒤 기둥2개 위로45stud 트러스·권양 드럼·지지대·케이블을 연결했다. 기존 TLT 환경 키트의 primitive/Metal/steel·brass 재사용, 신규28파트 전부 anchored·비충돌·비쿼리·비접촉. 기존 기어 장착, 화물12stud/4초 이동, 도착등의 개인 저장 투영을 유지한다. 새 진행 조건·보상·운영 TD·서버 바닥·Bounds·Terrain 변경 없음. source-preservation.json은 추가 블록과 모듈버전2→3 이외 소스가 기준과 같음을 확인한다.

## 실제 검증 범위

- 새 빌드를 별도 Studio Edit/PlaceId0/플레이어0에서 열고 create.luau 실행. 변경 모듈 Source 원문 일치, 전체 LuaSourceContainer523개 loadstring 구문 통과. baseline은 입력 d0dd44be209f8db79186c2b67cb7a8c133c16570의 원본0.111.0에서 BaseScript Disabled만 설정한 별도 로컬 fixture다.
- verify.luau: 추가28파트의 물리 플래그/원본 태그, 받침2개 지면 틈0, 기존 화물 pose0/3·4초·기어/등 저장 태그, 재호출 후 Epic4 그룹1개 확인. 드럼은 local X축 Cylinder. 저장 서비스/실제 클라이언트 애니메이션 시험은 아니다.
- routes.luau: EC11장/9연결/144목표/8,396표본. easy-routes.luau:150목표/8,526표본. 차단·바닥 누락·진행 보정·안내 실패·단차0. 기존 엔진 경로 감사의 EC 범위이며 실제 Humanoid 입력 보행이 아니다. results.json에 원본 응답을 기록했다.
- 추가28파트/그림자 비용은 존재한다. 다인/저사양 FPS·메모리·스트리밍 측정은 하지 않았다.

## 동일 조건 비교

before.jpg / before-low.jpg는0.111.0, after.jpg / after-low.jpg는 고정0.111.1 새 세션. 중간 후보는 baseline fixture의 모듈 복제본으로 미리 봤으나 아래 최종 비교는 실제 빌드 장면이다. baseline 모듈은 원본으로 복구한 뒤 low 촬영했다. 두 장면 모두 EC만 생성·Clock14·FOV70·Focus와CFrame 동시 지정. camera.luau로 재현한다. base=(-847.84998,124,-11736.40039), 원경 offset=(64,26,72)/target=(0,14,0), 근접 offset=(18,6,22)/target=(0,16,0). 게임 조명/실제 영웅 카메라가 아닌 Edit 시점이다. 근접은 상부 트러스가 화면 밖으로 잘리는 모습까지 보존한다.

![이전](before.jpg)
![최종](after.jpg)
![근접 이전](before-low.jpg)
![근접 최종](after-low.jpg)

전후 원경에서 떠 있던 기둥 상단이 트러스로 이어지고 황동 드럼·케이블로 화물 시설의 실루엣이 생겼다. 가까이에서는 상부가 프레임 밖에 나가므로 전체 크기 인지/드럼 겹침은 실제 카메라에서 추가 수용해야 한다. 주변 큰 평지·빈 하늘은 그대로다.

다음 담당 DES/QA: 실제 지역 조명·영웅 카메라의 접근/orbit/상호작용·회피/전투, 화물 이동0→3/기어 복구/재접속, 게시 클라이언트·터치/패드·스트리밍·다인/실기기 성능·사용자 미술수용. 미검증을 티켓 완료로 처리하지 않는다. 다음 맵 작업은 같은 트러스/잔석 증량보다 화산 도시의 큰 공간과 도보 진입 조망을 검토한다.
