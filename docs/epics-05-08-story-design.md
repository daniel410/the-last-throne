# 에픽5~8 줄거리·26스토리·몬스터 설계 목차

> **2026-10-30 사용자 지시 · 보류:** 기존 에픽5~8의 줄거리·개별 스토리·몬스터·컨셉 확장은 중단한다. 기존 자료는 참고안으로 보존한다. 에픽1~4는 수정하지 않는다. [어두운 숲·거미 여왕 후보](production/dark-forest-epic-candidate-2026-10-30.md)는 번호/채택 미정의 별도 제안이다.

> 2026-10-30 [지역4장·몬스터8종씩4장 컨셉 갤러리](../assets/concepts/2026-10-30-late-epics-v1/index.html) · [원본/프롬프트·시각 검토](../assets/concepts/2026-10-30-late-epics-v1/README.md). 사용자 검토 전 생성 컨셉이며 게임 모델/실행 완성을 뜻하지 않는다.

2026-10-30 · **TLT-065/late-epics-20261030** · 사용자 요청에 따른 상세 기획 초안, 구현 전

앞서 개정한 전체 줄거리를 이어 에픽마다 도입·지역 갈등·선택/대가·결전·다음 장 연결을 작성했다.4개 전체 줄거리,26개 개별 시나리오,32개 몬스터/보스 교전 정의를 제공한다.26개는 **메인25개+에필로그1개**이며 앞의 승인32구간과 구분한다. 후반의 레벨 범위·명칭·배치·새 퀘스트/적ID는 설계 제안이고 XP/Coins/전투 수치는 미정이다.

[공통 진행·성장·복구 계약](epics-05-08-content-contract.md) · [몬스터 상세](epics-05-08-monsters.md) · [설계 JSON](../assets/narrative/epics-05-08-design.json) · [조사/채택 근거](research/2026-10-30-late-epics-and-enemies.md) · [검증·인계 기록](evidence/epics-05-08/README.md)

## 에픽별 이야기와 재미

| 에픽·전체 줄거리 | 스토리 수·레벨 위치 목표 | 플레이/감정의 중심 | 필수 보스 |
| --- | --- | --- | --- |
| [5 · 하늘에 남은 다섯 번째 서약](epic-05-aether-spire-story.md) | 6개 · Lv40→50 목표·XP 미설계 | 아는 것과 결정할 권한은 다르다. 이리아가 답을 독점하려는 태도를 바꾼다. | Archive Custodian / The First Warden |
| [6 · 갈라진 성채](epic-06-divided-citadel-story.md) | 6개 · Lv50→60 목표·XP 미설계 | 두려움 속의 선택에도 책임이 남는다. 세렌은 명령보다 주민을, 루칸은 끝내 통제권을 고른다. | Writbound Captain / Regent Lucan |
| [7 · 다섯 깃발의 원정](epic-07-five-banners-story.md) | 7개 · Lv60→70 목표·XP 미설계 | 동의는 서명에서 끝나지 않는다. 철회와 실패도 견디는 협력을 실제 원정으로 증명한다. | Riftbreaker Behemoth / Dread Commander |
| [8 · 영원의 왕좌](epic-08-fractured-crown-story.md) | 7개 · Lv70→80 목표·최종전 전 안전 전직 안내 | 기억하는 것과 붙잡는 것은 다르다. 주인공은 독점 권한과 대신 짊어질 희생을 내려놓는다. | Crown Custodian / The Eternal King |

각 에픽은 일반5·필수 보스2·선택 보스1의8교전 정의다. 총32개는 일반20·필수8·선택4이며 같은 원형/종의 지역 변형이 포함된다.32신규 모델이나 완성 AI 수가 아니다. 기존 프롤로그/에픽1~4의32구간과 합쳐58구간의 설계 문서가 되지만, 승인된 성장 정본은 여전히 기존32행이다.

## 세부 스토리

### 에픽5 · 하늘에 남은 다섯 번째 서약

