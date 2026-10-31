# 에픽1 Deepwood · 스토리2 무너진 수레 공터

2026-10-31 · 0.41.0 시험 구현 · TLT-061/072. [승인5에픽](production/five-epic-adventure-story-2026-10-30.md)에 맞춘 현재 시나리오는 아래와 같다. [전체 구현 계약/인계](production/deepwood-five-epic-scenarios.md)와 [검증](evidence/deepwood/adventure-0410/README.md)을 함께 따른다. 기존ID·좌표·보상을 보존한다.

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


<details>
<summary>이전 시나리오 기록 · 충돌하는 서사는 현재 본문으로 대체</summary>

> 2026-10-29 구현 갱신: 본 문서를 기준으로 **0.30.4 최초 캠페인 원형**에 목표·연결 지형·TD 원본 몬스터·서버 진행을 연결했다. 아래 수용 목록과 세부 제안 전체가 완료된 것은 아니다. [실제 범위·빌드·검증·남은 작업](evidence/deepwood/README.md)을 우선 확인한다. 맵 상대 좌표에는 기존 트레이닝장과 분리하는 런타임 Z -2000 이동을 적용했다.

2026-10-29 수정 · 상태: 이야기/배치 제작 초안, 구현·플레이 검증 전 · 작업 TLT-061

[에픽 전체](epic-01-deepwood-story.md) · [이전: 고블린 숲길](story-01-goblin-trail.md) · [다음: 거목 전초기지](story-03-elder-tree-outpost.md)

## 역할과 이야기

DW-01 완료 후 진입한다. 권장 Lv6~7은 기존 시험값이다. 플레이어는 수레 잔해에 피신한 생존자 두 명을 찾고 고블린의 위협을 해제해 안전한 길을 만든다. 생존자들은 식량은 남겨두고 사람들을 숲 안으로 끌고 갔다고 증언한다. 큰 발자국과 부러진 나무, 멀리 움직이는 거대한 실루엣은 오우거를 예고하지만 접근·추적·전투는 없다. 잔해에 남은 희미한 문양은 아직 뜻을 알 수 없는 단서다. 생존자들은 안전 확보 후 짧은 장면으로 전초기지 방향으로 이동한다.

## 공간과 교전

```text
A 숲길 입구·안전 지점 → B 수레·생존자 확인 → C 엄폐·대피
                              └→ S 선택 물자       ↓
F 전초기지 길 ← E 흔적·증언 ← D 고블린 위협
```

B의 Goblin Lv6 두 마리와 D의 별도 소규모 Goblin 교전을 초안으로 둔다. D의 수·레벨·행동은 네 클래스 솔로와 1~4인 테스트로 정한다. 무리를 한꺼번에 몰아넣지 않고 공격 예고와 안전한 이동 공간을 확보한다. 주민 전투선과 엄폐를 분리하며 시간 제한 호위나 주민 HP 보호를 요구하지 않는다. S는 선택이다. 오우거 첫 필수 교전은 DW-05 막사 접근으로 미룬다.

## 목표·복구

1. 두 생존자의 위치와 대피 방향을 확인한다.
2. 접근과 공터의 고블린 위협을 해제하고 주민을 안전하게 안내한다.
3. 흔적과 증언을 확인하고 전초기지 접근로 F에 도착한다.

주민 안전 확보, 위협 해제, 증언/흔적 조사, F 도착이 필수다. 완료된 대피·조사는 유지하고 전멸 시 미완료 교전과 임시 효과만 초기화한다. 위협 해제 후 끊기면 증언부터 재개한다. 개인 선행과 보상 수령은 별도로 저장한다. 완벽 방어·특정 클래스·동료·선택 물자는 필수가 아니다.

## 보상과 검증

기존 승인 초회 퀘스트XP163 (**163**), Coins **240**, 클래스용 방어구 1개와 반복 퀘스트 XP **40**, Coins **72**는 유지한다. 기존 필수 전투 XP **62**와 처치 Coins **18**은 오우거를 포함한 옛 배치의 예산이다. 새 고블린 배치의 처치 수와 XP/Coins가 정해지지 않았으므로 총 XP 225, 총 Coins 258 및 완료 Lv7은 **이전 가정의 결과이며 변경 후 미검증**이다. 승인 XP를 임의 재조정하거나 차액을 자동 지급하지 않는다. TLT-061/065에서 새 필수 처치 구성과 보상 정본을 검토하고 성장 시뮬레이션 및 사용자 수용을 거쳐 확정한다.

TD Goblin과 수레·돌길·바위 원본을 후보로 조사한다. 오우거 실루엣은 원본 권한과 성능 확인 후 환경 연출로 제작한다. 네 클래스 솔로·동료 0, 1~4인, 위협 분리, 대피/재접속, 보상 중복 및 실제 플레이 난도를 검증해야 한다. 게임에 표시할 목표·대사는 별도 en-US 원문으로 작성한다.

</details>
