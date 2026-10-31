# 로비 UI 빌드 0.43.4

- 작업: 사용자 요청 로비/전투 로컬 빌드 (별도 백로그 ID 없음). 영웅 선택창 축소와 지갑 배치 수정을 포함한다.
- 입력 소스: `8cca38246b7811d852eee3f7703ebdac3aee7aaf`, VERSION `0.43.4`. Git 커밋의 소스를 별도 임시 디렉터리에 재구성하고 LFS 입력의 크기와 SHA-256을 확인했다.
- Rojo 7.7.1로 `default.project.json`, `battle.project.json` 빌드 성공. 경로·명령·산출물 크기와 SHA-256은 [build.json](build.json)에 기록했다.
- 로비 산출물에서 `run-in-roblox --place builds/0.43.4/TheLastThrone-Lobby-0.43.4.rbxlx --script tests/lobby-wallet-native.luau`: 16개 통과. 같은 산출물과 `tests/k0-resource-ui-native.luau`: 4,808개 통과. 로그에는 기존 자산 `203785492`의 유형 경고가 있다.
- 제한: 격리된 GUI/상태 검사이며 이 빌드의 실제 Player 화면·실기기·전투 동작은 미검증이다. Roblox 게시와 릴리스 태그는 수행하지 않았다.
- 다음 담당: QA/사용자가 빌드를 Studio와 실제 기기에서 확인한다.
