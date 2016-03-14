var/datum/subsystem/job/SSjob

/datum/subsystem/job
	name = "Jobs"
	priority = 5

	var/list/occupations = list()		//List of all jobs
	var/list/unassigned = list()		//Players who need jobs
	var/list/job_debug = list()			//Debug info
	var/initial_players_to_assign = 0 	//used for checking against population caps

/datum/subsystem/job/New()
	NEW_SS_GLOBAL(SSjob)


/datum/subsystem/job/Initialize(timeofday, zlevel)
	if (zlevel)
		return ..()
	SetupOccupations()
	if(config.load_jobs_from_txt)
		LoadJobs()
	..()


/datum/subsystem/job/proc/SetupOccupations(faction = "Station")
	occupations = list()
	var/list/all_jobs = subtypesof(/datum/job)
	if(!all_jobs.len)
		world << "<span class='boldannounce'>Error setting up jobs, no job datums found</span>"
		return 0

	for(var/J in all_jobs)
		var/datum/job/job = new J()
		if(!job)
			continue
		if(job.faction != faction)
			continue
		if(!job.config_check())
			continue
		occupations += job

	return 1


/datum/subsystem/job/proc/Debug(text)
	if(!Debug2)
		return 0
	job_debug.Add(text)
	return 1


/datum/subsystem/job/proc/GetJob(rank)
	if(!rank)
		return null
	for(var/datum/job/J in occupations)
		if(!J)
			continue
		if(J.title == rank)
			return J
	return null

/datum/subsystem/job/proc/AssignRole(mob/new_player/player, rank, latejoin=0)
	Debug("Running AR, Player: [player], Rank: [rank], LJ: [latejoin]")
	if(player && player.mind && rank)
		var/datum/job/job = GetJob(rank)
		if(!job)
			return 0
		if(jobban_isbanned(player, rank))
			return 0
		if(!job.player_old_enough(player.client))
			return 0
		var/position_limit = job.total_positions
		if(!latejoin)
			position_limit = job.spawn_positions
		Debug("Player: [player] is now Rank: [rank], JCP:[job.current_positions], JPL:[position_limit]")
		player.mind.assigned_role = rank
		unassigned -= player
		job.current_positions++
		return 1
	Debug("AR has failed, Player: [player], Rank: [rank]")
	return 0


/datum/subsystem/job/proc/FindOccupationCandidates(datum/job/job, level, flag)
	Debug("Running FOC, Job: [job], Level: [level], Flag: [flag]")
	var/list/candidates = list()
	for(var/mob/new_player/player in unassigned)
		if(jobban_isbanned(player, job.title))
			Debug("FOC isbanned failed, Player: [player]")
			continue
		if(!job.player_old_enough(player.client))
			Debug("FOC player not old enough, Player: [player]")
			continue
		if(flag && (!(flag in player.client.prefs.be_special)))
			Debug("FOC flag failed, Player: [player], Flag: [flag], ")
			continue
		if(player.mind && job.title in player.mind.restricted_roles)
			Debug("FOC incompatible with antagonist role, Player: [player]")
			continue
		if(config.enforce_human_authority && !player.client.prefs.pref_species.qualifies_for_rank(job.title, player.client.prefs.features))
			Debug("FOC non-human failed, Player: [player]")
			continue
		if(player.client.prefs.GetJobDepartment(job, level) & job.flag)
			Debug("FOC pass, Player: [player], Level:[level]")
			candidates += player
	return candidates

/datum/subsystem/job/proc/FindValidCandidates(datum/job/job, flag)
	var/list/candidates = list()
	for(var/mob/new_player/player in unassigned)
		if(jobban_isbanned(player, job.title))
			Debug("FOC isbanned failed, Player: [player]")
			continue
		if(!job.player_old_enough(player.client))
			Debug("FOC player not old enough, Player: [player]")
			continue
		if(flag && (!(flag in player.client.prefs.be_special)))
			Debug("FOC flag failed, Player: [player], Flag: [flag], ")
			continue
		if(player.mind && job.title in player.mind.restricted_roles)
			Debug("FOC incompatible with antagonist role, Player: [player]")
			continue
		if(config.enforce_human_authority && !player.client.prefs.pref_species.qualifies_for_rank(job.title, player.client.prefs.features))
			Debug("FOC non-human failed, Player: [player]")
			continue
		candidates += player
	return candidates

