# 사용자 지정 HP50·방어5 후속

2026-11-06 · TLT-027/029/041/052/084 · ENG → QA · 0.78.6 · 부모 티켓 In Progress.

사용자 후속 “HP 50, 방어력 5까지는 괜찮아”를 적용한다. 공격력 합계5%는 유지한다. Traveler's Hood 방어2·Coat HP20/방어2·Boots 방어1·Amber Charm HP30으로 무강화 기본 구성은 HP50·방어5다. 무료 Lv5 Veteran's Hood도 방어2로 맞춰 교체해도 같은 방어5를 유지한다. 강화·별도 획득 장비의 상한을 새로 만들지는 않는다.

영웅별 최초1회 보급·수량·소유권/안정ID·강화단계·가격·퀘스트 보상은 유지한다. 기존 보유품도 새 서버의 동일 정의로 계산한다. 앞선 비교 조사와 검증 범위를 재사용하며 사용자 지정 수치가0.78.5 시험값보다 우선한다.

검증: `lua tests/starter-gear-balance.spec.lua`45·`inventory.spec.lua`271·`skill-stat-preview.spec.lua`1392·`starter-potions-and-shop.spec.lua`316·`difficulty-enhancement.spec.lua`125, 합계2149검사 PASS. `git diff --check` 통과. 빌드 결과는 follow-up-build.json에 기록한다. 미게시·릴리스 태그 없음. 실제 전투/실기기 수용은 QA→사용자 후속이다. 기존 Blender 변경은 포함하지 않는다.

단일 빌드0.78.6 성공. 입력 커밋 `8bd8201b5e23109ad685bd21dbfa6e1b6f67480b`, SHA-256 `5a8886299f4b8391d8a3afd92645602820ca1d6195c9ce5082bad4b8f20bedb2`. 빌드 XML ItemCatalog와 검증한 소스가 바이트 일치한다. 이번 후속은 Studio 재실행 없이 순수 계산/빌드 검증이며 이전45개 Studio 통과는0.78.5의 증거다.
