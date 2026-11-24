// RMH EDIT: Champion kits. The rank sets the base (robes, mail or plate); the patron sets the colours,
// the holy symbol and the weapon. To change a god's look, edit only its row in GLOB.champion_kits.
// Each entry maps an outfit slot (the /datum/outfit var name) to the item that goes there.

GLOBAL_LIST_INIT(champion_kits, list(
	// Gaedon, the Firstborn: ambition and perfection. Forge greys and the hammer.
	/datum/patron/spira/primordial/gaedon = list(
		CHAMPION_RANK_PRIEST = list(
			"shirt" = /obj/item/clothing/shirt/robe,
			"head" = /obj/item/clothing/head/roguehood,
			"cloak" = /obj/item/clothing/cloak/templar/malumite,
			"neck" = /obj/item/clothing/neck/psycross/silver/divine/malum,
			"r_hand" = /obj/item/weapon/mace,
		),
		CHAMPION_RANK_CLERIC = list(
			"cloak" = /obj/item/clothing/cloak/templar/malumite,
			"wrists" = /obj/item/clothing/neck/psycross/silver/divine/malum,
			"r_hand" = /obj/item/weapon/mace/warhammer,
			"l_hand" = /obj/item/weapon/shield/wood,
		),
		CHAMPION_RANK_PALADIN = list(
			"head" = /obj/item/clothing/head/helmet/heavy/necked/malumhelm,
			"cloak" = /obj/item/clothing/cloak/stabard/templar/malum,
			"wrists" = /obj/item/clothing/neck/psycross/silver/divine/malum,
			"r_hand" = /obj/item/weapon/mace/warhammer/steel,
			"l_hand" = /obj/item/weapon/shield/heater,
		),
	),
	// Saelion, the Bluish Flame: life, light and creation. Briar robes and the staff.
	/datum/patron/spira/primordial/saelion = list(
		CHAMPION_RANK_PRIEST = list(
			"shirt" = /obj/item/clothing/shirt/robe/dendor,
			"head" = /obj/item/clothing/head/roguehood,
			"neck" = /obj/item/clothing/neck/psycross/silver/divine/dendor,
			"r_hand" = /obj/item/weapon/polearm/woodstaff,
		),
		CHAMPION_RANK_CLERIC = list(
			"cloak" = /obj/item/clothing/cloak/stabard/templar/dendor,
			"wrists" = /obj/item/clothing/neck/psycross/silver/divine/dendor,
			"r_hand" = /obj/item/weapon/mace,
			"l_hand" = /obj/item/weapon/shield/wood,
		),
		CHAMPION_RANK_PALADIN = list(
			"head" = /obj/item/clothing/head/helmet/heavy/necked/dendorhelm,
			"cloak" = /obj/item/clothing/cloak/stabard/templar/dendor,
			"wrists" = /obj/item/clothing/neck/psycross/silver/divine/dendor,
			"r_hand" = /obj/item/weapon/sword/long,
			"l_hand" = /obj/item/weapon/shield/heater,
		),
	),
	// Sirokel, the Blue Star: justice, the stars and the martyrs. Sun-gold and the sword.
	/datum/patron/spira/greater/sirokel = list(
		CHAMPION_RANK_PRIEST = list(
			"shirt" = /obj/item/clothing/shirt/robe/astrata,
			"head" = /obj/item/clothing/head/roguehood/astrata,
			"neck" = /obj/item/clothing/neck/psycross/silver/divine/astrata,
			"r_hand" = /obj/item/weapon/mace/cudgel,
		),
		CHAMPION_RANK_CLERIC = list(
			"cloak" = /obj/item/clothing/cloak/templar/astratan,
			"wrists" = /obj/item/clothing/neck/psycross/silver/divine/astrata,
			"r_hand" = /obj/item/weapon/sword/arming,
			"l_hand" = /obj/item/weapon/shield/wood,
		),
		CHAMPION_RANK_PALADIN = list(
			"head" = /obj/item/clothing/head/helmet/heavy/necked/astrata,
			"cloak" = /obj/item/clothing/cloak/stabard/templar/astrata,
			"wrists" = /obj/item/clothing/neck/psycross/silver/divine/astrata,
			"r_hand" = /obj/item/weapon/sword/long,
			"l_hand" = /obj/item/weapon/shield/heater,
		),
	),
	// Naverae, the Silent Sage: knowledge, mages and scholars. Moon robes and the quarterstaff.
	/datum/patron/spira/greater/naverae = list(
		CHAMPION_RANK_PRIEST = list(
			"shirt" = /obj/item/clothing/shirt/robe/noc,
			"head" = /obj/item/clothing/head/roguehood/nochood,
			"neck" = /obj/item/clothing/neck/psycross/silver/divine/noc,
			"r_hand" = /obj/item/weapon/polearm/woodstaff/quarterstaff,
		),
		CHAMPION_RANK_CLERIC = list(
			"cloak" = /obj/item/clothing/cloak/stabard/templar/noc,
			"wrists" = /obj/item/clothing/neck/psycross/silver/divine/noc,
			"r_hand" = /obj/item/weapon/polearm/woodstaff/quarterstaff/iron,
		),
		CHAMPION_RANK_PALADIN = list(
			"head" = /obj/item/clothing/head/helmet/heavy/necked/noc,
			"cloak" = /obj/item/clothing/cloak/stabard/templar/noc,
			"wrists" = /obj/item/clothing/neck/psycross/silver/divine/noc,
			"r_hand" = /obj/item/weapon/mace/steel,
			"l_hand" = /obj/item/weapon/shield/heater,
		),
	),
	// Ragelia, the Spear of Paradise: warriors, vigilance and loyalty. War-red and the spear.
	/datum/patron/spira/greater/ragelia = list(
		CHAMPION_RANK_PRIEST = list(
			"shirt" = /obj/item/clothing/shirt/robe/ravox,
			"head" = /obj/item/clothing/head/roguehood/ravox,
			"neck" = /obj/item/clothing/neck/psycross/silver/divine/ravox,
			"r_hand" = /obj/item/weapon/polearm/spear/stone,
		),
		CHAMPION_RANK_CLERIC = list(
			"cloak" = /obj/item/clothing/cloak/ravox,
			"wrists" = /obj/item/clothing/neck/psycross/silver/divine/ravox,
			"r_hand" = /obj/item/weapon/polearm/spear,
			"l_hand" = /obj/item/weapon/shield/tower/buckleriron,
		),
		CHAMPION_RANK_PALADIN = list(
			"head" = /obj/item/clothing/head/helmet/heavy/necked/ravox,
			"cloak" = /obj/item/clothing/cloak/stabard/templar/ravox,
			"wrists" = /obj/item/clothing/neck/psycross/silver/divine/ravox,
			"r_hand" = /obj/item/weapon/polearm/halberd,
		),
	),
	// Lunestra, the Guardian of the Hourglass: time, death and rest. Mourning black and the flail.
	/datum/patron/spira/lesser/lunestra = list(
		CHAMPION_RANK_PRIEST = list(
			"shirt" = /obj/item/clothing/shirt/robe/necra,
			"head" = /obj/item/clothing/head/necrahood,
			"neck" = /obj/item/clothing/neck/psycross/silver/divine/necra,
			"r_hand" = /obj/item/weapon/flail/towner,
		),
		CHAMPION_RANK_CLERIC = list(
			"cloak" = /obj/item/clothing/cloak/templar/necran,
			"wrists" = /obj/item/clothing/neck/psycross/silver/divine/necra,
			"r_hand" = /obj/item/weapon/flail,
			"l_hand" = /obj/item/weapon/shield/wood,
		),
		CHAMPION_RANK_PALADIN = list(
			"head" = /obj/item/clothing/head/helmet/heavy/necked/necra,
			"cloak" = /obj/item/clothing/cloak/stabard/templar/necra,
			"wrists" = /obj/item/clothing/neck/psycross/silver/divine/necra,
			"r_hand" = /obj/item/weapon/flail/sflail/necraflail,
			"l_hand" = /obj/item/weapon/shield/heater,
		),
	),
))