/datum/subsystem/job/proc/GiveRandomJob(mob/new_player/player)
	Debug("GRJ Giving random job, Player: [player]")
	for(var/datum/job/job in shuffle(occupations))
		if(!job)
			continue

		if(istype(job, GetJob("Assistant"))) // We don't want to give him assistant, that's boring!
			continue

		if(job in command_positions) //If you want a command position, select it!
			continue

		if(jobban_isbanned(player, job.title))
			Debug("GRJ isbanned failed, Player: [player], Job: [job.title]")
			continue

		if(!job.player_old_enough(player.client))
			Debug("GRJ player not old enough, Player: [player]")
			continue

		if(player.mind && job.title in player.mind.restricted_roles)
			Debug("GRJ incompatible with antagonist role, Player: [player], Job: [job.title]")
			continue

		if(config.enforce_human_authority && !player.client.prefs.pref_species.qualifies_for_rank(job.title, player.client.prefs.features))
			Debug("GRJ non-human failed, Player: [player]")
			continue


		if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
			Debug("GRJ Random job given, Player: [player], Job: [job]")
			AssignRole(player, job.title)
			unassigned -= player
			break

/datum/subsystem/job/proc/ResetOccupations()
	for(var/mob/new_player/player in player_list)
		if((player) && (player.mind))
			player.mind.assigned_role = null
			player.mind.special_role = null
	SetupOccupations()
	unassigned = list()
	return

/datum/subsystem/job/proc/FillCaptainPosition()
	if(unassigned.len >= 6)
		var/captain_selected = 0
		var/datum/job/job = GetJob("Captain")
		if(!job)
			return 0
		for(var/i = job.total_positions, i > 0, i--)
			for(var/level = 1 to 3)
				var/list/candidates = list()
				candidates = FindOccupationCandidates(job, level)
				if(candidates.len)
					var/mob/new_player/candidate = pick(candidates)
					if(AssignRole(candidate, "Captain"))
						if(adminlog)
							message_admins("Capitan elegido por eleccion de jugador")
							log_game("Capitan elegido por eleccion de jugador")
						captain_selected++
						break
		if(captain_selected)
			return 1
		//Disabled mientras no sepamos que hacer con esto.
		/*for(var/i = job.total_positions, i > 0, i--)
			for(var/level = 1 to 3)
				var/list/candidates = list()
				candidates = FindOccupationCandidates(GetJob("Head of Personnel"), level)
				if(candidates.len)
					var/mob/new_player/candidate = pick(candidates)
					if(AssignRole(candidate, "Captain"))
						if(adminlog)
							message_admins("Capitan elegido por ser HOP, aver studiao")
							log_game("Capitan elegido por ser HOP, aver studiao")
						captain_selected++
						break
		if(captain_selected)
			return 1
		else
			if(adminlog)
				message_admins("No hay jugadores que quieran ser HOP")
				log_game("No hay jugadores que quieran ser HOP")
		if(adminlog)
			message_admins("Empieza la eleccion random de capitan")
			log_game("Empieza la eleccion random de capitan")
		var/list/candidates = list()
		candidates = FindValidCandidates(job)
		if(candidates.len)
			var/mob/new_player/candidate = pick(candidates)
			if(AssignRole(candidate, "Captain"))
				if(adminlog)
					message_admins("Capitan elegido por eleccion de jugador")
					log_game("Capitan elegido por eleccion de jugador")
				captain_selected++
		if(captain_selected)
			return 1
		else
			if(adminlog)
				message_admins("No hay jugadores que puedan ser capitan todos son too young")
				log_game("No hay jugadores que puedan ser capitan todos son too young")*/
	else
		if(adminlog)
			message_admins("No hay suficientes jugadores para asignar un capitan")
			log_game("No hay suficientes jugadores para asignar un capitan")
		return 0
	return 0


//This proc is called before the level loop of DivideOccupations() and will try to select a head, ignoring ALL non-head preferences for every level until
//it locates a head or runs out of levels to check
//This is basically to ensure that there's atleast a few heads in the round
/datum/subsystem/job/proc/FillHeadPosition()
	for(var/level = 1 to 3)
		for(var/command_position in command_positions)
			var/datum/job/job = GetJob(command_position)
			if(!job)
				continue
			if((job.current_positions >= job.total_positions) && job.total_positions != -1)
				continue
			var/list/candidates = FindOccupationCandidates(job, level)
			Debug(candidates)
			if(!candidates.len)
				continue
			var/mob/new_player/candidate = pick(candidates)
			if(AssignRole(candidate, command_position))
				return 1
	return 0

