# Haunted Graveyard 몬스터 개별 움직임 리뷰

2026-11-03 · TLT-032/033/055/057/064/084 · ART/ENG/QA · 0.65.2 로컬 교정본·미게시.

[11종 개별 전후 갤러리](index.html) · [종별 발견/수정/원본 한계](review-notes.json) · [F-curve/자산 추적](../../../assets/animations/haunted-graveyard-v1/manifest.json) · [조사/적용 근거](../../research/2026-11-03-haunted-monster-motion.md).

## 변경과 실제 검토

TD 원본10종과 같은 Dread Commander 외형을 쓰는 Veyr까지11개 런타임 종류를 하나씩 검토했다. 각 모델의 수정 전/후 보행0/0.25/0.5/0.75·공격 준비0.4/접촉0.62/회수0.78을 원본 GLB와 실제 로컬 Roblox MeshPart/Motor6D 행렬로 Blender에서 렌더했다. 154원시 자세 렌더와11개 비교판을 남긴다. 갤러리는 native 자세의 Blender 재현이며 실제 플레이 영상/최종 미술 수용과 구분한다.

- Zombie: 낮은 다리에 맞춘 작은 교차 보폭·실제 어깨 축·짧은 손 뻗기/회수.
- Skeleton / Skeleton Knight: 방패 대신 실제 검 ArmL로 공격. 검 끝 소켓·해부학 축·낮은 방패 가드·짧은 지지 보폭.
- Hellhound: 자기 체형의 네 다리 피벗·대각 보행·낮은 물기 예고/접촉/회수.
- Ghoul: 낮은 전신 예고와 전방 할퀴기 이동. Mummy: 작은 팔 뻗기와 몸통 흔들기. Death Knight: 실제 분리된 다리만 보행하고 갑옷/대검은 상체 동작으로 준비/접촉을 표시.
- Lich / Lich Sovereign: 지팡이/옷 조각은 같은 몸통 축에 유지하고 몸통 시전·실제 지팡이 머리의 충전 초점을 사용.
- Dread Commander / Veyr: 큰 일체형에 무거운 전신 예고·전방 접촉·회수. Veyr는 같은 외형의 별도 회전 예고 프로필.

전체에 모델별 Idle/Walk/Attack/AttackAlt/Heavy/HeavyAlt/Stunned,201표본·77클립을 적용한다. 모델별로 총385 Action·1617개 수치 F-curve를 Blender MCP에서 평가했다. 일체형 모델6종은 텅 빈 바운딩 박스 꼭짓점 대신 기존 TD Body 하단의35~43개 표면 표본으로 접지한다. HG 종류를 처음 사용할 때 해당 표본 테이블만 로드한다. 서버 AI/공격 시각/판정·피해/보상과 TD 메시·텍스처 ID는 변경하지 않는다. Gloamwood 임시 외형은 이번 범위 밖이다.

## 검증·재현

- `python3 tools/prepare-haunted-motion.py`: 원본 geometry 해시 대조, 종별 방향/축/소켓과 하단 표본·authoring-keys 생성.
- `tools/author-haunted-motion-blender.py`: `MOTION_KEYS`를 앞에 JSON으로 주입해 Blender MCP에서 실행. 기존 사용자 씬/파일을 보존하고 별도 `TLT_Haunted_v1_Curves` 씬을 만든다. 그 씬의 `haunted_v1_export`는 실제 평가한 clips.json이다. safe mode의 외부 파일 exec/open·library write를 쓰지 않고 호스트에서 입력을 주입/출력을 저장했다. 별도 .blend 파일 저장을 완료했다고 주장하지 않는다.
- `python3 tools/export-haunted-motion.py`: 루프/201표본/유한값/종 일치 검증·200KB 미만의 모델별 ModuleScript 생성. 원본3D와 행동/저장ID 보존.
- `python3 tests/haunted-motion-assets.spec.py`, `python3 tests/haunted-graveyard-assets.spec.py`:385채널·11종/10원본·해시/소켓·원본ID PASS.
- `tools/capture-haunted-monster-review.luau`: 로컬 전용 native 전후 행렬 캡처. `tools/review-haunted-monsters-blender.py --stage before|after --kind <Kind> --output /tmp/review.py`로 safe-mode용 Blender 입력을 만들고 MCP에서 코드를 직접 실행한다. `tools/assemble-haunted-review.py`는 Pillow가 포함된 번들 Python으로 실행한다.
- 수정 후보를 기존0.65.1 로컬 fixture에만 주입한 [엔진 결과](candidate-native.json):380,137검사 PASS. 주로201표본의 유한값 검사이며 접지·접촉·흔적 정리 검사를 함께 포함한다. 6stud/s 지지 발 미끄러짐은 체고0.75~1.26%, 검 끝 전방 이동은 약1.27~2.45stud. 이 수치는 평지 시험이고 실제 플레이/경사 수용이 아니다.
- 기존 Frozen Vale/Ember Caldera full story·지역/Deepwood 동작·스트리밍·배틀 부트스트랩 후보 회귀도 PASS. 최종 고정 소스 빌드 결과는 후속 파일에 기록한다.

최초 fixture는 plugin에 HttpEnabled 쓰기 권한이 없어 실패했고, 불필요한 설정 쓰기를 제거해 허용된 plugin HTTP 읽기로 실행했다. 첫 HG 검사에서는 팔이 분리된 Mummy를 일체형 팔로 잘못 가정해 실패했다. 해부학에 맞춰 해당 준비/접촉 검사를 분기하고 통과했으며 게임 결함 수정을 가장하지 않는다([로그](candidate-first-failure.log)). Blender 엔진 enum 목록이 실제 렌더 엔진을 누락해 첫 렌더가 중단됐고 지원 엔진 할당/예외 처리와 원래 씬 복원을 추가해 재실행했다.

## 남은 한계와 다음 담당

기존3D 분할 때문에 Ghoul/Dread Commander/Veyr의 독립 팔다리, Mummy의 다리, Death Knight의 팔/대검, Lich류의 팔/손목 완전 소유 리그를 새로 완성하지 않았다. Skeleton Knight 등의 갑옷·천 절단면은 큰 회전에서 작은 이음새/조각이 여전히 보일 수 있다. 얼굴·원본 메시를 교체하거나 새 자산을 업로드하지 않았다.

QA/DES: 게시된 클라이언트의 정상 전투/경사·PC/패드/터치·4인+AI 성능·사용자 눈으로 본 자연스러움. ART: 일체형의 실제 관절/스킨과 절단면 후속 미술. 부모 티켓은 In Progress다. 게임 게시/릴리스 태그를 만들지 않으며 기존 로비/이동·애니메이션 미커밋 작업을 선별 커밋/고정 빌드에서 보존한다.
