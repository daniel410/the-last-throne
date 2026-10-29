# TD 배틀 HUD 적용

작업: TLT-028/052/084 일부 · 2026-10-29 · 엔지니어/QA

사용자 요청에 따라 배틀의 상태·목표 패널, 액션·아이템·스킬·귀환 버튼을 TD 공통 아틀라스 프레임으로 연결했다. HP는 TD BattleChromeArtAssets의 healthFrame/healthFill, MP는 같은 프레임의 파란 채움이다. 공격은 녹색 주 버튼, 나머지는 청색 보조 버튼이다. 원본은 TD 커밋 `22ff3be95a8e9d3c034d83d93b8c540a36070ac2`의 바이트 동일 사본이며 공유 manifest에 SHA256을 기록했다. TD 운영 코드는 수정하지 않았다.

기존 입력 API·유지 공격/블록/달리기·쿨다운·3/5 슬롯·물약 수량·MP 조건부 표시를 유지한다. Stamina를 추가하지 않았다. 폭1100 미만은 스킬을 액션 위 별도 행에 두며 화면 크기 변화에 재배치한다. CoreUISafeInsets를 사용한다.

빌드 전 source-probe GUI 생성/상태 검사: `tests/k0-resource-ui-native.luau` 100개 통과, 실패0. LocalPlayer 대역의 엔진 GUI 검사이며 실제 화면/기기 수용과 구분한다. 기존 `203785492` 자산 유형 경고가 관측됐다.

최종 고정 빌드·실제 Player 검사 결과는 아래에 추가한다. 실제 폰/태블릿/패드·다인·게시 Experience 권한/성능은 미검증이며 상위 티켓을 Done 처리하지 않는다. 다음 담당: QA의 실기기/게시 환경 수용.

0.20.0 고정 빌드: Rojo 성공, 소스 `d60fb58f0f3b428d56ddaf1a11b00d9edff61e72`, 1,009,152 bytes, SHA256 `04e7405b996cd5c7a191c548b114ee4427c043abb682f58108d9ced1ac3337ea`. UI100개·smoke469개 통과, 실패/수집 런타임 오류0. 실제 Player에서 TD 이미지 로드/표시와 Mage HP/MP를 확인했으나 BAG이 귀환 버튼을 가리는 결함을 발견했다. 귀환을 별도 행(y68)으로 옮기고 0.20.1에서 재검증한다.

0.20.1 고정 빌드: 소스 `de300d886eb93a6ca05d06efa0216cc6ebabd911`, 1,009,152 bytes, SHA256 `b77d0fd539358cd5a0703bf50092cb82854492b928314bec9568d7074ba1fe9a`, Rojo 성공/UI101개 통과. 실제 Mage 키1 입력 후 MP85/100과 쿨다운2.7s·분리된 BAG/귀환 표시 확인. Root만390×700으로 제한해 스킬 폭362.88px·하단540px, 액션 상단560.64px(겹침 없음)을 확인했다. 640×360 Root에서는 목표 하단203.64px와 스킬 상단151.04px가 겹쳐 낮은 가로 화면의 목표를 상단 옆으로 재배치한다. Root 제한은 실제 디바이스/전체 뷰포트 에뮬레이션이 아니다. 첫 Start 입력은 초기화 중 반영되지 않아 상태를 보고 다시 클릭한 후 진입했다.

## 최종 0.20.2 결과

- 소스 `5bbf013ca43668edf31a522c36c85adc50772d2d`, 빌드 전 origin/main 일치 확인. `rojo build default.project.json --output builds/0.20.2/TheLastThrone-0.20.2.rbxlx` 종료0, 1,009,431 bytes, SHA256 `2c2e3c4af5e2d53025cd1a1095251088994660aff3955fefe5ad67b81d1cf68b`.
- `run-in-roblox --place builds/0.20.2/TheLastThrone-0.20.2.rbxlx --script tests/k0-resource-ui-native.luau`: 종료0,101개 통과/실패0. [원시 로그](0.20.2-ui.log). 새 UI 원본 모듈을 포함한0.20.0 smoke469개·실패0·수집 런타임 오류0은 [원시 로그](0.20.0-smoke.log)에 있다. 마지막 두 수정은 배치만 바꾸며 smoke 전체는0.20.2에서 재실행하지 않았다.
- 고정0.20.2의 격리 비게시 Studio 단일 실제 R15 Player: Knight HP1000/1000, MP 숨김, BLOCK 버튼 누름 중 서버 `K0State=Block`/HUD BLOCKING 확인. 최초 mouseUp 도구 호출은 위치 누락으로 거부되어 방어 상태의 스킬 요청은 기존 서버 규칙대로 거부됐다. 위치를 지정한 mouseUp 후 키1을 다시 눌러 ATTACKING과 슬롯 안9.7s 쿨다운을 확인했다. 이는 도구 호출 오류이며 제품 코드 수정 없이 해제됐다.
- B로 가방 열기(`TLTInventoryOpen=true`), B로 닫기, 귀환 버튼 클릭 후 HUD 숨김/로비 표시/가방 닫힘을 확인했다. TD 배틀 이미지·패널·버튼의 실제 로드를 화면에서 확인했다. Mage MP 소비와 쿨다운은 앞선0.20.1 실제 Player 증거이며0.20.2의 Mage 실플레이 결과로 바꿔 적지 않는다.
- Root390×700: 스킬 폭362.88px, 하단540px < 액션 상단560.64px. Root640×360: 목표 하단96.64px < 스킬 상단151.04px, 상태 우측194.56px < 목표 좌측206px. 각각 엔진에서 assert 통과. Root만 제한했으므로 가방 버튼 등 다른 ScreenGui와 실제 모바일 기본 컨트롤·safe-area 전체 수용이 아니다.
- QA bridge는 Play 중지 후 Ctrl-C로 종료(130)했다. 실제 게시·DataStore·TD 운영 변경·릴리스 태그는 수행하지 않았다.

