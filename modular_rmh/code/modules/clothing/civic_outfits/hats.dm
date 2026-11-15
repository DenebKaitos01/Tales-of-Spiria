//----------------- CIVIC OUTFITS: HATS.DM ---------------------
/obj/item/clothing/head/roguetown
	item_weight = 300 GRAMS
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/roguetown/helmet/guildguard
	item_weight = 2.5 KILOGRAMS
	// Looks like /obj/item/clothing/head/helmet/sallet: free Vanderlin art in place of the licensed sprite
	icon = /obj/item/clothing/head/helmet/sallet::icon
	mob_overlay_icon = /obj/item/clothing/head/helmet/sallet::mob_overlay_icon
	icon_state = /obj/item/clothing/head/helmet/sallet::icon_state
	item_state = /obj/item/clothing/head/helmet/sallet::item_state
	sleeved = /obj/item/clothing/head/helmet/sallet::sleeved
	sleevetype = /obj/item/clothing/head/helmet/sallet::sleevetype
	ignore_sleeves_code = /obj/item/clothing/head/helmet/sallet::ignore_sleeves_code
	nodismemsleeves = /obj/item/clothing/head/helmet/sallet::nodismemsleeves
	color = /obj/item/clothing/head/helmet/sallet::color
	detail_tag = /obj/item/clothing/head/helmet/sallet::detail_tag
	detail_color = /obj/item/clothing/head/helmet/sallet::detail_color
	uses_lord_coloring = /obj/item/clothing/head/helmet/sallet::uses_lord_coloring
	boobed = /obj/item/clothing/head/helmet/sallet::boobed
	name = "guild guard helm"
	desc = "A reinforced steel helm issued to the guards of the Waterdeep Merchant’s Guild. Its weight and craftsmanship speak of coin-backed authority rather than civic duty."
	max_integrity = 225
	prevent_crits = list(BCLASS_CUT, BCLASS_STAB, BCLASS_CHOP, BCLASS_BLUNT, BCLASS_TWIST)
	armor_class = AC_MEDIUM
	smeltresult = /obj/item/ingot/steel
	melting_material = /datum/material/steel
	melt_amount = 100
	body_parts_covered = HEAD|HAIR|EARS
	flags_inv = HIDEHAIR
	clothing_flags = CANT_SLEEP_IN
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	sewrepair = null

/obj/item/clothing/head/roguetown/duchess_hood
	// Looks like /obj/item/clothing/head/veiled: free Vanderlin art in place of the licensed sprite
	icon = /obj/item/clothing/head/veiled::icon
	mob_overlay_icon = /obj/item/clothing/head/veiled::mob_overlay_icon
	icon_state = /obj/item/clothing/head/veiled::icon_state
	item_state = /obj/item/clothing/head/veiled::item_state
	sleeved = /obj/item/clothing/head/veiled::sleeved
	sleevetype = /obj/item/clothing/head/veiled::sleevetype
	ignore_sleeves_code = /obj/item/clothing/head/veiled::ignore_sleeves_code
	nodismemsleeves = /obj/item/clothing/head/veiled::nodismemsleeves
	color = /obj/item/clothing/head/veiled::color
	detail_tag = /obj/item/clothing/head/veiled::detail_tag
	detail_color = /obj/item/clothing/head/veiled::detail_color
	uses_lord_coloring = /obj/item/clothing/head/veiled::uses_lord_coloring
	boobed = /obj/item/clothing/head/veiled::boobed
	name = "duchess' veil"
	desc = "A finely tailored hood and veil favored by noble ladies. It conceals the face just enough to preserve mystery—and hide what must remain unseen."
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
