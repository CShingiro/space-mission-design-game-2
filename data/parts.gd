class_name GameParts
const PARTS = {
	"bus": [
		{"id": "bus_cubesat_6u", "name": "6U CubeSat frame", "mass": 12, "cost": 0.4, "payload_capacity": 4, "class": "cubesat"},
		{"id": "bus_small", "name": "Small satellite bus", "mass": 500, "cost": 10, "payload_capacity": 200, "class": "standard"},
		{"id": "bus_medium", "name": "Medium satellite bus", "mass": 1500, "cost": 45, "payload_capacity": 1500, "class": "standard"},
		{"id": "bus_large", "name": "Large flagship bus", "mass": 3000, "cost": 150, "payload_capacity": 3000, "class": "standard"},
		{"id": "cap_2", "name": "2-seat crew capsule", "mass": 6000, "cost": 100, "payload_capacity": 1500, "seats": 2, "class": "crewed"},
		{"id": "cap_4", "name": "4-seat crew capsule", "mass": 9000, "cost": 140, "payload_capacity": 3000, "seats": 4, "class": "crewed"},
		{"id": "cap_7", "name": "7-seat crew capsule", "mass": 12000, "cost": 200, "payload_capacity": 4000, "seats": 7, "class": "crewed"}
	],
	"power": [
		{"id": "sol_body_cube", "name": "Body-mounted solar cells", "mass": 1.5, "cost": 0.05, "watts": 15, "uses_sun": true, "class": "cubesat"},
		{"id": "sol_deploy_cube", "name": "Deployable CubeSat panels", "mass": 2.5, "cost": 0.15, "watts": 40, "uses_sun": true, "class": "cubesat"},
		{"id": "sol_small", "name": "Small solar array", "mass": 60, "cost": 2, "watts": 400, "uses_sun": true, "class": "standard"},
		{"id": "sol_large", "name": "Large solar array", "mass": 150, "cost": 8, "watts": 2000, "uses_sun": true, "class": "standard"},
		{"id": "rtg", "name": "Radioisotope power (2 RTGs)", "mass": 200, "cost": 100, "watts": 220, "uses_sun": false, "class": "standard"}
	],
	"battery": [
		{"id": "bat_cube", "name": "CubeSat battery (40 Wh)", "mass": 1.5, "cost": 0.03, "wh": 40, "class": "cubesat"},
		{"id": "bat_medium", "name": "Medium battery (800 Wh)", "mass": 30, "cost": 1, "wh": 800, "class": "standard"},
		{"id": "bat_large", "name": "Large battery (3000 Wh)", "mass": 80, "cost": 3, "wh": 3000, "class": "standard"}
	],
	"comms": [
		{"id": "com_sband_cube", "name": "S-band CubeSat radio", "mass": 1.0, "cost": 0.05, "power": 4, "rate_mbps": 2, "class": "cubesat"},
		{"id": "com_xband", "name": "X-band transmitter", "mass": 30, "cost": 3, "power": 60, "rate_mbps": 50, "class": "standard"},
		{"id": "com_ka_hga", "name": "Ka-band high-gain antenna", "mass": 80, "cost": 12, "power": 100, "rate_mbps": 300, "class": "standard"}
	],
	"computer": [
		{"id": "obc_basic", "name": "Basic flight computer", "mass": 1.0, "cost": 0.05, "power": 2, "fail_rate": 0.003, "class": "cubesat"},
		{"id": "obc_radhard", "name": "Radiation-hardened computer", "mass": 15, "cost": 4, "power": 15, "fail_rate": 0.0005, "class": "standard"}
	],
	"adcs": [
		{"id": "adcs_mag", "name": "Magnetorquers", "mass": 1.0, "cost": 0.05, "power": 1, "pointing": 1, "class": "cubesat"},
		{"id": "adcs_wheels", "name": "Reaction wheels", "mass": 25, "cost": 2, "power": 20, "pointing": 2, "class": "standard"},
		{"id": "adcs_precise", "name": "Star tracker + reaction wheels", "mass": 40, "cost": 6, "power": 35, "pointing": 3, "class": "standard"}
	],
	"propulsion": [
		{"id": "prop_none", "name": "No propulsion", "mass": 0, "cost": 0, "power": 0, "type": "none", "class": "cubesat"},
		{"id": "prop_coldgas", "name": "Cold-gas thruster", "mass": 5, "cost": 0.3, "power": 2, "type": "small", "class": "cubesat"},
		{"id": "prop_chemical", "name": "Chemical engine + propellant", "mass": 800, "cost": 15, "power": 10, "type": "chemical", "class": "standard"},
		{"id": "prop_lander", "name": "Lunar landing engine + propellant", "mass": 1500, "cost": 40, "power": 15, "type": "lander", "class": "standard"}
	],
	"life_support": [
		{"id": "ls_none", "name": "No life support", "mass": 0, "mass_per_crew": 0, "cost": 0, "power_per_crew": 0, "fail_rate": 0, "class": "cubesat"},
		{"id": "ls_basic", "name": "Basic life support", "mass": 500, "mass_per_crew": 100, "cost": 15, "power_per_crew": 100, "fail_rate": 0.01, "class": "crewed"},
		{"id": "ls_redundant", "name": "Redundant life support", "mass": 800, "mass_per_crew": 150, "cost": 35, "power_per_crew": 120, "fail_rate": 0.001, "class": "crewed"}
	],
	"escape_system": [
		{"id": "esc_none", "name": "No launch escape system", "mass": 0, "cost": 0, "escape_success": 0, "class": "cubesat"},
		{"id": "esc_las", "name": "Launch abort system", "mass": 1500, "cost": 25, "escape_success": 0.95, "class": "crewed"}
	],
	"instruments": [
		{"id": "ins_cam_cube", "name": "CubeSat camera", "mass": 0.5, "cost": 0.2, "power": 3, "data_gb_day": 2, "science": 5, "pointing": 1, "tags": ["imaging"], "class": "cubesat"},
		{"id": "ins_magnetometer", "name": "Magnetometer", "mass": 0.5, "cost": 0.5, "power": 1, "data_gb_day": 0.1, "science": 2, "pointing": 1, "tags": ["magnetic"], "class": "cubesat"},
		{"id": "ins_hires_cam", "name": "High-resolution camera", "mass": 150, "cost": 25, "power": 150, "data_gb_day": 60, "science": 25, "pointing": 2, "tags": ["imaging"], "class": "standard"},
		{"id": "ins_multispectral", "name": "Multispectral imager", "mass": 80, "cost": 15, "power": 80, "data_gb_day": 30, "science": 20, "pointing": 2, "tags": ["imaging", "multispectral"], "class": "standard"},
		{"id": "ins_thermal_ir", "name": "Thermal infrared camera", "mass": 50, "cost": 10, "power": 40, "data_gb_day": 10, "science": 15, "pointing": 2, "tags": ["thermal"], "class": "standard"},
		{"id": "ins_sar", "name": "Synthetic aperture radar (SAR)", "mass": 400, "cost": 80, "power": 360, "data_gb_day": 150, "science": 40, "pointing": 2, "tags": ["radar"], "class": "standard"},
		{"id": "ins_spectrometer", "name": "Imaging spectrometer", "mass": 60, "cost": 20, "power": 50, "data_gb_day": 5, "science": 18, "pointing": 2, "tags": ["spectroscopy"], "class": "standard"},
		{"id": "ins_ice_radar", "name": "Ice-penetrating radar", "mass": 100, "cost": 40, "power": 100, "data_gb_day": 10, "science": 30, "pointing": 1, "tags": ["radar", "ice"], "class": "standard"},
		{"id": "ins_ir_telescope", "name": "Infrared space telescope", "mass": 1200, "cost": 350, "power": 400, "data_gb_day": 40, "science": 80, "pointing": 3, "tags": ["astronomy", "infrared"], "class": "standard"},
		{"id": "ins_neutron", "name": "Neutron spectrometer", "mass": 30, "cost": 12, "power": 15, "data_gb_day": 0.5, "science": 20, "pointing": 1, "tags": ["ice", "spectroscopy"], "class": "standard"},
		{"id": "ins_lab_kit", "name": "Microgravity research lab", "mass": 800, "cost": 20, "power": 200, "data_gb_day": 5, "science": 40, "pointing": 1, "tags": ["research"], "class": "crewed"}
	]
}