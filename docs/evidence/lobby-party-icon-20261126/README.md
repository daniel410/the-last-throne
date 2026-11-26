# Dawnspire 파티 진입과 LoT 아이콘

2026-11-26 · TLT-053 / G3 · ENG → QA · [로비와 원정 계약](../../production/lobby-economy-and-expeditions.md#솔로와-파티)

- League of Throne 작업 트리의 `game/client/CitadelArt/lobbynav.txt`에서 `Art.lobbyIcon`이 사용하는 `party` 셀을 추출했다. 원본 아틀라스 SHA-256은 `e10a9b83d82af2eee2a056f2fcf9b33dc2bd92c3937a481e3aa883cae32b0dcf`다. 128×128 셀에서 투명 여백만 잘라 126×86으로 만들고, LoT의 채도·중간톤 보정을 팔레트에 적용했다. 기존 지도 그림과 같은 팔레트 포맷으로 이미지 데이터를 빌드에 포함시켰다. Dawnspire는 기존 TD 이름표와 크기 규칙에 맞춰 표시한다.
- [파티 접근 비교 조사](../../research/2026-11-20-party-access.md)를 재사용했다. Diablo IV의 모집 목적 표시, World of Warcraft의 인스턴스 모집, Lost Ark의 비밀번호 가입을 공식 문서로 재확인했다. 이번 작업의 적용 범위는 기존 모집과 협동 원정으로 들어가는 로비 진입점이다. [Diablo IV](https://news.blizzard.com/en-us/article/24128995/delve-deeper-into-nahantu-with-mercenaries-dark-citadel-and-more) · [World of Warcraft](https://news.blizzard.com/en-gb/article/23796742/shadowlands-a-look-at-cross-faction-instances) · [Lost Ark](https://www.playlostark.com/en-us/news/articles/august-2023-wield-the-storm-release-notes).
- Studio Play의 격리 미리보기에서 로비의 **PARTY**를 마우스로 눌러 모집 탭이 선택되고 2·3·4인 생성 버튼이 표시되는 것을 확인했다. 기사를 선택한 뒤 **CREATE 2-HERO PARTY**를 눌러 `PARTY · 1/2` 명단, 활성 **READY**, 비활성 **START PARTY ADVENTURE**를 확인했다. [로비 화면](dawnspire-party-lobby.jpg) · [모집 화면](dawnspire-party-recruitment.jpg).
- 첫 정식 빌드 0.117.11에서 Rojo가 Base64 끝 줄바꿈을 보존해 아트 디코딩이 실패했다. payload의 끝 줄바꿈을 제거하고 0.117.12로 다시 빌드했다. 고정된 0.117.12 산출물에서 Studio Edit의 아이콘 41개, 그리드 2,113개, 모의 행위자와 저장소를 사용한 파티 접근 26개, 2~4인 파티 출발·실패 복구 223개 검사를 통과했다. 정적 단일 빌드에서 Place 역할 10개와 도착 로딩 326개 검사도 통과했다. [초기 빌드](initial-build.json) · [최종 빌드·SHA-256](build.json) · [Studio 로그](native.log).
- 게시 Roblox 클라이언트, 실제 계정 간 파티 이동과 합류, 실기기 입력과 사용자 수용은 대기 중이다. 다음 담당은 QA이며, 같은 버전의 테스트 로비와 배틀에서 실제 3계정으로 모집·준비·입장·재접속을 확인한다.
