// RMH EDIT: the sling and its stones. Sprites and sounds ported from Azure Peak (code/game/objects/items/rogueweapons/ranged/slings.dm).
// Built on the bow, so it shares bow handling and skill, and NPC archers already know how to load and loose it:
// the stones sit in a sling pouch (a quiver subtype) and come back to the pouch when picked up.

/obj/item/gun/ballistic/revolver/grenadelauncher/bow/sling
	name = "sling"
	desc = "Twisted fibers manifest into a strung pouch capable of hurling stones afar."
	icon = 'modular_rmh/icons/obj/weapons/sling.dmi'
	icon_state = "sling"
	base_icon = "sling"
	item_state = "sling"
	item_weight = 150 GRAMS
	possible_item_intents = list(/datum/intent/shoot/bow/sling, /datum/intent/arc/bow/sling, INTENT_GENERIC)
	mag_type = /obj/item/ammo_box/magazine/internal/shot/sling
	fire_sound = 'modular_rmh/sound/combat/sling/sling-shot-01.ogg'
	load_sound = 'modular_rmh/sound/combat/sling/slingload.ogg'
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_BACK|ITEM_SLOT_WRISTS
	w_class = WEIGHT_CLASS_SMALL
	force = 5
	can_parry = FALSE
	verbage = "load"
	cartridge_wording = "stone"
	metalizer_result = null

/obj/item/ammo_box/magazine/internal/shot/sling
	ammo_type = /obj/item/ammo_casing/caseless/sling_stone
	caliber = "slingstone"
	max_ammo = 1
	start_empty = TRUE

/datum/intent/shoot/bow/sling
	chargetime = 0.5

/datum/intent/shoot/bow/sling/prewarning()
	var/mob/master = get_master_mob()
	if(master)
		master.visible_message(span_warning("[master] whirls [get_master_item()]!"))
		playsound(master, 'modular_rmh/sound/combat/sling/sling-draw-01.ogg', 100, FALSE)

/datum/intent/arc/bow/sling
	chargetime = 0.5

/datum/intent/arc/bow/sling/prewarning()
	var/mob/master = get_master_mob()
	if(master)
		master.visible_message(span_warning("[master] whirls [get_master_item()] in an arc!"))
		playsound(master, 'modular_rmh/sound/combat/sling/sling-draw-01.ogg', 100, FALSE)

/obj/item/ammo_casing/caseless/sling_stone
	name = "sling stone"
	desc = "A smooth, round stone, just the right size for a sling's pouch."
	icon = 'modular_rmh/icons/obj/weapons/sling_stone.dmi'
	icon_state = "stone_sling_bullet"
	item_weight = 60 GRAMS
	projectile_type = /obj/projectile/bullet/reusable/sling_stone
	caliber = "slingstone"
	force = 5
	dropshrink = 0.6
	max_integrity = 50
	firing_effect_type = null

/obj/projectile/bullet/reusable/sling_stone
	name = "sling stone"
	desc = "A smooth, round stone."
	icon = 'modular_rmh/icons/obj/weapons/sling_stone_proj.dmi'
	icon_state = "slingbullet_proj"
	ammo_type = /obj/item/ammo_casing/caseless/sling_stone
	damage = 22
	damage_type = BRUTE
	armor_penetration = 0
	woundclass = BCLASS_BLUNT
	flag = "blunt"
	range = 15
	speed = 0.5
	embedchance = 0
	hitsound = 'sound/combat/hits/blunt/bluntsmall (1).ogg'

/obj/projectile/bullet/reusable/sling_stone/fire(angle, atom/direct_target)
	embedchance = 0 // bows set it on a full draw; a stone bounces off and lands
	return ..()

/obj/item/ammo_holder/quiver/sling_pouch
	name = "sling pouch"
	desc = "A small leather pouch for sling stones."
	icon_state = "slingpouch"
	item_state = "dartpouch"
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_NECK
	w_class = WEIGHT_CLASS_SMALL
	item_weight = 100 GRAMS
	max_storage = 15
	ammo_type = list(/obj/item/ammo_casing/caseless/sling_stone)

/obj/item/ammo_holder/quiver/sling_pouch/update_icon_state()
	. = ..()
	icon_state = "slingpouch" // one sprite, full or not

/obj/item/ammo_holder/quiver/sling_pouch/stones
	fill_type = /obj/item/ammo_casing/caseless/sling_stone
	fill_to = 10
