# 에픽5~8 지역·몬스터 컨셉 v1

> **2026-10-30 사용자 지시 · 보류:** 기존 에픽5~8의 줄거리·개별 스토리·몬스터·컨셉 확장은 중단한다. 기존 자료는 참고안으로 보존한다. 에픽1~4는 수정하지 않는다. [어두운 숲·거미 여왕 후보](../../../docs/production/dark-forest-epic-candidate-2026-10-30.md)는 번호/채택 미정의 별도 제안이다.

2026-10-30 · **TLT-065/late-epic-concepts-20261030** · DES/ART · 신규 컨셉 제작, 사용자 검토 전

[전체 갤러리](index.html) · [파일·원본·해시](catalog.json) · [스토리/몬스터 설계](../../../docs/epics-05-08-story-design.md)

사용자가 새 에픽들의 지역 컨셉과 해당 몬스터 컨셉 이미지를 요청했다. 지역4장과 각8종의 몬스터 보드4장, 총8장의 PNG를 제작했다. 일반20·필수 보스8·선택 보스4의32교전 설계가 보드에 모두 등장한다.32개별 PNG·새3D모델32개·RPG AI 완성이 아니라 **8종씩 묶은 시각 컨셉**이다.

## 이미지와 사용한 프롬프트

| 에픽 | 지역 컨셉 | 몬스터/보스 컨셉 | 프롬프트 |
| --- | --- | --- | --- |
| 5 · Aether Spire | [부유 학술도시](world/epic-05-aether-spire.png) | [AS8종](monsters/epic-05-roster.png) | [지역](prompts/world-05.txt) · [몬스터](prompts/monsters-05.txt) |
| 6 · The Divided Citadel | [비상 통치 중인 Dawnspire](world/epic-06-divided-citadel.png) | [DC8종](monsters/epic-06-roster.png) | [지역](prompts/world-06.txt) · [몬스터](prompts/monsters-06.txt) |
| 7 · The March of Five Banners | [연합 원정·다리와 우회로](world/epic-07-five-banners.png) | [FB8종·보정본](monsters/epic-07-roster.png) | [지역](prompts/world-07.txt) · [몬스터](prompts/monsters-07.txt) · [Signal Binder 보정](prompts/monsters-07-revision-01.txt) |
| 8 · The Fractured Crown | [겹쳐진 지역과 최종 왕좌](world/epic-08-fractured-crown.png) | [FC8종](monsters/epic-08-roster.png) | [지역](prompts/world-08.txt) · [몬스터](prompts/monsters-08.txt) |

지역은1672×941px 4장, 보드는 AS/FB/FC1774×887px·DC1536×1024px다. 내장 도구의 실제 출력 크기를 그대로 보존했고 확대/리사이즈로 새 해상도를 주장하지 않았다. PNG 바이트·크기·SHA256은 catalog.json에 있다.

## 생성 방식과 참고 원본

**built-in `image_gen`**을 사용했다. 신규 생성8회와FB Signal Binder 셀의 보정1회, 총9회다. CLI/API 우회·별도 API 키를 사용하지 않았다. 모든 최종 선정본을 프로젝트 폴더에 복사했고 기본 생성 경로의 원본은 보존했다. 폐기한FB 첫 결과는 기본 생성 위치에 남기며 프로젝트 갤러리는 보정본만 참조한다. 최종 프롬프트 집합과 보정 원문을 위9개 파일에 보존한다.

입력은 기존 Dawnspire/Deepwood 지역 컨셉2장, TD forest/snow/volcano/cemetery 몬스터 카탈로그4장, TD 기사 계열 보드1장, Inquisitor 컨셉1장이다.8개 입력 이미지를 도구로 직접 열람한 뒤 스타일/형상 참고로 전달했다. 원본 경로·해시는 catalog.json의 source_references와 [TD 레지스트리](../../shared/td-asset-registry.json)에 연결한다. 기존 이미지는 편집 대상으로 바꾸지 않았다. 새 그림의 인물·표정·장식은 사용자 승인 정본이 아니라 제안이다.

Dawnspire의 아이보리 석조·청금 배너·보라 포탈과 TD 블록형 캐릭터/갑옷을 유지하는 방향이다. 왕도 인간 경비·루칸은 인간으로, The First Warden은 실제Lyra가 아닌 빈 갑옷 수호체로, The Eternal King은 해골 리치가 아닌 왕의 인격이 읽히는 형태로 구분했다. 에픽7은 다섯 깃발과 신호 중계 마차를 표현하며 중앙 왕좌에 네 핵을 반납하는 그림으로 취급하지 않는다.

## 시각 검토와 보정

