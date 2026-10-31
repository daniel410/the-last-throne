# 로그인 보상·퀘스트·RPG Gold 교환 조사

TLT-028/031/043/046/048/050/061/084 · 2026-10-31 확인

관찰: TD 원본 `src/Server/LoginCalendar.lua`는 UTC 날짜당1회, 48시간 유예, 7일 순환, 서버 계산/저장 확인 구조다(SHA-256 `50f88a5bb412f5f92969d658f15152f56e6d1261cab43a7844db034aae370c4e`). TD 원본 `src/Shared/Config.lua`(SHA-256 `664abb2c1faa6f1277ca8f4f71fc686d4c636f73c72d534086876ce792cc1249`)의 Gold 상품은 10 Diamonds에 한 판용100 Battle Gold다. `LobbyHomeArtAssets.lua` SHA-256 `acc224ec5472b9a3e2d80601e018a12dd2d48eebbf9d215302b0fa73edd0d809`의 shop 영역은 기존 사용자 소유 TD 원본이다. TD 소스와 운영 데이터는 수정하지 않는다.

[Roblox DataStore 공식 문서](https://create.roblox.com/docs/cloud-services/data-stores) 및 [best practices](https://create.roblox.com/docs/cloud-services/data-stores/best-practices)는 단일 키 UpdateAsync와 응답 불명/순서 보존 재시도를 설명한다. [WoW 공식 UI 설명](https://worldofwarcraft.blizzard.com/en-us/news/15707238)은 지역별 퀘스트와 진행을 함께 탐색하는 접근을 설명한다. 이 사례가 게임 성과를 입증한다는 뜻은 아니다.

적용: 사용자 확정7일 보상을 RPG 계정키의 Gold/수령 기록에 동시에 반영하고 같은 요청의 불명 응답을 재시도한다. Gold 교환은 10 RPG Diamonds→100 계정 RPG Gold로 TD 비율을 참고하되 통화·지갑·지속기간은 분리한다. 퀘스트는 에픽별 본편/선택과 잠금/수락/완료를 스냅샷에서 계산하며 실제 수락은 모험 NPC/발견 경로가 권위다. 왼쪽 Diamond Shop은 기존 TD 원본의 별도 문구 영역을 잘라 같은 표시 크기로 맞춘다.

위험/최소 실험: UTC 전환·48시간 경계·복구/동시성·잔액 부족/가방 가득 참·서버 위조 차단·잠금 퀘스트/옛 진행·작은 화면·배틀 전환을 검사한다. 7일보상/환율의 실제 경제 수용, 게시된 클라이언트와 실기기는 후속이다.
