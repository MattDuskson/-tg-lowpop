/datum/intercept_text
	var/text
	/*
	var/prob_correct_person_lower = 20
	var/prob_correct_person_higher = 80
	var/prob_correct_job_lower = 20
	var/prob_correct_job_higher = 80
	var/prob_correct_prints_lower = 20
	var/prob_correct_print_higher = 80
	var/prob_correct_objective_lower = 20
	var/prob_correct_objective_higher = 80
	*/
	var/list/org_names_1 = list(
		"Blighted",
		"Defiled",
		"Unholy",
		"Murderous",
		"Ugly",
		"French",
		"Blue",
		"Farmer"
	)
	var/list/org_names_2 = list(
		"Reapers",
		"Swarm",
		"Rogues",
		"Menace",
		"Jeff Worshippers",
		"Drunks",
		"Strikers",
		"Creed"
	)
	var/list/anomalies = list(
		"Huge electrical storm",
		"Photon emitter",
		"Meson generator",
		"Blue swirly thing"
	)
	var/list/SWF_names = list(
		"Grand Wizard",
		"His Most Unholy Master",
		"The Most Angry",
		"Bighands",
		"Tall Hat",
		"Deadly Sandals"
	)
	var/list/changeling_names = list(
		"Odo",
		"The Thing",
		"Booga",
		"The Goatee of Wrath",
		"Tam Lin",
		"Species 3157",
		"Small Prick"
	)


/datum/intercept_text/proc/build(mode_type, datum/mind/correct_person)
	switch(mode_type)
		if("revolution")
			src.text = ""
			src.build_rev(correct_person)
			return src.text
		if("gang")
			src.text = ""
			src.build_gang(correct_person)
			return src.text
		if("cult")
			src.text = ""
			src.build_cult(correct_person)
			return src.text
		if("wizard")
			src.text = ""
			src.build_wizard(correct_person)
			return src.text
		if("nuke")
			src.text = ""
			src.build_nuke(correct_person)
			return src.text
		if("traitor")
			src.text = ""
			src.build_traitor(correct_person)
			return src.text
		if("changeling","traitorchan")
			src.text = ""
			src.build_changeling(correct_person)
			return src.text
		if("shadowling")
			src.text = ""
			src.build_shadowling(correct_person)
			return src.text
		else
			return null

// NOTE: Commentted out was the code which showed the chance of someone being an antag. If you want to re-add it, just uncomment the code.

/*
/datum/intercept_text/proc/pick_mob()
	var/list/dudes = list()
	for(var/mob/living/carbon/human/man in player_list)
		if (!man.mind) continue
		if (man.mind.assigned_role=="MODE") continue
		dudes += man
	if(dudes.len==0)
		return null
	return pick(dudes)


/datum/intercept_text/proc/pick_fingerprints()
	var/mob/living/carbon/human/dude = src.pick_mob()
	//if (!dude) return pick_fingerprints() //who coded that is totally crasy or just a traitor. -- rastaf0
	if(dude)
		return num2text(md5(dude.dna.uni_identity))
	else
		return num2text(md5(num2text(rand(1,10000))))
*/

/datum/intercept_text/proc/build_traitor(datum/mind/correct_person)
	var/name_1 = pick(src.org_names_1)
	var/name_2 = pick(src.org_names_2)

	/*
	var/fingerprints
	var/traitor_name
	var/prob_right_dude = rand(prob_correct_person_lower, prob_correct_person_higher)
	if(prob(prob_right_dude) && ticker.mode == "traitor")
		if(correct_person:assigned_role=="MODE")
			traitor_name = pick_mob()
		else
			traitor_name = correct_person:current
	else if(prob(prob_right_dude))
		traitor_name = pick_mob()
	else
		fingerprints = pick_fingerprints()
	*/

	src.text += "<BR><BR>El agente enemigo <B><U>[name_1] [name_2]</U></B> se ha infiltrado en su estación."
	src.text += "Se recomienda sospechar de todo el mundo ya que estos agentes pueden tener chips que mantendrian su memoria borrada hasta que fueran necesarios ser activas. El o ella podria incluso ser oficiales de alto rango"
	src.text += "<BR><HR>"

	/*
	src.text += "After some investigation, we "
	if(traitor_name)
		src.text += "are [prob_right_dude]% sure that [traitor_name] may have been involved, and should be closely observed."
		src.text += "<BR>Note: This group are known to be untrustworthy, so do not act on this information without proper discourse."
	else
		src.text += "discovered the following set of fingerprints ([fingerprints]) on sensitive materials, and their owner should be closely observed."
		src.text += "However, these could also belong to a current Centcom employee, so do not act on this without reason."
	*/