| ID | 개별 시나리오 | en-US 가칭 | 그 이야기에서 달라지는 것 |
| --- | --- | --- | --- |
| AS-01 | [추락하는 하늘 항구](aether-spire-story-01-falling-quay.md) | The Falling Quay | 현존 조사대를 구하고 AS-02 도서관 진입로를 확보한다. 시민 잔향은 구조 대상 생존자로 오인하지 않는다. |
| AS-02 | [매달린 도서관](aether-spire-story-02-suspended-library.md) | The Suspended Library | 안전 거점과 기록 열람 기준을 확정한다. 전투/구매/편성 없이 완료한다. |
| AS-03 | [빌려온 하루](aether-spire-story-03-borrowed-day.md) | A Borrowed Day | 기억 재생의 한계를 체험하고 AS-04 피난 원본의 위치를 얻는다. |
| AS-04 | [명령이 갈라진 관측소](aether-spire-story-04-command-observatory.md) | The Divided Observatory | 왕의 공적과 독점의 시작을 모두 확인하고 부분 공동 제어 절차를 얻는다. |
| AS-05 | [혼자만의 정지 버튼](aether-spire-story-05-unshared-switch.md) | A Switch for Everyone | 실패를 회복 가능한 사건으로 경험하고 이리아의 권한 양도를 확정한다. |
| AS-06 | [최초 수호자의 거절](aether-spire-story-06-first-warden.md) | The First Warden's Refusal | 설계·리라의 의사·국소 안전 시험을 확보한다. 핵은 아직 차단 보관이며 DC-01 귀환이 열린다. |

### 에픽6 · 갈라진 성채

| ID | 개별 시나리오 | en-US 가칭 | 그 이야기에서 달라지는 것 |
| --- | --- | --- | --- |
| DC-01 | [닫힌 귀환길](divided-citadel-story-01-sealed-homecoming.md) | A Sealed Homecoming | 왕도 생활권에 진입한다. 일반 경비 제압은 사망/처치로 표현하지 않는다. |
| DC-02 | [빛이 머무는 병원](divided-citadel-story-02-hospital-of-light.md) | The Hospital of Borrowed Light | 전투 없는 거점에서 비상 가동의 이익과 피해를 함께 보고 대체 지원 계획을 얻는다. |
| DC-03 | [목소리 이전의 명령](divided-citadel-story-03-orders-before-the-voice.md) | Orders Before the Voice | 루칸의 책임과 세렌의 선택을 확정하고 물길 피난 경로를 얻는다. |
| DC-04 | [성벽 아래의 물길](divided-citadel-story-04-water-beneath-the-wall.md) | Water Beneath the Wall | 왕좌 가동 축소 전 최소 돌봄·물길·피난 기반을 확보한다. |
| DC-05 | [명령장의 계단](divided-citadel-story-05-captains-stair.md) | The Captain's Stair | 인간 경비를 죽이지 않고 왕성 연결실에 접근한다. |
| DC-06 | [섭정의 마지막 명령](divided-citadel-story-06-regents-last-order.md) | The Regent's Last Order | 루칸의 통치가 끝나고 재판 경로를 기록한다. Lv60 전직 시험을 안전 거점에서 안내하고 FB-01을 연다. |

### 에픽7 · 다섯 깃발의 원정

| ID | 개별 시나리오 | en-US 가칭 | 그 이야기에서 달라지는 것 |
| --- | --- | --- | --- |
| FB-01 | [다섯 자리가 놓인 식탁](five-banners-story-01-table-of-five.md) | A Table for Five | 다섯 역할의 본편 기본 지원을 확보한다. 숨은 퀘스트/동료 호감도/재화 지불은 선행이 아니다. |
| FB-02 | [왕을 향하지 않는 호송](five-banners-story-02-relay-convoy.md) | A Convoy Away from the Throne | 네 핵이 중앙이 아닌 지역 순환에 재배치되고 중계 수정이 전선에 도착한다. |
| FB-03 | [서로 응답하는 불빛](five-banners-story-03-answering-lights.md) | Lights That Answer | 정상 연결·위조 신호 구별을 배우고 네 지역이 독립 운용 중임을 확인한다. |
| FB-04 | [끊어진 다리의 약속](five-banners-story-04-broken-span.md) | The Broken Span | 한 구간의 단절과 안전 복구를 실제 사건으로 검증한다. 누구도 영구 연료로 쓰지 않는다. |
| FB-05 | [여러 손이 지키는 성벽](five-banners-story-05-walls-of-many-hands.md) | Walls Held by Many Hands | 성채 최소 방어와 최종 원정로를 유지한다. 수호전을8인 레이드로 바꾸지 않는다. |
| FB-06 | [갈라진 전선의 지휘관](five-banners-story-06-commander-of-fractures.md) | The Commander of Fractures | 원정 지휘체를 처치하고 최종 지역으로 가는 안전 입구·귀환 신호를 확보한다. |
| FB-07 | [함께 먹는 마지막 저녁](five-banners-story-07-last-shared-supper.md) | The Last Shared Supper | 개인 FB-C1을 기록하고 FC-01을 연다. 기본 동료 영입/편성은 필수가 아니며 연락으로 장면을 전달한다. |

