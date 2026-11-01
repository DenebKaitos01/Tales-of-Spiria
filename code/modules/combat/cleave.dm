// Cleave patterns let a normal attack also strike secondary targets around the primary one.
// Set on an intent through its cleave var; see [/obj/item/proc/execute_cleave]. Ported from Azure Peak.

/datum/cleave_pattern
	/// Offsets drawn as if facing NORTH, rotated to the attack direction
	var/list/tile_offsets = list()
	/// Optional explicit offsets for diagonal directions (NE baseline). Rotated to other diagonals via 90° steps.
	/// If null, diagonal uses the standard rotation math on tile_offsets.
	var/list/diagonal_offsets
	/// Description shown in examine for diagonal behavior. Only shown if diagonal_offsets is set.
	var/diagonal_desc
	/// How many extra targets can be hit, 0 for no limit
	var/max_targets = 1
	var/respect_dir = TRUE
	/// If TRUE, offsets are relative to the user's turf instead of the target's turf.
	var/user_relative = FALSE
	var/desc = "Cleaves into nearby targets."

/datum/cleave_pattern/proc/get_facing_dir(mob/living/user, turf/origin)
	var/use_dir = user.dir
	// Already diagonal
	if(use_dir & (use_dir - 1))
		return use_dir
	// Check if we should be diagonal based on origin position
	if(origin)
		var/turf/user_turf = get_turf(user)
		var/rel_x = origin.x - user_turf.x
		var/rel_y = origin.y - user_turf.y
		if(rel_x && rel_y)
			var/dir_x = rel_x > 0 ? EAST : WEST
			var/dir_y = rel_y > 0 ? NORTH : SOUTH
			return dir_x | dir_y
	return use_dir

/// Rotates an offset (dx, dy) from north-facing baseline to the given direction.
/datum/cleave_pattern/proc/rotate_offset(dx, dy, dir)
	switch(dir)
		if(SOUTH)
			return list(-dx, -dy)
		if(WEST)
			return list(-dy, dx)
		if(EAST)
			return list(dy, -dx)
		if(NORTHEAST)
			return list(dx + dy, -dx + dy)
		if(NORTHWEST)
			return list(dx - dy, dx + dy)
		if(SOUTHEAST)
			return list(-dx + dy, -dx - dy)
		if(SOUTHWEST)
			return list(-dx - dy, dx - dy)
	return list(dx, dy)

/datum/cleave_pattern/proc/get_cleave_turfs(mob/living/user, turf/origin)
	var/list/turfs = list()
	if(!origin || !user)
		return turfs
	var/use_dir = get_facing_dir(user, origin)
	var/turf/base_turf = user_relative ? get_turf(user) : origin
	var/is_diagonal = use_dir & (use_dir - 1)
	var/list/offsets = (is_diagonal && diagonal_offsets) ? diagonal_offsets : tile_offsets
	// Diagonal offsets are a NE baseline, rotate them to the actual diagonal via 90° steps
	var/rotate_dir = use_dir
	if(is_diagonal && diagonal_offsets)
		switch(use_dir)
			if(NORTHEAST)
				rotate_dir = NORTH
			if(NORTHWEST)
				rotate_dir = WEST
			if(SOUTHEAST)
				rotate_dir = EAST
			if(SOUTHWEST)
				rotate_dir = SOUTH
	for(var/list/offset in offsets)
		var/dx = offset[1]
		var/dy = offset[2]
		if(respect_dir)
			var/list/rotated = rotate_offset(dx, dy, rotate_dir)
			dx = rotated[1]
			dy = rotated[2]
		var/turf/T = locate(base_turf.x + dx, base_turf.y + dy, base_turf.z)
		if(T && !T.density)
			turfs += T
	return turfs

/// Renders a grid display for a set of offsets. target_pos and user_pos are (x,y) lists for T and U markers.
/datum/cleave_pattern/proc/render_grid(list/offsets, list/target_pos, list/user_pos)
	var/list/all_points = list(list(target_pos[1], target_pos[2]))
	for(var/list/offset in offsets)
		all_points += list(list(offset[1], offset[2]))
	var/min_x = min(target_pos[1], user_pos[1])
	var/max_x = max(target_pos[1], user_pos[1])
	var/min_y = min(target_pos[2], user_pos[2])
	var/max_y = max(target_pos[2], user_pos[2])
	for(var/list/p in all_points)
		min_x = min(min_x, p[1])
		max_x = max(max_x, p[1])
		min_y = min(min_y, p[2])
		max_y = max(max_y, p[2])
	var/list/rows = list()
	for(var/y = max_y, y >= min_y, y--)
		var/row = ""
		for(var/x = min_x, x <= max_x, x++)
			if(x == target_pos[1] && y == target_pos[2])
				row += "<font color='#fa4'>T</font>"
				continue
			if(x == user_pos[1] && y == user_pos[2])
				row += "<font color='#4af'>U</font>"
				continue
			var/found = FALSE
			for(var/list/p in all_points)
				if(p[1] == x && p[2] == y)
					row += "<font color='#f44'>X</font>"
					found = TRUE
					break
			if(!found)
				row += "<font color='#888'>O</font>"
		rows += row
	return rows.Join("\n")

