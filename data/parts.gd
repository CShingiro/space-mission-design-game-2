class_name GameParts
# Just a sample to show how the data maps. You can paste the rest from your JSON.
const PARTS = {
	"bus": [
		{"id": "bus_small", "name": "Small satellite bus", "mass": 80, "cost": 10, "payload_capacity": 200, "class": "standard"},
		{"id": "cap_4", "name": "4-seat crew capsule", "mass": 9000, "cost": 140, "payload_capacity": 3000, "class": "crewed", "seats": 4}
	],
	"power": [
		{"id": "sol_small", "name": "Small solar array", "mass": 15, "cost": 2, "watts": 400, "uses_sun": true, "class": "standard"},
		{"id": "sol_large", "name": "Large solar array", "mass": 60, "cost": 8, "watts": 2000, "uses_sun": true, "class": "standard"}
	],
	"battery": [
		{"id": "bat_medium", "name": "Medium battery", "mass": 8, "cost": 1, "wh": 800, "class": "standard"}
	],
	"comms": [
		{"id": "com_xband", "name": "X-band transmitter", "mass": 8, "cost": 3, "power": 60, "rate_mbps": 50, "class": "standard"}
	],
	"computer": [
		{"id": "obc_radhard", "name": "Radiation-hardened computer", "mass": 5, "cost": 4, "power": 15, "fail_rate": 0.0005, "class": "standard"}
	],
	"adcs": [
		{"id": "adcs_wheels", "name": "Reaction wheels", "mass": 10, "cost": 2, "power": 20, "pointing": 2, "class": "standard"}
	],
	"propulsion": [
		{"id": "prop_none", "name": "No propulsion", "mass": 0, "cost": 0, "power": 0, "type": "none", "class": "cubesat"},
		{"id": "prop_chemical", "name": "Chemical engine", "mass": 600, "cost": 15, "power": 10, "type": "chemical", "class": "standard"}
	],
	"life_support": [
		{"id": "ls_redundant", "name": "Redundant life support", "mass": 500, "mass_per_crew": 150, "cost": 35, "power_per_crew": 120, "fail_rate": 0.001, "class": "crewed"}
	],
	"escape_system": [
		{"id": "esc_las", "name": "Launch abort system", "mass": 1200, "cost": 25, "escape_success": 0.95, "class": "crewed"}
	],
	"instruments": [
		{"id": "ins_thermal_ir", "name": "Thermal infrared camera", "mass": 30, "cost": 10, "power": 40, "data_gb_day": 10, "science": 15, "pointing": 2, "tags": ["thermal"], "class": "standard"}
	]
}