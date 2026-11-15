# 환영 메일 뉴스 안내 문구

작업: TLT-047/049/084 후속 · 2026-11-15 · 소스 문구 수정.

- 근거: 사용자 첨부 화면의 환영 메일에서 뉴스 안내만 유지하고, 실제 기프트 제공 시 리딤을 안내하라는 요청.
- 변경: `src/server/Lobby/DeliveryCatalog.luau`의 `welcome-v1` 본문에서 기프트 예고와 상시 Redeem Code 안내를 제거했다. 기존 ID·제목·발신자·빈 보상과 수령 기록은 유지한다.
- en-US 본문: `Welcome, adventurer! Check your mailbox for the latest news from The Last Throne team. Thank you for joining us!`
- 정적 검증: `git diff --check` 통과. 카탈로그 diff에서 본문 한 줄만 변경되었고, 뉴스 안내만 포함함을 확인했다.
- 미검증: Studio 화면, 게시 클라이언트, 실기기, 사용자 수용. 빌드·Roblox 게시는 실행하지 않았다.
- 다음 담당: 후속 빌드/QA 담당자가 로비 `MENU > MORE > Mailbox`에서 환영 메일 본문과 줄바꿈을 확인한다. TLT-047/049 전체 완료나 G3/G7 통과로 처리하지 않는다.