/datum/subsystem/job/proc/FillEssentialPosition(oficio, jefe)
	var/datum/job/job = GetJob(jefe)
	var/boss = 0
	var/cantidad = 0
	if(!job)
		cantidad = 0
		boss = 1
	else
		cantidad = job.current_positions
		boss = 0
	job = GetJob(oficio)
	cantidad += job.current_positions
	if(cantidad == 0)
		if(boss)
			job = GetJob(jefe)
		for(var/level = 1 to 3)
			var/list/candidates = list()
			candidates = FindOccupationCandidates(job, level)
			if(candidates.len)
				var/mob/new_player/candidate = pick(candidates)
				if(AssignRole(candidate, job))
					if(boss)
						if(adminlog)
							message_admins("[jefe] elegido por eleccion de jugador")
							log_game("[jefe] elegido por eleccion de jugador")
					else
						if(adminlog)
							message_admins("[oficio] elegido por eleccion de jugador")
							log_game("[oficio] elegido por eleccion de jugador")
					return 1
					break
		if(boss)
			job = GetJob(oficio)
		for(var/level = 1 to 3)
			var/list/candidates = list()
			candidates = FindOccupationCandidates(job, level)
			if(candidates.len)
				var/mob/new_player/candidate = pick(candidates)
				if(AssignRole(candidate, job))
					if(boss)
						if(adminlog)
							message_admins("[jefe] elegido por eleccion de jugador")
							log_game("[jefe] elegido por eleccion de jugador")
					else
						if(adminlog)
							message_admins("[oficio] elegido por eleccion de jugador")
							log_game("[oficio] elegido por eleccion de jugador")
					return 1
					break
	else
		if(adminlog)
			message_admins("Ya hay suficientes [oficio]")
			log_game("Ya hay suficientes [oficio]")
	return 0


//This proc is called at the start of the level loop of DivideOccupations() and will cause head jobs to be checked before any other jobs of the same level
//This is also to ensure we get as many heads as possible
/datum/subsystem/job/proc/CheckHeadPositions(level)
	for(var/command_position in command_positions)
		var/datum/job/job = GetJob(command_position)
		if(!job)
			continue
		if((job.current_positions >= job.total_positions) && job.total_positions != -1)
			continue
		var/list/candidates = FindOccupationCandidates(job, level)
		if(!candidates.len)
			continue
		var/mob/new_player/candidate = pick(candidates)
		AssignRole(candidate, command_position)
	return


/datum/subsystem/job/proc/FillAIPosition()
	var/ai_selected = 0
	var/datum/job/job = GetJob("AI")
	if(!job)
		return 0
	for(var/i = job.total_positions, i > 0, i--)
		for(var/level = 1 to 3)
			var/list/candidates = list()
			candidates = FindOccupationCandidates(job, level)
			if(candidates.len)
				var/mob/new_player/candidate = pick(candidates)
				if(AssignRole(candidate, "AI"))
					ai_selected++
					break
	if(ai_selected)
		return 1
	return 0

