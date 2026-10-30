# 재화·상점·파티 원형0.36.0 검증

2026-10-30 · TLT-003/016/017/021/028/041/044/045/047/049/050/053/084 · ENG/DES → QA/DIR.
[실행 계약](../../production/lobby-economy-and-expeditions.md) · [후속0.36.1](../lobby-0361/README.md) · [고정 입력/빌드](build.json) · [LFS5파일](inputs.json).

원격 푸시된 `901b6af13cf8d7b8996a5f161ebf4f2a017a008f`를 Git archive로 분리하고 Rojo7.7.1로 Lobby/Battle을 따로 빌드했다. 미게시·릴리스 태그 없음. 산출물 경로/크기/SHA256은 build.json에 기록했다.

| 검증 | 결과와 범위 |
| --- | --- |
| 순수 Lua | 경제23·원정 저장43·인벤토리265·성장81·진행570·퀘스트31·보스96·세션97·스킬1435·스탯 미리보기855 통과. [원문](pure.log) |
| 격리 Studio Lobby | 실제 모듈 컴파일/GUI·TD 무기 전시·Player 대역20/4명 입장 제한 **126개·실행기 종료0**. [로그](native.log) |
| 격리 Studio 캠페인 회귀 | Player/계정 대역, 실제 몬스터 사망 콜백·7본편/선택·증원 **126개·종료0**. [로그](story.log) |
| 격리 Studio Battle | 역할·월드/리모트 부트스트랩 **10개·종료0**. [로그](battle-boot.log) |
| 실제 Studio Player | 정상 클릭으로2인 모집/준비/1명 출발 거부·탈퇴·Solo 미리보기·두 번 확인 구매/판매. [상세](actual-player.json) |

상점 QA는 정상 전투 완주 대신 서버 시험으로7본편 완료 보상을 준비했다.2290 Gold/14 Diamonds에서 검250 Gold 구매→2040/14, 매각50 Gold→2090/14, Veteran Sword10 Diamonds 구매→2090/4와 영웅 가방 소유를 확인했다. Studio 세션 저장이며 게시 DataStore·실제 과금 검증이 아니다.

![실제 Studio Player의 무기 상점](armory.png)

광범위 검사 중 기존 `k0-appearance`의 GetDescendants 대역 누락, `k0-rules`의 GetAttribute 대역 누락은 이전0.35.2 고정 소스에서도 동일하게 실패했다. [기존 기준 비교](baseline-failures.log). 전체 테스트 통과로 보고하지 않는다. 기존 자산203785492 타입 경고도 남아 있다.0.36.1은 전체 명단 출발 잠금/불명 lease 해제 복구를 보완했으므로 최신 구현 근거는 후속 문서를 따른다.

Creator Dashboard에서 RPG 로비 최대 방문 인원20 저장을 확인했다. 실제20명 부하 시험과 구분한다.

![RPG 시작 Place 최대 방문 인원20 저장](lobby-capacity20.jpg)

새 Battle Place 생성은 API 접근 비활성 오류로 실패했고 보안 설정 변경 승인은 대기 중이다. TD의 기존 전투 Place는 이동/수정하지 않았다. 실제 게시 이동·서버 간 파티·리조인·4클라이언트·모바일은 QA 후속이다.
