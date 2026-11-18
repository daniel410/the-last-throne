# TLT-064 · HG-05 묘역 접근 결함 수정

2026-11-18 UTC. MAP/ART/환경 모델링/리서치 역할 순차 수행. **별도 후보 장면 수정, 본편 미반영·G5 미완료.**

HG-05 원고 `CampaignStoryText['HG-05']`의 서쪽/동쪽 방어 연결 해제와 왕릉 접근, `CampaignExpansionContent['HG-05']`의 귀환 통로 유지에 연결한다. 이전 [묘역 후보](../hg05-terraces-20261118/README.md)의 실제 보행 부족을 이번 범위로 삼았다. 기존 TD/장치 좌표/스토리/적/보상/저장 변경 없음.

## 제작표·변경

| epic/story | 사건과 표현 | 자산/배치 | 상태·플레이 목적 |
| --- | --- | --- | --- |
| HauntedGraveyard/HG-05 | 왕릉 뒤편 묘역의 높이와 사람이 사용하는 접근면 | 기존 EpicEnvironmentKit HauntedGraveyard trim/Slate 파생, 16×48×18.05stud WedgePart 3개, x150/270/390, 중심 y197.025,z-17468, Y회전180도 | 장치 파괴/복원을 미리 표현하지 않으며 6stud 석축 턱을 돌아 상면 왕복. 신규 외부 자산 없음 |

`access.luau`는 후보 루트에 고체 경사면3파트를 추가한다. 약20.6도 경사. 기반부는 기존 지면 아래로 들어가며 상단은 후보 상면206.05와 일치한다. 원본/생산 생성기는 보존한다. 동일3개 반복을 해소한 최종 미술이라고 판단하지 않는다.

## 재현·결과

기존0.113.2 QA 파일을 `/tmp/tlt-hg05-access-review.rbxlx`로 복사한 PlaceId0 자체 Studio `d7c46cb7-6c34-4609-bfed-317a5b2c36e6`. 모든 BaseScript 비활성화, 이전 증거의 candidate ModuleScript 설치 후 setup.luau 실행. 최신0.113.7 전체 소스 검증이 아니다. 새 게임 빌드는 하지 않았다.

1. 경사로 없이 walk.luau의 x목록을 `{390}`으로 실행. RunService Run의 실제 R15 물리, WalkSpeed16, 자동점프 및 Jumping 비활성화. 상행은 z-17479.39의 첫 턱에서 정지, 목적지까지18.61stud 남음. 하행만 통과. baseline.json에 실패 trace 보존.
2. Stop 없이 같은 생성 장면에서 access.luau 실행 후 walk.luau 실행. 3곳 상·하행6조건 모두 도착, 점프0, 정지/오류 없음, 약3.42초. 각 rig는 독립 collision group으로 서로 비충돌. 종점 판정은 수평거리3stud 미만 및 목표 높이+3과4stud 이내이며 trace에 실제 높이 보존. `complete=true`는 실행 종료를 뜻하므로 개별 arrived도 확인한다.
3. 기존 navigation.luau 엔진 검사 재실행: HG7장105목표4749표본6연결, points를 worldPoints로 바꾼 Easy배치119목표5192표본6연결. 차단/지면누락/서버보정 호출/안내실패/작은단차 모두0. 보간 표본 검사이며 실제 전체경로 보행이 아니다.
4. EpicWorldArt 대상 GetPartsInPart 고체 교차검사에서 새 경사면3개와 후보 외부 소품 겹침0. 후보 석축과의 의도적 교차는 제외한다.

before.jpg/after.jpg: 같은 Run 장면, 카메라(429,219,-17428)→(390,198,-17494), 동일 조명. 실제 플레이 카메라가 아닌 낮은 시점 편집 카메라다. 추가 전후 이미지는 LFS. 사용자 Studio는 변경하지 않았다.

## 연구 재확인·판정·다음 담당

[직전 세 게임 연구](../../research/2026-11-18-hg05-burial-terraces.md)의 공식 본문을 이번 실행에서 다시 열었다. Diablo IV 2022 환경 제작의 역사/재료/건축 구성, WoW Retail Dragonflight 알파 Azure Span의 시각적 고저차, Lost Ark 글로벌 Voldis 2024 제작기의 건축 높이와 주제 연결을 유지한다. 현행 패치나 직접 플레이 자료가 아니다. 이번 적용은 TLT의 사용 가능한 묘역 접근면이며 새 게임 규칙 도입 없음. 단순 결함 수정이라 별도 신규 사례 증량은 하지 않았다.

실제 정상 Easy 세션/장치 상호작용/귀환 진행, 회피·전투·측면 낙하, 카메라 충돌, 게시 클라이언트, 기기/다인/스트리밍/성능/사용자 미술 수용은 미검증. Run R15 검사를 Play 세션 수용으로 간주하지 않는다. MAP/ART는 3반복 석축의 비대칭 형상과 실제 장치의 의미를 조정하고 ENG/QA는 정상 전투 세션을 검증한 뒤 생산 통합한다. 접근 결함 수정은 통과했으나 후보 전체 채택과 TLT-064 완료는 보류한다. VERSION/게시/태그 변경 없음.