8장 모두 도구 결과의 픽셀을 직접 확인했다. 지역의 제목/주요 분위기·연결 경로와 보드의4열×2행·32ID/영문명·전신 구별을 검토했다. 괴물/인간·장치·이름 있는 보스가 서로 다른 형태로 나타나는 것을 확인했다. 생성 글자를 OCR로 게임 원문에 추출하거나 최종 UI로 재사용하지 않는다.

FB 첫 보드에서 Signal Binder가 지정한 Volcano Shaman 대신 Lich를 닮았다. 해당 셀만 화산 주술사의 가면/깃털 망토와 신호 도장 지팡이로 보정하고 다른7종·표시명·배치를 보존하는 수정을 요청했다. 보정 결과를 열람해 셀의 시각 원형이 바뀌고8ID/배치가 유지됨을 확인했다. 다른 셀의 바이트 단위 동일성을 주장하는 픽셀 차분 검사는 하지 않았다.

얼굴/무기 소켓·뒷면·발 접지·정확한 장식/리본 수·늑대/골렘의 비례·몬스터 공격 가능 높이는 이 정면 컨셉만으로 확정하지 않는다. 영문 이름표는 검토 가독성용이며 장치의 작은 룬/스크롤 무늬는 최종 문자나 설정으로 읽지 않는다. 지역 그림의 배경 포탈·연결 신호·수정은 분위기 표현이고 실제 월드 수치/새 핵/게임 오브젝트 수를 확정하지 않는다.

## 검증·마감·다음 담당

- 선정 PNG8개 존재/PNG 서명·실제 크기·바이트·SHA256, 프롬프트9개와 입력8개 현재 해시, catalog의32교전ID와 설계 JSON을 대조한다.
- HTML의 이미지/다운로드/프롬프트·문서 상대링크 존재와 `git diff --check`를 확인한다. HTML은 로컬 검토 갤러리이며 웹 게시를 하지 않는다.
- `.gitattributes`에 따라8PNG를 Git LFS로 스테이징하고 포인터·업로드·원격 커밋을 확인한다. JSON/Markdown/HTML/프롬프트는 일반 Git이다.
- 게임 소스·보상 정본·기존 승인 UI9장·VERSION은 이번 작업에서 변경하지 않는다. 빌드/게시/릴리스 태그를 만들지 않으며 컨셉 작성으로 부모 TLT-065~070을 완료하지 않는다.

다음 담당은 사용자/디렉터의 시각 방향 검토, ART의 전후측면·정확한 원본 부품·RPG 리그/권한 감사, DES의 실제 블록아웃/가독성, ENG/QA의 전투·기기·성능 수용이다. 기존 원본 파일의 라이선스/Experience별 메시 권한을 이번 생성으로 새로 검증했다고 보고하지 않는다.


### 실제 정적 검사 결과

`python3 /private/tmp/tlt-validate-concepts.py` 종료0.선정PNG8개의 서명/모든 청크CRC·바이트/크기·원본 복사/결과SHA256이 일치했고,프롬프트9개·참고 이미지8개 해시와32고유 교전ID 매핑을 확인했다. 총PNG23,268,516바이트다. [구조화 검사 결과](validation.json)에 최종 문서/갤러리 링크·앵커 수를 보존한다. `git diff --check` 종료0. VERSION·보상 정본·후반 설계JSON·기존 승인UI 기록4파일은HEAD 대비 바이트 불변이다. PNG8개를LFS 포인터로 선별 스테이징하고 푸시 결과/원격 커밋을 최종 보고한다. 로컬 갤러리는 파일 패널 열기를 요청했으나 도구가queued로 응답해 실제 브라우저 렌더/사용성 검증으로 기록하지 않는다.

### 원격 마감 상태

컨셉 산출물 커밋은 `bfe103e`다. `git push origin main`은 SSH `Permission denied (publickey)`로 실패했고,기존 키를 등록한 같은 셸의 재시도에서는 LFS의 `Unable to verify locks`도 관찰됐다. 훅/잠금 검증을 끄지 않았으며 원격의 API 지원 여부를 오류 문구만으로 확정하지 않는다. 같은 저장소에 기존 HTTPS 자격 증명으로도 시도했으나 자격 증명이 없어 실패했다. **원격 커밋 반영·8PNG LFS 전송 성공은 확인하지 못했다.** 로컬 이미지/프롬프트·LFS 객체와 커밋은 보존했다. 다음 담당은 GitHub 인증이 정상인 세션에서 `git push origin main`을 재실행하고8개 LFS 업로드/원격 커밋을 확인한다. 게임 빌드/게시/릴리스와 무관한 Git 마감 잔여다.
