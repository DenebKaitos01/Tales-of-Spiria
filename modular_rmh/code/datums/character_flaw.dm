/datum/quirk/vice/addiction/lovefiend
	name = "Nymphomaniac"
	desc = "I must make love!"
	time = 70 MINUTES // RMH EDIT: Azure's timing (was 40 minutes)
	needsate_text = "I'm so horny..."
	sated_text = "That's much better..."
	point_value = 3
	debuff = /datum/status_effect/debuff/addiction/lovefiend
	/// world.time before which another tumble while sated gives no partial sate
	var/partial_sate = 0

// As Azure: the first craving comes 65-75 minutes in, not 10-20
/datum/quirk/vice/addiction/lovefiend/on_spawn()
	. = ..()
	next_sate = world.time + rand(time - 5 MINUTES, time + 5 MINUTES)

/datum/quirk/vice/addiction/lovefiend/sate(mob/living/carbon/human/user)
	if(sated)
		// Partial sate, as Azure: another tumble while sated pushes the next craving back, at most every 15 minutes
		if(partial_sate < world.time)
			partial_sate = world.time + 15 MINUTES
			next_sate = max(next_sate, world.time + time / 1.5)
			to_chat(user, span_blue("<i>This will do... for now...</i>"))
		return
	. = ..()
	next_sate = world.time + time
	partial_sate = world.time + 5 MINUTES

/datum/quirk/vice/addiction/sadist
	name = "Sadist"
	desc = "There is no greater pleasure than the suffering of another."
	time = 2 HOURS
	needsate_text = "I need to hear someone whimper."
	sated_text = "That's much better..."
	point_value = 3
	debuff = /datum/status_effect/debuff/addiction/sadist

/datum/status_effect/debuff/addiction/lovefiend
	id = "addiction_lovefiend"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/addiction/lovefiend

/atom/movable/screen/alert/status_effect/debuff/addiction/sadist
	name = "Sadistic Craving"
	desc = "I need to hear someone suffer."

/atom/movable/screen/alert/status_effect/debuff/addiction/lovefiend
	name = "Nymphomaniac Craving"
	desc = "I need intimacy."

// Hidden until existing saves have been migrated to the addiction subtype.
/datum/quirk/vice/lovefiend
	parent_type = /datum/quirk/vice/addiction/lovefiend
	abstract_type = /datum/quirk/vice/lovefiend
