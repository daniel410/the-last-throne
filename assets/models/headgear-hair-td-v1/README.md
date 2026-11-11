# TD 파생 머리 장비 머리카락

TLT-028/032/057/084 · 2026-11-11 · 사용자 요청: 마법사 모자, 기사/드워프 헬멧, 엘프 후드에 TD 스타일의 실제3D 머리카락을 추가한다.

- MageHair: TD Arcanist의 뒤통수·목덜미·옆머리·앞머리5개 메시. 모자 계열별 황갈색/청회색/녹색/청색.
- ShortHair: TD Elf Archer의 짧은 머리3개에 TD Arcanist 앞머리2개를 결합. 후드 앞에서 보이도록 소켓을 보정한다.
- HelmetHair: TD Arcanist 뒤/옆머리3개에서 목덜미를 늘린 파생. TD 기사 원본은 닫힌 투구로 별도 머리 메시가 없어 눈을 가리는 앞머리는 제외한다. 기사·드워프가 공유한다.

각 하위 manifest에 TD 커밋·원본 경로·SHA256·선택 노드·파생 메시·Standard 색상 설정을 기록했다. TD 원본/운영 코드는 변경하지 않는다. `source-hair.glb`는 선택 메시, `prepared-hair.glb`와 Blender 파일은 정규화 파생이다. `runtime.rbxm`은 스크립트·PackageLink·텍스처 없는 흰색 tintable MeshPart3개다. 총15,748삼각형. 원본28종 방어구 메시·무기·방패는 그대로 사용한다.

승인 Model ID는 Mage111855007956452, Short133876699652217(revision2), Helmet74548520297829다. Mesh ID·소켓·144점 실측은 `native-import.json`, 승인 응답은 `uploaded.json`에 고정했다. 모자/후드/헬멧과 함께 머리에 용접하고, 착용 해제 때 원래 아바타 머리의 투명도를 복구한다. 소유권·능력치·피해 판정은 변경하지 않는다.

검증: `python3 tools/validate-headgear-hair.py`, [엔진·미술 증거](../../../docs/evidence/headgear-hair-20261111/README.md).
