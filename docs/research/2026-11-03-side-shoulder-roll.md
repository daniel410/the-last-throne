# 옆 회피 모션 비교와 적용

2026-11-03 · TLT-005/028/032/033/084 · RES/3D/ENG → QA

사용자가 지정한 [Cobra Code 튜토리얼](https://dev.epicgames.com/community/learning/tutorials/ryqp/dodge-roll-dash-step-movement-tutorial)과 추가 RPG 비교 요청을 적용한다. Epic 페이지의 작성/수정일은2022-05-25, 연결 영상은 `nV_JGMNRGpc`다. 브라우저에서 초반0~8초 시연/소개와 페이지의 구르기 연속 자세 이미지를 확인했다. 전체10분36초 튜토리얼이나 게임을 직접 플레이한 것은 아니다.

추가 비교 자료는 모두2026-11-03 확인했다.

- [Elden Ring 공식 시작 안내](https://en.bandainamcoent.eu/elden-ring/news/elden-ring-starter-guide-tips-know-playing-the-game): 방향 이동과 Dodge Roll/Backstep을 구분한다. [공식 능력치 안내](https://www.bandainamcoent.com/news/elden-ring-introduction-part-2-advanced-stats)는 장비 무게에 따른 빠른/보통/무거운 구르기를 설명한다. 회피의 방향과 회복 속도가 읽혀야 한다는 비교 기준으로 사용한다. 본편의 Stamina 제거/현재 거리·행동 시간 계약을 유지한다.
- [Monster Hunter Rise: Sunbreak 공식 조작 설명](https://game.capcom.com/manual/Multi-Platform/en/windows/page/3/4): 검색 색인에서 이동 중 Dodge와 무기 사용 중 Evade를 확인했다. 직접 페이지 열람은403으로 제한됐다. 장비를 든 상태의 회피 실루엣을 검토해야 한다는 비교 항목으로 사용하며 정확한 애니메이션·프레임 수는 확인하지 못했다.
- [ESO 공식 회피 설명](https://help.bethesda.net/app/answers/detail/a_id/3924/~/how-do-i-dodge-and-roll%3F): PC/Mac의 방향키 더블탭 회피를 확인했다. 기존2026-11-02 조사의 입력 비교를 재확인한다. Roblox 타 게임의 모션/판정·인기도는 이번 작업에서 새로 검증하지 않았다.

공식 문서에서 확인한 것은 조작/규칙이며 관절 각도·접지 프레임이 아니다. 아래 포즈·수치는 이를 바탕으로 만든 프로젝트의 독자 설계다. 다른 게임의 클립을 추출/복사하지 않는다.

현재 길게 누운 몸의 길이 축 회전 대신, 선택한 좌우로 시각 몸체를 돌려 전진 구르기를 한다. 시작16%에서 몸을 낮추고12~78% 사이 한 바퀴, 후반22%에서 일어난다. 팔을 몸 가까이 두고 엉덩이·무릎·목을 접으며12도 어깨 기울기를 더한다. 수평 barrel roll/양팔을 길게 뻗는 dive보다 compact shoulder roll을 선택했다. 네 클래스·R6/R15에 같은 시간 곡선을 적용하되 R6의 무릎/팔꿈치 분절 부재는 남는다.

기존 서버14스터드/0.55초 이동·0.65초 행동·무적·벽/낭떠러지·더블탭·스킬 전환을 보존한다. 루트 위치/회전은 시각 관절에만 적용한다. 서버 이동 속도 곡선이나 네트워크 처리 변경은 없다. 긴 거리의 미끄러짐과 무기/방패 지면 접촉은 실제 전투 화면에서 후속 수용한다.

최소 실험은 네 클래스 좌우·R6/R15·30/60/144Hz 샘플에서 방향 평면/한 바퀴/낮은 자세/복귀/물리 루트 불변을 확인하는 것이다. [구현 검증](../evidence/side-shoulder-roll-20261103/README.md)을 따른다. 직접 RPG 플레이 비교·실기기·사용자 미술 수용은 미검증이다.
