# Deepwood 5에픽 반영 시나리오 · 0.41.0

2026-10-31 · TLT-001/016/050/061/072 · 기획/시험 구현

정본은 `DeepwoodContent`·`DeepwoodAdventure`·`DeepwoodQuestCatalog`의 영어 원문이다. 본편7스토리/기존ID·단계ID·좌표·필수/선택 보스·승인1173 XP/2290 Gold를 유지한다. 기존 저장의 봉인핵 명칭 키는 호환을 위해 남기고 플레이어에게는 구조/포탈/북쪽 추적 사건으로 보여 준다. 선택 퀘스트4개와 그 보상은 유지한다.

합류: **DW-02 구조/귀환로 완료 → DW-03:report의 account/missing 보고 완료 → Selene 무료 동료 해금**. 첫 보고 응답만으로는 해금하지 않는다. 야영지에서 F/패드X/터치로 Invite Selene 또는 Ask Selene to rest를 선택한다. 해금은 개인 기록에서 파생하며 기존 보고 완료 저장도 자동 인정한다. 신규 XP/Gold·숨은 퀘스트·유료 조건은 없다.

동행: 플레이어1/2/3/4명에 파티 AI최대2/2/1/1. 현재 구현은 소유자별Selene1명이며 선택자 중 UserId 순으로 전체 상한을 적용한다. 3/4인 대표 동료 선택 전용UI는 후속이다. 해금·동행 선택은 저장하고 실제 모델/쿨다운은 서버 세션 상태다.

지원 시험값:12초 공유 쿨다운,18studs/시야 내 소유자만 지원. 현재 기절 해제 우선 → HP65% 미만에서 최대HP12% 회복 → 가까운 적이 있을 때 최대HP10%/3초 보호막. 기존 성기사 보호막과 큰 잔량 우선이며 기존 만료도 보존한다. 부활/모든 저주 면역·다른 보스 기믹 해제는 제공하지 않는다. 최종 수치/밸런스는 미수용이다.

시각: TD `nun` 원본 몸/양팔 메시를 재사용한 고정 모델 이동 시험이다. 경로 찾기로 추종하고 위험 근접 시 멈춘다.100studs 이상 벌어지면 기다리며 벽을 통과해 순간 이동하지 않는다. 정식 보행/시전 애니메이션·전기기 수용은 후속이다. 포탈은 TD ForestKit 원본이며 DW-07:stabilize 완료자의 에너지에만 로컬 숨김을 적용해 미완료자의 공유 포탈을 삭제하지 않는다.

## DW-01 · The Missing Supply Convoy

보급품과 수레 흔적을 조사하고 Eryn의 안내를 따라 사라진 보급대를 찾는다.

완료 보상: **140 XP / 150 Gold**. 보상 정본 불변.

| 저장 목표ID | 영어 목표 | 진행 방식 |
| --- | --- | --- |
| `trail_guards` | Clear the trail ambush | battle |
| `supplies` | Find the convoy supplies | investigate |
| `supply_guards` | Secure the supply trail | battle |
| `tracks` | Follow the convoy trail | trail |
| `trail_exit` | Reach the clearing approach | travel |

목표 대사/단서와 단계:

**supplies**

- `manifest` — Read the convoy packing list: The convoy was carrying food and medicine for the village. Let us bring the supplies back.
- `bindings` — Find the loose travel ropes: Someone untied these ropes and escaped. Look for the survivors by the clearing.
- `resin` — Find the convoy wheel marks: The wheel marks lead to a broken cart. Eryn has marked the way!

**tracks**

- `drag_marks` — Follow the broken branches: The convoy came this way. Keep following the trail.
- `heavy_prints` — Find the large footprints: An ogre passed here. Watch for its big swings!
- `scout_sign` — Find Eryn's trail mark: Eryn: This way! I can hear people calling from the clearing.

**trail_exit**

- `approach` — Reach the overlook above the clearing: Smoke rises from a broken cart. Someone below is calling for help.


## DW-02 · Friends to the Rescue

Selene와 함께 부상자/생존자를 돕고 안전한 피난처와 전초기지로 이어지는 길을 확보한다.

완료 보상: **163 XP / 240 Gold**. 보상 정본 불변.

| 저장 목표ID | 영어 목표 | 진행 방식 |
| --- | --- | --- |
| `cart_guards` | Secure the broken cart | battle |
| `survivors` | Help the convoy survivors | escort |
| `escape_guards` | Clear the evacuation route | battle |
| `testimony` | Find the route to the safe camp | investigate |
| `clearing_exit` | Reach the outpost road | trail |

목표 대사/단서와 단계:

**survivors**

- `shelter` — Guide the survivors behind the wall: Selene: I will care for the wounded. Let us get everyone to the shelter.
- `crossing` — Lead everyone around the cart: Survivor: Thank you for coming! Some of our friends are still in the ruins.
- `safety` — Reach the lantern shelter: Everyone is safe at the shelter! Clear the road so they can reach camp.

**testimony**

