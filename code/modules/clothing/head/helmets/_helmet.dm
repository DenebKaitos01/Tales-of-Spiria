/obj/item/clothing/head/helmet
	equip_sound = 'sound/foley/equip/equip_armor.ogg'
	drop_sound = 'sound/foley/dropsound/armor_drop.ogg'
	break_sound = 'sound/foley/breaksound.ogg'
	pickup_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	blocksound = PLATEHIT
	resistance_flags = FIRE_PROOF
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	sewrepair = null
	smeltresult = /obj/item/ingot/iron
	sellprice = VALUE_IRON_ITEM
	clothing_flags = CANT_SLEEP_IN
	slot_flags = ITEM_SLOT_HEAD | ITEM_SLOT_HIP
	armor_type = /datum/armor/head/plate/bad
	max_integrity = INTEGRITY_POOR //Looked like it was defaulting to integrity_worst from head.dm which gave some helmets the same durability has hats.
	body_parts_covered = COVERAGE_SKULL
	prevent_crits = ALL_EXCEPT_STAB

	grid_height = 64
	grid_width = 64
	experimental_onhip = TRUE
	abstract_type = /obj/item/clothing/head/helmet

	material_category = ARMOR_MAT_PLATE

/obj/item/clothing/head/helmet/getonmobprop(tag)
	if(tag)
		switch(tag)
			if("onbelt")
				return list("shrink" = 0.42,"sx" = -3,"sy" = -8,"nx" = 6,"ny" = -8,"wx" = -1,"wy" = -8,"ex" = 3,"ey" = -8,"nturn" = 180,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 1,"sflip" = 0,"wflip" = 0,"eflip" = 8,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)
	return ..()
