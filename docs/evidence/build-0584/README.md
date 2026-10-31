# 일반 빌드 0.58.4

- 작업: 최신 확정 소스의 로비·전투 Place 재빌드. 진행 중인 미커밋 변경은 입력에서 제외했다.
- 입력: `9f33ab09e6f90e0abee8a95474cf7fa3002e822f`, VERSION `0.58.4`. 분리된 Git worktree에서 빌드했다.
- 도구: Rojo 7.7.1. `rojo build default.project.json -o builds/0.58.4/TheLastThrone-Lobby-0.58.4.rbxlx`, `rojo build battle.project.json -o builds/0.58.4/TheLastThrone-Battle-0.58.4.rbxlx` 모두 성공.
- Lobby: 7,048,499 bytes, SHA-256 `82b11ca09324cc30e007d3e26140a5177cc3212a5df391606925e35483e04a66`.
- Battle: 7,048,500 bytes, SHA-256 `b745ed34292b4f86f54a430dbc3b0eb7a9b8224341ba71b69fdc2d385d3ed8cf`.
- 검증: 두 산출물 XML 파싱 성공, 각각 Item 1,214개. 입력 worktree의 `git lfs fsck --objects` 통과.
- 미검증: Studio 실행, 실제 클라이언트·멀티플레이·실기기. Roblox 게시 및 릴리스 태그 없음. 다음 담당: QA/엔지니어링.
