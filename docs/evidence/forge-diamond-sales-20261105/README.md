# 대장간 Diamonds 판매 검증

2026-11-05 · TLT-028/029/041/043/044/046/052/057/084 · 0.75.0 · ENG/DES → QA

[변경과12종가격표](../../production/forge-diamond-sales-2026-11-05.md). Rare12종과신규Epic12종을Diamonds로판매하고Common/Uncommon Gold판매는유지했다. 구Rare Gold SKU는중단하되기존51품목/영수증/보유권은보존한다. 신규Epic을무료상자에자동추가하지않는다. 40계열Epic세트/MP제안전체구현과구분한다.

검증: verification.json의8개테스트PASS. 상점430검사는기존/신규SKU전구매·서버가격/통화·다른잔액보존·재요청·판매·잘못된Gold offer(상점미지정포함)·Gold로Diamond대체불가·만석무차감·기존상자Rare선택보존/신규Epic거부를포함한다. 구카탈로그51개정의전체를Git기준과재귀비교해동일PASS. 변경Luau6개컴파일PASS. 상위등급모드정책·수치·아이콘Python4검사도PASS.

실제GUI/터치/패드·실계정DataStore/게시클라이언트·경제밸런스는미검증이다. 연결된기존RPG/TD Studio를수정하거나실제구매하지않았다. 신규등록/형태별아이콘은코드연결이며새40이미지업로드/장착3D모델이아니다. 게임게시는수행하지않으며실제릴리스태그도없다. 고정소스단일빌드결과는build.json에기록한다. 다음담당은QA/DES의실제대장간/가방/강화UI검수와PLAN의가격/성장검증이다.
