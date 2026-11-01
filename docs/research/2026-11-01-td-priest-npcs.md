# TD 성녀 원본 3D 모델의 NPC 활용 조사·제안

2026-11-01 · TLT-002/016/031/057/061/062/063/065/072/084 · 조사·설계 제안 완료, 게임 적용 미실행

## 요청과 추천

사용자는 설린느(Selene) 외 TD 성녀들도 NPC로 활용할 방법을 요청했고 **TD의 3D 모델을 그대로 사용**하도록 지정했다. 추가 다섯 원형을 지역에서 만나는 교단 인물로 배치하는 안을 추천한다. 이름·배치·새 상호작용은 제안이며 승인된 게임 기능으로 간주하지 않는다.

Selene는 기존 `nun` 모델과 무료 영입·선택 동행 역할을 유지한다. 다른 성녀들은 축복, 조사, 노래, 추적, 봉인으로 플레이 경험을 구분한다. 10~15세 대상의 구조·우정·용기·회복과 승인된 다섯 에픽에 맞추며 플레이어 클래스와 전직을 추가하지 않는다.

## 1. 실제 원본 확인

- [공유 레지스트리](../../assets/shared/td-asset-registry.json)의 `model.towers`는 `../throne-defense/assets/models/meshy-factions-refresh-v1/runtime.rbxmx`를 가리킨다.
- 현재 TD `default.project.json`의 `ServerStorage.TowerModels`는 **`../throne-defense/assets/models/blender-mcp-rapid-v2/runtime.rbxmx`**를 참조한다. 레지스트리 경로와 다르므로 옛 경로를 최신으로 간주하면 안 된다.
- 현재 파일 SHA-256: `8d5c66f001dd1a59081ac91e43a7115be6b6af6d63102ec9d90436de29473ad6`, 226,671 bytes. 로컬 XML에서 여섯 원형을 모두 확인했다. 상세 부품/리소스·소스 커밋·프로젝트 해시는 [원본 감사 JSON](2026-11-01-td-priest-npc-source-audit.json)에 기록했다. TD 작업 트리에 변경이 있으므로 커밋ID만으로 현재 바이트를 대표하지 않는다.
- `src/Shared/Config.lua`의 Priestess 목록은 `nun`, `blessing`, `judge`, `cantor`, `inquisitor`, `grand`다. 아래 영어 직함은 RPG의 최신 Priestess 통일 표기다. TD 원문 명칭은 별도 원본에 보존한다.
- 별도의 `towers-priests-design-v1` Blender/GLB 6종도 존재하지만 manifest는 `local review not Studio integration`이라고 명시한다. 이 미적용 후보를 현재 TD 런타임 모델과 혼동하지 않는다.
- Selene의 현행 RPG 자산은 [별도 manifest](../../assets/shared/td-selene/manifest.json)에 고정된 기존 `nun`이다. 이번 조사로 자동 교체하지 않는다.

| TD 키 / 기존 명칭 | 현재 XML의 MeshPart 수 | 재사용 판단 |
| --- | ---: | --- |
| `nun` / Light Nun | 3 | Selene 현행 적용 유지 |
| `blessing` / Blessing Priestess | 3 | 추가 고정 NPC 후보 |
| `judge` / Judgment Priestess | 2 | 추가 조사 NPC 후보 |
| `cantor` / Holy Cantor | 1 | 추가 의식 NPC 후보 |
| `inquisitor` / Inquisitor | 2 | 추가 추적 NPC 후보 |
| `grand` / High Priestess | 1 | 추가 고위 교단 NPC 후보 |

MeshPart 수는 삼각형 수·메모리·성능 수치가 아니다. XML에서 외부 메시/텍스처 참조를 확인한 것이며 실제 Roblox 로드, 권한, 시각 수용, 보행 리그 완성을 검증한 결과가 아니다. TD는 `VisualFactoryTowerMeshes.lua` 등에서 별도 장식과 자세를 더할 수 있어 XML 복제만으로 실제 TD 화면과 완전히 같다고 단정하지 않는다.

## 2. 지역별 활용안

개인 이름은 구현 전에 정한다. 우선 TD 직함으로 식별하여 불필요한 새 설정을 줄인다. 아래 사건은 기존 본편의 목적을 돕는 선택 장면 또는 기존 장면의 표현 후보이며 새로운 필수 스토리/보상 단계가 아니다.

