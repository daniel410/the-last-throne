# 0.113.12 빌드 게시

2026-11-18 · TLT-061 / TLT-065/GW / TLT-062 / TLT-063 / TLT-064 · ENG → QA/사용자

사용자 요청에 따라 Studio에서 검증한 최신 단일 빌드 0.113.12를 기존 Private Experience `10773575153`의 로비와 배틀에 게시했다. 다섯 에픽의 길목 지물과 DW-Q1 습지 보고 동선 개선을 포함한다. [변경 및 Studio 검증](../epic-approach-readability-20261118/README.md).

- 입력 커밋 `07386181e2dbdb5434000b5738107bb62ec3a0a0`의 기존 산출물 `builds/0.113.12/TheLastThrone-0.113.12.rbxlx`를 사용했다. 최신 원격 소스 `25a20981`과의 차이는 검증 문서와 증거 파일이다. 기존 작업 트리의 미커밋 변경은 보존했다. [고정 빌드 기록](../epic-approach-readability-20261118/build.json).
- 게시 전후 파일은 26,600,343바이트이며 SHA-256은 `0d16f0797013f7477f84120233a694daa6698802a264d49553bff4d228ebc861`로 빌드 기록과 일치한다. 기존 Studio 검증에서 Luau 543개 구문과 DW-Q1 보고 구간의 R15 양방향 통과를 확인했다.
- 로비 `70829337938054`는 19:20:30 EST에 게시 로그의 `PublishSuccessful`과 Studio의 `The Last Throne is ready to test!`를 확인했다. 게시 과정에서 기존 Private Experience에 게임 자산 사용 권한을 연결했다.
- 배틀 `129388473517823`은 19:21:58 EST에 게시 로그의 `PublishSuccessful`과 Studio의 `Successfully published!`, `Private`을 확인했다. 두 게시의 대상 Place ID는 Studio 데이터 모델 및 게시 로그와 일치했다.
- 주석 릴리스 태그 `v0.113.12`는 실제 빌드 입력 커밋을 가리킨다. 이전 배포 묶음은 [0.113.7 게시 기록](../release-0.113.7-20261117/README.md)에서 확인할 수 있다.

Creator Dashboard의 Place 버전 번호, 게시 클라이언트 입장·이동, 멀티플레이와 실기기 검증은 미확인이다. 다음 담당 QA/사용자는 게시본에서 로비→배틀 입장과 DW-Q1 실제 보고를 확인한다. G5 수용은 진행 중이다.
