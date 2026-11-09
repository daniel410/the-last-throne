# 물약·스킬 하단 배치 복원

2026-11-08 · TLT-028/052/057/084 · ENG/DES → QA · 0.88.2 · 미게시

사용자 첨부 화면과 “예전처럼 제일 아래” 지시에 따라 물약2개와 스킬5개를 하단 한 줄로 복원했다. 터치는 안전 영역 하단12px, 마우스/키보드는24px 여백을 유지한다. 좁은 화면에서 줄을 위로 올리던 터치780px/데스크톱1100px 분기를 제거하고, 좌우 조작부 공간320px을 남기도록 크기를 줄인다. TD 원본 아이콘·버튼, 단축키·수량·쿨다운·전투/저장 로직은 유지한다. 원인이 명확한 배치 복원으로 제작 스킬의 결함 수정 예외를 적용해 별도 리서치를 추가하지 않았다.

변경 파일: `src/client/K0Hud.luau`, 기존 UI 검사 하단 기대값, `VERSION`. 기존 모델·컨셉 삭제·첨부·미추적 작업은 제외했다.

검증: `rojo build default.project.json -o /tmp/tlt-hud-bottom.rbxlx` 성공. `run-in-roblox --place /tmp/tlt-hud-bottom.rbxlx --script docs/evidence/hud-bottom-20261108/layout-probe.luau`에서 실제 HUD 생성자와 PlayerGui/입력/화면 크기 대역으로 가로568×320, 740×360, 844×390, 1050×506, 첨부 비율1280×591, 1920×1080의 터치/비터치12조건에서 하단 위치·7버튼 한 줄·화면 경계·오른쪽 조작부 비겹침 **276검사 PASS**. [로그](layout-native.log).

기존 `tests/k0-resource-ui-native.luau`는21,757검사 후 변경 범위 이전의 `temporary feedback uses bold high-contrast text` 기대에서 실패했다. [실패 로그](native.log). 전체 검사 통과로 보고하지 않는다.

연결된 The Last Throne Battles Studio의 Edit `StarterPlayer.StarterPlayerScripts.Client.K0Hud`에도 해당 배치 변경만 적용했다. 실제 Play 렌더·Place 파일 저장·Roblox 게시를 뜻하지 않는다.

미검증: 휴대폰 터치/세로 화면·실제 렌더·게시 클라이언트·사용자 수용. 다음 담당 QA는 새 빌드 가로 화면에서 아이콘 터치와 기본 점프·이동 조작부를 확인한다. 좁은 화면은 하단 공간에 맞춰 버튼이 작아지므로 실기기 터치 수용은 별도다. 부모 티켓은 완료로 바꾸지 않는다. 릴리스 태그 없음.
