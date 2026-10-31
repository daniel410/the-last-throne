# 로비 탐색 아이콘 수정

- 작업: 사용자 요청 / 디자인·엔지니어링 / 구현, 시각 수용 대기
- 왼쪽 메뉴의 도형을 승인된 로비 컨셉을 참고해 생성한 5개 아이콘으로 교체했다. 이미지 원본 `assets/ui/lobby-navigation/navigation-atlas.png`, SHA-256 `2379ea2ee8f5389a5acff23cef5f20e70ab8853a9e592215d08bf2ce103650c9`, Roblox 이미지 `137280207574223`.
- Diamond Shop은 왼쪽 메뉴로 옮기고 TD 원본 `LobbyHomeArtAssets.lua`의 `shop` 영역과 이미지 `135608370136189`를 사용한다. 원본 SHA-256 `acc224ec5472b9a3e2d80601e018a12dd2d48eebbf9d215302b0fa73edd0d809`은 공유 레지스트리와 일치한다. TD 소스에서 이 영역은 Diamond Shop으로 연결되어 있다.
- 검증: 로비 Studio 편집 환경에서 두 ImageLabel의 `ContentProvider:PreloadAsync` 콜백 모두 Success. `git diff --check` 통과. 이는 자산 로딩만 확인하며 게시된 RPG Experience의 자산 권한을 보증하지 않는다.
- 미검증: 변경 소스의 Studio Play 화면·클릭 동작, 작은 화면 및 실기기 배치, 게시된 Experience 권한과 사용자 시각 수용. 다음 담당: QA가 실제 로비에서 여섯 버튼과 상점 열기/닫기를 검증한다. 빌드·릴리스·Place 게시 없음.

## Blacksmith 검 수정

- 작업: 사용자 후속 요청 / 디자인·엔지니어링 / 구현, 화면 수용 대기. 구부러진 검을 직선 검으로 교체하고 Blacksmith에만 수정본을 연결했다. 다른 버튼은 기존 이미지를 유지한다.
- 수정본 `assets/ui/lobby-navigation/navigation-atlas-straight-sword.png`, SHA-256 `c4b0eee70bec43efe514f998b40b320762f1e3de54d390968d4034643a35634b`, Roblox 이미지 `97662984602605`.
- 검증: 로비 Studio 편집 환경에서 이미지 `PreloadAsync` 성공, `git diff --check` 통과. 변경 소스의 Play 화면과 게시된 Experience의 권한은 미검증. 다음 담당: QA의 실제 화면 확인.

## 중복 테두리 수정

- 작업: 사용자 요청 / 로비 UI 결함 수정 / TLT-028 관련. 아이콘 이미지에 이미 테두리가 있는데 공통 버튼 배경과 장식도 표시되어 두 겹으로 보였다. 여섯 탐색 버튼의 공통 배경과 장식만 숨기고 이미지·텍스트·클릭 영역은 유지했다.
- 검증: 원본 아틀라스와 버튼 생성 코드를 확인하고 `git diff --check` 통과. Studio Play 화면·클릭과 실기기 확인은 미검증이다. 다음 담당: QA 시각 및 입력 확인. 빌드·게시 없음.