/// Base Champion outfit: the rank's armour, then the patron's row of GLOB.champion_kits on top.
/datum/outfit/adventurer_champion
	name = "Champion"
	belt = /obj/item/storage/belt/leather/adventurers_subclasses
	backl = /obj/item/storage/backpack/satchel
	backpack_contents = list(/obj/item/storage/belt/pouch/cloth/coins/poor = 1, /obj/item/reagent_containers/food/snacks/hardtack = 1)
	/// One of the CHAMPION_RANK_* values; picks the column of GLOB.champion_kits.
	var/champion_rank

/datum/outfit/adventurer_champion/pre_equip(mob/living/carbon/human/equipped_human, visuals_only)
	. = ..()
	var/list/by_rank = GLOB.champion_kits[equipped_human?.patron?.type]
	var/list/kit = by_rank?[champion_rank]
	if(!kit)
		// A patron with no row (an admin swap, a preview dummy): the Sirokel kit keeps the outfit whole.
		var/list/fallback = GLOB.champion_kits[/datum/patron/spira/greater/sirokel]
		kit = fallback[champion_rank]
	for(var/slot in kit)
		vars[slot] = kit[slot]

/datum/outfit/adventurer_champion/priest
	name = "Champion Priest"
	champion_rank = CHAMPION_RANK_PRIEST
	pants = /obj/item/clothing/pants/tights
	shoes = /obj/item/clothing/shoes/sandals
	wrists = /obj/item/clothing/wrists/bracers/leather

/datum/outfit/adventurer_champion/cleric
	name = "Champion Cleric"
	champion_rank = CHAMPION_RANK_CLERIC
	head = /obj/item/clothing/head/helmet/kettle
	neck = /obj/item/clothing/neck/chaincoif
	armor = /obj/item/clothing/armor/chainmail/hauberk/iron
	shirt = /obj/item/clothing/armor/gambeson
	gloves = /obj/item/clothing/gloves/leather
	pants = /obj/item/clothing/pants/trou/leather
	shoes = /obj/item/clothing/shoes/boots/leather

/datum/outfit/adventurer_champion/paladin
	name = "Champion Paladin"
	champion_rank = CHAMPION_RANK_PALADIN
	neck = /obj/item/clothing/neck/gorget
	armor = /obj/item/clothing/armor/plate/full
	shirt = /obj/item/clothing/armor/gambeson/light
	gloves = /obj/item/clothing/gloves/plate
	pants = /obj/item/clothing/pants/platelegs
	shoes = /obj/item/clothing/shoes/boots/armor
	belt = /obj/item/storage/belt/leather/steel/adventurers_subclasses