| 성녀 | 등장 장소 제안 | 플레이어가 하는 일 → 반응 | 기존 인물과의 역할 구분 |
| --- | --- | --- | --- |
| **Blessing Priestess** `blessing` | Dawnspire 귀환 거점·예배소 | 구조 소식을 전하고 주민을 위한 축복에 참여 → 주민이 안도하고 다음 모험을 응원 | Tessa의 원정 출발, Mira의 거래, Selene의 동행 선택은 유지. 초안은 대화/연출이며 전투 능력치 강화 없음 |
| **Judgment Priestess** `judge` | Ember Caldera 구조 후 안전 구역 | 광부를 구한 뒤 오염 흔적을 함께 확인 → Veyr의 침공 흔적을 밝히고 안전한 작업장 회복을 돕는 짧은 정화 연출 | Brann/Orik은 구조, Dagna는 냉각 장치 수리 담당을 유지. 성녀는 저주·오염 조사 담당 |
| **Holy Cantor** `cantor` | Frozen Vale 피난처 | 흩어진 주민이 돌아왔음을 알리고 의식에 참여 → 따뜻한 빛과 짧은 성가로 쉼터가 되살아나는 장면 | Haldor는 피난처 운영, Nessa는 의무, Ylva는 수호수 돌봄 유지. 성가는 정서적 회복과 의식 표현 |
| **Inquisitor** `inquisitor` | Gloamwood 정찰 캠프 | 끊어진 밧줄·발자국 등 단서를 함께 확인 → 속임수 표식과 안전한 구조 경로를 설명 | Maeve/Finn의 정찰·Tali 구조를 돕는 조사자. 심문·고문 대신 실종자 찾기와 환영 판별로 연령대에 맞춤 |
| **High Priestess** `grand` | Haunted Graveyard 최종 봉인 장소·완결 후 Dawnspire | Elowen의 기록과 친구들의 도움을 모아 준비 완료를 알림 → 전투 이후 왕관의 심장 회복·봉인 의식·귀환 축제를 이끔 | Elowen은 기록, Garrick은 길 안내, Selene는 주민/선택 동료 지원. 주인공의 Veyr 저지·심장 회수 업적을 빼앗지 않음 |

이렇게 배치하면 **설린느는 함께 걷는 친구, 다른 성녀들은 각 지역에서 도움을 주고받는 사람들**이 된다. 최종 의식에 다섯 명을 모두 실물로 소환하기보다 대사·지역 회복 결과로 연대감을 회수하는 편을 우선 검토한다.

### 선택 확장 후보

1. **고정 NPC 대화·퀘스트 연출** — 추천 1차. 기존 모델 배치와 짧은 대화로 역할이 전달되고 경로 AI/새 경제가 필요 없다.
2. **플레이어 참여형 의식** — 후속. 단서 확인·종 울리기·봉인석 상호작용으로 구체적인 행동을 준다. 필수 봉인/저주 해제는 모든 클래스가 실행할 수 있어야 한다.
3. **정지형 전투 지원** — 후속 검토. Cantor의 성역이나 Judge의 제한 정화 등을 별도 임무 예산으로 설계한다. 동행 슬롯을 우회한 추가 전투원으로 제공하지 않으며 효과 중첩·서버 권위·성능 검증이 필요하다.
4. **추가 영입 동료** — 우선 보류 제안. 원본 모델이 있다고 보행·추종·전투 AI가 준비된 것은 아니다. 도입 시 Selene와 동일한 기존 편성 한도 안에서 선택 교대한다. 현행 파티 전체 최대 1명을 지킨다.

## 3. 모델을 그대로 사용하는 제작 계약

- 얼굴·몸·의복·무기/등불/책 등 원형 소품, MeshId/TextureID/SurfaceAppearance·색상·비율을 유지한다. native NPC 얼굴/헤어 생성 경로로 재가공하지 않는다. 새 생성 이미지나 새 3D 제작은 필요하지 않다.
- RPG는 모델 바깥의 이름표·대화·서버 상호작용 앵커·충돌/쿼리 설정을 담당한다. 전체 위치/회전과 배치용 피벗은 조정하되 외형 변형·임의 리스케일은 기본 작업에 넣지 않는다.
- 원본 TD 파일을 수정하지 않고 RPG 전용 경로에 선택한 다섯 모델만 스냅샷으로 고정한다. 원본 해시와 파생 manifest를 기록하고 `.gitattributes`에 따라 3D 파일을 LFS로 관리한다. 전체 타워 팩을 월드에 불필요하게 복제하지 않는다.
- TD의 기존 런타임 장식이 원형 외형의 일부라면 해당 시각 결과를 비교한 뒤 장식만 RPG 표시 어댑터에 재현한다. TD 타워 공격·가격·해금·상품·피해 수치를 RPG NPC 행동으로 이식하지 않는다.
- 기존 NPC 안정ID·퀘스트 수주/보고 위치·상점/창고 서비스와 새 성녀의 책임을 나눈다. Nessa 등의 정체성을 성녀로 자동 교체하지 않는다. 이름/별칭 하나당 실제 고정 인스턴스 하나를 유지한다.
- 추가 기능은 서버가 거리·지역·개인 진행·파티 상태를 확인한다. 중복 입력·재접속·서로 진행이 다른 파티원에 의해 완료/연출이 중복되거나 다른 사람의 진행이 강제 변경되지 않게 한다.
- 승인된 본편 순서, 보상 JSON과 XP/Gold, 무료 Selene 영입, 인간 정원 4명과 현재 AI 생성 상한 1명을 보존한다. 축복의 수치 강화·새 보상·무료 리셋·판매 기능을 이번 제안에 자동 추가하지 않는다.