/datum/cleave_pattern/proc/get_pattern_display()
	var/result
	if(user_relative)
		result = render_grid(tile_offsets, list(0, 1), list(0, 0))
	else
		result = render_grid(tile_offsets, list(0, 0), list(0, -1))
	if(diagonal_offsets)
		result += "\n<font color='#aaa'>Diagonal:</font>\n"
		if(user_relative)
			result += render_grid(diagonal_offsets, list(1, 1), list(0, 0))
		else
			result += render_grid(diagonal_offsets, list(0, 0), list(-1, -1))
	return result

/datum/cleave_pattern/proc/show_cleave_visuals(mob/living/user, turf/origin)
	var/resolved_dir = get_facing_dir(user, origin)
	var/list/turfs = get_cleave_turfs(user, origin)
	turfs |= origin
	for(var/turf/T as anything in turfs)
		new /obj/effect/temp_visual/dir_setting/cleave_visual(T, resolved_dir)

/obj/effect/temp_visual/dir_setting/cleave_visual
	plane = ABOVE_LIGHTING_PLANE
	icon = 'icons/effects/effects.dmi'
	icon_state = "cut"
	duration = 5

/// Strikes the secondary targets of the user's cleaving intent around an origin turf. Primary is excluded.
/obj/item/proc/execute_cleave(mob/living/user, turf/origin, mob/living/primary)
	var/datum/cleave_pattern/cleave = user.used_intent?.cleave
	if(!cleave || !origin)
		return
	cleave.show_cleave_visuals(user, origin)
	var/list/cleave_turfs = cleave.get_cleave_turfs(user, origin)
	// Living targets first, then corpses
	var/list/living_targets = list()
	var/list/dead_targets = list()
	for(var/turf/T as anything in cleave_turfs)
		for(var/mob/living/L in T)
			if(L == primary || L == user)
				continue
			if(L.stat == DEAD)
				dead_targets += L
			else
				living_targets += L
	var/cleave_targets_hit = 0
	for(var/mob/living/L as anything in living_targets + dead_targets)
		if(cleave.max_targets && cleave_targets_hit >= cleave.max_targets)
			break
		if(L.checkdefense(user.used_intent, user))
			continue
		L.set_damage_attack_context(user)
		var/hit = L.attacked_by(src, user)
		L.clear_damage_attack_context()
		if(hit)
			cleave_targets_hit++
			var/tempsound = user.used_intent?.hitsound
			if(tempsound)
				playsound(L, tempsound, 100, FALSE, -1)
			log_combat(user, L, "cleaved", src.name, "(INTENT: [uppertext(user.used_intent.name)])")

// ---- Predefined Patterns ----

/datum/cleave_pattern/adjacent
	tile_offsets = list(list(-1, 0), list(1, 0))
	max_targets = 1
	desc = "Cleaves into an adjacent target."

/datum/cleave_pattern/forward_cleave
	tile_offsets = list(list(0, 1))
	max_targets = 1
	desc = "Cleaves forward into a second target."

/datum/cleave_pattern/wide_sweep
	tile_offsets = list(list(-1, 0), list(1, 0), list(0, -1), list(0, 1))
	max_targets = 2
	desc = "Sweeps wide, cleaving up to two nearby targets."

/datum/cleave_pattern/horizontal_sweep
	tile_offsets = list(list(-1, 0), list(0, 0), list(1, 0))
	// NE baseline: target tile + two adjacent tiles on user's side
	diagonal_offsets = list(list(-1, 0), list(0, 0), list(0, -1))
	diagonal_desc = "Fans out in an L shape when diagonally swept."
	max_targets = 2
	desc = "Sweeps horizontally, cleaving up to two additional targets."

/datum/cleave_pattern/frontal_arc
	tile_offsets = list(list(-1, 0), list(1, 0), list(-1, 1), list(0, 1), list(1, 1))
	// NE baseline: arc wrapping from upper-left around to lower-right
	diagonal_offsets = list(list(-1, 1), list(0, 1), list(1, 0), list(1, -1))
	diagonal_desc = "Fans out in an L shape when diagonally swept."
	user_relative = TRUE
	max_targets = 4
	desc = "Sweeps in a massive arc, hitting up to four targets to the sides and ahead."

/datum/cleave_pattern/lance
	tile_offsets = list(list(0, 1), list(0, 2))
	max_targets = 1
	desc = "Lances forward, skewering a target and anyone behind them."

/datum/cleave_pattern/frontal_t
	tile_offsets = list(
		list(-1, 1), list(0, 1), list(1, 1), // The horizontal bar
		list(0, 2), // The top tip
	)
	user_relative = TRUE
	max_targets = 2
	desc = "Cleaves in a T-shaped pattern directly ahead."
