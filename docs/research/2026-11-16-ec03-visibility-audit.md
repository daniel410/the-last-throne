# TLT-063 · 맵 카메라와 서사 공간 재검토

2026-11-16 확인. 기존 조사 재사용·공식 근거 재확인이며 새 규칙 도입 없음. PC/터치/패드, 1~4인+AI를 대상으로 하되 이번 실험은 Studio Edit 촬영에 한정한다.

- Diablo IV, 2022-03-29 개발 환경 아트: 게임 카메라의 가독성과 서사·재료·건축 의도를 함께 고려한다고 설명한다. 본문 확인. https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022
- WoW Retail Shadowlands, 2020-04-22 Revendreth 소개: 공식 검색 결과만 확인, 본문403. 지역 건축과 서사의 연결 참고를 유지하되 미열람 본문으로 세부 원리를 주장하지 않는다. https://worldofwarcraft.blizzard.com/en-us/news/23391567/aper%C3%A7u-de-shadowlands-revendreth-et-la-congr%C3%A9gation-des-venthyrs
- Lost Ark 글로벌, 2023-06-13 Elgacia: 공식 본문의 도시/정원/성산이 지역 서사와 이어지는 설명 확인. 실플레이·현행 수치 조사는 아니다. https://www.playlostark.com/en-gb/news/articles/elgacia-release-notes

해석: 지역 정체성은 소품 개수보다 플레이 카메라에서 읽히는 큰 공간과 사건의 연결로 평가한다. TLT EC-03의 광부/Orik 구출·광산 지지·Magma Worm 저지 사건은 유지한다. 타 게임 자산·진행·보상을 복제하지 않는다. 이번에는 카메라 고정/대기 전후에 지형이 다르게 보이는 문제를 재현해, 불안정한 캡처를 근거로 불필요한 재제작하는 위험을 줄였다.

대안: 장식 증량은 보류. 카메라 고정 후 연속 프레임 안정 확인을 채택한다. 비용은 촬영 대기와 증거 보존, 위험은 고정3초를 렌더 보증으로 오해하는 것. 최소 실험은 동일 geometry/조명에서 임시 카메라와 유지 카메라 A/B, 관측 지표는 실루엣·발밑 굴곡·카메라 위치/Focus/FOV다. 원래 충돌/동선과 개인 진행은 변경하지 않는다. 큰 채굴 공간 제작은 후속 맵/환경 아트 담당이며 미술·실제 플레이 수용 전까지 완료가 아니다.

[실험 증거](../evidence/ec03-visibility-audit-20261116/README.md)
