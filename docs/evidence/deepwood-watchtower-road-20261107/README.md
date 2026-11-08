# Deepwood 스토리4 중앙 도로 충돌 수정 · 0.81.2

2026-11-07 · TLT-050/057/061/084 · ENG/QA · 로컬 수정·Studio 소스 적용 / 미게시

사용자가 스토리4 페이즈3의 길 위에서 이동 불가를 보고했다. 정확한 좌표·입력 상태는 확보하지 못했으므로 제보 현상의 원인을 확정하지 않는다. 조사 중 별도로 재현한 중앙 도로의 보이지 않는 기둥 충돌을 수정한다. 원인이 명확한 결함 수정으로 별도 기능 조사·전투/성장/보상 조정은 수행하지 않는다.

## 원인과 수정

`EpicWorldArt`는 옛 `WatchtowerPillar` 4개를 숨겼지만 충돌과 쿼리는 유지했다. 북동쪽 기둥 `(521,51,-1886)`은 중앙 도로를 가로막고, 서쪽→동쪽 장치 직선 접근에도 두 기둥이 겹쳤다. 길찾기는 우회 경로가 있어 Success였으므로 길찾기 성공만으로 통과를 판단할 수 없었다.

`DeepwoodWorld`는 새 기둥을 비충돌/비쿼리로 생성하고, 기존 월드 재사용 시에도 해당 이름의 기둥4개만 정리한다. 지형 바닥·다른 기둥/나무/경계·감옥·목표 위치·영웅/저장/보상은 변경하지 않는다.

## 검증

- 기존0.81.1에서 새 회귀 검사 실행: `retired pillar cannot stop walking or dodge` 실패. [baseline.log](baseline.log).
- 페이즈3 실제 5단계 직선 동선 사전 조사: 모든 경로 Success, 몸체 겹침/바닥 이상0. [phase3-audit.log](phase3-audit.log). 이 결과는 제보의 정확한 재현과 구분한다.
- 수정 임시 Place의 `tests/deepwood-watchtower-road-native.luau`: **573 PASS**, 중앙 도로 폭4/높이5 Blockcast·페이즈3 다섯 단계의 몸체 겹침0/정상 바닥/점프 없는 경로·옛 월드 기둥 복원 후 재사용 정리·스폰 보존 검사. [native-initial.log](native-initial.log). 프로세스는 종료1이며 자산 타입 경고와 Roblox TexturePack HTTP429가 함께 출력됐다. Luau 검사 자체는 `pass=true`; 도구 종료 성공으로 기록하지 않는다.
- `lua tests/deepwood-progress.spec.lua`: **570 PASS**. `lua tests/story-respawn.spec.lua`: **28 PASS**.
- 현재 TLT Studio `70829337938054` Edit: 기존 소스가 HEAD와 같음을 확인하고 `DeepwoodWorld`1개 문법 검사/동기화. 원본은 `ServerStorage.TLTBeforeWatchtowerRoad20261107`에 보존. 실행 중 월드나 라이브 저장·게시는 변경하지 않음.
- `git diff --check`: PASS. 버전 MICRO 증가0.81.2.

## 빌드·인계

검증 소스 커밋 후 `python3 tools/build-game.py --source HEAD --record docs/evidence/deepwood-watchtower-road-20261107/build.json`으로 단일 고정 빌드를 만든다. 고정 산출물 검사/해시·종료 결과는 후속 마감 기록에 추가한다. 릴리스 태그·Place 게시는 수행하지 않는다.

다음 QA/사용자는 실제 제보 위치에서 이동/회피·재접속을 확인해야 한다. 입력 잠금이나 다른 위치의 충돌까지 해결했다고 선언하지 않는다. 실제 계정/기기/4인+AI 검증은 미실행, 부모 티켓 In Progress 유지.

## 고정 빌드 마감

- 소스 `a44bceca5ae231c7384511ab0090c2681c689486` / 버전0.81.2의 단일 파일 빌드 성공. [build.json](build.json)의 소스·산출물 SHA256을 다시 대조했다. 입력 LFS 포인터0개이며 이번 작업의 자산 변경/전송 없음.
- 해당 고정 산출물에서 동일 native 회귀 재실행: **573 PASS / 프로세스 종료0**. [native-final.log](native-final.log). 기존 자산203785492 타입 경고1개는 검증 실패와 구분한다. 최초 임시 실행의 HTTP429/종료1도 위에 그대로 보존한다.
- 구현 커밋을 `origin/main`에 푸시하고 `git ls-remote origin refs/heads/main`으로 일치를 확인했다. 빌드 기록은 후속 증거 커밋으로 저장한다. Roblox 미게시·릴리스 태그 없음.
