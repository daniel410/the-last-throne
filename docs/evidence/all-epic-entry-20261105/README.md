# 전체 에픽 진입 추가 검사 · 2026-11-05

TLT-003/057/061/062/063/064/065/084 · ENG 검증 → QA · 검사 대상 0.75.7

사용자 요청: 칼데라 외 에픽도 로딩에서 멈추는지 검사한다. 게임 소스 변경이나 추가 빌드·게시 없이 0.75.7 단일 산출물을 검사한다. 기존 0.75.5의 설원/칼데라/어두운 숲/묘지 체크포인트 Enabled=false 결함과 수정은 [선행 기록](../regional-entry-spawn-20261105/README.md)에 있다.

## 환경과 재현

- `tools/prepare-all-epic-entry-test.py --artifact builds/0.75.7/TheLastThrone-0.75.7.rbxlx --output /tmp/tlt-all-epic-entry-0757.rbxlx`로 별도 Studio fixture를 만든다. 원본 산출물은 덮어쓰지 않는다.
- fixture의 InventoryService.open에서 Studio session adapter의 단일 계정에만 검증된 Lv80 Knight/완료된 영구 본편 저널을 만든다. 실계정·DataStore 변경 없음. 이 fixture는 게시하지 않는다.
- 실제 원정 Configure/Solo 원격 요청, 실제 CampaignWorld/스토리/전투 초기화, HeroSession/SpawnService 캐릭터 교체, 실제 클라이언트 HUD/지도·카메라/스트리밍을 사용한다.
- 이동이 없는 Lobby Play에서는 도착 스크립트의 역할 선택만 Battle로 지정한 비활성 QAEntryLoader 사본을 각 진입 직전 실행한다. 나머지 로딩 완료 로직은 산출물과 동일하다. 커버 설치→Tutorial/SpawnReady→커버 제거→현지 지역 판정→ReturnLobby/새 캐릭터 준비를 확인한다.
- `tests/all-epic-entry-native.client.luau`를 격리 Play의 Client에서 실행한다. 전체 검사 결과는 LocalPlayer의 TLTQAEntryResult JSON으로 남는다. 대기에는 제한 시간을 둔다.

## 결과

최종 새 Studio Play에서 27검사 PASS. 5에픽 모두 실제 캐릭터 준비·현지 지역 판정·로딩 커버 해제·로비 복귀 PASS. 원본 결과는 [native-result.json](native-result.json)에 기록했다. 이 로컬 조건의 진입→로딩 해제는 약2.55~4.28초였으며 실제 Teleport 시간과 비교하지 않는다. 첫 실행에서 FV/EC/GW/HG는 모두 정상 진입·로딩 해제·복귀했다. DW도 로딩은 해제됐으나 테스트가 지역 공통 오프셋을 가정해 위치 검사에 실패했다. 실제 위치의 CampaignAccess.region이 DW-01임을 확인했다. 위치 검사 기준을 서버와 공통인 지역 판정으로 교체하고 새 Play 세션에서 전부 다시 실행했다. 이 과정에서 게임 코드는 변경하지 않았다.

기존 회귀: battle-startup223, arrival-loading108, story-respawn28, Frozen Vale460, Ember Caldera600, late-epics959, late-epics-adventures186 PASS. k0-spawn 수명주기 PASS. 새 클라이언트 테스트 Luau 컴파일 및 fixture 생성 PASS.

## 한계와 다음 담당

선행 5에픽44지점/93검사는 독립 월드 생성과 충돌 바닥을 확인했다. 이번 Play 검사는 한 로컬 세션에서 설원→칼데라→어두운 숲→묘지→Deepwood 순서로 월드를 추가 생성하며 각 에픽 시작 스토리에 진입하고 매번 로비로 복귀한다. 모든35스토리/난이도/다인 테스트는 아니다.

게시된 0.75.5에는 이전 결함이 남아 있으며 0.75.7은 미게시다. 실제 Experience 간 Teleport/MemoryStore 입장권·느린 네트워크·모바일 실기기는 검증하지 않았다. 다음 QA는 게시된 테스트 Lobby→Battle에서 같은5에픽을 확인한다. 상위 티켓 완료나 실제 게시 이동 통과로 표시하지 않는다.
