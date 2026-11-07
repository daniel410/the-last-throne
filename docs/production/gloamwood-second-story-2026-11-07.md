# Gloamwood 에픽2 개편 · 연결 시나리오와 구현 인계

2026-11-07 · TLT-001/050/061~065/084 · PLAN/DES · 승인 서사 문서 반영, 런타임 미반영

사용자는 Gloamwood를 Deepwood 다음으로 옮기는 제안에 “변경해줘”라고 지시했다. [본편 정본](five-epic-adventure-story-2026-10-30.md)을 **Deepwood → Gloamwood → Frozen Vale → Ember Caldera → Haunted Graveyard** 순서로 개정한다. Dawnspire의 프롤로그·귀환, 왕관의 심장 회수, Veyr 최종전과 다섯 에픽 완결을 유지한다.

이번 범위는 줄거리·연결 시나리오·영어 변경 원고·계획 문서다. `src/`·보상 JSON·VERSION·맵·자산·실제 저장은 변경하지 않는다. 게임은 여전히 DW → FV → EC → GW → HG 순서다. 아래 영어 문장은 게임 적용을 위한 원고이며 현재 표시 문구라는 뜻이 아니다. [검증 기록](../evidence/gloamwood-second-story-20261107/README.md).

## 지역별 연결과 보존 계약

| 지역 | 서사상 번호 전 → 후 | 진입 동기 | 완료 후 다음 행동 | 유지할 ID |
| --- | --- | --- | --- | --- |
| Deepwood | 1 → 1 | 실종 보급대 구조 | 운반 명령서를 Eryn에게 보고하고 Gloamwood 정찰대 추적 | DW-01~07 |
| Gloamwood | 4 → 2 | 왕관의 심장 운반대를 쫓던 정찰대의 실종 | 정찰대 구조·북쪽 옛길 개방·Frozen Vale행 증언 확보 | GW-01~07 |
| Frozen Vale | 2 → 3 | Tali가 목격한 운반대 추적 | 수호수 진정·눈보라 해제·화산 도시의 가공 목적 확인 | FV-01~07 |
| Ember Caldera | 3 → 4 | 왕관의 심장 가공 저지·광부 구조 | Veyr 침공 계획·왕릉 진입로 확보 후 Haunted Graveyard 출발 | EC-01~07 |
| Haunted Graveyard | 5 → 5 | Veyr의 침공을 막고 왕관의 심장 회수 | 포탈 폐쇄·Dawnspire 귀환 | HG-01~07 |

지역 번호와 저장 ID를 구분한다. 번호가 바뀌어도 ID·목표ID·단계ID를 재명명하지 않는다. 거미 여왕은 독립적인 숲의 괴물이며 Veyr의 부하가 아니다. 기존 수호수 진정/비살상 판정, 솔로 완주와 선택형 동행 계약을 유지한다. Selene 미동행·구매0 상태에서도 모든 필수 목표를 진행할 수 있어야 한다. Selene의 로비 동행/지원권 소비는 최신 계약을 따르며 이번 개편으로 지원을 무료 시작하거나 자동 갱신하지 않는다.

## Gloamwood 일곱 스토리

기존 런타임의 세 보스 구간을 재사용한다. 아래 개편은 보스 제거·추가나 필수/선택 변경의 승인이 아니다.

| ID / 기존 영어 제목 | 사건과 플레이 | 완료 후 보이는 결과 |
| --- | --- | --- |
| GW-01 / Lantern Trail | Maeve에게 정찰대 실종 소식을 듣고, 버려진 수레와 끊어진 표식으로 운반대의 흔적을 확인한다. | 랜턴 길이 열리고 Finn이 있는 곳을 찾는다. |
| GW-02 / A Light in the Webs | 겁내는 Finn과 함께 Tali의 거미줄을 끊는다. Tali는 운반대가 먼저 지나갔음을 증언한다. | Tali가 안전한 피난처 길을 안내한다. |
| GW-03 / Lantern Refuge | Tali를 호위하고 Maeve에게 보고한다. Wispkeeper에게 북쪽 옛길을 묻는다. | 구조된 대원이 피난처에 남고 다음 구조 경로가 표시된다. |
| GW-04 / The Ancient Rootway | Ancient Hollowbark가 막은 뿌리 길을 통과하고 정찰대 랜턴을 다시 켠다. | 피난처와 안쪽 길이 연결된다. |
| GW-05 / Venomcoil Crossing | 지네 사냥터와 Venomcoil King 구간을 통과해 안전 밧줄을 확보한다. | 구조된 대원이 사냥터를 피해 이동할 수 있다. |
| GW-06 / One Brave Step | 여왕 둥지 앞의 마지막 대원을 풀어 준다. Finn은 대원들을 안내하고 플레이어는 추격하는 적을 막는다. | 구조 대상 모두 탈출을 시작하고 여왕에게 가는 길이 열린다. |
| GW-07 / The Queen of the Webs | Widow Queen을 격파하고 북쪽 출구의 거미줄을 끊는다. Tali에게 Frozen Vale행 목격담을 듣는다. | 옛길이 열리고 안개 너머 설산이 보인다. 다음 목표는 Frozen Vale다. |

