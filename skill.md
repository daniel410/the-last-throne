# The Last Throne 프로젝트 스킬

2026-10-28 · [실제 SKILL.md](skills/the-last-throne-production/SKILL.md) · [공통 지침](AGENTS.md) · [역할](agent.md)

이 파일은 사용자가 요청한 `skill.md` 진입점이다. 재사용 가능한 스킬 본문과 메타데이터는 `skills/the-last-throne-production/`에 둔다.

| 파일 | 용도 |
| --- | --- |
| [SKILL.md](skills/the-last-throne-production/SKILL.md) | 기존 결정 확인 → 역할별 제작 → 통합 → 증거 기반 완료 절차 |
| [agents/openai.yaml](skills/the-last-throne-production/agents/openai.yaml) | 스킬 표시명·설명·호출 예시 메타데이터 |
| [agent.md](agent.md) | 여섯 역할과 산출물·핸드오프 |
| [plan.md](plan.md) | 전체 제품·단계·품질·미결정 기준 |
| [backlog.md](backlog.md) | 작업ID·우선순위·의존·수용 조건·상태 |
| [Git·빌드·릴리스·LFS 규칙](docs/development-workflow.md) | 작업별 커밋/푸시·세 자리 빌드 버전·릴리스 태그·대용량 자산 저장 |

사용 예:

```text
skills/the-last-throne-production/SKILL.md를 읽고 이번 작업에 적용해 줘.
backlog.md의 다음 준비된 작업을 선택하고 기존 컨셉/스토리/성장/공유 자산을 확인해 줘.
문서는 한국어, 게임 문자열은 영어로 작성하고 검증 결과를 남겨 줘.
```

이 위치는 프로젝트에 포함된 스킬 원본이다. 현재 세션의 자동 스킬 목록에 설치됐다고 선언하지 않는다. 파일 경로를 명시하면 사용할 수 있고, 환경에서 정식 스킬 설치를 요청하면 해당 설정 범위에 맞춰 별도 등록한다. 현재 개인 전역 설정이나 보호된 `.agents/`·`.codex/`는 변경하지 않았다.

성장 검증(추가 패키지 불필요):

```bash
python3 scripts/simulate_story_progression.py --output /tmp/tlt-progression-check.json
```

이 명령은 승인된32구간 성장 예산의 정합성만 검사하며 실제 게임 지급·저장·재접속을 검증하지 않는다.

스킬 생성 도구의 정식 구조 검사 명령은 아래와 같다. 실행하는 Python에 **PyYAML이 필요**하며, 다른 컴퓨터에서는 설치된 `skill-creator/scripts/quick_validate.py` 경로로 바꾼다.

```bash
python3 /Users/daniel/.codex/skills/.system/skill-creator/scripts/quick_validate.py skills/the-last-throne-production
```

현재 기본/번들 Python에는 PyYAML이 없어 이 도구 실행은 의존성 오류로 끝났다. 대신 QA가 Ruby 표준 YAML 파서로 실제 frontmatter/메타데이터를 읽고 이름·필수 필드·허용키·길이·미완성 문구를 검사했다. 결과는 [QA 검증 기록](docs/production/qa-and-release-plan.md)에 있으며 정식 도구 성공과 구분한다. 패키지나 전역 환경은 변경하지 않았다.
