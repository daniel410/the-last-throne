# 상점 교환 요청 거부 수정

2026-11-06 · TLT-029/041/043/052/084 · ENG → QA · 0.78.12 · 로컬 수정·미게시.

사용자 보고: 보석→마석 변환 오류. 실제 사용자 오류 화면/로그는 확보하지 않았으나 현재 클라이언트 요청으로 재현되는 서버 결함을 확인했다. EnhancementView는 exchangeVersion을 보내지만 MerchantService의 필드 허용 목록에 없어 InvalidRequest로 거부했다. ExchangeGems도 액션 허용 목록에서 누락됐다. 이전 검사들은 reducer/InventoryService를 직접 호출하여 실제 RemoteEvent 진입점 결함을 놓쳤다. 직전 Ore 유료변환에도 같은 누락이 영향을 주므로 함께 수정한다.

MerchantService에서 exchangeVersion 필드를 허용하고 선택적 비음수 정수 검사를 적용했다. 가격 버전의 유효성은 기존 서버 reducer가 확정한다. ExchangeGems 액션도 허용한다. 잘못된 필드 요청은 검증한 requestId로 거부 응답해 클라이언트가 저장 대기를 해제하도록 한다. 사용자 지정 가격/권한·소유·재고·Gold·견적·저장 검증은 유지한다. 신규 설계/경제 수치 변경 없이 명확한 요청 경계 결함만 수정하므로 별도 사례 조사는 생략한다.

검증: tests/merchant-exchange.spec.lua는 실제 MerchantService.start와 RemoteEvent callback을 모의 Roblox 환경에서 실행하고 실제 InventoryRules.shop으로 연결한다. 수정 전 동일 요청의 실패 재현, 수정 후 마석/보석/Ore교환·중복·부족·잘못된 필드/버전·응답ID10검사 PASS. 재료교환180·인벤토리271 합계461검사 PASS. luac 구문 검사 PASS. 결과는 tests.log, 고정 소스 빌드는 build.json에 기록한다.

미검증: Studio/게시 Roblox 클라이언트의 실제 통신·화면·실기기·live DataStore. 게시/릴리스 미실행. 다음 담당 QA는 새 빌드에서 보석5+50Gold→마석1 교환과 대기 해제·재접속을 확인한다. 사용자 보고가 이 결함과 같은 오류였는지는 실제 클라이언트 재확인 필요. 상위 티켓 완료로 처리하지 않는다.
