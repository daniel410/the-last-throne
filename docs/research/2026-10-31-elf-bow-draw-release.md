# 엘프 활·시위 당김·발사 동작 개선 조사

2026-10-31 · TLT-005/032/033/055/057/084 · RES/ART/ENG → QA/DES

목표는 엘프의 활 끝·시위·화살 노크·오른손이 서로 떨어지거나 발사 순간 앞으로 끌려가는 인상을 줄이는 것이다. 기존 TD 나무 활/PBR과 영웅 정체성·서버 사격 시각·피해·사거리·쿨다운을 유지한다.

## 확인한 자료와 한계

| 자료 | 확인 내용 | 적용 |
| --- | --- | --- |
| [World Archery, 9 common recurve archery mistakes](https://www.worldarchery.sport/news/149488/9-common-recurve-archery-mistakes-and-how-fix-them), 2017년, 2026-10-31 확인 | 발사 때 당기는 손이 앞으로 튀는 문제, 등/어깨의 당김과 활 손의 밀기, 안정된 자세·앞팔 유지 설명 | 오른손은 발사 직후 시위 IK에서 빠져 턱 뒤쪽으로 흐르고 왼팔은 조준을 유지한다. |
| [World Archery Level1 Coach Manual](https://extranet.worldarchery.sport/documents/index.php/Coaches/Accreditation/Coaching_Levels/MANUAL_COACHING_LEVEL_1.pdf), 검색으로 확인한 상체 준비 설명 | 어깨와 머리를 미리 정렬해 당김 중 큰 움직임을 줄인다. PDF 전체를 내려받아 정독한 결과는 아니다. | 들기→당기기→짧은 앵커→발사→후속 자세로 분리한다. |
| [Capcom 공식 Monster Hunter Wilds Bow overview](https://www.youtube.com/watch?v=6D0x3KLl8jA), 2024-08-16 | 공식 소개의 차지·기동성·다중 발사 구분 | TLT의 짧은 기본 당김, 긴 조준 사격, 연사 재장전, 다중 사격에 같은 기하 계약을 적용한다. 이번에는 영상 프레임을 직접 재생 비교했다고 주장하지 않는다. |
| [Roblox IKControl](https://create.roblox.com/docs/reference/engine/classes/IKControl)·[Inverse Kinematics](https://create.roblox.com/docs/animation/inverse-kinematics), 2026-10-31 확인 | IK 타깃/체인/가중치, 확실한 해제에는 Enabled 사용 | R15 오른손 타깃을 화살의 실제 뒤쪽으로 옮기고 팔꿈치 Pole을 추가한다. 발사 후 시위를 따라가지 않도록 IK를 해제한다. R6는 관절 곡선 폴백이다. |

타 게임 자산/관절 데이터를 복제하지 않았고 직접 게임 플레이나 인기 순위를 검증하지 않았다. 올림픽 리커브의 긴 조준 시간은 짧은 RPG 기본 공격에 그대로 적용하지 않는다. 새로운 차지 입력/공격 지연/자원 소모를 추가하지 않는다.

## 원본 조사와 선택

실제 TD GLB를 Blender MCP로 읽었다. 활은1,256삼각형, 화살100, 기존 시위56이다. 원래 시위는 이미 약2.48studs 깊이를 가진 V 모양이며 기존 런타임은 메시 깊이를 줄인 다음 프레임별로 늘렸다. 원본 화살 길이는 약3.854studs, 뒤쪽은 grip좌표 약+2.4056이다. 기존 손 타깃에는 시위/화살 높이 차이와-0.475 오프셋이 있었다. 단순 속도 변경으로 네 접점을 일치시키기 어렵다.

선택한 개선은 다음과 같다.

- TD 활 메시/PBR을 보존하고 작은 높이 압축3.5%·깊이 변화15%를 Blender Shape Key와 같은 런타임 외곽 변형으로 표현한다. 독립 림 관절/물리 탄성을 새로 시뮬레이션한 결과는 아니다.
- 기존 당겨진 시위 메시를 숨기고 활 끝2곳→하나의 노크로 이어지는 두 직선 가닥을 만든다. Roblox는 Beam2개를 쓰므로 파트/업로드가 증가하지 않는다.
- 원본 화살의 길이를 파생본에서2.70studs로 정리하고 뒤쪽을 brace0.35에 맞춘다. 노크·시위·화살이 같은0.86studs 당김을 사용한다. TD 원본은 불변이다.
- Blender의 연속 곡선을 절대 서버 시각으로 샘플한다. 기본/조준/다중 사격은 기존 windup으로 재시간화하고 연사는 서버가 확인한 횟수·시각 사이에 다시 당긴다. 클라이언트는 발사/피해를 생성하지 않는다.
- 비행체도 장전 화살과 같은 메시/PBR·크기를 복제한다. 없는/늦은 무기에는 기존 경량 폴백을 사용한다.

외부 새 활 메시 구입/업로드는 외형·권리·제작량과 게시 권한 검증이 늘어난다. 현재 접근은 TD 외형을 유지하면서 가장 눈에 띄는 시위/노크/손 불일치를 먼저 고친다. Blender에는 편집 가능한 리그·Shape Key·키프레임·검토용 GLB를 보존한다. 최소 검증은 Blender 독립 샘플 대조, R6/R15 전방 운동학, 발사 전후 정렬, FPS 독립성, 연사 재당김, 중복 비행체 방지와 공통 액션 취소다. 실제 플레이·다양한 비율·네트워크/모바일·최종 미술 수용은 별도다.
