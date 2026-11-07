# 0.79.3 로비·배틀 게시

2026-11-06 Toronto(UTC2026-11-07) · TLT-003/028/057/084 · ENG → QA.

사용자 명시 지시로 기존 RobloxStudio 프로세스79640을 강제 종료하고 검증된0.79.3 단일 파일을 새 Studio에서 열었다. 저장하지 않은 Studio 편집 내용은 강제 종료 시 손실될 수 있음을 사전에 알렸다. 디스크의 사용자 Blender·첨부·미추적 작업은 포함하거나 수정하지 않았다. TD Place를 게시하지 않았다.

고정 소스 `24c695a69850d0d802d661f9c0035fa7c2177a68`, 파일 `builds/0.79.3/TheLastThrone-0.79.3.rbxlx`(13,299,601bytes), SHA-256 `c53119df81678f0723d0efa2ac38b58b9867cb0604e8c78b4a5527fdd6ff0e18`. 게시 전후 파일 해시 동일. [빌드 기록](../battle-loading-stall-20261106/build.json). 재빌드/버전 재사용 없음.

Studio File→Publish As에서 The Last Throne Experience를 선택한 뒤 기존 로비70829337938054와 배틀129388473517823에 순서대로 덮어쓰기 게시했다. 로비에서 필요한 자산 사용 권한을 Grant Permissions and Publish로 대상 RPG Experience에 적용했다. 로비의 ready to test·기존 제한 접근 화면과 배틀의 Successfully published!/Private 화면을 직접 확인했다. [두 게시 성공 타임스탬프](publication-studio.log), [대상·UTC/현지시간·관측 결과](publication.json). 게시 이후 Applying script changes 안내를 확인하고 OK로 완료 화면에 진행했다. 숫자 Place 버전은 조회하지 않았으며 로컬 PlaceVersion을 게시 버전으로 사용하지 않는다.

포함 수정: 모험 복귀 영웅 선택 유지, 최종 스폰 스트리밍 요청의 대기 순서 수정, 로딩 중 영웅UI boolean/level 오류 교정 및0.79.3에 고정된 선행 변경. [영웅 선택 회귀](../lobby-return-hero-20261106/README.md), [로딩·영웅UI 회귀와 엔진66검사](../battle-loading-stall-20261106/README.md). 게시 직전 `python3 tests/single-build.spec.py --artifact builds/0.79.3/TheLastThrone-0.79.3.rbxlx`의 실제 산출물 역할10/로딩192·프로젝트 구성 검사도 PASS.

검증된 빌드 소스에 주석 태그v0.79.3을 생성해 해당 태그만 푸시하고 원격 커밋/태그를 확인한다. 새 LFS 자산 업로드는 없다. 실제 게시된 Roblox 앱의 로비→배틀 이동·로딩 해제·복귀 영웅 선택과 모바일/다인 수용은 미검증이므로 다음 QA가 새 서버에서 확인한다. 원인 후보 수정/게시 성공을 제보 서버의 정확한 원인 확정 또는 실제 이동 통과로 보고하지 않는다. 부모 티켓은 In Progress 유지.
