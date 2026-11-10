# 0.95.0 게시·Studio 종료

2026-11-09 · TLT-028/029/032/041/052/073/082/084. 사용자 요청 “스튜오닫고 게시해줘”에 따라 최신 검증 빌드를 TLT 두 Place에 게시하고 Studio를 종료했다. [게시 기록](publish.json).

## 게시 결과

- 로비70829337938054: **게시 버전75**, 2026-11-09 20:53 America/Toronto. [버전 기록](https://create.roblox.com/dashboard/creations/experiences/10773575153/places/70829337938054/version-history)에서 Published Version 체크를 직접 확인했다.
- 배틀129388473517823: **게시 버전18**, 20:56. Studio의 Successfully published!와 [버전 기록](https://create.roblox.com/dashboard/creations/experiences/10773575153/places/129388473517823/version-history)의 Published Version 체크를 확인했다.
- 두 곳 모두 Experience10773575153의 기존 Place를 선택했다. TD는 게시/내용 변경 없이 열려 있던 창만 닫았다.
- 게시 때 누락된 TLT Experience 에셋 사용 권한은 Studio의 Grant Permissions and Publish로 연결했다. 기존 Private/테스트 접근 범위를 유지했고 공개 출시나 협업자 변경은 하지 않았다.
- Studio 앱/모든 편집 창 종료 후 CUA 앱 인벤토리에서 com.Roblox.RobloxStudio **isRunning=false**를 확인했다. 로컬 고정 빌드는 덮어쓰지 않았다.

## 소스와 검증

소스 `828f3d16efebeb28c4023cf83a62e5daaf3e2b57`, 게임 버전0.95.0. 원본 파일 `builds/0.95.0/TheLastThrone-0.95.0.rbxlx`, SHA256 `f47c0f10d3ac548a87ba8d050433c80e27f0047e80f73f6a397b53c416bb5a7e`. 게시 전후 디스크 SHA256 동일. 기존 [고정 빌드/형상/착용 검증](../four-family-shields-20261109/README.md)의 방패151·회귀835, 역할/로딩/프로젝트 검사를 재사용했다. 같은 파일의 현재 편집 내용에서 검토용 모델/배경/조명을 제거한 뒤 로비와 배틀을 차례로 게시했다. 단일 빌드의 역할 선택은 실제 Place ID에 따른다.

주석 태그 `v0.95.0`은 실제 빌드 입력 소스에 고정한다. 게시 뒤 증거 문서는 별도 커밋/푸시한다. 이는 비공개 테스트 Place 버전 업데이트이며 공개 출시/실계정·실기기 수용 완료가 아니다.

미검증: 게시된 Roblox 클라이언트에서 실제 게임/지역 이동/새 자산 권한, 실제 계정 저장/재접속, 물리 기기·4인 성능과 사용자 최종 미술 수용. 다음 담당은 게시 클라이언트 QA/사용자 플레이 검수다. Studio 시험으로 이 항목을 통과 처리하지 않았다.
