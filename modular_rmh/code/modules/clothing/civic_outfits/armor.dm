//----------------- CIVIC OUTFITS: ARMOR.DM ---------------------

/obj/item/clothing/suit
	item_weight = 500 GRAMS
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/suit/roguetown/armor/guildguard
	item_weight = 8 KILOGRAMS
	// Looks like /obj/item/clothing/armor/cuirass: free Vanderlin art in place of the licensed sprite
	icon = /obj/item/clothing/armor/cuirass::icon
	mob_overlay_icon = /obj/item/clothing/armor/cuirass::mob_overlay_icon
	icon_state = /obj/item/clothing/armor/cuirass::icon_state
	item_state = /obj/item/clothing/armor/cuirass::item_state
	sleeved = /obj/item/clothing/armor/cuirass::sleeved
	sleevetype = /obj/item/clothing/armor/cuirass::sleevetype
	ignore_sleeves_code = /obj/item/clothing/armor/cuirass::ignore_sleeves_code
	nodismemsleeves = /obj/item/clothing/armor/cuirass::nodismemsleeves
	color = /obj/item/clothing/armor/cuirass::color
	detail_tag = /obj/item/clothing/armor/cuirass::detail_tag
	detail_color = /obj/item/clothing/armor/cuirass::detail_color
	uses_lord_coloring = /obj/item/clothing/armor/cuirass::uses_lord_coloring
	boobed = /obj/item/clothing/armor/cuirass::boobed
	name = "guild guard cuirass"
	desc = "A heavy, meticulously maintained suit of armor bearing the sigils of the Waterdeep Merchant’s Guild. Worn by guild guards sworn to protect caravans, vaults, and trade halls alike."
	slot_flags = ITEM_SLOT_ARMOR
	blocksound = PLATEHIT
	blocksound = CHAINHIT
	drop_sound = 'sound/foley/dropsound/chain_drop.ogg'
	pickup_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	equip_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	body_parts_covered = CHEST|GROIN|VITALS
	armor_type = /datum/armor/rmh/armor/guild_guard
	prevent_crits = list(BCLASS_CUT, BCLASS_STAB, BCLASS_CHOP, BCLASS_BLUNT, BCLASS_TWIST)
	max_integrity = 250
	armor_class = AC_MEDIUM
	clothing_flags = CANT_SLEEP_IN
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	smeltresult = /obj/item/ingot/steel
	melting_material = /datum/material/steel
	melt_amount = 100
	sewrepair = null

/obj/item/clothing/suit/roguetown/armor/leather/duchess
	// Looks like /obj/item/clothing/shirt/dress/gown: free Vanderlin art in place of the licensed sprite
	icon = /obj/item/clothing/shirt/dress/gown::icon
	mob_overlay_icon = /obj/item/clothing/shirt/dress/gown::mob_overlay_icon
	icon_state = /obj/item/clothing/shirt/dress/gown::icon_state
	item_state = /obj/item/clothing/shirt/dress/gown::item_state
	sleeved = /obj/item/clothing/shirt/dress/gown::sleeved
	sleevetype = /obj/item/clothing/shirt/dress/gown::sleevetype
	ignore_sleeves_code = /obj/item/clothing/shirt/dress/gown::ignore_sleeves_code
	nodismemsleeves = /obj/item/clothing/shirt/dress/gown::nodismemsleeves
	color = /obj/item/clothing/shirt/dress/gown::color
	detail_tag = /obj/item/clothing/shirt/dress/gown::detail_tag
	detail_color = /obj/item/clothing/shirt/dress/gown::detail_color
	uses_lord_coloring = /obj/item/clothing/shirt/dress/gown::uses_lord_coloring
	boobed = /obj/item/clothing/shirt/dress/gown::boobed
	name = "duchess' court gown"
	desc = "An elegant gown of noble cut and ancient fashion."
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_ARMOR //ugly hack to make it render over the head
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|VITALS