/datum/intercept_text/proc/build_cult(datum/mind/correct_person)
	var/name_1 = pick(src.org_names_1)
	var/name_2 = pick(src.org_names_2)
	/*
	var/traitor_name
	var/traitor_job
	var/prob_right_dude = rand(prob_correct_person_lower, prob_correct_person_higher)
	var/prob_right_job = rand(prob_correct_job_lower, prob_correct_job_higher)
	if(prob(prob_right_job) && is_convertable_to_cult(correct_person))
		if (correct_person)
			if(correct_person:assigned_role=="MODE")
				traitor_job = pick(get_all_jobs())
			else
				traitor_job = correct_person:assigned_role
	else
		var/list/job_tmp = get_all_jobs()
		job_tmp.Remove("Captain", "Chaplain", "AI", "Cyborg", "Security Officer", "Detective", "Head Of Security", "Head of Personnel", "Chief Engineer", "Research Director", "Chief Medical Officer")
		traitor_job = pick(job_tmp)
	if(prob(prob_right_dude) && ticker.mode == "cult")
		if(correct_person:assigned_role=="MODE")
			traitor_name = src.pick_mob()
		else
			traitor_name = correct_person:current
	else
		traitor_name = pick_mob()
	*/

	src.text += "<BR><BR>	Hemos obtenido información sobre la posible aparición del culto <B><U>[name_1] [name_2]</U></B> cerca de su estación. Aparentemente intenta expandir el conocimiento sobre artes oscuras dentro de la estación."
	src.text += "Se recomienda vigilar la estación en búsqueda de los siguientes indicios de cultismo: Rezar a un dios poco familiar, sacrificios, poderes magicos, aparición de criaturas magicas y portales al inframundo."
	src.text += "<BR><HR>"

	/*
	src.text += "Based on our intelligence, we are [prob_right_job]% sure that if true, someone doing the job of [traitor_job] on your station may have been converted "
	src.text += "and instilled with the idea of the flimsiness of the real world, seeking to destroy it. "
	if(prob(prob_right_dude))
		src.text += "<BR> In addition, we are [prob_right_dude]% sure that [traitor_name] may have also some in to contact with this "
		src.text += "organisation."
	src.text += "<BR>However, if this information is acted on without substantial evidence, those responsible will face severe repercussions."
	*/


/datum/intercept_text/proc/build_rev(datum/mind/correct_person)
	var/name_1 = pick(src.org_names_1)
	var/name_2 = pick(src.org_names_2)
	/*
	var/traitor_name
	var/traitor_job
	var/prob_right_dude = rand(prob_correct_person_lower, prob_correct_person_higher)
	var/prob_right_job = rand(prob_correct_job_lower, prob_correct_job_higher)
	if(prob(prob_right_job) && is_convertable_to_rev(correct_person))
		if (correct_person)
			if(correct_person.assigned_role=="MODE")
				traitor_job = pick(get_all_jobs())
			else
				traitor_job = correct_person.assigned_role
	else
		var/list/job_tmp = get_all_jobs()
		job_tmp-=nonhuman_positions
		job_tmp-=command_positions
		job_tmp.Remove("Security Officer", "Detective", "Warden", "MODE")
		traitor_job = pick(job_tmp)
	if(prob(prob_right_dude) && ticker.mode.config_tag == "revolution")
		if(correct_person.assigned_role=="MODE")
			traitor_name = src.pick_mob()
		else
			traitor_name = correct_person.current
	else
		traitor_name = src.pick_mob()
	*/

	src.text += "<BR><BR>Han llegado informes de un posible intento de revolución en su estación causado por <B><U>[name_1] [name_2]</U>."
	src.text += "Vigile cualquier actividad sospechosa entre la tripulación y asegurese de que los heads reporten situación periodicamente por su seguridad."
	src.text += "<BR><HR>"

	/*
	src.text += "Based on our intelligence, we are [prob_right_job]% sure that if true, someone doing the job of [traitor_job] on your station may have been brainwashed "
	src.text += "at a recent conference, and their department should be closely monitored for signs of mutiny. "
	if(prob(prob_right_dude))
		src.text += "<BR> In addition, we are [prob_right_dude]% sure that [traitor_name] may have also some in to contact with this "
		src.text += "organisation."
	src.text += "<BR>However, if this information is acted on without substantial evidence, those responsible will face severe repercussions."
	*/

/datum/intercept_text/proc/build_gang(datum/mind/correct_person)
	src.text += "<BR><BR>	Tenemos reportes de actividad criminal cerca de sus proximidades."
	src.text += "Asegúrense de mantener la ley y el orden en la estación y estén atentos a posibles apariciones de agresiones territoriales y graffitis en las paredes."
	src.text += "En el evento de que los criminales intenten tomar control de la estación, se ordena evacuar la estación junto con cualquier avance tecnológico hallado."
	src.text += "<BR><HR>"


