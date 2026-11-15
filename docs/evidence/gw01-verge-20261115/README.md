# TLT-065 / GW-01 숲 가장자리 군집

2026-11-15. 제작 스킬의 맵 구현·환경 아트·환경 3D·리서치 역할을 순차 수행했다. G5 미완료.

## 제작표와 변경 범위

GW-01 화물 수송로에서 정찰대의 거미줄 수색 공간으로 갈라지는 서사에 맞춰, 기존 양옆 두 줄의 동일 간격 수목을 높이와 깊이가 다른 군집으로 재구성했다. TD ForestTree 원본을 기존 DeepwoodEnvironment의 pinned clone과 Gloamwood 재질 어댑터로 재사용한다. 외부 자산·새 메시·텍스처·Blender 수정 없음. 원본 권한/해시는 assets/shared/td-deepwood-environment/manifest.json을 따른다.

- GloamwoodVergeVegetation: 최대18후보, 실제15나무/45메시파트, 6군집, 높이42/47/54/59/68/73stud. 군집별 회전·깊이 변화. 기존 거미줄 지지 나무와 거미줄은 유지한다.
- 기존 LayeredVegetation 전체 ForestTree는36그루였다. 새15그루는 군집 부분의 수이며 유지된 거미줄 나무는 포함하지 않는다.
- 바닥/진행/보상/저장/다른 지역 미변경. 지면 지지와6stud 네 방향 높이차1이하·나무 간24stud·수관 반경 예약·지역 내부를 통과한 위치만 채택한다. 다른 장식의 RNG 소비를 보존했다.
- EpicWorldArt23, GW-01에만 적용. 원래 권위 보행/전투 예약과 최종 충돌·배치 처리를 유지한다.

## 검증

고정0.110.5 / d62e438b1e74a41b1a810ef4e94946bc483e010e. [빌드](build.json), [엔진 결과](results.json), tests/gloamwood-verge-vegetation-native.luau.

격리 /tmp/tlt-gw01-verge-qa.rbxlx, PlaceId0/플레이어0, Studio Edit에서 후보 소스 주입 없이 실제 Epic2를 생성했다. 원본 메시·접지·높이/군집·예산·34조사흔적 유지110검사 통과. 기존 epic-map-navigation-native를 같은 생성 world에 연결하고 epic=2만 검사: points 105목표5196표본, worldPoints 117목표5491표본. 차단/바닥/보정/안내/단차 모두0. 실제 Humanoid 보행이 아닌 엔진 표본 감사다. 다른 에픽·전체 전투 회귀는 재실행하지 않았다.

[이전](before.png) / [변경](after.png): Edit 기본 조명, 카메라(-1460,240,-3760)→(-1000,65,-4070). 별도 이전 클라이언트가 아니라885db3ae의 EpicWorldArt 모듈을 QA 장면에서 재생성한 뒤 LayeredVegetation만 교체한 비교다. 초기 baseline 재생성의 scope 인자 오류를 W.scope(2)로 정정한 후 촬영했다. 군집은 확인했으나 조감 화면은 실제 게임 카메라/지역 안개가 아니다. 지면 재질 로딩 차이는 식생 효과로 해석하지 않는다.

넓은 평지·각진 외곽·지역 경계와 재질 대비는 남았다. 최고 품질 수용/게시/릴리스로 판정하지 않는다. 게시 클라이언트·지역 카메라/입력·실기기·스트리밍·다인 성능·사용자 미술 수용 미검증. 다음 DES/QA는 게임 카메라의 군집/수색 단서 판독, 맵 담당은 큰 외곽 대표 구간 개선을 맡는다.
