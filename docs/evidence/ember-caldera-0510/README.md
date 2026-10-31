# Ember Caldera 로컬 구현

2026-10-31 · TLT-063/057/084 · ENG/ART/QA · 0.51.0 로컬 시험판, 미게시

## 플레이와 구현

Frozen Vale 완료 저장에서 EC-01로 이어진다. Ash Gate→Forge City→Collapsed Resonance Mine→Split Coolant Canals→Ancestral Design Vault→Geothermal Heart Testworks→Great Furnace의7본편과3선택 지역/4선택 퀘스트·7체크포인트를 구현했다. 최신 승인대로 광부 구조→냉각 복구→Magma Golem/Inferno Overlord 격파→도시 복구→열쇠를 쫓아 Gloamwood로 향하는 단서를 잇는다. Gloamwood 자체는 아직 미구현이다.

- 기존 EC 안정ID·고정3883XP/4640Gold와 기존 두 에픽 저장/선택을 유지한다. 선택 퀘스트 고정 예산0은 미확정 예산을 새로 배정하지 않는 시험값이며 처치 보상은 별도다. 클래스/전직/재화 공유 계약은 변경하지 않는다.
- 광부 Orik 개인 호위·거리/위협 시 정지·단계 저장, 솔로 순차 밸브/시험 장치, 수리 저장 확정 후 승강기의 도시 안전 체크포인트 이동을 연결했다. 도보 길도 제공하며 물리 승강기 탑승/다중 플레이어 동기화가 완성됐다고 보고하지 않는다.
- 지속 지반/넓은 현무암 길·용암 배경/광산 지지대/냉각 수로/도시 작업장/시험로/대용광로, NPC5명과 창고/기존 Selene 편성 게시판을 적용했다. 현재4인/AI전체1명 제한을 유지한다. 개인 완료 장치/용광로 복구색을 서버 저장 스냅샷에 따라 표시한다.
- Inferno Overlord는65%/30%에서 치명타를 단계 경계로 제한하고 유한 증원을 예약한다. 주황 지면 경고는 기존2초 예고/서버 피해 계약을 쓴다. 화산 보스는 격파 전투이며 Frozen Vale의 비살상 처리와 분리한다. 보스 격파 후 미보고/재접속도 저장된 목표에서 계속한다.

## TD 자산과 Blender

[원본/해시/삼각형/권한 범위](../../../assets/shared/td-ember-caldera/manifest.json): Imp/Lava Slime/Golem/Magma Worm/Volcano Shaman/Magma Imp/Magma Golem/Inferno Overlord/Caldera Titan/King Volcano Shaman10종을 현재 TD 런타임에서 추출했다. 메시·텍스처 ID와 원본 GLB/geometry를 고정하며 실행 코드를 반입하지 않는다. TD 운영 소스/게시/상품은 변경하지 않았다.

Blender MCP에서 별도 `TLT_EmberCaldera_Monsters_v1` 장면을 만들고70논리 클립/350 Action/채널당201표본을 제작했다. 대기/보행/일반2/강공격2/스턴,슬라임 압축/도약·벌레 몸 공격·주술사 시전·큰 적 준비/타격/회수와 원본 무기 끝 소켓을 적용했다. 서버 접촉 시점은.62표본에 대응한다. [모션 GLB](../../../assets/animations/ember-caldera-v1/ember-caldera-motion.glb) · [곡선/해시](../../../assets/animations/ember-caldera-v1/manifest.json).

현재 Blender의 다른 TD 작업 장면과 원본 파일을 보존했다. 활성 장면만 GLB로 내보내고 코드/JSON을 재현 원본으로 보존한다. 단일 GLB 리뷰 릴의 애니메이션 트랙 수와70개 논리 클립 수는 다르다. NLA: Idle0/Walk140/Attack280/AttackAlt420/Heavy560/HeavyAlt700/Stunned840,각120프레임,120fps.

재현: `python3 tools/prepare-ember-caldera-assets.py` → manifest를 INPUT 상수로 `tools/author-ember-caldera-motion.py`를 Blender MCP에서 실행 → scene의 ember_export/ember_sockets를 clips.json/sockets.json으로 수신 → `python3 tools/export-ember-caldera-motion.py`. 별도 Blender 프로세스로 동작을 합성하거나 새 Roblox 에셋을 업로드하지 않았다.

## 검증과 한계

최종 소스/빌드/SHA는 build.json,검사 결과는 final-validation.json과 각 로그에 기록한다. 미게시 로컬 Studio의 실제 지반/메시/관절/GUI·서버 콜백 검증과 가상 플레이어/계정 의존성을 구분한다. 가상 플레이어의 승강기 이동은 저장 후 이동 요청/목적지를 검증하는 mock이며 실제 플레이어의 CombatService 이동 수용은 후속이다. 일반 공격 타이밍/거리·영웅 전투 회귀는 별도 네이티브 검사로 확인한다.

미검증: 실제 플레이어 정상 전투 완주/Lv30 성장·실계정 장애 저장/재접속·PC/패드/터치 입력·4인+AI 성능·경사 IK·게시 Experience의 메시/텍스처 권한·최종 미술/난이도 수용. 지형/소품은 네이티브 파트 시험 미술이고, 손목/팔꿈치 스키닝과 독립 화염 투사체는 새로 완성하지 않았다. Lava Slime은 이번 버전에서 강체 압축/도약 동작이며 신규 분열 메커니즘은 미구현이다.

TLT-063/057/084 부모 작업은 In Progress를 유지한다. 다음 담당은 QA/DES이며 정상 입력·실기기·다인 수용을 진행한다. 일반 로컬 빌드이므로 Roblox 게시/릴리스 태그를 만들지 않는다. 관련 소스·자산·증거만 커밋/푸시하고 기존 미커밋 로비/이동 변경은 제외한다.
