# 0.88.1 로비·배틀 게시

- 작업ID: TLT-001/050/057/061~065/084. 사용자 `게시해줘` 지시에 따라 기존 RPG 두 Place에 검증된 단일 빌드를 게시했다.
- 로컬 날짜: 2026-11-08 (America/Toronto). 서버 로그 UTC: 2026-11-09.
- 빌드 소스: `532a748c63dd1bfd664bb70135fc8b7f54cf9f0b`, 버전 `0.88.1`.
- 산출물: `builds/0.88.1/TheLastThrone-0.88.1.rbxlx`, 15,983,130 bytes.
- SHA256: `59d54142b43af5dbd56452c82006f2af7e95578b76f047553498d4957bbd090b`. 게시 전후 일치.
- Universe: `10773575153`. 로비 `70829337938054`, 배틀 `129388473517823`.

## 결과와 근거

Studio에서 해당 로컬 파일을 열고 File → Publish As → The Last Throne → 기존 로비/배틀 선택 → Overwrite를 순서대로 실행했다. 로비 게시 때 목적 Experience의 포함 자산 사용 권한을 부여했다. 새 Place를 만들지 않았다.

로비는 `The Last Throne is ready to test!`와 기존 소유자·협업자·초기 테스터 범위를 확인했다. 배틀은 `Successfully published!` / `The Last Throne Battles` / `Private` 화면을 확인했다. 공개 범위·TD·라이브 프로필을 변경하지 않았다. [게시 기록](publication.json)과 [Studio 로그 발췌](publication-studio.log)는 두 목적 Place와 각각의 게시 성공 시각을 연결한다. 로그의 `placeId 0`은 로컬 파일 출발 상태이므로 실제 게시 버전 번호로 해석하지 않는다.

## 검증과 남은 수용

- `python3 tests/single-build.spec.py --artifact builds/0.88.1/TheLastThrone-0.88.1.rbxlx`: PASS. 역할10 / 도착·로딩192 / 프로젝트·실제 아티팩트 계약 확인.
- Python hashlib SHA256 비교: PASS, 기존 빌드 기록과 게시 후 파일 동일.
- 기존 [스토리 개선 검증](../story-fun-20261108/README.md): 18 회귀 묶음 및 native 9,192 PASS. 이번 게시 작업은 코드를 수정하거나 재빌드하지 않았다.
- Studio는 Place 게시 성공 뒤 스크립트 VersionHistory 자산 업로드에 HTTP 429를 기록했다. Place 게시 성공과 별도이며, 실제 클라이언트 동작 통과로 보고하지 않는다.
- 실제 게시 클라이언트의 로비→배틀→귀환, 기존 계정 저장·보상·구순서 이관, 모바일/컨트롤러 성능과 스토리 재미 수용은 미검증이다.
- 다음 담당자: QA/사용자. 새 서버에서 기존 진행 보존 및 다섯 에픽·사이드 퀘스트 상호작용을 확인한다.

## Git 릴리스

주석 태그 `v0.88.1`은 검증된 빌드 소스 커밋을 가리킨다. 게시 증거는 별도 문서 커밋으로 보존한다. 원본 빌드 기록의 `published: false`는 당시 빌드 시점 상태이며 현재 게시 상태는 이 기록을 따른다.
