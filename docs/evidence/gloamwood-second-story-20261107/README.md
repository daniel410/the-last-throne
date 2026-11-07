# Gloamwood 에픽2 줄거리 개편 · 문서 검증

2026-11-07 · TLT-001/050/061~065/084 · PLAN/DES · 문서 반영 완료 / 게임 구현 후속

사용자의 “변경해줘” 지시로 Deepwood → Gloamwood → Frozen Vale → Ember Caldera → Haunted Graveyard 순서와 연결 사건을 문서에 반영했다. Gloamwood는 정찰대 구조와 북쪽 옛길 개방, Ember Caldera는 Veyr의 침공 계획·왕릉 진입로 확보를 맡는다.

## 산출물과 근거

- [줄거리 정본](../../production/five-epic-adventure-story-2026-10-30.md): 다섯 에픽 순서·각 지역 진입/이탈 동기·결말·감정선 개정.
- [상세 연결 시나리오](../../production/gloamwood-second-story-2026-11-07.md): GW-01~07 재사용, 기존 키에 대응한 영어 원고, 저장/성장/월드 분기 후속 범위.
- [비교 조사](../../research/2026-11-07-gloamwood-story-order.md): Diablo II 공식 Act I 문헌과 적용 원리·비용·실험 기준.
- README/AGENTS/결정표/plan/backlog/통합 제안서/게임 설계/시스템 제작 계획/지역별 상세안·Deepwood 영어 시나리오/NPC 리뷰에 현재 서사와 적용 상태 반영. 과거 증거와 번호는 명시적인 참고 이력으로 보존.

`CampaignContent`·`DeepwoodProgress`·`AdventureRules`·`Difficulty`·`CampaignAccess`·`CampaignWorld`·`LateEpicWorld`·`DeepwoodService`를 읽어 순서 변경의 의존을 확인했다. 현재 진행은 연속 정수이며, 지역 번호가 월드 생성·비살상 판정·난도에 연결되어 있다. 문서 변경을 런타임 재배치나 저장 호환 완료로 보고하지 않는다.

## 검증 결과

- `python3 /tmp/tlt-verify-story-order.py`: 문서 순서·통합 원고 일치·35개 기존 ID 참조·영어 원고 키/단계 대응·로컬 링크·런타임/보상/VERSION 무변경 검사 PASS. 검사 스크립트와 출력은 이 작업 세션의 임시 파일이며 저장소 테스트를 추가하지 않았다.
- `git diff --check -- <작업 문서>`: PASS.
- 실제 게임 테스트·Studio·빌드·Roblox 게시·실기기/대상 연령 관찰은 미실행. 런타임을 변경하지 않았으므로 XP 시뮬레이션이나 게임 회귀를 실행한 것으로 보고하지 않는다.

기존 사용자 작업인 Blender 변경·이미지 삭제·첨부/임시 파일은 보존하고 작업 커밋에서 제외한다. VERSION은0.80.0 그대로이며 릴리스 태그를 만들지 않는다. Git 커밋/푸시 결과는 최종 작업 보고에서 실제 해시와 함께 확인한다.

다음 담당: PLAN/DES의 성장·기존 진행 이관 계약 → ENG의 실제 순서/원고/지역 분기 구현 → QA의 기존 계정·네 클래스 솔로·협동/기기 검증. TLT-061~065/084의 구현 완료 상태는 변경하지 않았다.
