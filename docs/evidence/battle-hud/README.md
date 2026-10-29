# TD 배틀 HUD 적용

작업: TLT-028/052/084 일부 · 2026-10-29 · 엔지니어/QA

사용자 요청에 따라 배틀의 상태·목표 패널, 액션·아이템·스킬·귀환 버튼을 TD 공통 아틀라스 프레임으로 연결했다. HP는 TD BattleChromeArtAssets의 healthFrame/healthFill, MP는 같은 프레임의 파란 채움이다. 공격은 녹색 주 버튼, 나머지는 청색 보조 버튼이다. 원본은 TD 커밋 `22ff3be95a8e9d3c034d83d93b8c540a36070ac2`의 바이트 동일 사본이며 공유 manifest에 SHA256을 기록했다. TD 운영 코드는 수정하지 않았다.

기존 입력 API·유지 공격/블록/달리기·쿨다운·3/5 슬롯·물약 수량·MP 조건부 표시를 유지한다. Stamina를 추가하지 않았다. 폭1100 미만은 스킬을 액션 위 별도 행에 두며 화면 크기 변화에 재배치한다. CoreUISafeInsets를 사용한다.

빌드 전 source-probe GUI 생성/상태 검사: `tests/k0-resource-ui-native.luau` 100개 통과, 실패0. LocalPlayer 대역의 엔진 GUI 검사이며 실제 화면/기기 수용과 구분한다. 기존 `203785492` 자산 유형 경고가 관측됐다.

최종 고정 빌드·실제 Player 검사 결과는 아래에 추가한다. 실제 폰/태블릿/패드·다인·게시 Experience 권한/성능은 미검증이며 상위 티켓을 Done 처리하지 않는다. 다음 담당: QA의 실기기/게시 환경 수용.