- `crest` — Find the convoy captain's badge: This is the convoy captain's badge. The survivors saw the captain taken toward the ruins.
- `ritual` — Find the raiders' portal sign: A purple portal sign marks the raiders' route. Eryn will help us follow it.
- `witness` — Ask for the safe camp route: Selene: Follow the lanterns to the elder tree camp. I will meet you there with our friends.

**clearing_exit**

- `road` — Follow the safe-route lanterns: The lanterns show the safe route home.
- `outpost` — Reach the elder tree camp road: The camp is ahead. Tell Selene that everyone is safe!


## DW-03 · New Friends at Camp

주민이 야영지에 도착했음을 Selene에게 보고하고 무료 동료 해금한다. 동행은 선택이며 Eryn과 다음 구조를 계획한다.

완료 보상: **62 XP / 100 Gold**. 보상 정본 불변.

| 저장 목표ID | 영어 목표 | 진행 방식 |
| --- | --- | --- |
| `report` | Bring the rescue news to Selene | dialogue |
| `erin` | Meet Eryn at the camp | dialogue |
| `watchtower_order` | Plan the next rescue with Eryn | investigate |

목표 대사/단서와 단계:

**report**

- `account` — Tell Selene the rescue news: Selene: Everyone made it to camp! You helped us bring them home.
  - `survivors` — Help everyone settle in: Selene: Warm beds and medicine are ready. Everyone can rest now!
  - `road` — Check the safe road: Selene: The road is safe. The next group can reach us too!
- `missing` — Welcome Selene as a friend: Selene: I would like to help on your journey. You can invite me at this camp whenever you are ready. Selene is now available as a free companion.

**erin**

- `trust` — Meet Eryn at camp: Eryn: You brought our friends home! Let us find the rest of the convoy together.
  - `truth` — Let us find the missing workers: Eryn: Together, we will bring them home!
  - `people` — Let us stop the monster portal: Eryn: Yes! Our friends will have a safe forest again.
- `signal` — Plan the watchtower rescue: Eryn: The raiders are building a monster portal. We can stop their devices and free our friends.
- `agreement` — Make a rescue plan together: Eryn: We will bring our friends home and stop that portal!

**watchtower_order**

- `map` — Find the watchtower on the map: Eryn marks a safe route to the watchtower.
- `ward` — Prepare for the rescue: Eryn: Watch for the purple portal devices. Stop them to open the cage.
- `departure` — Set out with your friends: The rescue plan is ready. Follow the lanterns toward the watchtower!


## DW-04 · The Watchtower Rescue

포탈 장치2개를 끄고 숲의 친구를 구한다. 경로 표식을 확인해 실종 노동자들이 있는 폐허를 찾는다.

완료 보상: **200 XP / 320 Gold**. 보상 정본 불변.

| 저장 목표ID | 영어 목표 | 진행 방식 |
| --- | --- | --- |
| `courtyard` | Clear the watchtower courtyard | battle |
| `west_link` | Stop the western portal device | battle |
| `east_link` | Stop the eastern portal device | battle |
| `spirit` | Free the trapped forest friend | escort |
| `link_record` | Find the raiders' route map | sequence |
| `shortcut` | Open the outpost shortcut | mechanism |

목표 대사/단서와 단계:

**west_link** — One device is off! Stop the other one to open the cage.

**east_link** — Both devices are off. Our friend can go free!

**spirit**

- `cage` — Open the forest friend's cage: The portal devices are off. The cage can open!
- `spring` — Open the safe return path: The path to the forest spring is open. Our friend can head home.
- `release` — Guide the forest friend home: The forest friend is free and follows the lanterns toward camp.

**link_record**

- `leaf` — Read the raiders' route map: The raiders marked the occupied ruins. The missing workers must be there.
- `rain` — Find the prison camp mark: Eryn: More friends need our help. Let us take the safe route to the ruins.
- `root` — Mark the safe ruins approach: The route is marked. Let us bring the convoy workers home!

**shortcut**

- `counterweight` — Open the return gate: The gate is open. Our rescued friends have a shorter way home.
- `lantern` — Light the return-route lantern: The way back to camp is bright again!


## DW-05 · Bring the Workers Home

노동자를 구조하고 신호 장치와 Orc Warlord를 물리친다. 명령서로 King Shaman의 제단을 알아낸다.

완료 보상: **247 XP / 450 Gold**. 보상 정본 불변.

| 저장 목표ID | 영어 목표 | 진행 방식 |
| --- | --- | --- |
| `ruin_guards` | Clear the prison approach | battle |
| `prison_guards` | Secure the prisoner cages | battle |
| `prisoners` | Guide the convoy workers to safety | escort |
| `first_ogre` | Defeat the ogre at the barracks | battle |
| `barracks` | Stop the barracks signal device | battle |
| `warlord` | Defeat the Orc Warlord | battle |
| `transfer` | Find King Shaman's orders | investigate |

목표 대사/단서와 단계:

**prisoners**

