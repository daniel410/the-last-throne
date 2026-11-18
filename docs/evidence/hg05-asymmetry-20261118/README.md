# TLT-064 · HG-05 비대칭 묘역 후보

2026-11-18 UTC. 맵 구현·환경 아트·환경 모델링·리서치 역할 순차 수행. 본편 미반영, G5 미완료.

## 변경·제작표

HG-05 원고의 서/동 방어 연결 해제와 왕릉 접근·귀환로 유지에 연결한다. 직전 3동일 석축 후보에서 접근 경사로와 상면206.05stud·중앙 기둥 조립체를 보존했다. 서쪽 추모 묘역의 깊이를 늘리고 동쪽 묘역을 좁혀 중앙 방어 장치의 공간 위계를 드러내는 실험이다. 스토리 장치 자체가 이 후보 기둥과 같은 좌표/기능인지는 정상 세션에서 미확인이다.

| 구역 | 1/2/3단 폭 | 깊이 | X 이동 | 목적 |
| --- | --- | --- | --- | --- |
| 서쪽 x150 | 104/86/68 | 94/80/68 | 0/4/6 | 깊은 추모 묘역 |
| 중앙 x270 | 104/92/80 | 80/68/56 | 0/0/0 | 기존 방어 기둥 기반 유지 |
| 동쪽 x390 | 90/74/58 | 70/60/48 | 0/-4/-6 | 좁은 묘역, 묘비 행 안쪽 재배치 |

단위 stud. 각 단의 접근 방향 끝선을 유지하고 뒤쪽만 깊이 변경. 석재 덮개는 각 단보다0.4stud 크다. 신규 파트0, 총93 BasePart. 기존 EpicEnvironmentKit HauntedGraveyard 팔레트와 EpicArchitecture.grave 파생을 유지한다. 외부 자산/Blender 작업 없음. TD·서버 권위·보상·저장·진행·생산 소스 변경 없음.

## 재현·검증

- 기존0.113.2 QA 사본을 /tmp/tlt-hg05-asymmetry-review.rbxlx로 복사. 자체 Studio 2e067bd6-0a11-405d-92c8-8dfd97e2d98e, PlaceId0. 최신0.113.8 전체 소스 검증은 아니다.
- 모든 BaseScript 비활성화 → 이전 hg05-terraces 증거의 RoyalBurialTerraces.candidate.luau를 RoyalBurialTerracesCandidate ModuleScript로 World 아래 설치 → setup.luau → hg05-access의 access.luau → 이번 reshape.luau 순서. 마지막 walk 실행까지 Stop하지 않는다.
- geometry.json: 기존 후보93파트 유지. 석축/덮개18개의 바닥 투영 외접원 예약 침범0, EpicWorldArt 고체와 실제 GetPartsInPart 교차0. 실제 장치 진행 검증이 아니다.
- 이전 navigation.luau 실행 및 .points를 .worldPoints로 치환해 각각 실행. navigation.json: HG7장105목표4749표본6연결, navigation-easy.json:119목표5192표본6연결. 차단/바닥누락/보정/안내실패/작은단차 모두0. 보간 검사이며 전 경로 실제 보행이 아니다.
- 이전 walk.luau 그대로 실행. Run R15, WalkSpeed16, 점프 금지, x150/270/390 접근 왕복6조건 모두 도착·점프0·정지0, 3.433~3.438초. trace는 walk.json. sampleCount0은 사용하지 않는 배열이며 실제 trace/arrived로 판정했다.
- before.jpg/after.jpg: 같은 Edit 장면 카메라(520,370,-17270)→(270,205,-17520), 같은 조명. 접근 경사로가 있는 직전 후보와 비교했다. 실제 플레이 카메라가 아니다.

## 연구·판정·다음 담당

[기존 세 게임 공식 연구](../../research/2026-11-18-hg05-burial-terraces.md)의 Diablo IV 2022 환경 아트·WoW Retail Dragonflight 2022 알파 Azure Span·Lost Ark 글로벌 2024 Voldis 공식 본문을 재확인했다. 역사/재료에 맞는 건축 구성, 고저차 위계, 주제와 건축 형상의 연결을 참고했다. 현행 라이브 패치 조사/직접 플레이가 아니다. 이번 해석은 기존 좁은 예약 공간 내 묘역의 폭·깊이 차별화다. Roblox와 대형 RPG의 규모/기기 비용 차이 때문에 외곽 증량은 보류한다. 기존 제품 결정 충돌 없음.

비교 화면에서 동일 크기 반복은 줄었으나 3단 직각 석축과 경사로의 반복 문법은 남는다. 최고 품질/최종 미술 수용으로 판단하지 않는다. 다음 MAP/ART는 정상 Easy 장치와 기반부 의미를 먼저 확인하고, ENG/QA는 정상 조작·귀환·회피·측면 낙하·실제 카메라를 검증한 뒤 생산 통합 여부를 판단한다. 게시 클라이언트/실기기/다인/스트리밍/성능/사용자 수용은 미검증. 이번에는 후보 소스·측정·비교 증거만 커밋하며 VERSION·빌드·게시·태그는 생성하지 않았다.