### 에픽8 · 영원의 왕좌

| ID | 개별 시나리오 | en-US 가칭 | 그 이야기에서 달라지는 것 |
| --- | --- | --- | --- |
| FC-01 | [고향 사이에 열린 문](fractured-crown-story-01-gate-between-homes.md) | A Gate Between Homes | FC 안전 전실을 확보하고 기억/현재 신호 구분을 재확인한다. |
| FC-02 | [뿌리와 거울의 길](fractured-crown-story-02-root-and-mirror.md) | The Root and the Mirror | 숲/설원의 배움을 합쳐 중앙 강제 연결만 제거한다. |
| FC-03 | [이름을 태우는 용광로](fractured-crown-story-03-forge-of-names.md) | The Furnace of Names | 화산/묘지의 해결을 결합해 생명/기억 소모 없이 다음 구간을 연다. |
| FC-04 | [끝나지 않는 왕의 뜰](fractured-crown-story-04-court-that-cannot-end.md) | The Court That Cannot End | 왕의 부활 약속의 한계를 확인하고 최종 안전 전실로 진입한다. |
| FC-05 | [새벽 전의 서약](fractured-crown-story-05-oath-before-dawn.md) | The Oath Before Dawn | 최종 전투 전 안전 정비·Lv80 전직 안내와 재도전 동선을 확보한다. 레벨을 이벤트 보상으로 강제 설정하지 않는다. |
| FC-06 | [영원의 왕](fractured-crown-story-06-eternal-king.md) | The Eternal King | 왕의 독점·영혼 징수를 끝내고 리라의 안식을 확정한다. FC-07 후일담으로 이어진다. |
| FC-07 | [우리가 지킬 세계](fractured-crown-story-07-world-we-keep.md) | The World We Keep | 세 결말 중 개인 후일담을 확정한다. 필수 성능/최강 장비/레이드 자격은 동등하며 중앙 희생 체계를 되살리지 않는다. |

## 후반을 잇는 계약

AS는 추가 핵 대신 공동 제어 규칙을 찾고 이리아가 자기 독점권을 내려놓는다. DC는 병원·주거지·성문을 지키면서 루칸의 직접 연결 전 책임을 밝힌다. FB는 네 핵을 지역에 따로 인계하고 중계 수정을 호송하며 실패/단절을 견딜 협력을 증명한다. FC는 앞선 해결법을 적용하고 왕의 제안을 거절해 독점 권한을 없앤다. Lyra는 안전 전환 뒤 해방돼 자기 인사를 끝내며 세 결말은 성능/자격이 동등하다.

본편의 핵심 진실·필수 지원은 숨은 퀘스트/선택 보스·구매·동료 영입/편성으로 잠그지 않는다. 일반1~4인/솔로 완결·4인AI0을 유지한다. 새 스토리에서 일어나는 비살상 항복·장치 정지·포탈 적 처치·기억 해제는 별개 승리로 설계한다. 최종전 전 Lv80 안전 전직 안내 위치는 FC-05 제안이며 실제 주동선 XP와 시험은 후속이다.

새 숨은 퀘스트는 에픽마다 기록1/선택보스1의2개, 총8개 초안이다. 기존4개 후보는 각Q1로 흡수했다. 앞의 본편32행 보상·기존 스토리ID·TD 운영/자산 원본·게임 소스·VERSION·게시/릴리스는 이번 설계 작업에서 변경하지 않는다. 제작/저장/정식 영어 원고·실기기/재미 수용은 TLT-065~070 및 연결 담당의 후속이다.