/datum/subsystem/job/proc/DivideOccupations()
	if(ticker)
		for(var/datum/job/ai/A in occupations)
			if(ticker.triai)
				A.spawn_positions = 3

	for(var/mob/new_player/player in player_list)
		if(player.ready && player.mind && !player.mind.assigned_role)
			unassigned += player

	initial_players_to_assign = unassigned.len

	if(unassigned.len == 0)
		return 0

	setup_officer_positions()

	if(config.minimal_access_threshold)
		if(config.minimal_access_threshold > unassigned.len)
			config.jobs_have_minimal_access = 0
		else
			config.jobs_have_minimal_access = 1

	unassigned = shuffle(unassigned)

	HandleFeedbackGathering()

	var/datum/job/assist = new /datum/job/assistant()
	var/list/assistant_candidates = FindOccupationCandidates(assist, 3)

	for(var/mob/new_player/player in assistant_candidates)
		AssignRole(player, "Assistant")
		assistant_candidates -= player

	if(adminlog)
		message_admins("Empieza la selecion de capitan, ahora mismo tenemos [unassigned.len] jugadores a asignar")
		log_game("Empieza la selecion de capitan, ahora mismo tenemos [unassigned.len] jugadores a asignar")
	FillCaptainPosition()


	if(adminlog)
		message_admins("Empieza la selecion de jobs esenciales, ahora mismo tenemos [unassigned.len] jugadores a asignar")
		log_game("Empieza la selecion de jobs esenciales, ahora mismo tenemos [unassigned.len] jugadores a asignar")
	FillEssentialPosition("Station Engineer", "Chief Engineer")
	FillEssentialPosition("Chief Medical Officer", "Medical Doctor")

	if(adminlog)
		message_admins("Empieza la selecion de heads, ahora mismo tenemos [unassigned.len] jugadores a asignar")
		log_game("Empieza la selecion de heads, ahora mismo tenemos [unassigned.len] jugadores a asignar")
	FillHeadPosition()

	if(adminlog)
		message_admins("Empieza la selecion de la IA, ahora mismo tenemos [unassigned.len] jugadores a asignar")
		log_game("Empieza la selecion de la IA, ahora mismo tenemos [unassigned.len] jugadores a asignar")
	FillAIPosition()


	if(adminlog)
		message_admins("Empieza la selecion del resto de la tripuilacion, ahora mismo tenemos [unassigned.len] jugadores a asignar")
		log_game("Empieza la selecion del resto de la tripuilacion, ahora mismo tenemos [unassigned.len] jugadores a asignar")


	var/list/shuffledoccupations = shuffle(occupations)
	for(var/level = 1 to 3)
		CheckHeadPositions(level)

		for(var/mob/new_player/player in unassigned)
			if(PopcapReached())
				RejectPlayer(player)

			for(var/datum/job/job in shuffledoccupations) // SHUFFLE ME BABY
				if(!job)
					continue

				if(jobban_isbanned(player, job.title))
					Debug("DO isbanned failed, Player: [player], Job:[job.title]")
					continue

				if(!job.player_old_enough(player.client))
					Debug("DO player not old enough, Player: [player], Job:[job.title]")
					continue

				if(player.mind && job.title in player.mind.restricted_roles)
					Debug("DO incompatible with antagonist role, Player: [player], Job:[job.title]")
					continue

				if(config.enforce_human_authority && !player.client.prefs.pref_species.qualifies_for_rank(job.title, player.client.prefs.features))
					Debug("DO non-human failed, Player: [player], Job:[job.title]")
					continue

				if(player.client.prefs.GetJobDepartment(job, level) & job.flag)
					if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
						Debug("DO pass, Player: [player], Level:[level], Job:[job.title]")
						AssignRole(player, job.title)
						unassigned -= player
						break

	for(var/mob/new_player/player in unassigned)
		if(PopcapReached())
			RejectPlayer(player)
		else if(jobban_isbanned(player, "Assistant"))
			GiveRandomJob(player)

	for(var/mob/new_player/player in unassigned)
		if(PopcapReached())
			RejectPlayer(player)
		else if(player.client.prefs.userandomjob)
			GiveRandomJob(player)

	for(var/mob/new_player/player in unassigned)
		if(PopcapReached())
			RejectPlayer(player)
		AssignRole(player, "Assistant")
	return 1

//Gives the player the stuff he should have with his rank
/datum/subsystem/job/proc/EquipRank(mob/living/H, rank, joined_late=0)
	var/datum/job/job = GetJob(rank)

	H.job = rank

	//If we joined at roundstart we should be positioned at our workstation
	if(!joined_late)
		var/obj/S = null
		for(var/obj/effect/landmark/start/sloc in start_landmarks_list)
			if(sloc.name != rank)
				S = sloc //so we can revert to spawning them on top of eachother if something goes wrong
				continue
			if(locate(/mob/living) in sloc.loc)
				continue
			S = sloc
			break
		if(!S) //if there isn't a spawnpoint send them to latejoin, if there's no latejoin go yell at your mapper
			world.log << "Couldn't find a round start spawn point for [rank]"
			S = pick(latejoin)
		if(!S) //final attempt, lets find some area in the arrivals shuttle to spawn them in to.
			world.log << "Couldn't find a round start latejoin spawn point."
			for(var/turf/T in get_area_turfs(/area/shuttle/arrival))
				if(!T.density)
					var/clear = 1
					for(var/obj/O in T)
						if(O.density)
							clear = 0
							break
					if(clear)
						S = T
						continue
		if(istype(S, /obj/effect/landmark) && istype(S.loc, /turf))
			H.loc = S.loc

	if(H.mind)
		H.mind.assigned_role = rank

	if(job)
		var/new_mob = job.equip(H)
		if(ismob(new_mob))
			H = new_mob
		job.apply_fingerprints(H)

	H << "<b>Tu eres [rank].</b>"
	H << "<b>Como [rank] respondes directamente ante [job.supervisors]. Circunstancias especiales pueden cambiar esto.</b>"
	H << "<b>Para hablar por tu radio puedes usar ; para la radio general o :h para la de tu grupo..</b>"
	if(job.req_admin_notify)
		H << "<b>Eres un job importante para el desarrollo de la partida, si te vas a desconectar avisa a un admin.</b>"
	if(config.minimal_access_threshold)
		H << "<FONT color='blue'><B>As this station was initially staffed with a [config.jobs_have_minimal_access ? "full crew, only your job's necessities" : "skeleton crew, additional access may"] have been added to your ID card.</B></font>"
	return 1


