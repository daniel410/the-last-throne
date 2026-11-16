# 영웅별 스킬 아이콘

TLT-057/059 · 2026-11-15 · 제작 도구: 내장 `image_gen`

사용자 요청에 따라 [승인 Skill Tree 컨셉](../../concepts/2026-10-27-shared-ui-v2/ui/06-skill-tree.png)을 직접 참조해 네 영웅의 공통/조기 공통/8전직 계열 스킬을 개별 심볼로 제작한다. 후속 지시는 곧은 칼날과 컨셉 재참조다. 작은 원형 노드의 굵은 심볼·발광 대비·남색 여백을 기준으로 삼고, 검이 들어가는24종에는 [곧은 검 기준](../../concepts/2026-11-09-starter-weapons-only-v1/png/starter_knight_sword.png)을 추가 제공한다. 검신과 곡선 궤적을 분리한다.

기사 검/방패·도발, 드워프 도끼/총/폭탄/포격, 엘프 단발/연사/부채꼴/자연/번개, 마법사의 물/바람/비전/중력/화염/대지/냉기/번개를 실제 스킬 정의에 맞춰 구분한다. 성기사의 금빛 효과, 반복 타격·이동·보호·광역의 형상 차이를 반영한다. 외곽 프레임은 PNG에 중복 생성하지 않고 기존 TD 런타임 셸을 사용한다.

- `icons/`: 선택된 원본 PNG. 생성 후 복사하며 색·알파·윤곽을 코드로 수정하지 않는다.
- [프롬프트와 참조 해시](prompts.json): 스킬별 정의·그림 의미·직선 검 적용 여부·전체 생성 지시.
- [생성 원본 경로](generation.json), [등록/해시 목록](manifest.json), [Roblox ID](uploaded.json), `uploads/`의 실제 도구 응답.
- [PNG 비교표](gallery.html): 영웅/이름 필터와40/64px 비교. 실제 게임 화면 증거와 구분한다.
- [픽셀/원본 검사](pixel-report.json): 크기·모드·해시·바이트. 이미지를 읽기만 한다.

`src/shared/SkillIconAssets.luau`의 스킬 ID 등록표를 `SkillIcon`이 공통으로 사용한다. 스킬트리 노드/상세, 편성 슬롯, 전투1~5번과 전용 궁극기에 연결한다. 다른 영웅·편성 변경·빈 슬롯에서 이전 아이콘을 지우고 잠금/쿨다운은 기존 문구·키·남은 시간과 함께 표시한다. 스탯의 기존 기본 도형은 스킬 이미지로 바꾸지 않는다. 서버 스킬 정의/피해/해금/저장과 TD Experience는 변경하지 않는다.

정합성 검사 및 등록표 생성: `uv run --with pillow python tools/finalize-hero-skill-icons.py`. UI 실행문 생성: `python3 tools/prepare-hero-skill-icon-review.py`. 단계별 실제 결과와 미검증 범위는 [검증 기록](../../../docs/evidence/hero-skill-icons-20261115/README.md)에 둔다. 부모 TLT-057/059의 전체 G4 수용을 이 아이콘 작업만으로 완료 처리하지 않는다.
