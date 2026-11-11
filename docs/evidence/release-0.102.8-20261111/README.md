# 0.102.8 게시·Studio 종료

2026-11-11 · TLT-057/084 · 사용자 요청 “스튜디오닫고 빌드게시해줘”. [게시 기록](publish.json).

검증된 단일 빌드 `builds/0.102.8/TheLastThrone-0.102.8.rbxlx`를 기존 TLT Experience10773575153의 로비·배틀에 각각 게시했다. 빌드 소스는 `a50c20a88fb858b0d52691499c3221cd164027ee`이며 [빌드/자산 로딩 엔진 검증](../equipment-asset-loading-20261111/README.md)을 재사용했다. 새 빌드를 만들지 않았고 버전도 추가로 증가하지 않았다.

- 로비70829337938054: 게시 버전 **93**, 2026-11-11 14:04 America/Toronto. [버전 기록](https://create.roblox.com/dashboard/creations/experiences/10773575153/places/70829337938054/version-history).
- 배틀129388473517823: 게시 버전 **20**, 14:06. [버전 기록](https://create.roblox.com/dashboard/creations/experiences/10773575153/places/129388473517823/version-history).
- 두 게시 모두 Studio의 Successfully published! 화면과 Creator Dashboard의 Show published only 필터에서 최신 버전을 확인했다. 기존 Private 범위는 유지했다. TD에는 게시하지 않았다.
- 로비 첫 업로드는 서버 busy로 재시도했다. 스크립트 업로드에서도 HTTP429가 기록됐으나 최종 게시 성공과 대시보드 게시 버전을 확인했다. 일부 자산은 Studio의 Grant Permissions and Publish로 대상 TLT Experience의 사용 권한을 연결했다.
- 기존 Studio를 모두 종료하고0.102.8만 다시 열어 게시한 뒤 종료했다. 최종 앱 인벤토리에서 `com.Roblox.RobloxStudio`의 `isRunning=false`를 확인했다.
- 미저장 시험 세션0.102.0/0.102.3/0.102.5/0.102.6은 각 빌드 폴더의 `TheLastThrone-<version>-session-preserved-20261111.rbxl`로 별도 보존했다. 게시용 고정 파일은 변경하지 않았으며 전후 SHA256은 `8ec1b2f21a94c3351354e34b5c622fa48e292e2e474afe3beac5131eb2394fb5`로 같다.

주석 릴리스 태그 `v0.102.8`은 위 빌드 소스에 고정하고 푸시한다. 게시 확인은 게임 플레이 수용과 구분한다. 게시 클라이언트 첫 접속·저속망/실기기 색상 표시, 실계정 저장·재접속, 실제 Place 이동·다인 성능·사용자 미술 수용은 미검증이다. 다음 담당은 게시 클라이언트 QA/사용자 플레이 검수다.
