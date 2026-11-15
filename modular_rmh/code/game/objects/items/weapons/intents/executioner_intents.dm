// RMH EDIT: executioner's sword intents, ported from Azure Peak and scaled to this tree's sword timings
// (chop = clickcd 14 / swingdelay 1, longsword chop 16 / 1.5, zweihander cleave 16 and sweep 18).

/// A slower, harder chop that bites into armour
/datum/intent/sword/chop/heavy
	name = "heavy chop"
	damfactor = 1.3
	penfactor = PEN_MEDIUM
	clickcd = 16
	swingdelay = 1.5
	misscost = 12
	warnie = "mobwarning"

/// The flat, round tip does not pierce; a shove more than a stab
/datum/intent/sword/thrust/exe
	penfactor = PEN_NONE
	swingdelay = 1

/// Cuts through the first target into a second one behind it; slower than the zweihander's
/datum/intent/sword/cut/exe/cleave
	name = "cleaving cut"
	desc = "A heavy cleave that cuts through a second target behind the first."
	icon_state = "incleave"
	attack_verb = list("cleaves", "carves through")
	clickcd = 18
	damfactor = 1.2
	cleave = /datum/cleave_pattern/forward_cleave

/// Cuts across every target in front
/datum/intent/sword/cut/exe/sweep
	name = "sweeping cut"
	desc = "A heavy sweep that cuts through targets to the front."
	icon_state = "insweep"
	attack_verb = list("sweeps through", "cuts across")
	clickcd = 20
	damfactor = 1.2
	cleave = /datum/cleave_pattern/horizontal_sweep

/// A long wind-up for a single devastating blow
/datum/intent/sword/cut/rend
	name = "rend"
	desc = "A slow, wound-up blow that tears into a single target."
	icon_state = "inrend"
	attack_verb = list("rends", "cleaves")
	animname = "chop"
	blade_class = BCLASS_CHOP
	hitsound = list('sound/combat/hits/bladed/genchop (1).ogg', 'sound/combat/hits/bladed/genchop (2).ogg', 'sound/combat/hits/bladed/genchop (3).ogg')
	swingdelay = 3
	penfactor = PEN_NONE
	damfactor = 2.5
	clickcd = 24
	no_early_release = TRUE
	misscost = 10
	warnie = "mobwarning"
