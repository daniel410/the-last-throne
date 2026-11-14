# 대표 퀘스트 지형·지물·설비 연결 검증

2026-11-14 · TLT-061/062/063 · ENG/DES → QA

범위: [사양](../../production/quest-setpieces-2026-11-14.md)의 DW-01/FV-03/EC-01 세 장면. [비교 조사](../../research/2026-11-14-quest-terrain-props-and-items.md)를 기존 진행/저장 계약을 보존하는 범위에 적용한다. 사용자 미커밋 자산·TD 운영·경제는 변경하지 않는다.

## 검증 조건·결과

- `lua tests/campaign-expansion.spec.lua`:7,737검사 통과.35본편/12선택·82사건/246확장 단계 유지.
- `lua tests/story-fun.spec.lua`:1,761검사 통과. 기존 진행/정답/부분 저장 유지.
- `lua tests/story-prop-context.spec.lua`:4,129검사 통과.292단계 물품/63종의 기존 지정 계약 유지.
- `lua tests/campaign-context-review.spec.lua`:1,054검사·418저장 전이 통과.47개 원고와 런타임 계약 유지.
- 실제 Studio Edit 격리 엔진 `PlaceId0/플레이어0`: [고정 빌드 소스4개 일치](fixed-sources.json) 후 런타임 전체 LuaSourceContainer 컴파일·5에픽 생성·465검사 통과. 새268파트·167개 바닥 흔적. 생성 중복0, 모든 새 파트의 anchored/noncolliding/nontouch/nonquery, 실제 허용 바닥과 흔적 접지, 부분/완료·영웅 전환·구완료 저널·늦은 스트림 도착·중복 스냅샷·수리 전/후의12stud 이동을 확인했다. [최종 로그](native.log).
- 실제 `DeepwoodActivities.interactStep`에 위치/저널/저장 큐를 주입했다. 정상 요청은 기존 큐로 전달하고 큐만 접수한 상태에는 장착 연출 없음, 거리100stud 요청 거부, 확정 저널 반영 후 연출, 완료된 중복 요청 재큐잉 없음을 확인했다. 실제 DataStore 실패/동시 서버 실행 증거는 아니다.

## 빌드·재현

최종 버전0.107.1, 입력 커밋 `61c08ec25c384132e199a48d62bbd2fc2b49868c`. [빌드 명령·입력·LFS·산출물 해시](build.json). `python3 tools/build-game.py --source 61c08ec2 --record docs/evidence/quest-setpieces-20261114/build.json`으로 만들었으며 산출물을 덮어쓰지 않는다.

검사: `python3 tools/prepare-quest-setpieces-native.py` → `/tmp/tlt-run-in-roblox-50316 --place builds/0.107.1/TheLastThrone-0.107.1.rbxlx --script /tmp/tlt-quest-setpieces-native.luau`. 소스 주입 없이 고정 빌드를 열어 일치를 먼저 검사한다. 실행기 종료0·`QUEST_SETPIECES_NATIVE_PASS`를 확인했다. 화면 검토용 `--review`는 같은 빌드·검사 이후 전용 격리 창을 유지한다.

## 실제 편집 화면 확인

최종0.107.1 고정 빌드·검사 후의 완료 저널 투영 상태에서 [DW-01 수레 흔적/차축/신호](DW-01-fixed.jpg), [FV-03 높인 봉화/불꽃/응답선](FV-03-fixed.jpg), [EC-01 장착 기어/구동축/상승 화물](EC-01-fixed.jpg)을 직접 확인했다. 기본 밝은 Edit 조명·별도 지정 카메라이며 플레이어 HUD·실제 조작·지역 조명 수용 증거는 아니다. [촬영 좌표·파일 해시](captures.json).

첫0.107.0은 [DW 후보](DW-01-candidate.jpg)·[FV 후보](FV-03-candidate.jpg)·[EC 후보](EC-01-candidate.jpg)의 화면 검토에서 흔적 간격/봉화 실루엣/구동 연결을 보강하기 전 빌드다. [입력·해시](build-0.107.0.json)·[검사448개 통과](native-0.107.0.log)를 최종 결과와 구분한다. 새 빌드로 수정했고 이전 산출물은 덮어쓰지 않았다.

최종 확인에서도 넓고 평평한 기존 바닥 구조는 남는다. 이번 세 장면은 사건의 단서/작동/결과 연결이며, 협곡 재굴착·지역 전체 공간 개편이나 플레이 재미 개선의 수용 완료로 해석하지 않는다.

## 미검증·다음 담당

게시 클라이언트·실계정 DataStore/동시 서버·실기기/다인 성능·사용자 재미/미술 수용은 미검증이다. QA는 실제 카메라에서 수레 자국의 방향, 두 봉화의 응답, 기어 장착과 화물 상승을 구별할 수 있는지 확인한다. 부모 티켓/G5/G7 완료·Roblox 게시·릴리스 태그는 만들지 않는다.