/obj/item/clothing/suit/roguetown/armor/leather/marshall
	item_weight = 3 KILOGRAMS
	// Looks like /obj/item/clothing/armor/gambeson/hand: free Vanderlin art in place of the licensed sprite
	icon = /obj/item/clothing/armor/gambeson/hand::icon
	mob_overlay_icon = /obj/item/clothing/armor/gambeson/hand::mob_overlay_icon
	icon_state = /obj/item/clothing/armor/gambeson/hand::icon_state
	item_state = /obj/item/clothing/armor/gambeson/hand::item_state
	sleeved = /obj/item/clothing/armor/gambeson/hand::sleeved
	sleevetype = /obj/item/clothing/armor/gambeson/hand::sleevetype
	ignore_sleeves_code = /obj/item/clothing/armor/gambeson/hand::ignore_sleeves_code
	nodismemsleeves = /obj/item/clothing/armor/gambeson/hand::nodismemsleeves
	color = /obj/item/clothing/armor/gambeson/hand::color
	detail_tag = /obj/item/clothing/armor/gambeson/hand::detail_tag
	detail_color = /obj/item/clothing/armor/gambeson/hand::detail_color
	uses_lord_coloring = /obj/item/clothing/armor/gambeson/hand::uses_lord_coloring
	boobed = /obj/item/clothing/armor/gambeson/hand::boobed
	name = "marshall uniform"
	desc = "A formal uniform once worn by a city watch captain, now repurposed for a Burgmeister."
	armor_type = /datum/armor/rmh/armor/marshall
	prevent_crits = list(BCLASS_CUT, BCLASS_STAB, BCLASS_BLUNT)
	blocksound = SOFTHIT
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT|ITEM_SLOT_BELT
	blade_dulling = DULLING_BASHCHOP
	body_parts_covered = CHEST|VITALS|ARMS
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = /datum/attribute/skill/craft/tanning/patching
	armor_class = AC_LIGHT
	salvage_result = /obj/item/natural/hide/cured

/obj/item/clothing/suit/roguetown/armor/leather/burgmeister
	// Looks like /obj/item/clothing/shirt/tunic/noblecoat: free Vanderlin art in place of the licensed sprite
	icon = /obj/item/clothing/shirt/tunic/noblecoat::icon
	mob_overlay_icon = /obj/item/clothing/shirt/tunic/noblecoat::mob_overlay_icon
	icon_state = /obj/item/clothing/shirt/tunic/noblecoat::icon_state
	item_state = /obj/item/clothing/shirt/tunic/noblecoat::item_state
	sleeved = /obj/item/clothing/shirt/tunic/noblecoat::sleeved
	sleevetype = /obj/item/clothing/shirt/tunic/noblecoat::sleevetype
	ignore_sleeves_code = /obj/item/clothing/shirt/tunic/noblecoat::ignore_sleeves_code
	nodismemsleeves = /obj/item/clothing/shirt/tunic/noblecoat::nodismemsleeves
	color = /obj/item/clothing/shirt/tunic/noblecoat::color
	detail_tag = /obj/item/clothing/shirt/tunic/noblecoat::detail_tag
	detail_color = /obj/item/clothing/shirt/tunic/noblecoat::detail_color
	uses_lord_coloring = /obj/item/clothing/shirt/tunic/noblecoat::uses_lord_coloring
	boobed = /obj/item/clothing/shirt/tunic/noblecoat::boobed
	name = "burgmeister's civic vestments"
	desc = "Soft yet dignified garments worn by the elected Burgmeister."
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_ARMOR //ugly hack to make it render over the head

