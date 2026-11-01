# NPC 컨셉 개별 재대조 v4

2026-11-01 · TLT-031/057/061/084 · ART/ENG → ART/QA · 0.58.8 로컬 교정본

사용자 피드백에 따라 Selene를 제외한29명을 여섯 원본 컨셉 보드와 한 명씩 대조했다. [인물 선택형 비교 미리보기](index.html)는 원본 컨셉 얼굴 확대, 현재 정면/60도 측면, 이전v3를 보여 준다. [개별 기록](review.json), [자산 출처/해시](../../../assets/npcs/heads-v4/manifest.json).

## 변경

- 29명 각각의 머리 폭/높이, 헤어 길이/가르마와 실루엣을 프로필로 분리했다. 블록 몸체·복장·소품·서비스·안정ID와 Selene 원본은 유지한다.
- 곡선을 따라 회전/두께를 바꾸는 머리 가닥과 세 갈래 땋기, 단발 끝 웨이브, 묶은 머리/번/장발을 Blender MCP로 제작했다. 귀·귀걸이·모자 표면은600개 삼각형으로 내보내고 Roblox에서 WedgePart로 재구성한다.
- Aldric/Haldor/Brann의 긴 수염과 Oren/Fen의 짧은 흰 수염을 분리했다. Rowan/Rook은 돌출 턱 부품 대신 Blender에서 가까운 수염을 직접 페인팅했다.
- Pip의 넓은 녹색 얼굴/큰 귀, 엘프 귀, Dagna 고글, Orik 작업등/헬멧, Garrick 모자와 Elowen/Wispkeeper 장식을 조정했다. 모자는 머리 위에 뜨지 않도록 낮추고 윗면을 닫았다.
- 회색 머릿결 텍스처1장만 image_gen으로 생성했다. 원본 얼굴29장은 v3를 재사용하고 Rowan/Rook 두 장만 페인팅했다. 얼굴은 머리 표면 직접 Decal이다.

## 확인과 한계

29명 모두 개별 정면/측면 렌더를 직접 확인했다. 비교 갤러리는 Blender 검토용 어깨 셸을 사용한다. 실제 Roblox의 원래 복장/소품과 구면 Decal 투영은 Blender 렌더와 다르다. [Studio Aldric](studio-aldric.png), [Rowan](studio-rowan.png), [Pip](studio-pip.png), [Orik](studio-orik.png)는 실제 Edit 모드 중간v4 캡처다. `studio-mira.png`는 최종 단발 웨이브 보강 전 캡처다.

최종 소스 격리 캐스트 검사: `python3 tools/prepare-npc-preview.py`와 `run-in-roblox --place /tmp/tlt-npc-cast-v1/tlt-npc-cast-preview.rbxlx --script tests/npc-cast-native.luau`에서 **9,882개/30인물/3,716파트 통과**, Deepwood8배치 확인. Studio 검토 모델29명에서29얼굴+머릿결 총30이미지 로드 Success를 확인했다. 고정 버전의 최종 빌드/검사 결과는 `build.json`에 기록한다.

최종 미술 수용은 아직 없다. 원화의 흐르는 모발과 달리 분할 곡선의 겹침/연결선과 뭉친 형태가 남고, 비스듬한 얼굴 투영에는 왜곡이 남는다. 캐스트 전체 파트는 v3의1,230개에서3,716개로 늘었으므로 모바일·다인·스트리밍 성능을 수용하지 않는다. 구조/로드 통과를 원화 일치나 최종 미술 통과로 간주하지 않는다.

기존 TD 자산203785492 타입 불일치 경고는 별도다. 실제 게시·릴리스 태그·라이브 DataStore·TD 운영 자산은 변경하지 않았다. 다음 ART는 사용자 검토와 함께 연결선이 남는 헤어를 전용 곡면 메시/UV로 다듬고, QA는 두 게시 테스트 Place의 권한·실기기 성능을 확인한다. 상위 티켓은 진행 중이다.

최종 고정0.58.8 빌드: 소스 `8c55dca`, Lobby 캐스트9,882개/30인물/3,716파트, Battle 시작136개 통과. [빌드 해시·명령](build.json), [캐스트 로그](cast-native.log), [Battle 로그](battle-native.log). 원격main 일치와 LFS38/38·125MB 전송, fsck 성공을 확인했다.