/datum/intercept_text/proc/build_wizard(datum/mind/correct_person)
	var/SWF_desc = pick(SWF_names)
	src.text += "<BR><BR>La Federación Especial de Magos ha liberado recientemente a uno de sus mas poderosos magos, conocido como <B>\"[SWF_desc]\"</B> out of space jail. "
	src.text += "<BR><BR>Aun se encuentre a la fuga y ha sido localizado cerca del sistema donde ustedes estan localizados. Si encuentras a cualquier persona sospechosa"
	src.text += "por favor actuen con extrema precaucación, desconocemos las intenciones del sujeto en cuestion. Queda en su juicio informar a la tripulación pero"
	src.text += "desde Centcom recomendamos no hacerlo."
	src.text += "<BR><HR>"
	src.text += "Se recomienda al departamento de seguridad que vigile a la propia población, ya que se han conocido casos de subversion e incluso motin por incitacion de estos alborotadores"
	src.text += "<BR><HR>"
	src.text += "Apariencia del mago: Sandalias marrones, un gran sombrero azul, una voluptuosa barba blanca y la capacidad de utilizar hechizos"
	src.text += "<BR><HR>"

/datum/intercept_text/proc/build_nuke(datum/mind/correct_person)
	src.text += "<BR><BR>Centcom ha recibo un reporte sobre un posible plan de destrución contra una de nuestras estaciones en el area. Creemos que el 'Nuclear Authentication Disc'"
	src.text += "es el objetivo principal de esta misión. Recomendamos almacenarlo en algun ambiente seguro. Esto posiblemente causaria"
	src.text += "panico entre los miembros de la tripulación. Queda a su discreción con quien comparte esta información pero recomendamos hacerlo solo "
	src.text += "con los miembros de mayor confianza de la tripulación."
	src.text += "<BR><HR>"


/datum/intercept_text/proc/build_changeling(datum/mind/correct_person)
	var/cname = pick(src.changeling_names)
	var/orgname1 = pick(src.org_names_1)
	var/orgname2 = pick(src.org_names_2)
	/*
	var/changeling_name
	var/changeling_job
	var/prob_right_dude = rand(prob_correct_person_lower, prob_correct_person_higher)
	var/prob_right_job = rand(prob_correct_job_lower, prob_correct_job_higher)
	if(prob(prob_right_job))
		if(correct_person)
			if(correct_person:assigned_role=="MODE")
				changeling_job = pick(get_all_jobs())
			else
				changeling_job = correct_person:assigned_role
	else
		changeling_job = pick(get_all_jobs())
	if(prob(prob_right_dude) && ticker.mode == "changeling")
		if(correct_person:assigned_role=="MODE")
			changeling_name = correct_person:current
		else
			changeling_name = src.pick_mob()
	else
		changeling_name = src.pick_mob()
	*/

	src.text += "<BR><BR>Hemos recibo un reporte de que un peligroso Cambiaformas conocido como <B><U>\"[cname]\"</U></B> puede haberse infiltrado entre su tripulación. "
	src.text += "Estos Cambiaformas están asociados con <B><U>[orgname1] [orgname2]</U></B> y posiblemente intenten adquirir información sensible sobre nuestra corporación. "
	src.text += "Entre las posibles mutaciones de este Cambiaforma es posible que puedan adquirir el aspecto de cualquier persona de la tripulación, correr a grandes velocidades y adquirir capacidades físicas imposible para el empleado medio entre otras mutaciones desconocidas. "
	src.text += "Informes demuestran que son débiles ante cremaciones, desmembramientos causado por explosiones, extración del cerebro y al N20 aunque podría adquirir mutaciones que cubran estos defectos. "
	src.text += "Procedan con precaución ante cualquier anomalía y sospeche de todo el mundo. Recuerde: Puede adquirir la apariencia de cualquier persona, sospeche de todo el mundo y actué en consecuencia."
	src.text += "<BR><HR>"

/datum/intercept_text/proc/build_shadowling(datum/mind/correct_person)
	src.text += "<br><br>Avistamiento de una extraña criatura alienigena han sido observados en su area. Estos aliens poseen la habilidad de esclavizar a su tripulación y alimentarse de ellos."
	src.text += "Tengan cuidado de zonas oscuras y mantengan la luces en el mejor estado posible. Monitorize todo miembro de la tripulación con comportamiento sospechosa y elimínelos si es necesario."
	src.text += "Investiga todos los avistamientos sospechosos en mantenimiento."
	src.text += "<br><br>"
