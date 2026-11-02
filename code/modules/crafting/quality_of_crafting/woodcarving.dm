// Woodcarving: whittle sticks and small logs into trinkets with a knife. Ported from Azure Peak.

/datum/repeatable_crafting_recipe/woodcarving
	abstract_type = /datum/repeatable_crafting_recipe/woodcarving
	skillcraft = /datum/attribute/skill/craft/carpentry
	category = "Woodcarving"
	allow_inverse_start = TRUE
	subtypes_allowed = TRUE
	requirements = list(
		/obj/item/grown/log/tree/stick = 1,
	)
	tool_usage = list(
		/obj/item/weapon/knife = list(span_notice("starts to whittle"), span_notice("start to whittle"), 'sound/items/wood_sharpen.ogg'),
	)
	attacked_atom = /obj/item/grown/log/tree/stick
	starting_atom = /obj/item/weapon/knife

/datum/repeatable_crafting_recipe/woodcarving/log
	abstract_type = /datum/repeatable_crafting_recipe/woodcarving/log
	requirements = list(
		/obj/item/grown/log/tree/small = 1,
	)
	attacked_atom = /obj/item/grown/log/tree/small
	craft_time = 3 SECONDS

/datum/repeatable_crafting_recipe/woodcarving/marble
	name = "wooden marble"
	output = /obj/item/carvedwood/marble
	craftdiff = 0

/datum/repeatable_crafting_recipe/woodcarving/spire
	name = "wooden spire"
	output = /obj/item/carvedwood/spire
	craftdiff = 0

/datum/repeatable_crafting_recipe/woodcarving/displaystand
	name = "wooden display stand"
	output = /obj/item/carvedwood/displaystand
	craftdiff = 0

/datum/repeatable_crafting_recipe/woodcarving/comb
	name = "wooden comb"
	output = /obj/item/carvedwood/comb
	craftdiff = 0

/datum/repeatable_crafting_recipe/woodcarving/cameo
	name = "wooden cameo"
	output = /obj/item/carvedwood/cameo
	craftdiff = 0

/datum/repeatable_crafting_recipe/woodcarving/prism
	name = "wooden prism"
	output = /obj/item/carvedwood/prism
	craftdiff = 0

/datum/repeatable_crafting_recipe/woodcarving/figurine
	name = "wooden figurine"
	output = /obj/item/carvedwood/figurine
	craftdiff = 1

/datum/repeatable_crafting_recipe/woodcarving/figurineelf
	name = "wooden elf figurine"
	output = /obj/item/carvedwood/figurineelf
	craftdiff = 1

/datum/repeatable_crafting_recipe/woodcarving/figurineanthro
	name = "wooden wildkin figurine"
	output = /obj/item/carvedwood/figurineanthro
	craftdiff = 1

/datum/repeatable_crafting_recipe/woodcarving/fish
	name = "wooden fish figurine"
	output = /obj/item/carvedwood/fish
	craftdiff = 1

/datum/repeatable_crafting_recipe/woodcarving/frog
	name = "wooden frog figurine"
	output = /obj/item/carvedwood/frog
	craftdiff = 1

/datum/repeatable_crafting_recipe/woodcarving/duck
	name = "wooden duck figurine"
	output = /obj/item/carvedwood/duck
	craftdiff = 1

/datum/repeatable_crafting_recipe/woodcarving/ashtray
	name = "wooden zigtray"
	output = /obj/item/carvedwood/ashtray
	craftdiff = 1

/datum/repeatable_crafting_recipe/woodcarving/saiga
	name = "wooden saiga figurine"
	output = /obj/item/carvedwood/saiga
	craftdiff = 1

/datum/repeatable_crafting_recipe/woodcarving/heart
	name = "wooden heart"
	output = /obj/item/carvedwood/heart
	craftdiff = 1

/datum/repeatable_crafting_recipe/woodcarving/moon
	name = "wooden moon"
	output = /obj/item/carvedwood/moon
	craftdiff = 2

/datum/repeatable_crafting_recipe/woodcarving/sun
	name = "wooden sun"
	output = /obj/item/carvedwood/sun
	craftdiff = 2

/datum/repeatable_crafting_recipe/woodcarving/log/plinth
	name = "wooden plinth"
	output = /obj/item/carvedwood/plinth
	craftdiff = 1

/datum/repeatable_crafting_recipe/woodcarving/log/gameboard
	name = "wooden game board"
	output = /obj/item/carvedwood/gameboard
	craftdiff = 1

/datum/repeatable_crafting_recipe/woodcarving/log/box
	name = "wooden box"
	output = /obj/item/carvedwood/box
	craftdiff = 1

/datum/repeatable_crafting_recipe/woodcarving/log/vase
	name = "wooden vase"
	output = /obj/item/carvedwood/vase
	craftdiff = 1

/datum/repeatable_crafting_recipe/woodcarving/log/pillar
	name = "wooden pillar"
	output = /obj/item/carvedwood/pillar
	craftdiff = 2

/datum/repeatable_crafting_recipe/woodcarving/log/vessel
	name = "large wooden vessel"
	output = /obj/item/carvedwood/vessel
	craftdiff = 2

/datum/repeatable_crafting_recipe/woodcarving/log/fancyvase
	name = "fancy wooden vase"
	output = /obj/item/carvedwood/fancyvase
	craftdiff = 2

/datum/repeatable_crafting_recipe/woodcarving/log/shrine
	name = "wooden shrine"
	output = /obj/item/carvedwood/shrine
	craftdiff = 3

/datum/repeatable_crafting_recipe/woodcarving/log/beaver
	name = "wooden beaver"
	output = /obj/item/carvedwood/beaver
	craftdiff = 3

/datum/repeatable_crafting_recipe/woodcarving/log/bust
	name = "wooden bust"
	output = /obj/item/carvedwood/bust
	craftdiff = 3
