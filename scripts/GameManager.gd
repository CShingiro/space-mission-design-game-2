extends Node

const Sim = preload("res://scripts/simulation.gd")

var current_design: Dictionary = {
	"mission": "m_satellite",
	"orbit": "leo",
	"launch_vehicle": "lv_small",
	"bus": "bus_small",
	"power": "sol_small",
	"battery": "bat_medium",
	"comms": "com_xband",
	"computer": "obc_radhard",
	"adcs": "adcs_wheels",
	"propulsion": "prop_none",
	"life_support": "ls_redundant",
	"escape_system": "esc_las",
	"crew": 0,
	"planned_months": 12,
	"instruments": ["ins_thermal_ir"]
}

var current_role: String = "Solo"
var player_name: String = "Player"
var difficulty_multiplier: float = 1.5

func update_design(field: String, value):
	current_design[field] = value

func get_dashboard():
	var d = Sim.get_dashboard(current_design)
	
	var base_budget = 80.0
	if difficulty_multiplier > 0.0:
		d["budget"] = base_budget * difficulty_multiplier
	else:
		d["budget"] = null
		
	if d["budget"] != null and d.total_cost > d["budget"]:
		d["issues"].append({
			"severity": "block", 
			"what": "Over Budget", 
			"why": "Cost exceeds limit.", 
			"fix": "Cut parts or change difficulty."
		})
		d["can_launch"] = false
		
	return d

func launch():
	return Sim.run_mission(current_design)
