# 포션 요청 대기 상태 복구

- 작업: TLT-043/046/084 관련 사용자 결함 수정 / 엔지니어. 보고: 상점 구매 포션을 HP가 줄어든 상태에서 사용해도 반응·메시지가 없음. 상위 티켓 완료 상태는 바꾸지 않는다.
- 확인한 결함: InventoryGui가 `Busy` 응답을 받으면 pending을 유지하지만 자동 재시도가 없었다. pending 중 다음 Z/C 요청은 안내 없이 반환했다. 또한 최신 상태 방송 이후 도착한 이전 revision의 요청 결과를 버려 pending을 해제하지 못하는 순서 문제가 있었다. 사용자의 실제 실패 세션에서 이 조건이 발생했는지는 아직 직접 관측하지 못했다.
- 변경: Busy 응답에는 같은 요청 객체·requestId·revision·itemVersion을 0.5초부터 최대2초 간격으로 재시도한다. 중복 Busy 응답은 타이머를 중복 생성하지 않으며 완료·GUI 파괴 후 재시도를 중지한다. 최신 snapshot은 유지하면서 늦은 요청 결과도 처리한다. 대기/데이터 미준비/영웅 미선택 상태의 포션 입력에도 영어 안내를 표시한다. SaveUnknown은 미확정으로 유지해 새 소비 요청을 만들지 않는다.
- 변경 파일: `src/client/InventoryGui.luau`, `tests/potion-request-recovery-native.luau`. 서버 피해/회복·저장·잔액·동일 요청 중복 방지 계약은 유지한다.
- 실제 Studio 재현 조사: 기존 로컬0.47.0 Battle 파일에서 세션 한정으로 ServerRole을 Lobby로 바꿔 Mage를 생성했다. 시작 HP XL1개를 팔아 Gold30을 얻고 Small HP1개를 Gold20에 구매해 기존 스택이3→4가 됐다. Training 진입 후 서버에서 HP30을 설정하고 실제 InventoryRequest Use를 보내 수량4→3 / HP30→100을 확인했다. 이어 HP30에서 실제 Z 입력으로 HP100 회복을 확인했다. 이는 일반 구매/사용 경로가 동작한다는 증거이며 사용자의 실패 화면 재현은 아니다. 조사 후 Play를 중지하고 원래 Battle 역할을 복구했다. 라이브 계정 데이터는 사용하지 않았다.
- 네이티브 회귀: `python3 tests/make_k0_source_probe.py --output-dir /tmp/tlt-potion-recovery --test-script tests/potion-request-recovery-native.luau`로 격리 Place를 생성했다. 기존 K0EnemyClips의 Source가200,000자 한도를 넘으므로 실제 shared/client 모듈(해당 미사용 대형 모듈과 실행 init 제외) 및 InventoryRules만 주입한 임시 runner를 사용했다. 외부 네트워크 대신 가짜 전송에 Busy/지연 응답을 주입하며 실제 GUI와 동일 receive/use/send 함수를 검사한다.
- 실행: `run-in-roblox --place /tmp/tlt-potion-recovery/tlt-k0-qa-empty.rbxlx --script /tmp/tlt-potion-recovery/potion-probe.luau`. 결과: **12개 통과, 실패0**. 구매 스택 사용·중복 Busy·같은 명령 재시도·중복 소비 방지·성공 후 다음 입력·늦은 응답/최신 revision 보존·SaveUnknown·GUI 파괴 정리를 확인했다.
- 부정 대조: 임시 runner에서 자동 Busy 재시도만 끄면4번째 검사에서 실패했다. 이전처럼 과거 revision의 응답을 버리는 동작을 복원하면 늦은 응답 뒤 다음 사용 검사에서 실패했다. 생산 소스는 두 수정 모두 유지한다.
- 순수 회귀: `lua tests/starter-potions-and-shop.spec.lua` **170개 통과**, `lua tests/inventory.spec.lua` **265개 통과**. `git diff --check` 통과. 기존 자산203785492 유형 경고는 유지한다.
- 로컬 적용/미검증: 현재 Studio의 InventoryGui에 수정 소스를 적용했다. 새 게임 빌드·저장·Roblox 게시·릴리스 태그는 수행하지 않았다. 게시 클라이언트의 실제 실패 세션, 실기기, 실제 저장 지연/다인 상황은 미검증이다.
- 다음 담당: QA/사용자가 같은 구매 포션과 Z/C·터치·가방 사용 경로에서 재확인한다. 증상이 남으면 실제 표시 오류와 메뉴/포커스 상태를 추가 수집한다.
