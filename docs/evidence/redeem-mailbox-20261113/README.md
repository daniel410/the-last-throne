# TLT-047/049/084 · 리딤·메일

2026-11-13 · 0.106.0 · 역할: 엔지니어/리서치 · 상태: 로컬 구현·고정 소스 빌드·자동 검사 완료, 엔진/게시 수용 대기.

로비 MENU에 TD 원본 아이콘의 `Mailbox`/`Redeem Code` 메뉴와 상세 창을 연결했다. 운영 공지·대상 계정별 선물·계정당 코드1회 수령, 미확인 수, 대기 아이템 지급, 저장 불명 재시도 경로를 추가했다. 기본 콘텐츠는 환영 공지1개, 실제 리딤 코드/보상은 미등록이다. [운영·저장 계약](../../production/redeem-and-mailbox.md), [공식 비교 조사](../../research/2026-11-13-redeem-mailbox.md), [TD 원본 해시](source-provenance.json).

편집 전 범위: 신규 DeliveryCatalog/Rules/Service, DeliveryGui/Text와 기존 AccountStore·InventoryService·LobbyCommerce·LobbyTopMenu·양쪽 초기화 연결, 전용 테스트/사양/증거. 기존 맵·전투·밸런스·장비 규칙의 미커밋 변경과 자산 수정/삭제는 포함하지 않았다. 빌드는 이번 변경만 커밋한 소스로 고정한다.

## 검사

- `lua tests/delivery.spec.lua`:34검사. 코드 대소문자/공백 정규화·같은 계정의 다른 요청 중복 거부·다른 계정1회·대상/시간 검사·아이템 대기 지급·공지 읽음·메일 중복 차단·잔액 상한·영구 원장 상한·변조 데이터 거부.
- 위 검사에서 실제 AccountStore에 메모리 UpdateAsync 어댑터를 연결해 저장은 커밋됐으나 응답이 유실된 장애를 주입했다.3번 내부 재시도/클라이언트 재시도 뒤 보상은1회이며 타 서버 세션은 AccountBusy로 차단됐다. 세션 해제·재오픈 후 새 요청도 AlreadyRedeemed다. 재접속·동시성은 **로컬 저장 어댑터 모의 검사**이며 실제 Roblox 네트워크 증거가 아니다.
- `lua tests/delivery-remote.spec.lua`:9검사. 클라이언트 금액 추가·추가 인수·잘못된 형식·길이·요청ID 거부, 초당 제한·전투 서버/단계 차단·상태 읽기 무지급.
- `lua tests/daily-login.spec.lua`:73검사, 기존 일일 지급과 계정 lease 회귀.
- `lua tests/inventory.spec.lua`:276검사, 기존 소유권·스택·용량·복구 회귀.
- Luau 컴파일러로 변경 게임 소스11파일을 검사했다. 오류0. 이는 엔진 실행/실제 UI 화면 검증이 아니다.

사용자 미커밋 변경을 제외한 Git 인덱스 트리를 임시 디렉터리에 추출해 위4개 테스트를 다시 실행했고 동일하게392검사를 통과했다. [격리 정적 검사 결과](static-results.json).

## 빌드

소스 `525b5d3c0d2f0646256ae48d601715fe541e215e`를 고정해 `python3 tools/build-game.py --source 525b5d3c --record docs/evidence/redeem-mailbox-20261113/build.json`으로 단일 로비/배틀 파일을 생성했다. 버전 `0.106.0`, 산출물 `builds/0.106.0/TheLastThrone-0.106.0.rbxlx`. 입력 LFS와 결과 SHA256은 [빌드 기록](build.json)에 연결했다. 실제 Place 게시/릴리스 태그는 없다.

## 미검증·인계

Studio의 실제 메뉴 클릭·레이아웃/텍스트·메시지 스크롤·기존 패널 가림, 터치/게임패드, 게시 테스트 계정의 실제 DataStore 저장/재접속·동시 서버는 미검증이다. Studio 연결 목록은 확인했으나 열려 있는 기존 작업 Place는 변경하지 않았다. 로컬/실제 빌드와 Roblox 게시를 구분하며 출시 태그/게시/상품 활성화는 하지 않는다.

다음 담당: UI/저장 QA. 게시 전 실제 로비에서 코드1회→반복→재접속·두 서버 접근, 공지 읽음·아이템 첨부·가득 찬 가방→Claims 수령, 저장 응답 지연 중 CHECK SAVE, 짧은 가로 화면/패드 포커스를 검증한다. 새 운영 코드/메일은 서버 설정에 실제 대상·보상을 등록한 뒤 별도 배포한다. TLT-047/049/084 전체 또는 G3/G7을 Done으로 바꾸지 않았다.
