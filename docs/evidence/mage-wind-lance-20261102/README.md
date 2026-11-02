# Wind Lance 바람 효과·기본 나무 지팡이

2026-11-02 · TLT-005/032/033/055/057/084 · ENG/DES → QA · 로컬 개선본·미게시

두 사용자 요청을 함께 적용했다. 기본 Mage가 무조건 Pyro용 EmberCrownStaff를 복제하던 경로를 기존 `WoodenStaffBuilder`로 복원했다. 나무 몸통·갈라진 나무 머리·가죽 손잡이·작은 수정과 WeaponTip을 그대로 사용한다. 현재 클래스 기본 외형 경로의 교정이며, 전직/장비별 별도 외형 선택 기능을 새로 구현한 것은 아니다. Pyro TD 원본은 삭제하지 않았다. 기존 sourceKey와 달라 이전 외형 캐시도 재사용하지 않는다. R6/R15·숨김/재장착·관절 복구·재생성 경로를 함께 확인한다.

Wind Lance의 기존 연녹색 직선 대신 다음을 추가했다.

- 준비: 현재 지팡이 끝을 따라 안쪽으로 모이는3가닥 바람.
- 발사: 흰색/민트색 나선3가닥·짧게 빛나는 중심선·가는 창끝.
- 명중: 서버가 확정한 최대3적중점에 짧은 바람 소용돌이.
- 제한: 로컬 장식, 충돌/쿼리/터치 없음, carrier1개, 동시4시전, 거리110stud 이내, 발사 수명0.48초. 단일 적중 기준 Beam71개·3적중 최대87개. 사건 중복/과거 이벤트·시전 취소·사망/미장착·종료에서 정리한다. RemoteEvent가 행동 속성보다 먼저 도착할 때 준비 연출이 사라지지 않도록80ms 유예 후 확인한다.

변경은 `WindLanceVisual`, `AdvancedSkillVisual`, `WeaponAppearance` 및 관련 검증이다. 스킬ID·MP14·쿨다운6초·사거리30stud·최대3대상·피해·서버 판정/명중 시각을 수정하지 않았다. 새 이미지/모델/오디오 업로드는 없다. [공식 RPG/Roblox 사례·선택 근거](../../research/2026-11-02-wind-lance-and-apprentice-staff.md).

[Studio 미리보기](studio-wind-lance.png)는 새 코드와 나무 지팡이의 **Edit 모드 격리 정적 표본**이다. 일반 R6 시험 몸체를 사용하며 최종 영웅 외형/실제 플레이 영상으로 해석하지 않는다. 시각 확인 때만 복사한 모듈에서 Heartbeat/Debris를 멈추고 발사0.08초를 수동 평가했다. 기존 사용자 Studio 스크립트는 덮어쓰지 않았으며 시험 몸체/모듈은 제거하고 카메라를 복원했다. 새 로컬 빌드에 실제 런타임 연결이 들어간다.

검증: `tests/wind-lance-visual-native.luau`는 실제 epoch 서버 시각, 지팡이 끝·서버 끝점·회전 기류, 프레임률30/60/144, 중복/과거/취소/거리/동시성/정리를 확인한다. 최초 미리보기에서 좌표 상한을 시각에도 적용한 문제를 발견해 분리했고 실제 서버 시각 회귀를 추가했다. `tests/refined-player-weapons-native.luau`는4클래스 R6/R15 lifecycle138개 통과. `tests/mage-staff-golden.luau`를 MageGolden으로 결합한 `tests/k0-mage-staff-native.luau`는 Blender 독립 표본과 기본/전체 Mage 시전17,087개 통과. 최종 고정 소스의 정확한 결과·빌드·해시는 `results.json`/`build.json`에 기록한다. 다른 미커밋 로비/이동/난이도/인벤토리/지원 작업은 포함하지 않는다.

미검증: 실제 입력·네트워크에서의 전투 가독성, 저품질 그래픽·모바일·4인 동시 성능, 사용자 최종 미술 수용. Studio 기본 자산203785492의 기존 유형 경고는 범위 밖이다. 상위 티켓 In Progress를 유지한다. 다음 QA/DES가 새 Battle 빌드에서 나무 지팡이·Wind Lance를 실제 시전해 수용한다. Roblox 게시/릴리스 태그는 수행하지 않는다.