화면: [최종 PC](0.20.2-pc.png) · [세로 Root 제한](0.20.2-portrait-layout.png) · [가로 Root 제한](0.20.2-landscape-layout.png) · [0.20.1 Mage MP/쿨다운](0.20.1-mage.png).

미검증: 실제 폰/태블릿/패드 입력·전환·안전 영역, 다인/지연·게시된 Experience의 제한 자산 권한, 전체 UI의 접근성/기기별 최소 글자/터치 크기와 사용자 시각 수용. 다음 담당은 QA이며 TLT-028/052/084 전체를 완료로 올리지 않는다.

## 0.20.3 사용자 배치 조정

TLT-028/084 일부. Dodge의 V 바인딩/힌트를 제거하고 키보드는 R을 유지한다. Attack x134→118(-16px), Sprint x78→92(+14px). 아이템과 스킬 사이 간격은8→32px, 바 전체 폭은528px로 조정한다. 아이템은 TD shellSell, 스킬/보조 액션은 shellDetails, Attack은 shellUpgrade로 유형을 구분한다. 물약 캡션은 실제 등록 HP/MP를 따라 따뜻한/차가운 색을 쓴다. 변경 파일은 K0Hud·init.client·K0Text·VERSION이며 GUI 검사와 실제 Player의 R/V·배치·색상/간격을 검증한다.

0.20.3 검증: 소스 `32cc0d05e270c30e14c619061cb6e939d242567e`를 푸시하고 원격 일치 확인 뒤 Rojo7.7.1 빌드 성공.1,009,590 bytes, SHA256 `3ad8b612a880f353ed16c8610ac58135f33444d8fb099c2feb44e75b7843561d`. [GUI 원시 로그](0.20.3-ui.log):101개 통과/실패0, CLI종료0. src에서 KeyCode.V/HintV/R / V 검색 결과0.

격리 비게시 Studio 단일 Knight 실제 Player: Dodge 힌트 R, 스킬/아이템 간격32px 확인. V 누르기 전/후 서버 복제 K0DodgeSeq=0→0, R 입력 후1로 증가(assert 통과). [실제 화면](0.20.3-pc.png)에서 아이템은 붉은 TD 셸, 스킬/방어/회피/달리기는 청색, 공격은 녹색으로 표시됨을 확인했다. Root390×700과640×360에서 바가 Root 안에 들어가며 스킬/액션 행이 겹치지 않는 assert를 통과했다. Root 제한은 실기기 검증과 구분한다. Play 중지 후 QA bridge를 Ctrl-C 종료130으로 정리했다. 게시·릴리스 태그·실기기/패드 검증은 수행하지 않았다. 다음 담당: QA 실기기/사용자 시각 수용.

0.20.3 Play bridge 콘솔에는 기존 `203785492` 자산 유형 경고와 Studio MaterialManager `debug.profileEnd()` 경고가 있었다. GUI 검사 통과 및 게임 입력 관측과 별도 기록한다.

## 0.20.4 — Attack 추가 이동

사용자 요청으로 Attack x118→102,16px 더 왼쪽. 소스 `93373b9520af360825a01197364c0c08e6128e59`를 푸시/원격 일치 확인 후 Rojo 빌드 성공.1,009,590 bytes, SHA256 `4e38367dc573e7e6cff00d6cb1bd19c4db98da8d910186dc64903988c1ca8742`. 격리 실제 Knight Player에서 x102·Dodge와 수평 비겹침 assert 통과. QA Play 중지/bridge 종료130. 같은 작업 중 추가된 HP 회복 요청은0.20.5로 분리한다. 다른 작업의 숨겨진 퀘스트 문서 커밋은 보존했다.
