# 난이도별 로비 표시·현장 장면 수정 검증

2026-11-15 · TLT-050/061~065/084 · ENG → QA/사용자. 로컬 수정·고정 빌드·격리 Studio 엔진 검증 완료. 게시·일반 입력 완주·실계정 저장·실기기·다인 수용은 미검증이다.

## 변경

[재검사에서 확인한 3결함](../campaign-mode-isolation-audit-20261115/README.md)을 수정했다. LobbyQuestJournal과 LobbyAtlas는 활성 원정의 난이도(없으면 Easy)의 영속 저널로 완료·접근 상태를 표시한다. 두 화면에 난이도를 명시하며, 지도는 그 모드에서 접근 가능한 지역에 한해 영웅 공통 탐색 기록을 겹친다. 재플레이의 임시 선행 기록은 로비 완료/개방 판정에 사용하지 않는다.

DawnspireHomecoming의 공통 장면 갱신은 atHub=true이고 Battle 역할이 아닌 경우에만 실행한다. 숨겨진 로비 UI의 InventoryState 갱신이 필드 원정의 장면을 덮지 않으며, 기존 영웅 공통 귀환 장면 계약은 유지한다. XP·지갑·아이템·보상·서버 진도 규칙은 변경하지 않았다.

## 검증

소스 `fd3d87693dd741290a7bede09554e83c58b8bbad`를 커밋·푸시하고 원격 일치를 확인한 뒤 **0.110.7**을 빌드했다. [빌드 기록](build.json)의 단일 산출물은 `builds/0.110.7/TheLastThrone-0.110.7.rbxlx`다. [산출물 검사](artifact-check.json)에서 수정3모듈의 Source와 빌드 SHA256을 확인했다.

기존 격리 Edit에서 3개 후보 클라이언트 모듈의 복사본으로 실제 UI 렌더링 [64개 검사를 먼저 통과](preview.json)했다. 이후 `python3 tools/prepare-campaign-mode-progress-native.py`로 준비한 검증기를 다음 명령으로 정확한 고정 빌드에 실행했다.

```sh
run-in-roblox --place builds/0.110.7/TheLastThrone-0.110.7.rbxlx --script /tmp/tlt-campaign-mode-progress-native.luau
```

실행기는 로컬 작업용 place 사본을 열며, 검증기는 PlaceId=0/플레이어0, 관련13모듈 Source 일치 및 전체 소스 컴파일을 선행한다. [실제 엔진 로그](native.log): 본편4난이도4,621 + 이관88 + 과거 에픽/재플레이3,723 + 교전/네비823 + 클라이언트64 = **9,319개 통과**, 실행 종료 코드0.

신규 `tests/campaign-mode-consumers-native.luau`는 실제 계정 API로 다른 모드 DW-01 완료 후 현재 모드의 미완료 상태를 만들고, Easy/Hard/Insane/Hell의 실제 퀘스트 목록·지도 생성/갱신을 검사한다. 잠긴 DW-02, 공통 탐색 보존, 난이도 문구, 명시적 재플레이의 실제 완료/접근 기록, 숨긴 로비의 필드 장면 덮기 차단, Battle 허브 예외와 공통 로비 장면 유지까지 포함한다. 임시 GUI/장면과 역할 속성은 정리·복원한다. 장면 검사는 임시 소품을 사용하며 실제 퀘스트 아이템 손실이나 일반 입력 완주를 증명하지 않는다.

## 미검증·다음 담당

Roblox 게시·릴리스 태그·live DataStore를 변경하지 않았다. QA/사용자는 이 빌드의 일반 입력으로 난이도 변경 뒤 QUEST/MAPS의 완료·개방/난이도 문구, 필드에서 가방·장비 갱신 후 미완료 장면 유지, 귀환 연출과 재플레이를 수용한다. 게시 테스트 Experience 이동, 실계정 재접속, 실기기·다인 검증과 상위 티켓 수용 게이트는 남아 있다.
