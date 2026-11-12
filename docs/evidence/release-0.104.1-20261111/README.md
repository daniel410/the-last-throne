# 0.104.1 게시

2026-11-11 · TLT-033/057/084/087 · 사용자 요청 “게시해줘”. 게시 완료이며 상위 수용 티켓/G7 완료 판정은 아니다.

- 기존 검증 산출물 `builds/0.104.1/TheLastThrone-0.104.1.rbxlx`를 재빌드 없이 게시했다. 입력 커밋 `bfa0dc4c33d71a6e8ed4f66da76abff88a5a0099`. [빌드 기록](../skill-vfx-individual-20261111/build.json). 버전은 증가하지 않았다.
- SHA-256 `bdb6bb07c116fecbeb178f227c7adc2d129407a94124cb4673f48811a1e8bbad`,18,599,416바이트. 게시 전후 해시가 빌드 기록과 일치한다. 현재 HEAD와 빌드 입력의 `src`·VERSION·두 프로젝트 설정 차이도 없다.
- [128개 스킬 VFX 개별 검토와 빌드 파일 엔진5,627검사 통과](../skill-vfx-individual-20261111/README.md)를 재사용했다. 이번 작업은 게시와 무결성 검증이며 엔진 회귀를 새로 실행한 것은 아니다.
- 로비 `70829337938054`: **게시 버전95**,19:24 America/Toronto. 배틀 `129388473517823`: **게시 버전22**,19:25. 두 Place 모두 Creator Dashboard의 **Show published only**를 켜고 최신 버전과 시간을 확인했다. 배틀의 Studio **Successfully published!**도 확인했다. [대상·시간·대시보드 링크](publish.json).
- 기존 **Private** 유지. Studio가 요구한 대상 TLT Experience의 자산 사용 권한을 `Grant Permissions and Publish`로 연결했다. TD Place·운영 코드·잔액·권리는 변경하지 않았다.
- 이전0.103.12 창의 미저장 상태는 `builds/0.103.12/TheLastThrone-0.103.12-session-preserved-release-0.104.1.rbxl`에 별도 저장 후 종료했다. 게시용0.104.1 파일은 덮어쓰지 않았다. 게시 창을 종료했으나 읽기 전용으로 중복 열린0.104.1 창은 종료 메뉴가 비활성화되어 남아 있다. 마지막 앱 인벤토리 `isRunning=true`; 강제 종료하지 않았다.
- 주석 릴리스 태그 `v0.104.1`의 대상은 실제 빌드 입력 커밋이다. 직전 게시본은 로비94·배틀21이다. 복구 시 대시보드 복원 후 Studio 재게시가 필요하며 복구 리허설은 미실행이다.

미검증: 게시 클라이언트 플레이·실계정 저장/재접속·각 Place 실제 이동·실기기/다인 성능·사용자 미술/조작 수용. 다음 담당은 QA/사용자 플레이 검수다. 게시 성공으로 이 수용을 완료 처리하지 않는다.
