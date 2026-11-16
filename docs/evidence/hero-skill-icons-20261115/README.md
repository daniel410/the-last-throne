# 영웅 스킬 아이콘 등록

TLT-057/059 · 2026-11-15 · 상태: 아이콘 생성/등록·Studio UI/로딩·단일 빌드 검증 통과. 게시/실기기/사용자 수용은 미검증.

사용자의 개별 아이콘 제작 요청과 후속 두 지시(칼날을 휘지 않게 재생성, Skill Tree 컨셉을 다시 참조)를 적용한다. [승인 컨셉](../../../assets/concepts/2026-10-27-shared-ui-v2/ui/06-skill-tree.png)의 작은 노드 심볼을 원천으로 삼고, [곧은 검](../../../assets/concepts/2026-11-09-starter-weapons-only-v1/png/starter_knight_sword.png)을 검 포함24종에 추가 제공한다. 전체 메뉴·초상의 세부 묘사를 스킬 아이콘으로 복제하지 않는다. [참고 조사](../../research/2026-11-15-skill-icon-readability.md).

산출물 정본은 [자산 안내](../../../assets/ui/hero-skill-icons-v2/README.md), [프롬프트](../../../assets/ui/hero-skill-icons-v2/prompts.json), [등록/해시 목록](../../../assets/ui/hero-skill-icons-v2/manifest.json)이다. 런타임의 공통 스킬 ID 표와 렌더러를 스킬트리·상세·편성·전투 슬롯·전용 궁극기에 연결한다. 기존 TD 프레임과 스탯 도형, 영어 이름·키·잠금·쿨다운을 보존한다. 서버 권한·수치·성장·저장 변경은 없다.

## 검증 조건과 결과

- 정적/원본 **PASS**: `uv run --with pillow python tools/finalize-hero-skill-icons.py`. 현행128개 스킬 정의와128개 PNG/ID가 일치한다. 클래스별32개, 고유 PNG 해시/ID, 원본 바이트/참조 해시, 정사각 RGB/RGBA1024px 이상, 검 포함24개를 확인했다. PNG 총202,761,489bytes. [픽셀 검사](../../../assets/ui/hero-skill-icons-v2/pixel-report.json).
- Studio **PASS**: 실제 UI 생성 코드68모듈 컴파일, 총2,224검사. 128개 스킬 ID·잠금/쿨다운·빈 슬롯/영웅 변경, 8계열×3폭(1160/640/280)의 트리24조건, HUD28조건과 전용 궁극기 연결을 확인했다. [결과](native.json)·[정확한 검사 소스 해시](source-hashes.json)·[실행문 생성기](../../../tools/prepare-hero-skill-icon-review.py)·[검사 코드](../../../tests/hero-skill-icons-native.luau). 모의 Actor와 실제 Studio GUI를 사용했으며 실제 Player/서버 저장 시험은 아니다.
- 생성기 초기2회는 [JSON 유니코드 이스케이프](native-first.json)와 [동적 `CampaignContent` 의존성 누락](native-second.json)으로 실행되지 않았다. 실행문 생성기의 인코딩과 의존성 수집을 수정한 최종 실행만 위 PASS로 센다.
- 로딩 **PASS 128/128**: 새 `TheLastThrone-0.111.0.rbxlx` 문서에서 빌드에 포함된 실제 `SkillGlyph`/스킬 정의를 직접 require하고 CoreGui의 보이는128개 ImageLabel을 생성했다. 모든 등록 ID가 `IsLoaded=true`, `AssetFetchStatus=Success`다. [최종 결과](loading.json). 이전 문서는 초기123/128표시, 나머지5개가 `HttpError: NetFail`이었으며 재요청 후 다운로드는 성공해도 표시되지 않았다. 동일 ID가 새 문서에서 모두 성공했으므로 세션 캐시 문제로 판단한다. [초기 실패](loading-initial.json)를 최종 통과와 구분한다. 부모 없는 `PreloadAsync`의 초기 시험300초 시간 초과는 성공으로 세지 않는다.
- 미술 대조: 승인 컨셉을 모든 생성 요청의 참조로 제공했다. 작은 노드의 굵은 심볼·발광 외곽·남색 여백을 적용했고 검신을 효과 곡선과 분리했다. 원본과40/64px [PNG 비교표](../../../assets/ui/hero-skill-icons-v2/gallery.html), Studio 네이티브 노드 표시를 육안으로 확인했다. 이것을 사용자 미술 수용으로 간주하지 않는다.
- 빌드 **PASS 0.111.0**: 기존 계약을 유지하는128종 아이콘/공통 ID 렌더링 기능 묶음으로 MINOR를 증가했다. 원격과 일치하는 입력 커밋 `d0dd44be209f8db79186c2b67cb7a8c133c16570`에서 `python3 tools/build-game.py --source d0dd44be209f8db79186c2b67cb7a8c133c16570 --record docs/evidence/hero-skill-icons-20261115/build.json`으로 단일 파일을 생성했다. [빌드 기록](build.json)·[무결성 결과](build-integrity.json): 19,785,482bytes, SHA256 `41358fb624bd20932ba40a9d31d0306a94b6b6244f6e0dc8e5ea505e9c195cd6`. 검사한68모듈 모두 빌드 소스와 SHA256이 일치한다. 새 Studio 문서에서 이 빌드를 열어 위128개 로딩을 확인했다. Place 게시·릴리스 태그는 수행하지 않았다.

## 후속

디자인/QA가 게시된 실제 클라이언트와 모바일/패드 실기기에서 작은 기술 식별성·첫 로딩·장착 변경·사용자 미술 수용을 확인한다. 해당 단계와 부모 G4 게이트는 미검증으로 남긴다.
