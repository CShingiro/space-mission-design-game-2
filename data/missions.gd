class_name GameMissions
const MISSIONS = {
	"m_satellite": {
		"id": "m_satellite", "name": "Wildfire Watch Satellite",
		"required_tags": ["thermal"], "useful_tags": ["thermal", "multispectral", "imaging"],
		"min_lifetime_months": 36, "target_science": 900,
		"allowed_orbits": ["leo", "sso"],
		"budget": 80.0, "real_budget": 70.0
	},
	"m_station": {
		"id": "m_station", "name": "Crew to Space Station",
		"required_tags": [], "useful_tags": ["research"],
		"min_lifetime_months": 6, "target_science": 450, "min_crew": 3,
		"allowed_orbits": ["iss"],
		"budget": 450.0, "real_budget": 340.0
	},
	"m_moon": {
		"id": "m_moon", "name": "Moon Ice Prospector",
		"required_tags": ["ice"], "useful_tags": ["ice", "spectroscopy", "imaging", "radar"],
		"min_lifetime_months": 6, "target_science": 400,
		"allowed_orbits": ["moon_orbit", "moon_surface"],
		"budget": 250.0, "real_budget": 210.0
	},
	"m_mars": {
		"id": "m_mars", "name": "Mars Ice Hunter",
		"required_tags": ["ice"], "useful_tags": ["ice", "radar", "imaging", "spectroscopy"],
		"min_lifetime_months": 24, "target_science": 1200,
		"allowed_orbits": ["mars"],
		"budget": 450.0, "real_budget": 450.0
	}
}