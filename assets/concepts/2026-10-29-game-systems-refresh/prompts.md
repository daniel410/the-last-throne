# 이미지 생성 프롬프트 기록

생성: built-in `image_gen`, 2026-10-29. 아래 각 항목은 요청 프롬프트이며 영어 게임 표면은 실제 문자열로 추출하지 않는다.

## 01 Battle HUD

참고: `../2026-10-27-shared-ui-v2/ui/03-battle-hud-corrected.png`.

> Use case: ui-mockup. New The Last Throne action RPG in-game battle HUD concept; image 1 is visual reference for blocky fantasy knight, Deepwood environment, silver gold blue visual system and third person camera. Knight with sword and shield fights a goblin in bright magical forest; clear red attack telegraph on ground. Top left knight portrait and one health bar, NO stamina or oath/mana bar for Knight. Bottom center show exactly two separate potion quick buttons LEFT of exactly five skill buttons; potion keys Z and C, skill keys 1 2 3 4 5, 5 skills as Lv40 unlocked example, no sixth skill or ultimate slot. Mobile attack/block/dodge buttons unobtrusively on right. English UI only. No text outside UI. Do not imply this is implemented.

## 02 Bag and equipment

참고: `../2026-10-27-equipment-storage-v2/01-bag-simple.png`.

> Use case: ui-mockup. New concept for The Last Throne, referencing image 1 for blue/silver/gold fantasy Roblox UI and knight identity; do not copy Korean text. Landscape widescreen. A readable inventory and character equipment screen, warm Dawnspire backdrop, knight with sword and shield and a blue fabric cloak as clothing. Clearly distinguish exactly eight equipment slots: weapon, offhand, head, body, hands, feet, accessory, accessory; NO relic slot or ninth equipment slot. Adjacent bag grid is a separate grid, tabs Equipment, Consumables, Materials, selection details and Equip button, clear substantial item cards. English en-US only. Counts are illustrative, no invented final stats. polished game UI mockup, not a screenshot of a real game.

수정 프롬프트:

> Use case: precise-object-edit. Edit this game UI concept image. Keep composition, exact eight equipment slots, knight, lighting, English UI, and all panels unchanged. Replace ONLY the unsupported fantasy weapon icons inside the middle BAG GRID (hammer, spears, maces, double-headed axes, ornate staff) with only approved equipment icons: small one-handed swords, simple hand axe, bows, wooden staffs, helmets, gloves, boots, shields, rings and blue/red potion bottles. The bag can include items for other classes. No hammer, spear, mace, double axe, fantasy wand, two-handed weapon, gun, or weapon group expansion. Do not change the character or slot icons.

## 03 Account storage

참고: `../2026-10-27-equipment-storage-v2/02-storage-simple.png`.

> Use case: ui-mockup. New concept for The Last Throne, image 1 is visual style reference only. Landscape wide polished Roblox fantasy UI, dark navy silver gold trim and blue controls, a warm royal town storage room behind. Account Storage interface: clearly separate BAG on left and ACCOUNT STORAGE on right, readable equipment and potion icons, one highlighted item, one STORE button, a subtle PENDING REWARDS badge. Both inventories are grids; do not show relic equipment. English only, no Korean, no fantasy gibberish. Numerical capacities are provisional and need not appear.

## 04 Hero stats

참고: `../2026-10-27-shared-ui-v2/ui/05-hero-stats.png`.

> Use case: ui-mockup. New The Last Throne character stats screen; image 1 provides only visual reference, preserving blocky knight identity and dark navy silver gold interface. Landscape polished game UI, knight with sword shield and blue cloak to left. A simple hero stats panel with exactly four clearly named attributes STR, DEX, INT, VIT, and separate HP and MP areas; Knight has no active MP required, no stamina, no invented derived statistics. Level advancement and 4 points per level are design direction but do not display numerical claims. English labels only, accessible whitespace and large buttons, visual concept not game screenshot.

수정:

> Use case: precise-object-edit. Keep this exact existing character stats UI, portrait, composition, English labels and four stat rows unchanged. Fix the eight equipment icons around knight: left column top to bottom sword, helmet, body armor, gloves; right column top to bottom shield, boots, accessory ring, accessory necklace. Replace the standalone cloak icon and lock icon only as needed. The blue cloak remains worn as clothing on knight but does not occupy its own equipment slot. Change bottom left button label RESET to PREVIEW. Keep the empty MP bar on this Knight visually disabled. No additional slot, no resource stamina.

후속 수정:

> Use case: precise-object-edit. Change ONLY the lowest icon in the LEFT vertical equipment column from armored boots to a pair of armored metal gloves. Leave the rest of image exactly as it is, including all seven other icons, hero, typography, and UI. Do not move, add, or remove slots.

## 05 Skill tree

참고: `../2026-10-27-shared-ui-v2/ui/06-skill-tree.png`.

> Use case: ui-mockup. New concept for The Last Throne skill tree using image 1 solely as reference for its visual language and blocky knight portrait. Clean spacious landscape screen in navy blue, silver and gold. Knight sword and shield, three distinct connected root branches with meaningful symbolic icons: Shield Bash, Whirlwind, Provoke. Show two advancement choices Steel Knight and Paladin, and progression milestones 20, 40, 60, 80, several unlock nodes between milestones; show optional selected skill detail panel. No LV15 ultimate. No stamina. English UI only; minimize words, no dense text, no invented statistics. It is a draft game design concept, no implementation claim.

수정:

> Use case: precise-object-edit. Revise this English fantasy skill tree concept. Keep the Knight portrait, Shield Bash / Whirlwind / Provoke root labels, Steel Knight and Paladin choices, navy silver gold style and selected skill detail panel. The present tree wrongly shows one skill only at each advancement: replace the central node graph with a visually believable dense branching tree with MULTIPLE SMALL DISTINCT UNLOCK NODES BETWEEN Lv.20 and Lv.40, between Lv.40 and Lv.60, and between Lv.60 and Lv.80 on each of three branches. Milestone labels remain 20, 40, 60, 80. For Lv.28 character, all nodes at Lv.40 or higher should look grayed/locked, Lv.20 and some interim nodes highlighted. At Lv.80 show only ONE ultimate node shared at the bottom, not 3 separate ultimates. Avoid showing made-up skill descriptions or exact skill counts. Render the prose label beneath Shield Bash as 'Front shield strike'.

## 06 Hero selection

참고: `../2026-10-27-shared-ui-v2/ui/07-hero-creation.png`.

> Use case: stylized-concept. New The Last Throne four-player class selection concept art using image 1 for art direction and established blocky Roblox heroic fantasy identities. Exactly four distinct playable characters on a shared polished selection screen: Knight with sword and shield, Dwarf with one hand axe, Elf Archer with a bow, Mage with wooden staff. Each distinct class silhouette; polished dark navy gold silver UI in recognizable Throne Defense visual language. Do not add priest, firearm equipped or giant two-handed weapons. Any cape is clothing, not an extra item slot. English labels Knight, Dwarf, Elf Archer, Mage, no other text, no numeric claims. Warm Dawnspire backdrop.