## 4. 비교 사례와 적용 해석

확인일 2026-11-01. 웹 문서 확인이며 직접 플레이·영상 관찰·인기 순위·유지율 효과의 검증은 수행하지 않았다. 인기작이라는 주장 없이 역할 설계 비교에 사용한다.

| 사례 / 출처 | 확인한 사실 | 우리 게임에 대한 해석·한계 |
| --- | --- | --- |
| [ESO 공식 Companion 안내](https://help.elderscrollsonline.com/app/answers/detail/a_id/53198/~/companions---the-elder-scrolls-online) / PC·콘솔 RPG, 문서 버전·게시일 미표시 | 동료는 전투를 돕고 관련 퀘스트로 해금되며 개인 퀘스트와 관계 요소를 갖는다. 파티에서는 빈 인원에 맞춰 동료가 조정된다 | 성녀마다 만남·함께 한 사건·역할을 부여하는 발상 참고. ESO의 편성 규칙·장비/친밀도 성장을 복제하지 않으며 우리 4인+AI1 계약과 Selene 무료 해금을 유지 |
| [World // Zero 공식 Roblox 설명](https://www.roblox.com/games/2727067538/World-Zero-Anime-RPG) / Roblox, 공개 설명 버전·게시일 미표시 | 지역 탐험·퀘스트·던전·보스·친구와의 플레이와 전투 펫을 소개한다 | 이동하는 전투 지원과 지역에서 맡는 퀘스트 역할을 별도로 고려할 비교 맥락. 이 설명은 NPC별 대화/성녀 시스템을 증명하지 않는다. 우리 안의 지역 의식·조사는 자체 설계 제안 |

## 5. 최소 시험·수용 조건·인계

**최소 시험:** Dawnspire에 `blessing` 한 명을 원본 그대로 고정 배치하고 대화 1개로 축복 역할을 전달한다. 능력치·경제·본편 진행 변경 없이 외형·상호작용 연결을 먼저 확인한다. 이후 `cantor` 1명을 Frozen Vale에 시험하고 나머지 세 명으로 확장한다.

게임 문자열 예시도 아직 제안이며 적용 시 키로 관리한다.

| 키 제안 | en-US 원문 |
| --- | --- |
| `npc.blessing.greeting` | You brought our friends home. Let us give them a warm welcome. |
| `npc.cantor.greeting` | Every voice makes our song stronger. Will you join us? |
| `npc.judge.greeting` | These marks lead back to Veyr. Help me check the area. |
| `npc.inquisitor.greeting` | Tracks can tell us where our missing friends went. |
| `npc.grand.greeting` | You brought the heart home. Together, we can restore its light. |

수용 조건:

- ART: 현재 TD 원본과 RPG 후보의 정면·측면·상호작용 거리 외형 비교. 메시/텍스처/색·소품 불변, 실제 로드 및 RPG Experience 권한 확인.
- ENG: 고정 NPC에 불필요한 Humanoid·경로 탐색·전투 루프 없음. 거리 밖 입력 거절, 대화 prompt 중복 없음, 재접속/스트리밍 재진입 시 인물 중복 없음.
- QA: PC·터치·패드에서 기존 시설 입력을 가리지 않고 대화를 열고 닫을 수 있음. 진행이 다른 1~4인과 Selene 동행 유무를 검증하고 현재 AI 상한이 유지되는지 확인.
- QA/DES: 신규 이용자가 직함·외형·대화를 보고 NPC의 도움과 다음 행동을 구별하는지 관찰. 관찰 인원·오인 횟수·조건을 기록하며 미측정 효과를 성과로 보고하지 않음.
- QA: 동일 장면의 NPC 추가 전후 클라이언트 프레임 시간·메모리·로드 시간과 서버 비용을 같은 기기/인원으로 비교. 삼각형 수·장식 비용·최종 성능 예산은 실측 후 판단.

**실행한 검증:** Python 표준 XML 파서로 현재 TD 프로젝트 경로를 해석하고 여섯 키 존재·MeshPart 수·리소스 참조·SHA-256을 기록했다. JSON 파싱과 문서 diff/상대 링크 검사를 수행한다. 런타임 변경이 없어 게임 빌드·VERSION 증가·릴리스 태그를 만들지 않는다.

**미검증:** 실제 TD 게시판 외형과의 일치, RPG 메시/텍스처 로드·권한, 시각/동작·실기기·4인+AI 성능·사용자 수용. 이번 산출물은 조사·활용 제안이며 모델 가져오기·게임 배치·지원 기능 구현 완료가 아니다. 관련 상위 티켓의 완료 상태는 변경하지 않는다.

**다음 담당:** PLAN/DES가 지역 역할과 기존 사건의 연결을 정리 → ART가 현재 TD 원본을 고정하고 외형·권한 확인 → ENG가 고정 NPC 최소 시험 적용 → QA가 입력·중복·기기/파티 회귀와 시각 수용 검증.