/obj/item/clothing/suit/roguetown/armor/leather/adjutant
	// Looks like /obj/item/clothing/armor/leather/jacket/gatemaster_jacket: free Vanderlin art in place of the licensed sprite
	icon = /obj/item/clothing/armor/leather/jacket/gatemaster_jacket::icon
	mob_overlay_icon = /obj/item/clothing/armor/leather/jacket/gatemaster_jacket::mob_overlay_icon
	icon_state = /obj/item/clothing/armor/leather/jacket/gatemaster_jacket::icon_state
	item_state = /obj/item/clothing/armor/leather/jacket/gatemaster_jacket::item_state
	sleeved = /obj/item/clothing/armor/leather/jacket/gatemaster_jacket::sleeved
	sleevetype = /obj/item/clothing/armor/leather/jacket/gatemaster_jacket::sleevetype
	ignore_sleeves_code = /obj/item/clothing/armor/leather/jacket/gatemaster_jacket::ignore_sleeves_code
	nodismemsleeves = /obj/item/clothing/armor/leather/jacket/gatemaster_jacket::nodismemsleeves
	color = /obj/item/clothing/armor/leather/jacket/gatemaster_jacket::color
	detail_tag = /obj/item/clothing/armor/leather/jacket/gatemaster_jacket::detail_tag
	detail_color = /obj/item/clothing/armor/leather/jacket/gatemaster_jacket::detail_color
	uses_lord_coloring = /obj/item/clothing/armor/leather/jacket/gatemaster_jacket::uses_lord_coloring
	boobed = /obj/item/clothing/armor/leather/jacket/gatemaster_jacket::boobed
	name = "councilor's uniform"
	desc = "A reinforced uniform worn by a former city watchman now serving as a councilor."
	body_parts_covered = CHEST|GROIN|VITALS|LEGS|ARMS
	slot_flags = ITEM_SLOT_ARMOR

/obj/item/clothing/suit/roguetown/armor/leather/heiress
	// Looks like /obj/item/clothing/shirt/dress/gown/summergown: free Vanderlin art in place of the licensed sprite
	icon = /obj/item/clothing/shirt/dress/gown/summergown::icon
	mob_overlay_icon = /obj/item/clothing/shirt/dress/gown/summergown::mob_overlay_icon
	icon_state = /obj/item/clothing/shirt/dress/gown/summergown::icon_state
	item_state = /obj/item/clothing/shirt/dress/gown/summergown::item_state
	sleeved = /obj/item/clothing/shirt/dress/gown/summergown::sleeved
	sleevetype = /obj/item/clothing/shirt/dress/gown/summergown::sleevetype
	ignore_sleeves_code = /obj/item/clothing/shirt/dress/gown/summergown::ignore_sleeves_code
	nodismemsleeves = /obj/item/clothing/shirt/dress/gown/summergown::nodismemsleeves
	color = /obj/item/clothing/shirt/dress/gown/summergown::color
	detail_tag = /obj/item/clothing/shirt/dress/gown/summergown::detail_tag
	detail_color = /obj/item/clothing/shirt/dress/gown/summergown::detail_color
	uses_lord_coloring = /obj/item/clothing/shirt/dress/gown/summergown::uses_lord_coloring
	boobed = /obj/item/clothing/shirt/dress/gown/summergown::boobed
	name = "council clerk attire"
	desc = "Neatly kept garments worn by a councilor’s clerk."
	body_parts_covered = CHEST|GROIN|VITALS|LEGS|ARMS
	slot_flags = ITEM_SLOT_ARMOR

/obj/item/clothing/suit/roguetown/armor/councillor
	item_weight = 3.5 KILOGRAMS
	// Looks like /obj/item/clothing/armor/leather/jacket/silk_coat: free Vanderlin art in place of the licensed sprite
	icon = /obj/item/clothing/armor/leather/jacket/silk_coat::icon
	mob_overlay_icon = /obj/item/clothing/armor/leather/jacket/silk_coat::mob_overlay_icon
	icon_state = /obj/item/clothing/armor/leather/jacket/silk_coat::icon_state
	item_state = /obj/item/clothing/armor/leather/jacket/silk_coat::item_state
	sleeved = /obj/item/clothing/armor/leather/jacket/silk_coat::sleeved
	sleevetype = /obj/item/clothing/armor/leather/jacket/silk_coat::sleevetype
	ignore_sleeves_code = /obj/item/clothing/armor/leather/jacket/silk_coat::ignore_sleeves_code
	nodismemsleeves = /obj/item/clothing/armor/leather/jacket/silk_coat::nodismemsleeves
	color = /obj/item/clothing/armor/leather/jacket/silk_coat::color
	detail_tag = /obj/item/clothing/armor/leather/jacket/silk_coat::detail_tag
	detail_color = /obj/item/clothing/armor/leather/jacket/silk_coat::detail_color
	uses_lord_coloring = /obj/item/clothing/armor/leather/jacket/silk_coat::uses_lord_coloring
	boobed = /obj/item/clothing/armor/leather/jacket/silk_coat::boobed
	name = "councilor's formal attire"
	desc = "A tailored uniform denoting a seated member of the Burgmeister’s council. Practical, dignified, and subtly armored against both blades and politics."
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|VITALS
	armor_type = /datum/armor/rmh/armor/councillor
	prevent_crits = list(BCLASS_CUT, BCLASS_BLUNT)
	blocksound = SOFTUNDERHIT
	blade_dulling = DULLING_BASHCHOP
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = /datum/attribute/skill/misc/sewing/mending
	armor_class = AC_LIGHT

