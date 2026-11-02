# Wind Lance 바람 식별성과 기본 나무 지팡이

2026-11-02 · TLT-005/032/033/055/057/084 · ENG/DES → QA

사용자는 Wind Lance의 바람 효과 강화와 기본 Mage의 Pyro 지팡이를 나무 지팡이로 교정하도록 요청했다. 현재 Wind Lance는 다른 line 스킬과 같은 연녹색 직사각 경로만 표시한다. 기본 외형도 모든 Mage에 EmberCrownStaff를 지정하고 있어 기존 견습용 WoodenStaffBuilder가 호출되지 않는다.

## 확인한 근거와 적용

- [Guild Wars 2 공식 Elementalist](https://www.guildwars2.com/en/the-game/professions/elementalist/)의 Air 설명은 wind/lightning의 원소 구분을 제시한다. 확인일2026-11-02. 직접 플레이나 동영상 관찰은 하지 않았으며, 특정 나선 연출을 이 게임의 실제 구현으로 주장하지 않는다. 적용 해석: 우리 Wind Lance는 불꽃·번개 대신 얇은 흰색/민트색 회전 기류와 길게 모이는 창 실루엣으로 바람을 구분한다. 타 게임 자산/고유 연출은 복제하지 않는다.
- [Roblox 공식 Beams](https://create.roblox.com/docs/effects/beams)는 Attachment 사이의 폭·곡선·색·투명도로 효과를 만들며 기기 그래픽 품질에 따라 시각 품질이 달라질 수 있다고 설명한다. [Weapons Kit](https://create.roblox.com/docs/resources/weapons-kit)의 Roblox 비교 사례는 무기 끝 Attachment와 사격/명중 효과를 분리한다. 확인일2026-11-02. 실제 무기 키트를 가져오거나 실행하지 않았다.
- 적용: 기존 스킬ID/서버 확정 이벤트·끝점·맞은 적 위치를 사용한다. 준비 때 지팡이 WeaponTip 주변에 모이는 회오리, 발사 때3가닥 나선 기류·얇은 중심선·창끝, 실제 적중점에 짧은 소용돌이를 표시한다. 새 이미지 업로드·피해 판정·발사 지연은 추가하지 않는다.
- 기본 Mage는 기존 로컬 WoodenStaffBuilder의 나무 재질·가죽 손잡이·작은 수정 외형으로 복원한다. Pyro용 원본은 삭제하지 않는다. 전직별 무기 자동교체나 장비 성능 변경은 이번 범위가 아니다.

대안: 녹색 직선만 두면 원소 식별성이 약하다. 대형 토네이도/대량 입자는 사선과 적 예고를 가릴 수 있다. 선택안은 충돌 없는 투명 carrier1개와 Beam 리본이며 동시4효과·거리110stud 이내·수명0.48초로 제한한다. 선형 판정의 기존폭1.5stud와 비교해 기류의 반경은 최대0.87stud다. 기류 회전은 피해를 재계산하지 않는다.

수용: 실제 R6/R15 장착/숨김/복구/재생성·기본/모든 Mage 시전 회귀, 정확한 서버 끝점, 중복·오래된 이벤트·취소·거리/동시성 제한·효과 정리와 게임 판정 불변을 검증한다. Studio 시각 미리보기는 실제 플레이/모바일 수용과 구분한다. 다음 담당 QA/DES는 실제 전투 거리·낮은 그래픽 품질·4인 동시 가독성을 수용한다.
