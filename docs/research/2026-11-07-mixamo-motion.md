# Mixamo 움직임 개선 조사

2026-11-07 확인 · TLT-032/033/057/084/087 · [실행 계획](../production/mixamo-motion-improvement-2026-11-07.md)

## 서비스와 가져오기

Adobe 공식 FAQ는 Adobe ID로 무료 이용 가능하고 게임을 포함한 상업 프로젝트에 캐릭터/애니메이션을 사용할 수 있다고 설명한다. 자동 리깅/라이브러리는 이족 인간형 대상이며 비율이 크게 변형되거나 큰 소품·추가 팔다리가 있으면 실패할 수 있다. 마지막 캐릭터만 보관하므로 다운로드 원본을 로컬에서 보존해야 한다. 이 허용이 TD/외부 원본 모델의 업로드 권한까지 대신하지는 않는다. [Adobe FAQ](https://helpx.adobe.com/creative-cloud/faq/mixamo-faq.html)

Adobe의 업로드 절차는 FBX/OBJ/ZIP과 리깅된 FBX 매핑을 안내한다. Roblox 공식 예제는 커스텀 리그와 외부 애니메이션 가져오기 경로를 설명한다. 이를 근거로 Mixamo→Blender→현재 리그 리타깃→게임 내 검증을 제안한다. 현재 R6/R15·스킨 리그에 대한 자동 호환은 표본으로 확인해야 한다. [Adobe 절차](https://helpx.adobe.com/creative-cloud/help/mixamo-rigging-animation.html), [Roblox 커스텀 캐릭터](https://create.roblox.com/docs/resources/beyond-the-dark/custom-characters)

## 디아블로 우선 비교와 적용

비교 기준은 Diablo IV의 **2021년 12월 출시 전 개발 설명**이다. 현행 시즌/패치의 관찰이나 수치 검증으로 해석하지 않는다. Blizzard는 무기 동작과 공격 영역, 공격 방향과 피격 반응을 연결하는 개발 원리를 설명한다. [공식 개발 설명](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021)

The Last Throne 적용안은 기존 서버 타격 시각에 리타깃 클립의 접촉 포즈를 맞추고, 준비·타격·회복의 실루엣과 방향 반응을 읽기 쉽게 만드는 것이다. 화면에서 무거워 보이게 하려는 이유로 공격 판정·쿨다운을 늘리지 않는다. Diablo의 폭력 표현·자원·스킬 규칙을 도입하는 범위가 아니다.

Roblox 비교는 공식 Beyond the Dark 커스텀 캐릭터 제작 사례다. 복잡한 형상은 필요한 부위에 관절을 배치하고 외부 제작·스키닝·가져오기·애니메이션으로 이어진다. 이 사례는 거미/지네를 인간형 리그로 축소하지 않고 전용 리그를 유지하는 대안을 뒷받침한다. 우리 모델의 성능 결과는 별도 측정한다. [공식 제작 사례](https://create.roblox.com/docs/resources/beyond-the-dark/custom-characters)

## 비용과 최소 실험

| 선택지 | 장점 | 비용/위험 | 판단 |
| --- | --- | --- | --- |
| Mixamo 동작을 기존 리그로 리타깃, 곡선으로 연결 | 현재 서버 시각/소켓/배포 경로를 활용 | 체형·R6 보정, 변환기와 독립 샘플 비교 필요 | 1차 권장 |
| Mixamo 리그/AnimationTrack으로 일괄 교체 | 외부 클립 재생 경로 활용 가능 | 장비/본/기존 포즈 writer·권한·멀티 회귀 범위 큼 | 대표 한 클립에서만 비교 후 판단 |
| Blender 직접 제작 | 무기/종족 고유 동작과 비인간형에 적합 | 제작/검토 공수 큼 | 비인간형과 특수 동작에 채택 |

최소 실험은 기사4·드워프2의 6클립이다. 동일 장면 전후 비교로 접지·타격 피크·관절·입력·프레임 시간을 확인한다. 접촉 시각 보존과 실제 시각 개선을 함께 통과해야 확대한다. 아직 Mixamo 로그인·다운로드·리타깃·Studio/실기기 실험은 수행하지 않았다. 다음 ART·ENG가 실행 계획의 MX-00/MX-01로 인계받는다.
