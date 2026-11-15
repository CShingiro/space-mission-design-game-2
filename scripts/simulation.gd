class_name GameSimulation

const SOLAR_DEGRADATION = 0.025
const INTEGRATION_FACTOR = 0.25

# Returns the live dashboard dictionary
static func get_dashboard(design: Dictionary) -> Dictionary:
	var issues = []
	var total_mass = 0.0
	var power_use = 0.0
	var power_gen = 0.0
	var total_cost = 0.0
	var data_per_day = 0.0
	
	# --- Mass & Cost Calculation ---
	var bus = _find_part("bus", design.get("bus", ""))
	var power = _find_part("power", design.get("power", ""))
	var battery = _find_part("battery", design.get("battery", ""))
	var comms = _find_part("comms", design.get("comms", ""))
	var computer = _find_part("computer", design.get("computer", ""))
	var adcs = _find_part("adcs", design.get("adcs", ""))
	var prop = _find_part("propulsion", design.get("propulsion", ""))
	var ls = _find_part("life_support", design.get("life_support", "ls_none"))
	
	var crew = int(design.get("crew", 0))
	if bus.is_empty() or power.is_empty(): return {"can_launch": false, "issues": [{"what": "Missing core parts"}]}

	total_mass += bus.get("mass", 0)
	total_cost += bus.get("cost", 0)
	
	# Subsystems
	for p in [power, battery, comms, computer, adcs, prop]:
		if not p.is_empty():
			total_mass += p.get("mass", 0)
			total_cost += p.get("cost", 0)
			power_use += p.get("power", 0)
			data_per_day += p.get("data_gb_day", 0)

	# Life support
	if crew > 0 and not ls.is_empty():
		total_mass += ls.get("mass", 0) + (ls.get("mass_per_crew", 0) * crew)
		total_cost += ls.get("cost", 0)
		power_use += ls.get("power_per_crew", 0) * crew

	# Instruments
	var instruments = design.get("instruments", [])
	for i in instruments:
		var ins = _find_part("instruments", i)
		if not ins.is_empty():
			total_mass += ins.get("mass", 0)
			total_cost += ins.get("cost", 0)
			power_use += ins.get("power", 0)
			data_per_day += ins.get("data_gb_day", 0)

	# Power & Launch
	var orbit = GameOrbits.ORBITS.get(design.get("orbit", "leo"), {})
	var lv = _find_vehicle(design.get("launch_vehicle", ""))
	
	var launch_capacity = 0.0
	if not lv.is_empty():
		launch_capacity = lv.get("capacity_leo", 0) * orbit.get("launch_factor", 1.0)
		total_cost += lv.get("cost", 0)

	power_gen = power.get("watts", 0) * (orbit.get("sun_fraction", 1.0) if power.get("uses_sun", false) else 1.0)
	power_use = power_use * 1.10 # Housekeeping

	# --- Validation ---
	if total_mass > launch_capacity:
		issues.append({"severity": "block", "what": "Too heavy for rocket!", "why": "Mass %.0fkg > Capacity %.0fkg" % [total_mass, launch_capacity], "fix": "Bigger rocket or lighter parts."})
	
	if power_gen < power_use:
		issues.append({"severity": "risk", "what": "Not enough power", "why": "Gen %.0fW < Use %.0fW" % [power_gen, power_use], "fix": "Bigger solar array."})

	var can_launch = true
	for issue in issues:
		if issue["severity"] == "block": can_launch = false

	return {
		"mass": total_mass,
		"launch_capacity": launch_capacity,
		"power_use": power_use,
		"power_gen": power_gen,
		"data_per_day": data_per_day,
		"total_cost": total_cost,
		"can_launch": can_launch,
		"issues": issues
	}

# --- Run the Mission ---
static func run_mission(design: Dictionary) -> Dictionary:
	var dash = get_dashboard(design)
	var log = []
	
	if not dash["can_launch"]:
		return {"status": "Not launched", "log": ["Launch blocked by design issues."], "score": 0, "science": 0.0}

	log.append("Launch successful!")
	var operated_months = int(design.get("planned_months", 6))
	var science = 0.0
	
	for month in range(1, operated_months + 1):
		var month_sci = 0.0
		for i in design.get("instruments", []):
			var ins = _find_part("instruments", i)
			# Explicitly cast to float to prevent GDScript type errors
			month_sci += float(ins.get("science", 0))
			
		science += month_sci
		log.append("Month %d: Nominal operations. Science +%.1f" % [month, month_sci])

	# Simple scoring metric
	var score = int(science * 10.0)
	return {
		"status": "Full success",
		"months_operated": operated_months,
		"science": science,
		"score": score,
		"log": log
	}

# --- Helpers ---
static func _find_part(category: String, id: String) -> Dictionary:
	var list = GameParts.PARTS.get(category, [])
	for p in list:
		if p.get("id") == id: return p
	return {}

static func _find_vehicle(id: String) -> Dictionary:
	var list = [
		{"id": "lv_small", "name": "Small launcher", "capacity_leo": 300, "cost": 8},
		{"id": "lv_medium", "name": "Medium launcher", "capacity_leo": 15000, "cost": 65}
	]
	for v in list:
		if v.get("id") == id: return v
	return {}