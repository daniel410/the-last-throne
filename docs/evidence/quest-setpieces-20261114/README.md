# 대표 퀘스트 지형·지물·설비 연결 검증

2026-11-14 · TLT-061/062/063 · ENG/DES → QA

범위: [사양](../../production/quest-setpieces-2026-11-14.md)의 DW-01/FV-03/EC-01 세 장면. [비교 조사](../../research/2026-11-14-quest-terrain-props-and-items.md)를 기존 진행/저장 계약을 보존하는 범위에 적용한다. 사용자 미커밋 자산·TD 운영·경제는 변경하지 않는다.

## 검증 조건·결과

- `lua tests/campaign-expansion.spec.lua`:7,737검사 통과.35본편/12선택·82사건/246확장 단계 유지.
- `lua tests/story-fun.spec.lua`:1,761검사 통과. 기존 진행/정답/부분 저장 유지.
- `lua tests/story-prop-context.spec.lua`:4,129검사 통과.292단계 물품/63종의 기존 지정 계약 유지.
- `lua tests/campaign-context-review.spec.lua`:1,054검사·418저장 전이 통과.47개 원고와 런타임 계약 유지.
- 실제 Studio 고정 빌드 검사와 화면 확인은 빌드 후 이 문서에 결과를 기록한다. 아직 통과로 표시하지 않는다.

## 미검증·다음 담당

게시 클라이언트·실계정 DataStore/동시 서버·실기기/다인 성능·사용자 재미/미술 수용은 미검증이다. QA는 실제 카메라에서 수레 자국의 방향, 두 봉화의 응답, 기어 장착과 화물 상승을 구별할 수 있는지 확인한다. 부모 티켓/G5/G7 완료·Roblox 게시·릴리스 태그는 만들지 않는다.
