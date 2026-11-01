# TLT-028/031/052/084 — TD 메뉴 리스트 원본 비교

확인일2026-11-01. 사용자 지정 TD 원본 UIController, UILayout, StatusWindowArt와 첨부 화면을 비교했다. TD는232px 패널,16px 패딩,20px 제목,52px 버튼,6px 간격,40px 왼쪽 아이콘과 gold/navy/blue 원본 미술을 사용한다. TLT의 기존168px 패널·아이콘 없는 작은 버튼과 차이가 있었다.

제안/적용: TD의 원본 atlas와 치수·영문 타이포그래피를 재사용하고 기존 TLT4개 기능을 같은 SUPPLIES/PROGRESS/MORE 제목 아래 배치한다. 위험은 이미지 로딩과 짧은 화면 넘침이며, 로딩 성공 뒤 배경 제거 및 짧은 화면 내부 스크롤로 처리한다. 최소 실험은 native45개 검사 및 Studio 실제 열기/설정 클릭/이미지 로딩 확인이다. 실제 모바일 터치·게임패드 수용은 별도다. 원본 해시와 결과는 [증거](../evidence/td-menu-list-20261101/README.md)를 따른다. TD 저장소는 읽기만 했다.
