// RMH EDIT: spell sheets, after Azure Peak. Shift+click an action button to print what it does in chat (for spells:
// how it is cast, range, charge, cooldown and cost). Alt+click puts a moved button back in its place (that used to be Shift+click).

/// Prints this action's sheet to [user]'s chat.
/datum/action/proc/examine_action(mob/user)
	var/list/lines = list("<span class='notice'><b>[name]</b></span>")
	if(desc)
		lines += desc
	lines += get_examine_stats()
	to_chat(user, "<br>[lines.Join("<br>")]")

/// Extra lines for the sheet; spells fill this in.
/datum/action/proc/get_examine_stats()
	return list()

/datum/action/cooldown/spell/get_examine_stats()
	. = list()
	var/mob/living/caster = isliving(owner) ? owner : null

	if(!click_to_activate)
		. += span_info("Activation: Self-cast")
	else if(charge_required)
		. += span_info("Activation: Hold middle-click to charge, release on a target")
	else
		. += span_info("Activation: Middle-click a target")
	. += span_info("Range: [click_to_activate ? "[cast_range] tiles" : "Self"]")

	if(charge_time > 0)
		var/charge = caster ? get_adjusted_charge_time() : charge_time
		. += span_info("Charge time: [DisplayTimeText(charge)][charge != charge_time ? " (base [DisplayTimeText(charge_time)])" : ""]")
	else
		. += span_info("Charge time: Instant")

	if(cooldown_time > 0)
		. += span_info("Cooldown: [DisplayTimeText(cooldown_time)]")
	var/time_left = max(next_use_time - world.time, 0)
	if(time_left > 0)
		. += span_warning("Remaining: [DisplayTimeText(time_left)]")

	if(spell_cost > 0)
		var/cost = caster ? round(get_adjusted_cost(), 0.1) : spell_cost
		. += span_info("[get_cost_label()]: [cost][cost != spell_cost ? " (base [spell_cost])" : ""]")

	if(spell_max_level > 1)
		. += span_info("Rank: [spell_level] / [spell_max_level]")

/// What this spell spends, by its spell type.
/datum/action/cooldown/spell/proc/get_cost_label()
	switch(spell_type)
		if(SPELL_STAMINA)
			return "Stamina cost"
		if(SPELL_MIRACLE, SPELL_PSYDONIC_MIRACLE)
			return "Devotion cost"
		if(SPELL_ESSENCE)
			return "Essence cost"
		if(SPELL_BLOOD)
			return "Blood cost"
		if(SPELL_RAGE)
			return "Rage cost"
	return "Mana cost"