Deepwood의 밝은 숲·열린 전투와 구분해 안개·거미줄·갈림길·정찰 표식으로 탐색과 기습 대응을 강조한다. 길을 잃은 상태를 오래 유지시키지 않는다. 랜턴/표식은 색만으로 구분하지 않고 형태와 영어 목표를 함께 제공한다. 설산 노출은 후속 맵 연출이며 이번에 구현한 장면은 아니다.

## 영어 연결 원고

키는 기존 `chapter:goal:step`을 사용하며 `quest.brief/outcome`은 기존 데이터 필드다. 아래 원고는 적용 시 해당 인물·상호작용과 함께 바꾼다. 단계 수와 완료 순서는 유지한다.

| 기존 키/필드 | 목표·대사 변경 원고 (en-US) |
| --- | --- |
| DW-07:core_record:cost | **Read the convoy orders** — Orders: Carry the Crownheart through the old road in Gloamwood. |
| DW-07:core_record:replacement | **Share the clue with Eryn** — Eryn: Our scouts followed that convoy into Gloamwood. We have not heard from them. First, let us close this portal! |
| DW-07:separate:secure | **Take the delivery orders** — The orders mark the old road into Gloamwood. Return to Eryn with the news. |
| DW-07 / quest.outcome | The portal is closed and the convoy is home! Follow the Crownheart trail into Gloamwood and find the missing scouts. |
| DW-07:restoration / text | Eryn: Our friends and supplies are home! Shall we help the forest camp or deliver supplies to the village first? Both groups will get help. Then we can follow the Crownheart trail into Gloamwood! |
| GW-01 / quest.brief | Follow the Crownheart convoy trail into Gloamwood and help Maeve find the missing scouts. |
| GW-01:maeve:confirmed | **Meet Maeve at the forest entrance** — Maeve: Our scouts followed the Crownheart convoy along this old road. Now they are trapped in the webs. Follow their lantern marks! |
| GW-01:marks:confirmed | **Read the missing scout trail marks** — Wheel tracks pass a broken cart. Beside them, scout marks point deeper into the webs. Finn is waiting ahead. |
| GW-02:bindings:confirmed | **Cut the web bindings** — Tali: You found me! The Crownheart convoy passed before the spiders caught us. Our other scouts are still deeper in the forest. |
| GW-03:wisp:confirmed | **Ask the Wispkeeper for the northern route** — Wispkeeper: The old road reaches the snowy mountains. Follow the lanterns past the roots, and bring your friends safely through. |
| GW-07 / quest.brief | Defeat the Widow Queen, free the northern exit, and learn where the Crownheart convoy went. |
| GW-07:exit:confirmed | **Cut the web sealing the northern exit** — The old road is open. Beyond the clearing mist, snowy mountains rise above the forest. |
| GW-07:entrance:confirmed | **Ask Tali where the convoy went** — Tali: I saw them carry the Crownheart toward Frozen Vale. Take the northern road. We will keep this path safe for everyone! |
| GW-07 / quest.outcome | Every scout is safe! The northern road is open, and the Crownheart trail leads to Frozen Vale. |
| FV-01 / quest.brief | Follow Tali's lead into Frozen Vale. Find Freya, rescue the stranded travelers, and relight the shelter lanterns. |
| FV-07:reunion / text | **Bring the good news to Ivo** — Ivo: The roads are open! These delivery records say the Crownheart was taken to the great furnace in Ember Caldera. The enemy plans to reshape it there. Our friends can show you the way! |
| FV-07 / quest.outcome | The storm has eased and the villages are reunited! The delivery records lead to the great furnace in Ember Caldera. |
| EC-07:courier:confirmed | **Meet Suri with the enemy delivery orders** — Suri: The enemy turned the Crownheart into a portal key. Veyr will use it at the royal tomb to attack Dawnspire. Brann marked their route. Maeve's scouts are securing the approach. Let us stop him together! |
| EC-07 / quest.outcome | The city is safe and the workshops are running again! Veyr's orders reveal the royal tomb and its approach. Your friends are ready. Set out for Haunted Graveyard! |
| HG-01:rook:confirmed | **Meet Rook at the hidden entrance** — Rook: We followed the route Brann marked. The scouts you rescued in Gloamwood secured the approach. The elves and dwarves are ready. Let us stop Veyr together! |