/obj/item/clothing/suit/roguetown/armor/leather/magos
	// Looks like /obj/item/clothing/shirt/robe/magus: free Vanderlin art in place of the licensed sprite
	icon = /obj/item/clothing/shirt/robe/magus::icon
	mob_overlay_icon = /obj/item/clothing/shirt/robe/magus::mob_overlay_icon
	icon_state = /obj/item/clothing/shirt/robe/magus::icon_state
	item_state = /obj/item/clothing/shirt/robe/magus::item_state
	sleeved = /obj/item/clothing/shirt/robe/magus::sleeved
	sleevetype = /obj/item/clothing/shirt/robe/magus::sleevetype
	ignore_sleeves_code = /obj/item/clothing/shirt/robe/magus::ignore_sleeves_code
	nodismemsleeves = /obj/item/clothing/shirt/robe/magus::nodismemsleeves
	color = /obj/item/clothing/shirt/robe/magus::color
	detail_tag = /obj/item/clothing/shirt/robe/magus::detail_tag
	detail_color = /obj/item/clothing/shirt/robe/magus::detail_color
	uses_lord_coloring = /obj/item/clothing/shirt/robe/magus::uses_lord_coloring
	boobed = /obj/item/clothing/shirt/robe/magus::boobed
	name = "magos-administrator robes"
	desc = "Layered robes, worn by the Burgmeister’s Magos, who governs through knowledge, archives, and written law."
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|VITALS
	slot_flags = ITEM_SLOT_ARMOR

/obj/item/clothing/suit/roguetown/armor/leather/banker
	// Looks like /obj/item/clothing/shirt/robe/merchant: free Vanderlin art in place of the licensed sprite
	icon = /obj/item/clothing/shirt/robe/merchant::icon
	mob_overlay_icon = /obj/item/clothing/shirt/robe/merchant::mob_overlay_icon
	icon_state = /obj/item/clothing/shirt/robe/merchant::icon_state
	item_state = /obj/item/clothing/shirt/robe/merchant::item_state
	sleeved = /obj/item/clothing/shirt/robe/merchant::sleeved
	sleevetype = /obj/item/clothing/shirt/robe/merchant::sleevetype
	ignore_sleeves_code = /obj/item/clothing/shirt/robe/merchant::ignore_sleeves_code
	nodismemsleeves = /obj/item/clothing/shirt/robe/merchant::nodismemsleeves
	color = /obj/item/clothing/shirt/robe/merchant::color
	detail_tag = /obj/item/clothing/shirt/robe/merchant::detail_tag
	detail_color = /obj/item/clothing/shirt/robe/merchant::detail_color
	uses_lord_coloring = /obj/item/clothing/shirt/robe/merchant::uses_lord_coloring
	boobed = /obj/item/clothing/shirt/robe/merchant::boobed
	name = "guild banker’s suit"
	desc = "A finely stitched suit worn by a senior banker of the Waterdeep Merchant’s Guild."
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|VITALS
	slot_flags = ITEM_SLOT_ARMOR