/datum/subsystem/job/proc/setup_officer_positions()
	var/datum/job/J = SSjob.GetJob("Security Officer")
	if(!J)
		throw EXCEPTION("setup_officer_positions(): Security officer job is missing")

	if(config.security_scaling_coeff > 0)
		if(J.spawn_positions > 0)
			var/officer_positions = min(12, max(J.spawn_positions, round(unassigned.len/config.security_scaling_coeff))) //Scale between configured minimum and 12 officers
			Debug("Setting open security officer positions to [officer_positions]")
			J.total_positions = officer_positions
			J.spawn_positions = officer_positions

	//Spawn some extra eqipment lockers if we have more than 5 officers
	var/equip_needed = J.total_positions
	if(equip_needed < 0) // -1: infinite available slots
		equip_needed = 12
	for(var/i=equip_needed-5, i>0, i--)
		if(secequipment.len)
			var/spawnloc = secequipment[1]
			new /obj/structure/closet/secure_closet/security/sec(spawnloc)
			secequipment -= spawnloc
		else //We ran out of spare locker spawns!
			break


/datum/subsystem/job/proc/LoadJobs()
	var/jobstext = return_file_text("config/jobs.txt")
	for(var/datum/job/J in occupations)
		var/regex/jobs = new("[J.title]=(-1|\\d+),(-1|\\d+)")
		jobs.Find(jobstext)
		J.total_positions = text2num(jobs.group[1])
		J.spawn_positions = text2num(jobs.group[2])

/datum/subsystem/job/proc/HandleFeedbackGathering()
	for(var/datum/job/job in occupations)
		var/tmp_str = "|[job.title]|"

		var/level1 = 0 //high
		var/level2 = 0 //medium
		var/level3 = 0 //low
		var/level4 = 0 //never
		var/level5 = 0 //banned
		var/level6 = 0 //account too young
		for(var/mob/new_player/player in player_list)
			if(!(player.ready && player.mind && !player.mind.assigned_role))
				continue //This player is not ready
			if(jobban_isbanned(player, job.title))
				level5++
				continue
			if(!job.player_old_enough(player.client))
				level6++
				continue
			if(player.client.prefs.GetJobDepartment(job, 1) & job.flag)
				level1++
			else if(player.client.prefs.GetJobDepartment(job, 2) & job.flag)
				level2++
			else if(player.client.prefs.GetJobDepartment(job, 3) & job.flag)
				level3++
			else level4++ //not selected

		tmp_str += "HIGH=[level1]|MEDIUM=[level2]|LOW=[level3]|NEVER=[level4]|BANNED=[level5]|YOUNG=[level6]|-"
		feedback_add_details("job_preferences",tmp_str)

/datum/subsystem/job/proc/PopcapReached()
	if(config.hard_popcap || config.extreme_popcap)
		var/relevent_cap = max(config.hard_popcap, config.extreme_popcap)
		if((initial_players_to_assign - unassigned.len) >= relevent_cap)
			return 1
	return 0

/datum/subsystem/job/proc/RejectPlayer(mob/new_player/player)
	if(player.mind && player.mind.special_role)
		return
	Debug("Popcap overflow Check observer located, Player: [player]")
	player << "<b>You have failed to qualify for any job you desired.</b>"
	unassigned -= player
	player.ready = 0
