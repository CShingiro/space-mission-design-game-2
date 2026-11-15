class_name GameSimulation

static func get_dashboard(design: Dictionary, launch_vehicles: Array) -> Dictionary:
	var issues = []
	var total_mass = 0.0
	var power_use = 0.0
	var power_gen = 0.0
	var total_cost = 0.0
	var data_per_day = 0.0
	
	# 1. Fetch Parts
	var bus = _find_part("bus", design.get("bus", ""))
	var power = _find_part("power", design.get("power", ""))
	var battery = _find_part("battery", design.get("battery", ""))
	var comms = _find_part("comms", design.get("comms", ""))
	var computer = _find_part("computer", design.get("computer", ""))
	var adcs = _find_part("adcs", design.get("adcs", ""))
	var prop = _find_part("propulsion", design.get("propulsion", ""))
	var ls = _find_part("life_support", design.get("life_support", "ls_none"))
	var esc = _find_part("escape_system", design.get("escape_system", "esc_none"))
	
	var crew = int(design.get("crew", 0))
	if bus.is_empty() or power.is_empty(): 
		return {"can_launch": false, "mass": 0, "launch_capacity": 0, "power_use": 0, "power_gen": 0, "data_per_day": 0, "total_cost": 0, "issues": [{"severity": "block", "what": "Missing core parts", "why": "You must select a bus and power source.", "fix": "Select them in the menu."}]}

	# 2. Mass & Cost
	total_mass += bus.get("mass", 0)
	total_cost += bus.get("cost", 0)
	
	for p in [power, battery, comms, computer, adcs, prop, esc]:
		if not p.is_empty():
			total_mass += p.get("mass", 0)
			total_cost += p.get("cost", 0)
			power_use += p.get("power", 0)
			data_per_day += p.get("data_gb_day", 0)

	if crew > 0 and not ls.is_empty():
		total_mass += ls.get("mass", 0) + (ls.get("mass_per_crew", 0) * crew)
		total_cost += ls.get("cost", 0)
		power_use += ls.get("power_per_crew", 0) * crew

	var instruments = design.get("instruments", [])
	for i in instruments:
		var ins = _find_part("instruments", i)
		if not ins.is_empty():
			total_mass += ins.get("mass", 0)
			total_cost += ins.get("cost", 0)
			power_use += ins.get("power", 0)
			data_per_day += ins.get("data_gb_day", 0)

	var orbit = GameOrbits.ORBITS.get(design.get("orbit", "leo"), {})
	var lv = _find_vehicle(design.get("launch_vehicle", ""), launch_vehicles)
	var mission = GameMissions.MISSIONS.get(design.get("mission", "m_satellite"))
	
	# Clean capacity calculation
	var launch_capacity = float(lv.get("capacity_leo", 0)) * float(orbit.get("launch_factor", 1.0)) if not lv.is_empty() else 0.0
	if not lv.is_empty(): 
		total_cost += float(lv.get("cost", 0))

	power_gen = power.get("watts", 0) * (orbit.get("sun_fraction", 1.0) if power.get("uses_sun", false) else 1.0)
	power_use = power_use * 1.10

	# --- VALIDATION (Blockers) ---
	if not orbit.get("id") in mission.get("allowed_orbits", []):
		issues.append({"severity": "block", "what": "Wrong orbit for mission", "why": "Mission requires %s" % str(mission.allowed_orbits), "fix": "Pick a valid orbit."})
	
	if not lv.is_empty() and not orbit.get("id") in lv.get("orbits", []):
		issues.append({"severity": "block", "what": "Rocket can't reach orbit", "why": "%s only supports %s" % [lv.get("name", ""), str(lv.get("orbits", []))], "fix": "Bigger rocket or closer orbit."})
	
	if total_mass > launch_capacity:
		issues.append({"severity": "block", "what": "Too heavy for rocket", "why": "Mass %.0fkg > Capacity %.0fkg" % [total_mass, launch_capacity], "fix": "Bigger rocket or lighter parts."})

	if mission.get("min_crew", 0) > 0:
		if bus.get("class", "") != "crewed":
			issues.append({"severity": "block", "what": "Astronauts need a crew capsule", "why": "Standard buses cannot hold people.", "fix": "Select a crew capsule."})
		if crew > bus.get("seats", 0):
			issues.append({"severity": "block", "what": "Not enough seats", "why": "You have %d crew but %d seats." % [crew, bus.get("seats", 0)], "fix": "Bigger capsule or fewer crew."})
		if not lv.get("human_rated", false):
			issues.append({"severity": "block", "what": "Rocket not human-rated", "why": "Crew rockets need extra safety checks.", "fix": "Use a medium launcher."})
		if not ls.get("id") == "ls_redundant" and not ls.get("id") == "ls_basic":
			issues.append({"severity": "block", "what": "No life support", "why": "People need air, water, and heat.", "fix": "Add life support."})

	var need = orbit.get("needs_propulsion", "none")
	var prop_type = prop.get("type", "none")
	if need == "chemical" and prop_type == "none":
		issues.append({"severity": "block", "what": "Need an engine", "why": "You must brake to enter this orbit.", "fix": "Add a chemical engine."})
	elif need == "lander" and prop_type != "lander":
		issues.append({"severity": "block", "what": "Need a landing engine", "why": "You must slow down to touch the surface.", "fix": "Add a landing engine."})
	elif need == "small" and prop_type == "none":
		issues.append({"severity": "block", "what": "Need thrusters to dock", "why": "You need cold-gas thrusters to approach the station.", "fix": "Add a cold-gas thruster."})

	# --- RISKS ---
	var missing = []
	for tag in mission.get("required_tags", []):
		var has_tag = false
		for i in instruments:
			var ins = _find_part("instruments", i)
			if tag in ins.get("tags", []): has_tag = true
		if not has_tag: missing.append(tag)
		
	if missing.size() > 0:
		issues.append({"severity": "risk", "what": "Missing required instruments", "why": "You don't have instruments for: %s" % str(missing), "fix": "Add the required instruments."})

	if power_gen < power_use:
		issues.append({"severity": "risk", "what": "Not enough power", "why": "Gen %.0fW < Use %.0fW" % [power_gen, power_use], "fix": "Bigger solar array or fewer parts."})

	var total_data = 0.0
	for i in instruments:
		var ins = _find_part("instruments", i)
		total_data += ins.get("data_gb_day", 0)
		
	if total_data > 0:
		var has_good_comms = comms.get("rate_mbps", 0) >= 50
		if not has_good_comms:
			issues.append({
				"severity": "risk", 
				"what": "Weak radio for science data", 
				"why": "Instruments make %.1f Gb/day, but the radio is too slow." % total_data, 
				"fix": "Upgrade to an X-band transmitter."
			})

	var can_launch = true
	for issue in issues:
		if issue["severity"] == "block": can_launch = false

	return {
		"mass": total_mass, "launch_capacity": launch_capacity,
		"power_use": power_use, "power_gen": power_gen, "data_per_day": data_per_day,
		"total_cost": total_cost, "can_launch": can_launch, "issues": issues
	}

