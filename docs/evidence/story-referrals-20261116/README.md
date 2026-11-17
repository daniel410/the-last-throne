# 본편에서 인물을 만나러 가는 이유와 길 안내

2026-11-16 · TLT-061~065 · 빌드 0.112.1 · 소스 `50d29eb8`

GW-01에서 Maeve를 만나면 Finn의 이름을 들었지만 누구인지와 왜 기다리는지 설명을 듣지 못했다. GW-02를 시작하거나 재접속하면 HUD가 목적과 세부 단계 양쪽에 같은 대화 지시를 표시했다. 다른 지역에서도 인물 이름만으로 임무를 시작할 수 있었다.

35개 본편의 출발 원고를 선행 사건과 연결하고, 진입 가능한 임무의 원정 상세에서 첫 목표 위에 표시한다. 17개 대화 목표는 첫 단계의 이동 안내에 인물의 역할과 만날 이유를 싣는다. 다음 대화 단계에 들어가면 해당 단계의 지시를 표시한다. GW에서는 Maeve의 의뢰, 수레에서 갈라지는 두 길, Finn의 등불, Tali가 보는 빛의 순서로 이어진다. Maeve에게 설명을 들은 시점부터 일지에서 Finn의 소개를 다시 읽을 수 있다. [비교 조사](../../research/2026-11-16-story-referrals.md)

## 검증

- 고정 커밋의 `CampaignContent`를 사용해 35장 본편의 저장 전이 418회를 실행하고 마지막 귀환 목표 완료를 확인했다. `campaign-context-review` 1,060개 검사에는 47개 임무의 비문구 데이터 비교, 단계별 대사, Finn 의뢰와 완료·재진입 안내가 포함된다.
- 같은 소스로 `story-rpg-guide` 1,011개, `story-fun` 1,761개, `story-completion` 356개, `expedition-presentation` 24개, `campaign-mode-legacy-replay` 3,723개, `campaign-mode-progress` 4,621개 검사를 통과했다. 마지막 검사는 네 난이도의 캠페인을 순차 완료했다.
- 세 기존 회귀 검사는 이전 커밋 `6c58b82a`와 이번 소스 양쪽에서 같은 위치에 실패했다. `deepwood-quests.spec.lua:36`은 DW-Q1 보상 표시에서 100 Gold를 기대한다. `campaign-reorder.spec.lua:123`과 `campaign-combat-pacing.spec.lua:65`는 테스트 영웅의 임무 시작에서 `StoryLocked`를 받는다.
- 격리된 Studio 편집 세션에서 고정 빌드에 든 변경 모듈 5개의 Source를 커밋과 대조하고 `tests/campaign-context-review-native.luau`를 실행했다. 336개 검사를 통과했다. 17개 대화 지점의 상호작용 전 HUD, 기존 목표 위치, 800×510·726×299·270×510 창의 GW-02 출발 설명과 로비 일지 줄바꿈, 잠긴 임무의 설명 숨김, 에픽 완료 카드의 글자 영역을 검사했다. [엔진 결과](native.log) · [Rojo 빌드와 SHA-256](build.json)

## 다음 담당과 수용

QA는 처음 플레이하는 사람이 GW-01의 수레에서 어느 흔적을 따라갈지, Finn이 왜 남아 있는지, 찾아가서 무엇을 도와야 하는지를 말하고 직접 찾아가는지 관찰한다. 이어서 Frozen Vale에서 피난처행, Ember Caldera에서 Orik의 지도 전달, Haunted Graveyard에서 Lumi와 만나는 구간을 같은 방식으로 확인한다. 게시 클라이언트·실기기·첫 플레이어 수용은 미검증이며 이 빌드는 미게시다.
