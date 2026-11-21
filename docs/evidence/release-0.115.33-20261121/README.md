# 0.115.33 비공개 게시

2026-11-21 · TLT-084 · ENG → QA

기존 비공개 Experience `10773575153`의 두 Place에 같은 `TheLastThrone-0.115.33.rbxlx`를 게시했다. [고정 빌드 기록](../hero-ultimate-finish-20261121/build.json)의 소스 커밋은 `1ba3dea5c31688df8218adb34195cbcfc54dd12c`이며 릴리스 태그는 `v0.115.33`이다. 로컬 파일은 게시 전후 SHA-256 `63dd778d65761d564fbbd224496b91d5615bb8cc1ff7461a31fb7fdef775bae6`이 일치했다.

| 대상 | Place ID | 최종 게시 버전 | 성공 시각 (EST) |
| --- | --- | --- | --- |
| The Last Throne Battles | `129388473517823` | 43 | 16:23:43 |
| The Last Throne | `70829337938054` | 118 | 16:24:12 |

## 게시와 검증

- 열려 있던 Studio 편집본 0.114.44와 0.115.0의 변경을 각각 로컬 파일에 저장하고 기존 Studio를 종료했다. 최종 게시 뒤 Studio 프로세스가 모두 종료된 것을 확인했다.
- 로컬 빌드를 열어 배틀의 `Publish As`와 로비의 `Save to Roblox As`를 실행했다. 두 작업 모두 Studio 성공 표시 직후 `/publish/v1/Scripts` 요청 513건씩 HTTP 429를 기록했다. 배틀을 저장할 때 빌드가 참조하는 자산 4개에 이 비공개 Experience의 사용 권한을 연결했다.
- Studio CLI로 각 클라우드 편집본을 열었다. 배틀 42와 로비 117에서 스크립트 573개를 경로·클래스·소스 길이·두 체크섬으로 로컬 빌드와 대조했다. 누락·빈 소스·불일치는 모두 0건이었다. 검증한 편집본에서 각각 Studio `Publish`를 실행했다. Studio 로그의 `PublishSuccessful`, `Published new changes`, 게시 버전 43과 118을 확인했다. 이 두 최종 게시 세션에서는 스크립트 업로드 HTTP 429나 `Commit Failure: Publish Assets`가 없었다.
- 게시 후 macOS Roblox Player `0.748.0.7481526`으로 16:24:26에 로비 Place에 접속했다. Dawnspire 월드, 기존 영웅과 로비 UI가 표시됐다. [0.114.31의 빈 시작 화면](../lobby-compact-hud-011431/README.md#게시-로비-시작-장애)은 이 세션에서 재현되지 않았다.

## 남은 수용

QA가 로비에서 원정을 시작해 배틀로 이동하는 실제 경로, 다인 플레이, 모바일 기기와 궁극기 연출을 확인한다. 배틀 직접 접속은 Roblox 오류 524를 반환했다. 모바일·다인·원정 이동·사용자 수용은 미검증이다.
