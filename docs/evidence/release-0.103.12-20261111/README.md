# 0.103.12 빌드·게시

2026-11-11 · TLT-057/084/087 · 사용자 요청 “빌드해주고 게시해줘”. 게시 작업 완료이며 상위 수용 티켓/G7 완료 판정은 아니다.

- 입력 소스 `c4e817807fb7d4b58dbd9bba02b3545eb90c289a`의 `VERSION`을0.103.12로 고정하고 origin/main 일치를 확인한 뒤 `python3 tools/build-game.py --source HEAD --record docs/evidence/release-0.103.12-20261111/build.json`을 실행했다. Rojo7.7.1. [빌드 기록](build.json).
- 단일 산출물 `builds/0.103.12/TheLastThrone-0.103.12.rbxlx`를 로비·배틀에 각각 게시했다. SHA-256 `aecd1070397a8746084160846d347737e1bbd7ee44d98b6d75fe6302c43cae96`. 게시 전후 해시 불변. [산출물 비교](artifact-check.json).
- 이 재빌드는0.103.11과 바이트까지 동일하다. [0.103.11 고정 산출물의 엔진6,330검사](../elf-confirmed-release-20261111/README.md)를 재사용한다. 이번 Studio에서는 전체 LuaSourceContainer **449개 컴파일 통과**를 별도 확인했다. 기존 종합 기본 공격 검사의 동일24실패는 여전히 후속이며 전체 회귀 통과로 확대하지 않는다.
- 로비70829337938054: **게시 버전94**,18:25 America/Toronto. 배틀129388473517823: **게시 버전21**,18:26. 두 Place 모두 Creator Dashboard에서 `Show published only`를 켜고 최신 버전/시간을 확인했다. 배틀은 Studio `Successfully published!`도 확인했다. [상세 게시 기록·대시보드 링크](publish.json).
- 기존 **Private** 유지. Studio가 요청한 대상 TLT Experience의 누락 자산 사용 권한을 `Grant Permissions and Publish`로 연결했다. TD에는 게시하지 않았다.
- 이전0.103.4/0.103.5 테스트 소스는 각각 빌드 폴더의 `TheLastThrone-<version>-session-preserved-release-20261111.rbxl`로 별도 저장했다.0.103.5 Play를 중지했으므로 임시 실행 상태/캐릭터 어댑터는 종료됐다. 게시용 파일은 덮어쓰지 않았다. 마지막 앱 인벤토리에서 Studio `isRunning=false` 확인.
- 주석 릴리스 태그 `v0.103.12`는 실제 빌드 입력 커밋에 고정한다. 복구 시 로비93·배틀20이 직전 게시본이며 대시보드 복원 후 Studio 재게시가 필요하다. 복구 리허설은 미실행이다.

미검증: 게시 클라이언트 플레이·실계정 저장/재접속·각 Place 실제 이동·실기기/다인 성능·사용자 수용. 다음 담당은 QA/사용자 플레이 검수이며, 이번 게시 성공으로 해당 수용을 완료 처리하지 않는다.