- `cage` — Guide the workers out of the cages: Worker: The captain is still ahead. Thank you for helping us!
- `cover` — Guide everyone behind cover: The workers wait safely behind the wall while the patrol passes.
- `refuge` — Reach the scout shelter: Everyone reaches the shelter. Stop the signal device, then face the Warlord!

**barracks** — The raiders can no longer call for help. The way to the Warlord is open.

**transfer**

- `names` — Check the convoy worker list: The list helps us check who is safely home and who still needs help.
- `orders` — Read King Shaman's orders: King Shaman ordered the convoy workers taken to the Black Root Altar.
- `route` — Find the safe altar route: The map passes a forest village. The families there may know a safe way through.


## DW-06 · A Safe Path for Everyone

고블린 가족들도 돕고 포탈 장치3개와 길 표식을 정리해 모두에게 안전한 귀환로를 연다.

완료 보상: **227 XP / 380 Gold**. 보상 정본 불변.

| 저장 목표ID | 영어 목표 | 진행 방식 |
| --- | --- | --- |
| `refugees` | Help the families by the forest path | dialogue |
| `root_west` | Disable the western root device | battle |
| `root_east` | Disable the eastern root device | battle |
| `root_depth` | Disable the deep root device | battle |
| `ancient_network` | Light the safe route markers | sequence |
| `altar_path` | Follow the safe route to the altar | trail |

목표 대사/단서와 단계:

**refugees**

- `listen` — Hear the village families: Villager: We need a safe path too. Can you help us stop those portal devices?
  - `shelter` — Offer a safe place at camp: Villager: Thank you! We will show you where the portal devices are.
  - `testimony` — Ask how to help the village: Villager: Stop the three portal devices and light the safe-route signs.
- `erin_response` — Plan the rescue with Eryn: Eryn: Of course. Everyone deserves a safe way home!
- `map` — Find the three portal devices: The families mark the devices on your map. We can clear the path together.

**ancient_network**

- `shelter` — Light the SHELTER marker: A shelter sign lights the way for the families.
- `water` — Light the WATER marker: The water sign points toward the safe stream crossing.
- `roots` — Light the ROOTS marker: The roots sign marks the bend in the path.
- `star` — Light the STAR marker: All four signs are lit! The families can find their way home.

**altar_path**

- `safe_root` — Follow the quiet forest path: The portal devices are off. The path is safe again.
- `overlook` — Reach the altar overlook: The monster portal is ahead. Two outer devices protect King Shaman.
- `approach` — Reach the sheltered altar path: We can rescue the remaining captives here. Their help is welcome, but you can win either way.


## DW-07 · The Forest Is Safe Again

King Shaman을 격파하고 Frozen Vale행 왕관의 심장 운반 명령서를 발견한다. 포탈을 닫고 보급품을 회수한 뒤 야영지에서 구조 성공을 기뻐한다.

완료 보상: **134 XP / 650 Gold**. 보상 정본 불변.

| 저장 목표ID | 영어 목표 | 진행 방식 |
| --- | --- | --- |
| `corridor` | Clear the root corridor | battle |
| `rescue_captives` | Free the altar captives | escort · 선택 구조 |
| `outer_west` | Disable the western corruption device | battle |
| `outer_east` | Disable the eastern corruption device | battle |
| `king_shaman` | Defeat King Shaman | battle |
| `core_record` | Find the northbound delivery orders | investigate |
| `stabilize` | Shut down the monster portal | sequence |
| `separate` | Collect the orders and recovered supplies | mechanism |
| `restoration` | Celebrate the rescue with Eryn | choice |

목표 대사/단서와 단계:

**rescue_captives**

- `cage` — Guide the captives out: The captives are free! They open a path for a trapped ogre too.
- `cover` — Guide everyone behind cover: The friendly ogre waits for a chance to help you.
- `safety` — Reach the safe return path: Everyone is safe! The freed ogre will help during the final battle.

**core_record**

- `purpose` — Find the delivery label: The label says Crownheart. The stolen crystal was carried through this camp!
- `cost` — Read the northbound orders: Orders: Take the Crownheart north through Frozen Vale.
- `replacement` — Share the clue with Eryn: Eryn: We know where to look next! First, let us close this monster portal.

**stabilize**

- `spring` — Turn off the SPRING switch: The first portal switch is off.
- `roots` — Turn off the ROOTS switch: The second portal switch is off. The portal is shrinking!
- `shelter` — Turn off the SHELTER switch: Only one switch left. We can do it!
- `return` — Turn off the RETURN switch: The monster portal closes. The forest is safe again!

**separate**

- `clamp` — Open the supply crate: The convoy's missing supplies are inside.
- `isolate` — Collect the food and medicine: The supplies can go back to the village.
- `secure` — Take the delivery orders: You have the northern route. Return to Eryn and celebrate the rescue!

**restoration** — Eryn: Our friends and supplies are home! Shall we help the forest camp or deliver supplies to the village first? Both groups will get help. Then we can follow the Crownheart trail to Frozen Vale!
