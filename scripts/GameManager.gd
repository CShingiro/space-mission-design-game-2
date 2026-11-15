extends Node

const Sim = preload("res://scripts/simulation.gd")

signal design_updated(new_design)
signal result_ready(r)

var launch_vehicles: Array = [
	{"id": "lv_rideshare", "name": "CubeSat rideshare", "capacity_leo": 24, "cost": 0.5, "reliability": 0.97, "human_rated": false, "orbits": ["leo", "sso"]},
	{"id": "lv_small", "name": "Small launcher", "capacity_leo": 1000, "cost": 8, "reliability": 0.95, "human_rated": false, "orbits": ["leo", "sso", "iss"]},
	{"id": "lv_medium", "name": "Medium launcher", "capacity_leo": 22000, "cost": 65, "reliability": 0.985, "human_rated": true, "orbits": ["leo", "sso", "geo", "l2", "mars", "iss", "moon_orbit", "moon_surface"]},
	{"id": "lv_heavy", "name": "Heavy launcher", "capacity_leo": 60000, "cost": 120, "reliability": 0.97, "human_rated": false, "orbits": ["leo", "sso", "geo", "l2", "mars", "iss", "moon_orbit", "moon_surface"]}
]

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
var difficulty_index: int = 1

func start_host(port: int = 7777):
	var peer = ENetMultiplayerPeer.new()
	if peer.create_server(port, 4) != OK: return false
	multiplayer.multiplayer_peer = peer
	return true

func start_client(ip: String, port: int = 7777):
	var peer = ENetMultiplayerPeer.new()
	if peer.create_client(ip, port) != OK: return false
	multiplayer.multiplayer_peer = peer
	return true

func disconnect_peer():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

@rpc("any_peer", "call_local", "reliable")
func request_design_change(field: String, value):
	if not multiplayer.is_server(): return
	current_design[field] = value
	sync_design.rpc(current_design)

@rpc("authority", "call_local", "reliable")
func sync_design(new_design: Dictionary):
	current_design = new_design
	design_updated.emit(current_design)

func update_design(field: String, value):
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		# Force a deep copy of the design so the UI sees a new reference
		var new_design = current_design.duplicate(true)
		new_design[field] = value
		current_design = new_design 
		design_updated.emit(current_design)
	else:
		request_design_change.rpc_id(1, field, value) 

func get_dashboard():
	var d = Sim.get_dashboard(current_design, launch_vehicles)
	
	var mission_id = current_design.get("mission", "m_satellite")
	var mission = GameMissions.MISSIONS.get(mission_id, {})
	
	if difficulty_index == 0: # Easy
		d["budget"] = null
	elif difficulty_index == 1: # Medium (1.5x)
		d["budget"] = mission.get("budget", 80.0) * 1.5
	elif difficulty_index == 2: # Hard (1.0x)
		d["budget"] = mission.get("budget", 80.0) * 1.0
	elif difficulty_index == 3: # Hard - Simulation
		d["budget"] = mission.get("real_budget", 70.0)
		if mission_id == "m_satellite":
			d["real_budget_source"] = "Based on Canada's WildFireSat design contract (~$70M)."
		elif mission_id == "m_station":
			d["real_budget_source"] = "Based on NASA's Commercial Crew program (~$340M per trip)."
		elif mission_id == "m_moon":
			d["real_budget_source"] = "Based on NASA's CLPS lunar lander task orders (~$210M)."
		elif mission_id == "m_mars":
			d["real_budget_source"] = "Based on NASA's Mars Reconnaissance Orbiter (~$450M)."
		
	if d["budget"] != null and d.total_cost > d["budget"]:
		d["issues"].append({
			"severity": "block", 
			"what": "Over Budget", 
			"why": "Cost $%.1fM > Limit $%.1fM." % [d.total_cost, d["budget"]], 
			"fix": "Cut expensive parts or change difficulty."
		})
		d["can_launch"] = false
		
	return d

func launch():
	var r = Sim.run_mission(current_design, launch_vehicles)
	result_ready.emit(r)
	if not multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		sync_result.rpc(r)
	return r

@rpc("authority", "call_local", "reliable")
func sync_result(r: Dictionary):
	result_ready.emit(r)
