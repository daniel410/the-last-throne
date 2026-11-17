# 에픽 지도와 지역 상세도 · 0.113.0

TLT-028/061~065/084 · DES·ENG → 기기 QA·플레이어 수용

다섯 에픽의 목록에서 지역을 고르면 실제 지형 위에서 대표 건축물, 사건 장소, 인접 도로를 선택할 수 있다. 도로 선택 후 인접 지역을 열면 그곳의 선행 이야기를 확인할 수 있다. 전투에서는 열린 구역에 개인 핀 하나를 놓고 미니맵과 전체 지도에서 추적한다. 추적 퀘스트 표식은 함께 표시된다. 핀은 현재 원정에서만 사용한다. [비교 조사와 수용 과제](../../research/2026-11-16-region-field-atlas.md)

## Studio Play 화면

[전체 비교](comparison.webp) · [에픽 전체 지도](Overview.webp) · [감시탑](DW-04.webp) · [거미줄 나루](GW-05.webp) · [설원 협곡](FV-03.webp) · [공명 광산](EC-03.webp) · [묘지 비밀 통로](HG-03.webp)

고정 빌드 복사본에서 게임 시작 스크립트를 끄고, 로컬 플레이어의 PlayerGui에 실제 로비 지도와 TD 공통 프레임을 생성했다. 진행도는 읽기 전용 시험 스냅샷이다. 실제 메뉴 영역만 잘라 저장했다. 각 상세 화면은 두 번째 장소를 선택하고 해당 사건 목표가 나타난 상태다.

- Studio Play의 클라이언트 입력으로 에픽 탭 → 스크롤 목록 → 구역 상세 → 두 번째 핀 → 전체 지도 복귀를 시험했다. 다섯 지역의 제목·선택 사건·원화 로드가 일치했다. 시험 입력 좌표에 Studio 상단 여백을 반영한 뒤 각 버튼의 실제 Activated 경로를 통과했다.
- 같은 클라이언트에서 전투 지도를 열고 DW-01 지역 → Creekside Cargo → Pin here → 전체 지도 → 같은 지점의 Clear pin을 눌렀다. 상세도와 전체 지도에서 개인 핀과 추적 목표의 동시 표시, 제거 후 클라이언트 상태 초기화를 확인했다.
- 로컬 Edit 엔진에서 44지역 데이터/GUI·다섯 에픽 연결·세로/가로/데스크톱 레이아웃·미니맵·현 위치·체크포인트·파티와 목표 표식·이미지 생성 불가 시 대체 표시를 검사했다. 6개 집계에서 10,470개 단언 통과. [엔진 로그](native.log)
- 정적 검사에서 체크포인트 메뉴 배치 36개, 파티 지도 96개, 단일 빌드의 역할 10개·도착 로딩 291개가 통과했다. 고정 파일 추출 검사에서 로딩에 필요한 기존 음악 정책 모듈이 누락되어 시험 도구가 중단됐다. 추출 목록에 실제 패키지의 모듈을 포함시켜 같은 빌드로 재검증했다.

## 입력과 재현

소스 `91e671d410c229771ac285d4d661dcfe7c20e44f`에서 단일 Place `builds/0.113.0/TheLastThrone-0.113.0.rbxlx`를 생성했다. 24,253,339바이트, SHA-256 `874abdbd8543ba24ecf95a289f5de74a7540dd6c01c91492b9662dfd41e5cd3f`. 에픽 삽화 5장, 구역 삽화 44장, 음영도 44장으로 이루어진 패키지 93개 항목을 LFS 원본과 대조했다. [빌드 기록](build.json)

- 지역 배치가 바뀌면 격리 Place에서 `tools/export-cartography-native.luau`와 `tools/export-atlas-relief.luau`를 실행한다. 각각의 로그를 `tools/compile-cartography.py --log <log>`와 `tools/compile-atlas-plates.py <log>`에 넣는다. 전자는 배치된 건물의 기본형과 투영 좌표, 도형 2,583개와 도로 선분 5,956개를 기록한다. 후자는 높이·색·법선으로 북서광 음영을 계산하고 저장소의 원본 콘셉트와 함께 패킹한다. 삽화는 분위기·장소 식별용이며 이동 좌표는 실측 도면에서 가져온다.
- 고정 Place에 `tests/region-field-map-native.luau`, `tests/lobby-atlas-native.luau`, `tests/cartography-native.luau`, `tests/epic-map-connections-native.luau`, `tests/deepwood-atlas-native.luau`를 실행한다. 로비 시험은 반환한 `pass` 값을 확인한다. 패키지 구조 검사는 `python3 tests/single-build.spec.py --artifact builds/0.113.0/TheLastThrone-0.113.0.rbxlx`다.

게시 클라이언트·터치/패드 실기기·저사양 기기의 프레임/메모리·사람이 지역을 식별하고 길을 찾는 시간은 미검증이다. 다음 담당은 QA와 플레이테스터다. 서로 다른 에픽 둘과 같은 에픽의 두 구역을 구별하고, 이름을 들은 사건 장소에 핀을 놓은 뒤 현장에서 찾는 과제를 확인한다. 상위 티켓의 사용자 수용은 열려 있다.