FV-07의 전직 안내는 해당 시점에 Lv20 이상인지와 전직 여부에 맞춰 별도로 표시한다. 지역 완료 자체를 전직 자격으로 바꾸지 않는다. 전직 조건은 Lv20/40/60/80과 자기 클래스·선택 계열의 순차 진행만 유지한다.

## ENG 후속 범위와 QA 수용

현재 코드는 `CampaignContent.mainChapters`와 `DeepwoodProgress.main`의 연속 순서를 사용한다. 따라서 GW의 숫자만 바꾸면 기존 FV/EC 진행 저장이 검증에 실패할 수 있다. 기존 계정의 완료 지역·활성 원정·부분 목표를 보존하는 이관 계약부터 정한다. 미완료 지역 자동 완료나 이미 받은 XP/Gold·드롭 재지급으로 해결하지 않는다. 로드 실패를 신규 프로필로 덮어쓰지 않는다.

| 구현 범위 | 확인한 의존 코드 / 필요한 수용 |
| --- | --- |
| 순서·이어하기·지도·지역 입장 | `CampaignContent`, `CampaignAccess`, `AdventureRules`, `Difficulty.requiredMain`와 목표별 `minMain`·구역 `requiresMain`을 함께 변경. DW→GW→FV→EC→HG 경계의 입장/복귀/계속 진행 검증. |
| 저장·활성 원정 | `DeepwoodProgress`, `InventoryRules`, `AccountStore`의 검증/로드와 `AdventureRules`의 활동 저널. 구순서의 경계7/14/21/28/35와 FV/EC/GW 부분 진행, 완료 후 재도전, 재접속·저장 불명/재시도·기존 보상 중복 방지를 검증. 이관 전후 목록을 비교하고 실패 시 원본을 보존. |
| 지역 정체성과 보스 | `CampaignWorld`, `LateEpicWorld`, `DeepwoodService`의 숫자 기반 지역 분기. 새 에픽2가 설원 월드로 생성되거나 거미 여왕이 비살상 수호수 판정을 받지 않게 분리. Frozen Vale 진정·Ember 냉각·각 지역 고유 패턴 유지. |
| 성장·드롭·난도 | `Difficulty.entry`, `epicScaling`, `DeepwoodEncounterBalance`, 장비 드롭/반복 보상과 규칙 버전. 초반 GW의 기존 Lv28~34를 그대로 요구하지 않게 설계하고 FV/EC의 후반 배치도 검토. 승인 고정 보상은 별도 수용 없이 재계산하지 않음. 기존 원정의 고정 규칙 호환 검증. |
| 영어 원고·NPC·연출 | 위 키와 기존 목표/단계ID 대응 확인. 원고만 바꾸고 이동 목적지는 이전 지역에 남는 상태를 방지. 실제 목표창·지도·완료 안내와 다음 지역을 함께 확인. |
| 플레이 수용 | 네 클래스 솔로·Selene0·구매0·1~4인/AI1에서 진행. PC/터치/패드 길/공격 예고 가독성, 두 숲의 차이와 다음 목적지 이해도 검증. 이후 버전 예약→빌드→격리 Studio→게시 테스트 클라이언트·실기기 수용을 구분. |

다음 담당은 PLAN/DES의 성장·저장 이관 계약 확정 → ENG의 순서/원고/지역 분기 적용 → QA의 회귀·플레이 검증이다. 본 문서로 TLT-061~065/084를 완료 처리하지 않는다. 이번에는 빌드·릴리스 태그·Roblox 게시를 수행하지 않는다.
