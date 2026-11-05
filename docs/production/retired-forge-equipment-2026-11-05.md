# 구형 Lv10 Rare/Epic 장비24종 정리

2026-11-05 · TLT-028/029/041/043/044/052/057/084 · ENG/DES → QA · 0.75.3

사용자가 구형24종 전체 정리를 명시했다. Dawnforge4무기·Sentinel5방어구·장신구3종의 Rare/Epic을 활성 판매·상자 선택·신규 지급에서 제거했다. [24종 명세](../../assets/economy/retired-forge-equipment-2026-11-05.json). 최신 [160종 재산정안](equipment-recalculation-2026-11-05.md)과 아이콘160개는 삭제/변경하지 않았다. Common/Uncommon·Veteran Lv5·재료의 Rare 등급도 대상이 아니다.

물리적으로 정의를 지우면 기존 프로필의 아이템ID가 유실되어 전체 프로필 로드/구매 영수증/강화 권리까지 깨질 수 있다. 따라서 정의24개를 retired=true·cacheEligible=false의 **호환용 기록**으로 유지한다. 활성 장비는45→21종, 신규 Rare/Epic 대장간 SKU는24→0이다. 전체 저장 호환 정의63개는 유지한다. 장비를 보유한 사용자는 기존 가방/장착/창고/강화·회수/Gold되팔기를 계속 사용할 수 있고 강제로 회수/삭제하지 않는다. 새 판매 목록이나 상자 후보로는 표시하지 않는다.

서버 차단은 상점별 UI에만 의존하지 않는다. EconomyCatalog.allowed는 폐기 정의의 신규 offer를 Gold/Diamonds·모든 상점 경로에서 거부한다. EquipmentTransactions는 캐시 플래그가 잘못 true가 되더라도 retired 정의 선택을 거부하며 일반 grant도 차단한다. 실패 시 잔액/상자/리비전/영수증은 변경하지 않는다. 이미 확정된 구매 요청의 재시도는 기존 멱등 결과로 반환한다.

**Lv10 상자 후속 제약:** 기존/새로 적립되는 Lv10 상자와 미수령 권리는 보존한다. 현재 교환 가능한 Lv10 장비가 없어 대장간에 영어 보관 안내를 표시한다. 최신160종은 아직 등록·MP/세트/효과·상점 매핑 전이므로 이 변경에서 대체 장비로 조기 활성화하지 않았다. 상자 수량을 삭제하거나 임의 재화로 환산하지 않는다. 임무 보상/상자 적립률/XP/Gold 정본도 변경하지 않았다. 따라서 **교환 공백이 남으며**, 새 Rare40종 연결이 PLAN/ENG의 우선 후속이다. 과거 상자의 즉시 교환 가능성을 유지했다고 보고하지 않는다.

| ID | 이름 | 등급 | Lv | 클래스 | 부위 |
| --- | --- | --- | ---: | --- | --- |
| `knight_weapon_forged` | Dawnforge Sword | Rare | 10 | knight | weapon |
| `knight_weapon_forged_epic` | Epic Dawnforge Sword | Epic | 10 | knight | weapon |
| `elf_weapon_forged` | Dawnforge Bow | Rare | 10 | elf | weapon |
| `elf_weapon_forged_epic` | Epic Dawnforge Bow | Epic | 10 | elf | weapon |
| `dwarf_weapon_forged` | Dawnforge Axe | Rare | 10 | dwarf | weapon |
| `dwarf_weapon_forged_epic` | Epic Dawnforge Axe | Epic | 10 | dwarf | weapon |
| `mage_weapon_forged` | Dawnforge Staff | Rare | 10 | mage | weapon |
| `mage_weapon_forged_epic` | Epic Dawnforge Staff | Epic | 10 | mage | weapon |
| `sentinel_shield` | Sentinel Shield | Rare | 10 | knight | offhand |
| `sentinel_shield_epic` | Epic Sentinel Shield | Epic | 10 | knight | offhand |
| `sentinel_helm` | Sentinel Helm | Rare | 10 | shared | head |
| `sentinel_helm_epic` | Epic Sentinel Helm | Epic | 10 | shared | head |
| `sentinel_mail` | Sentinel Mail | Rare | 10 | shared | body |
| `sentinel_mail_epic` | Epic Sentinel Mail | Epic | 10 | shared | body |
| `sentinel_gauntlets` | Sentinel Gauntlets | Rare | 10 | shared | hands |
| `sentinel_gauntlets_epic` | Epic Sentinel Gauntlets | Epic | 10 | shared | hands |
| `sentinel_boots` | Sentinel Boots | Rare | 10 | shared | feet |
| `sentinel_boots_epic` | Epic Sentinel Boots | Epic | 10 | shared | feet |
| `ruby_ring` | Ruby Ring | Rare | 10 | shared | accessory |
| `ruby_ring_epic` | Epic Ruby Ring | Epic | 10 | shared | accessory |
| `guardian_charm` | Guardian Charm | Rare | 10 | shared | accessory |
| `guardian_charm_epic` | Epic Guardian Charm | Epic | 10 | shared | accessory |
| `storm_pendant` | Storm Pendant | Rare | 10 | shared | accessory |
| `storm_pendant_epic` | Epic Storm Pendant | Epic | 10 | shared | accessory |

검증은 [명령과 결과](../evidence/retired-forge-equipment-20261105/verification.txt), 고정 소스 빌드는 [build.json](../evidence/retired-forge-equipment-20261105/build.json)에 기록한다. 신규 테스트는24종 전체의 구SKU 제거/가짜 Gold·Diamonds offer 거부/상자 조작·지급 거부/무변경 실패/기존 +9 저장·창고·장착/되팔기/퇴역 후 구매 영수증 재시도를 포함한다. 기존 장비·상점·인벤토리·강화 회귀와5모듈 Luau 컴파일도 검사한다. Studio/GUI/실제 계정/DataStore/게시 클라이언트·실기기는 미검증이며 Roblox 게시/릴리스 태그는 없다. 부모 구현/경제/신규160종 티켓은 완료 처리하지 않는다.
