# 영웅 스킬 아이콘 등록

TLT-057/059 · 2026-11-15 · 상태: 생성/등록·소스 UI 검사 통과, 빌드/로딩 최종 확인 중

사용자의 개별 아이콘 제작 요청과 후속 두 지시(칼날을 휘지 않게 재생성, Skill Tree 컨셉을 다시 참조)를 적용한다. [승인 컨셉](../../../assets/concepts/2026-10-27-shared-ui-v2/ui/06-skill-tree.png)의 작은 노드 심볼을 원천으로 삼고, [곧은 검](../../../assets/concepts/2026-11-09-starter-weapons-only-v1/png/starter_knight_sword.png)을 검 포함24종에 추가 제공한다. 전체 메뉴·초상의 세부 묘사를 스킬 아이콘으로 복제하지 않는다. [참고 조사](../../research/2026-11-15-skill-icon-readability.md).

산출물 정본은 [자산 안내](../../../assets/ui/hero-skill-icons-v2/README.md), [프롬프트](../../../assets/ui/hero-skill-icons-v2/prompts.json), [등록/해시 목록](../../../assets/ui/hero-skill-icons-v2/manifest.json)이다. 런타임의 공통 스킬 ID 표와 렌더러를 스킬트리·상세·편성·전투 슬롯·전용 궁극기에 연결한다. 기존 TD 프레임과 스탯 도형, 영어 이름·키·잠금·쿨다운을 보존한다. 서버 권한·수치·성장·저장 변경은 없다.

## 검증 조건과 결과

- 정적/원본 **PASS**: `uv run --with pillow python tools/finalize-hero-skill-icons.py`. 현행128개 스킬 정의와128개 PNG/ID가 일치한다. 클래스별32개, 고유 PNG 해시/ID, 원본 바이트/참조 해시, 정사각 RGB/RGBA1024px 이상, 검 포함24개를 확인했다. PNG 총202,761,489bytes. [픽셀 검사](../../../assets/ui/hero-skill-icons-v2/pixel-report.json).
- Studio **PASS**: 실제 UI 생성 코드68모듈 컴파일, 총2,224검사. 128개 스킬 ID·잠금/쿨다운·빈 슬롯/영웅 변경, 8계열×3폭(1160/640/280)의 트리24조건, HUD28조건과 전용 궁극기 연결을 확인했다. [결과](native.json)·[정확한 검사 소스 해시](source-hashes.json)·[실행문 생성기](../../../tools/prepare-hero-skill-icon-review.py)·[검사 코드](../../../tests/hero-skill-icons-native.luau). 모의 Actor와 실제 Studio GUI를 사용했으며 실제 Player/서버 저장 시험은 아니다.
- 생성기 초기2회는 JSON 유니코드 이스케이프와 동적 `CampaignContent` 의존성 누락으로 실행되지 않았다. 실행문 생성기의 인코딩과 의존성 수집을 수정한 최종 실행만 위 PASS로 센다.
- 로딩: 실제 등록 ID를 보이는 ImageLabel에 연결해 `IsLoaded`와 `AssetFetchStatus`를 검사한다. 초기123/128표시, 나머지5개는 Studio `HttpError: NetFail`이었다. 재요청5개 모두 `Success`이나 현재 세션의 이미지 표시 캐시가 남아 최종 표시 확인은 진행 중이다. [초기 결과](loading.json). 부모 없는 `PreloadAsync`의 초기 시험300초 시간 초과는 성공으로 세지 않는다.
- 미술 대조: 승인 컨셉을 모든 생성 요청의 참조로 제공했다. 작은 노드의 굵은 심볼·발광 외곽·남색 여백을 적용했고 검신을 효과 곡선과 분리했다. 원본과40/64px [PNG 비교표](../../../assets/ui/hero-skill-icons-v2/gallery.html), Studio 네이티브 노드 표시를 육안으로 확인했다. 이것을 사용자 미술 수용으로 간주하지 않는다.
- 빌드 예약: 기존 계약을 유지하는128종 아이콘/공통 ID 렌더링 기능 묶음으로 `0.111.0`을 예약한다. 커밋 입력 고정 후 단일 빌드를 생성한다. Place 게시·릴리스 태그는 수행하지 않는다.

## 후속

디자인/QA가 게시된 실제 클라이언트와 모바일/패드 실기기에서 작은 기술 식별성·첫 로딩·장착 변경·사용자 미술 수용을 확인한다. 해당 단계와 부모 G4 게이트는 미검증으로 남긴다.
