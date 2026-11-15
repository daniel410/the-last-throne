# 4난이도 캠페인 독립 진행 재검사

2026-11-15 · TLT-050/061~065/084 · QA → ENG 수정 → QA. **서버 진도·수령 분리 검사는 통과했으나 클라이언트 소비처3곳의 결함을 확인했다.** 이번 작업은 검사만 수행했으며 결함 수정·새 빌드·버전 변경·태그·게시를 하지 않았다.

검토 대상은 기존 **0.109.4**, 게임 소스 `561fd152c2efed6f89d5270ed70b4cba33158a39`, 재검사 기준 HEAD는 `067207876e50b03a543855fbb5a0fc38c00977ae`다. [기존 빌드 기록](../campaign-mode-migration-fix-20261115/build.json)의 산출물 `builds/0.109.4/TheLastThrone-0.109.4.rbxlx`, SHA256 `7505e73bda69d32678f86e2ca1f8316d307ab0e6a9985aea98f39ba4931572dc`를 재사용했고 원본 해시 불변을 확인했다. [앞선 이관·재플레이 수정](../campaign-mode-migration-fix-20261115/README.md)과 [현재 계약](../../production/campaign-mode-progress-2026-11-15.md)은 별도 근거다.

## 서버 규칙 검사

| 범위 | 결과·근거 |
| --- | --- |
| 기존 캠페인·이관·재플레이 재실행 | 4,621 + 88 + 3,723 = **8,432건 통과**. [실행 기록](existing-suites.json) |
| 본편 교차 진행 | **105,808건 통과**. 35본편×4모드140회 완료, 모드/원정 입장350회, 에픽 경계 재접속5회, 모드별 선택·진도·수령·부분 목표 복원과 오래된 요청 거부. [검사 코드](interleaved-main.lua)·[로그](interleaved-main.log) |
| 모든 선택 퀘스트 | **4,798건 통과**. 12퀘스트×4모드×활성 원정/캠페인 보고2경로 = 96회 완료. 독립 수락·부분 목표·모드 왕복·완료·초회 기록, 타모드 저널/수령 불변, XP/Gold/재료 정확량, 재시도·재로드 검사. [검사 코드](side-quests.lua)·[로그](side-quests.log) |

순수 Lua 검사는 합계 **119,038건**이다. 선택 퀘스트의 본편 선행은 각 모드에서 별도의 새 저널에 정상 `P.apply`로35장을 진행해 구성하고, fixture의 기존 이관 지급을 정규화한 뒤 실제 `A.begin`/`A.event` 및 로비 보고 규칙으로 검사했다. 메모리 기반 재접속/요청 검사는 live DataStore 검증이 아니다.

정확한0.109.4 파일을 연 격리 Studio Edit DataModel(`PlaceId=0`, 플레이어0)에서도 관련10개 Source 고정과 전체 소스 컴파일을 선행해 기존 **9,255건을 새로 실행해 통과**했다. `MODE_REAUDIT_06720787_START`/`END` 표식으로 이번 실행을 구분한다. [엔진 재실행 결과](native-reaudit.json). 소스 검사와 엔진 검사는 각각의 검증 층이며 두 수치를 합쳐 독립 사례 수로 취급하지 않는다.

## 확인된 미수정 결함

Easy DW-01을 완료한 뒤 새 Hard DW-01로 들어간 계정에서 서버는 `Hard.main=0`, Hard DW-01 미완료, Hard DW-02 입장 잠금을 올바르게 유지했다. 그러나 같은 계정을 실제 클라이언트 모듈로 렌더링하면 다음 불일치가 발생한다.

| 소비처·원인 | 실제 결과 |
| --- | --- |
| `LobbyQuestJournal.luau:44`의 공통 `hero.deepwood` 사용 | 미완료 Hard DW-01을 `COMPLETED`로 표시한다. |
| `LobbyAtlas.luau:26`의 공통 `hero.deepwood` 사용 | 서버에서 잠긴 Hard DW-02의 접근 가능 표시가 `true`다. |
| `DawnspireHomecoming.luau:51`의 공통 저널로 확장 장면 갱신 | 숨겨진 `LobbyNavigation.update`도 이를 호출한다. Hard 현장의 미완료 장면을 Easy의 완료 모습으로 덮는다. `CampaignIncidentScenes.luau:59~62`의 `UnresolvedIncident`는 단계0~2의 `UnfinishedWork`/`WorkPlan` 소품인데 공통 완료 단계3으로 숨겨진다. |

[최소 재현 코드](consumer-repro.lua)·[규칙 비교 로그](consumer-repro.log)에 이어, 실제 `LobbyQuestJournal`/`LobbyAtlas`/숨겨진 `LobbyNavigation`을 격리 Edit에서 렌더링했다. [Native 프로브](consumer-native-probe.luau)·[실제 결과](consumer-native-result.json)는 `pass=false`, `sceneLeak=true`, `actualQuestStatus=COMPLETED`, `actualDW02Accessible=true`를 기록한다. 임시 장면 Part의 투명도0→1과 하위 Prompt의 활성 상태 `true`→`false`도 관측했다. 이 Prompt는 프로브에만 추가한 것으로, 실제 수집물/퀘스트 Prompt anchor는 확장 장면과 별도다. 실제 필드 프롬프트 소실이나 진행 차단까지 확인한 결과로 일반화하지 않는다. 임시 GUI/장면은 검사 후 제거했다. 서버 검사 통과만으로 로비 표시와 현장 장면까지 모드별로 분리됐다고 판정할 수 없다.

## 미검증·다음 담당

ENG는 이3소비처가 선택/활성 난이도의 저널을 읽도록 수정하고, 숨겨진 로비 경로가 필드의 장면 투영을 덮어쓰지 않게 해야 한다. 이후 QA는 같은 최소 재현과 실제 렌더링 회귀를 다시 실행하고 일반 입력으로4모드 목표·네비·상호작용과 이어하기를 수용한다. 이번 재검사는 일반 입력 완주·live DataStore·게시 클라이언트·실기기·다인 플레이·사용자 수용을 확인하지 않았다. 상위 수용 게이트는 유지한다.
