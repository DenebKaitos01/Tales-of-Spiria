// Decorative ceramics thrown on the potter's lathe. They take the clay's material; porcelain sells for double.
// Ported from Azure Peak's porcelain trinkets.

/obj/item/ceramic_trinket
	name = "ceramic trinket"
	desc = "A small ceramic trinket."
	icon = 'icons/roguetown/items/ceramic_trinkets.dmi'
	icon_state = "clayporcelainbauble"
	w_class = WEIGHT_CLASS_SMALL
	obj_flags = CAN_BE_HIT|UNIQUE_RENAME
	main_material = /datum/material/clay/porcelain
	item_weight = 200 GRAMS
	sellprice = 8

/obj/item/ceramic_trinket/set_material_information()
	. = ..()
	var/porcelain = ispath(main_material, /datum/material/clay/porcelain)
	name = "[porcelain ? "porcelain" : "[LOWER_TEXT(initial(main_material.name))] clay"] [initial(name)]"
	sellprice = initial(sellprice) * (porcelain ? 2 : 1)

/obj/item/ceramic_trinket/bauble
	name = "bauble"
	desc = "A small bauble."
	icon_state = "clayporcelainbauble"
	sellprice = 8

/obj/item/ceramic_trinket/cameo
	name = "cameo"
	desc = "A small cameo."
	icon_state = "clayporcelaincameo"
	sellprice = 8

/obj/item/ceramic_trinket/box
	name = "trinket box"
	desc = "A medium-sized box, useful for storing baubles and trinkets."
	icon_state = "clayporcelainbox"
	item_weight = 400 GRAMS
	sellprice = 12

/obj/item/ceramic_trinket/display
	name = "display stand"
	desc = "A small display stand."
	icon_state = "clayporcelainstand"
	sellprice = 12

/obj/item/ceramic_trinket/duck
	name = "duck statue"
	desc = "An adorable duck statue."
	icon_state = "clayporcelainduck"
	sellprice = 12

/obj/item/ceramic_trinket/figurine
	name = "figurine"
	desc = "A small figurine."
	icon_state = "clayporcelainfigurine"
	sellprice = 12

/obj/item/ceramic_trinket/fish
	name = "fish figurine"
	desc = "A small fish figurine."
	icon_state = "clayporcelainfish"
	sellprice = 12

/obj/item/ceramic_trinket/heart
	name = "heart"
	desc = "A heart."
	icon_state = "clayporcelainheart"
	sellprice = 12

/obj/item/ceramic_trinket/comb
	name = "comb"
	desc = "A fashionable comb."
	icon_state = "clayporcelaincomb"
	sellprice = 18

/obj/item/ceramic_trinket/obelisk
	name = "obelisk"
	desc = "A medium-sized obelisk."
	icon_state = "clayporcelainobelisk"
	item_weight = 400 GRAMS
	sellprice = 18

/obj/item/ceramic_trinket/sun
	name = "sun"
	desc = "A medium-sized sun statue."
	icon_state = "clayporcelainsun"
	sellprice = 18

/obj/item/ceramic_trinket/tablet
	name = "tablet"
	desc = "A medium-sized tablet."
	icon_state = "clayporcelaintablet"
	item_weight = 400 GRAMS
	sellprice = 18

/obj/item/ceramic_trinket/moon
	name = "moon"
	desc = "A medium-sized moon statue."
	icon_state = "clayporcelainmoon"
	item_weight = 400 GRAMS
	sellprice = 25

/obj/item/ceramic_trinket/statuette
	name = "statuette"
	desc = "A medium-sized statuette."
	icon_state = "clayporcelainstatue"
	item_weight = 400 GRAMS
	sellprice = 25

/obj/item/ceramic_trinket/beaver
	name = "beaver statuette"
	desc = "A medium-sized beaver statuette."
	icon_state = "clayporcelainbeaver"
	w_class = WEIGHT_CLASS_NORMAL
	item_weight = 600 GRAMS
	sellprice = 35

/obj/item/ceramic_trinket/bust
	name = "bust"
	desc = "A large bust."
	icon_state = "clayporcelainbust"
	w_class = WEIGHT_CLASS_NORMAL
	item_weight = 600 GRAMS
	sellprice = 35

/obj/item/ceramic_trinket/carp
	name = "carp statuette"
	desc = "A large carp statuette."
	icon_state = "clayporcelaincarp"
	w_class = WEIGHT_CLASS_NORMAL
	item_weight = 600 GRAMS
	sellprice = 35

/obj/item/ceramic_trinket/caryatid
	name = "caryatid"
	desc = "A medium-sized caryatid."
	icon_state = "clayporcelaincaryatid"
	item_weight = 400 GRAMS
	sellprice = 35

/obj/item/ceramic_trinket/octopus
	name = "octopus statuette"
	desc = "A large octopus statuette."
	icon_state = "clayporcelainoctopus"
	w_class = WEIGHT_CLASS_NORMAL
	item_weight = 600 GRAMS
	sellprice = 35

/obj/item/ceramic_trinket/turtle
	name = "turtle statuette"
	desc = "A large turtle statuette."
	icon_state = "clayporcelainturtle"
	item_weight = 400 GRAMS
	sellprice = 35

/obj/item/ceramic_trinket/urn
	name = "urn"
	desc = "A large, lidded urn."
	icon_state = "clayporcelainurn"
	w_class = WEIGHT_CLASS_NORMAL
	item_weight = 600 GRAMS
	sellprice = 35