static func run_mission(design: Dictionary, launch_vehicles: Array) -> Dictionary:
	var dash = get_dashboard(design, launch_vehicles)
	var log = []
	var findings = []
	
	if not dash["can_launch"]:
		return {"status": "Not launched", "log": ["Launch was not approved."], "score": 0, "science": 0.0}

	var orbit = GameOrbits.ORBITS.get(design.get("orbit", "leo"))
	var lv = _find_vehicle(design.get("launch_vehicle", ""), launch_vehicles)
	var mission = GameMissions.MISSIONS.get(design.get("mission", "m_satellite"))
	var esc = _find_part("escape_system", design.get("escape_system", "esc_none"))
	var crew = int(design.get("crew", 0))
	
	# --- LAUNCH RISK ---
	var launch_roll = randf()
	if launch_roll > lv.get("reliability", 1.0):
		log.append("Month 0: LAUNCH FAILURE - the rocket malfunctioned during ascent.")
		if crew > 0:
			if randf() < esc.get("escape_success", 0.0):
				return {"status": "Failure", "log": log, "score": 0, "science": 0.0, "debrief": ["The abort system saved the crew, but the mission was lost."]}
			else:
				return {"status": "Crew lost", "log": log, "score": 0, "science": 0.0, "debrief": ["The crew was lost. Always use an abort system."]}
		return {"status": "Failure", "log": log, "score": 0, "science": 0.0}
	
	log.append("Month 0: Launch successful!")
	var travel = orbit.get("travel_months", 0)
	var operated = 0
	var planned = 12
	var science = 0.0
	
	# --- MONTH LOOP ---
	for month in range(1, travel + planned + 1):
		var op_month = month - travel
		if op_month <= 0: 
			if month == travel: log.append("Month %d: Arrived at destination." % month)
			continue
			
		var r = randf()
		if r < 0.02: log.append("Month %d: Solar storm! Systems rebooted." % month)
		elif r < 0.03: log.append("Month %d: Micrometeoroid hit - power dropped 15%%." % month)
		
		var month_sci = 0.0
		for i in design.get("instruments", []):
			var ins = _find_part("instruments", i)
			var is_useful = false
			for t in mission.get("useful_tags", []):
				if t in ins.get("tags", []): is_useful = true
			month_sci += float(ins.get("science", 0)) * (1.0 if is_useful else 0.25)
		
		month_sci *= orbit.get("surface_science_bonus", 1.0)
		science += month_sci
		operated += 1
		log.append("Month %d: Nominal operations. Science +%.1f" % [month, month_sci])

	# --- FINAL OUTCOME ---
	var met_life = operated >= mission.get("min_lifetime_months", 6)
	var met_sci = science >= mission.get("target_science", 100)
	var missing_tags = false
	for tag in mission.get("required_tags", []):
		var has_tag = false
		for i in design.get("instruments", []):
			if tag in _find_part("instruments", i).get("tags", []): has_tag = true
		if not has_tag: missing_tags = true

	var status = "Failure"
	if met_life and met_sci and not missing_tags:
		status = "Full success"
	elif science >= mission.get("target_science", 100) * 0.5:
		status = "Partial success"

	var score = int(science * 10.0) if status != "Failure" else 0
	return {
		"status": status, "months_operated": operated, "science": science,
		"score": score, "log": log
	}

static func _find_part(category: String, id: String) -> Dictionary:
	var list = GameParts.PARTS.get(category, [])
	for p in list:
		if p.get("id") == id: return p
	return {}

static func _find_vehicle(id: String, vehicles: Array) -> Dictionary:
	for v in vehicles:
		if v.get("id") == id: return v
	return {}