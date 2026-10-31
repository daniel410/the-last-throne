# 다섯 에픽 NPC 캐스트·서사/배치 리뷰

2026-10-31 · TLT-001/002/016/031/057/061/065/072/084 · 원형 적용 / 후반 맵·최종 미술 수용 대기

사용자 요구는 로비 대장간·상점과 다섯 에픽 각 장소에 필요한 NPC를 검토하고, **얼굴은 둥글고 비블록형 / 몸통·팔다리·손·신발은 블록형**인 컨셉을 생성해 게임에 적용하는 것이다. [승인된 본편](five-epic-adventure-story-2026-10-30.md)을 기준으로 구조·우정·용기·회복을 전달한다. 기존8에픽/심오한 서사는 채택하지 않는다. 새 인물 이름·세부 역할은 이번 제작 제안이며 Selene/Eryn/Brann은 기존 정체성을 이어간다.

[30명/6보드 갤러리](../../assets/concepts/2026-10-31-npc-cast-v1/index.html) · [정본 캐릭터 데이터](../../assets/npcs/cast-v1/catalog.json) · [장소별 출연 계획](../../assets/npcs/cast-v1/placement-plan.json) · [사례 조사](../research/2026-10-31-npc-cast-and-services.md)

| 지역 | 필요한 인물과 플레이 경험 | 리뷰 결과/적용 |
| --- | --- | --- |
| Dawnspire | Aldric 대장장이, Mira 무기 상인, Rowan 교관, Tessa 원정 안내, Oren 창고지기, Selene, Nia 주민 아이 | 떠날 준비와 귀환의 정서적 기준점. 대장간 거래·별도 상인 Armory·훈련/원정·창고 입력은 기존 서버 서비스를 사용. Selene/Nia는 짧은 대화. 귀환 축제의 상태별 대사는 아직 후속 |
| Deepwood | Eryn 정찰대장, Liora 보급 담당, Tobin 구조 대상, Pip 고블린 피난민, Fen 약초사. Selene 재등장 | 구할 사람이 실제 보이고 구한 뒤 야영지 친구가 됨. 기존 side giver/escort 별칭에 공통 모델 적용. 퀘스트ID·보상·무료 동행 해금·AI슬롯 계약 유지 |
| Frozen Vale | Freya 길잡이, Haldor 피난처 담당, Nessa 의무 담당, Ivo 운반자, Ylva 수호수 돌봄 | 눈길→쉼터→수호수 진정→길 재개통을 인물/소품으로 구분. 모델 라이브러리는 구현, 해당 맵과 상태별 구조 장면은 미구현 |
| Ember Caldera | Brann, Dagna 냉각장치 기술자, Orik 광부, Ketta 공구 담당, Suri 전령 | 구조→공동 수리→다시 움직이는 작업장으로 협력의 결과를 표현. 모델 라이브러리와 배치 계약 구현, 지역 플레이 맵은 후속 |
| Gloamwood (가칭) | Maeve 정찰대장, Finn 두려움을 이기는 정찰병, Tali 구조 대상, Wispkeeper 숲 친구 | 공포의 잔혹성보다 작은 용기를 보여줌. 랜턴과 잘린 밧줄로 역할 구분. 스토리 안정ID가 미정이라 의미 기반 장소 앵커만 제안 |
| Haunted Graveyard | Lumi 친근한 유령, Garrick 묘지기, Elowen 기록관, Rook 연합 정찰병. Eryn/Brann/Maeve/Selene 재등장 | 도움받은 친구가 최종 길을 열어 주는 회수. 적 Veyr/보스 제작은 이 우호 NPC 범위와 별개. 기존HG ID는 번호가 바뀌어도 보존 |

## 실제 구현과 제작 계약

`NPCCatalog`는 JSON에서 생성한다. 모든 영문 이름/역할/인사에 안정 문자열 키가 있으며 이미지 글자를 추출하지 않는다. 생성 PNG·원본 프롬프트·SHA256을 보존했다. 이미지 생성은 built-in image_gen을 사용했다.

`NPCVisual`은 native Part/Sphere SpecialMesh로 둥근 얼굴·눈동자·눈썹·코·입·머리카락과 직육면체 몸/팔다리를 조립한다. 소품과 색·종족·체형이 역할을 구분한다. 이미지에서 자동 생성한 메시가 아니며 헤어/천/표정의 완성형 아트와 같다고 보고하지 않는다. 서버 저장소 `NPCCastV1`에는30명의 원형을 만들고 실제 월드에는 사용 중인 인물만 생성한다. static NPC에는 Humanoid/공격·보상·충돌·터치·쿼리가 없다. Selene 동행은 기존 서버 지원/이동 서비스를 통해서만 동작한다.

로비 대장간의 기존 단순 상인 몸체를 Aldric으로 교체하고6명 주민을 추가한다. Mira는 기존 ArmoryState/서버 구매·판매 흐름으로 진입한다. 가격·상품·재화·저장은 새로 만들지 않는다. Rowan/Tessa/Oren은 기존 시설과 연결된 식별자를 제공한다. 가까운 NPC가 입력을 빼앗지 않도록 새 prompt는 Mira/Selene/Nia에만 두고 시설 prompt를 중복 생성하지 않는다. Selene/Nia의 원격 대화는 서버의 살아 있는 영웅·거리·Lobby·이동 잠금 판정을 통과해야 열린다.

기존 TD nun 모델은 `assets/shared/td-selene`에 보존한다. 새 외형 지시는 이번 요청을 우선해 Selene도 공통 블록 몸/둥근 얼굴과 ivory/lavender/gold·Priest 소품을 사용한다. 실제 TD 메시 재사용을 주장하지 않고 `TDDesignLineage`로 원형 계보를 기록한다. 이전 TD 외형 전용 검증은 새 형태 검증으로 바꾸되 무료 영입·거리·중복 회복·재영입 쿨다운·인원/영웅 변경 검증은 유지한다.

후반4개 에픽 모델은 서버 저장소와 별도 로컬 미술 쇼케이스에 존재한다. 실제 지역 맵이 없으므로 전체 맵 배치를 완료했다고 보고하지 않는다. `NPCCast.region(parent, region, anchors)`는 실제 CFrame 앵커를 모두 검증한 다음에만 생성한다. placement-plan은 장소별 등장 계약이며 보상/퀘스트/성장 데이터를 변경하지 않는다.

## 수용과 인계

[시험 기록](../evidence/npc-cast-0430/README.md)에 정적·엔진·빌드 결과를 남긴다. 최종 메시/텍스처·표정/생활 모션, 실제 기기 가독성·성능, 게시된 클라이언트 거래/저장·정상 플레이, 후반 지역 배치·귀환 축제는 미완료다. 다음 ART/ENG는 컨셉에 맞춘 최종 메시와 실제 후반 맵 앵커를 만들고 QA는 PC/터치/패드와1~4인에서 검증한다. 상위 티켓은 완료 처리하지 않는다.
