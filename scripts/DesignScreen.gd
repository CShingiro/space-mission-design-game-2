extends Control

var is_syncing := false

const LABELS := {
	"bus": "Spacecraft bus", "power": "Power", "battery": "Battery",
	"comms": "Radio", "computer": "Computer", "adcs": "Pointing",
	"life_support": "Life support", "propulsion": "Propulsion",
	"orbit": "Orbit", "launch_vehicle": "Rocket", "crew": "Astronauts",
	"planned_months": "Mission Length", "instruments": "Science Instruments"
}

var left_panel: VBoxContainer
var dash_text: RichTextLabel
var issues_text: RichTextLabel
var launch_btn: Button
var difficulty_picker: OptionButton
var mission_picker: OptionButton
var result_panel: PanelContainer
var result_text: RichTextLabel

func _ready():
	add_to_group("design_screen")
	GameManager.design_updated.connect(func(_new_design): _update_ui())
	GameManager.result_ready.connect(show_result)
	
	# Background Image
	var bg = TextureRect.new()
	bg.texture = load("res://assets/images/bg_planets.png")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(bg)
	
	# Dark overlay
	var overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.05, 0.08, 0.15, 0.85)
	add_child(overlay)
	
	# Main Margins
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 20)
	margin.add_child(main_vbox)
	
	# Top Bar
	var top_bar = HBoxContainer.new()
	top_bar.custom_minimum_size = Vector2(0, 40)
	top_bar.add_theme_constant_override("separation", 20)
	main_vbox.add_child(top_bar)
	
	mission_picker = OptionButton.new()
	mission_picker.add_item("Wildfire Watch Satellite", 0)
	mission_picker.set_item_metadata(0, "m_satellite")
	mission_picker.add_item("Crew to Space Station", 1)
	mission_picker.set_item_metadata(1, "m_station")
	mission_picker.add_item("Moon Ice Prospector", 2)
	mission_picker.set_item_metadata(2, "m_moon")
	mission_picker.item_selected.connect(func(idx): 
		if is_syncing: return
		GameManager.update_design("mission", mission_picker.get_item_metadata(idx))
		_update_ui()
	)
	top_bar.add_child(mission_picker)

	difficulty_picker = OptionButton.new()
	difficulty_picker.add_item("Easy (Unlimited)", 0)
	difficulty_picker.add_item("Medium (1.5x Budget)", 1)
	difficulty_picker.add_item("Hard (1.0x Budget)", 2)
	difficulty_picker.add_item("Hard - Simulation (Real World)", 3)
	difficulty_picker.selected = 1
	difficulty_picker.item_selected.connect(func(_idx): _update_ui())
	top_bar.add_child(difficulty_picker)
	
	# Main Content Area
	var hbox = HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 20)
	main_vbox.add_child(hbox)
	
	# LEFT PANEL
	var left_scroll = ScrollContainer.new()
	left_scroll.custom_minimum_size = Vector2(380, 0)
	left_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(left_scroll)
	
	left_panel = VBoxContainer.new()
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_panel.add_theme_constant_override("separation", 10)
	left_scroll.add_child(left_panel)
	
	# RIGHT PANEL
	var right_panel = VBoxContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.add_theme_constant_override("separation", 10)
	hbox.add_child(right_panel)
	
	dash_text = RichTextLabel.new()
	dash_text.bbcode_enabled = true
	dash_text.custom_minimum_size = Vector2(0, 200)
	dash_text.size_flags_vertical = Control.SIZE_EXPAND_FILL 
	right_panel.add_child(dash_text)
	
	issues_text = RichTextLabel.new()
	issues_text.bbcode_enabled = true
	issues_text.custom_minimum_size = Vector2(0, 200)
	issues_text.size_flags_vertical = Control.SIZE_EXPAND_FILL 
	right_panel.add_child(issues_text)
	
	launch_btn = Button.new()
	launch_btn.text = "LAUNCH MISSION"
	launch_btn.custom_minimum_size = Vector2(0, 60)
	launch_btn.add_theme_font_size_override("font_size", 24)
	launch_btn.pressed.connect(_on_launch)
	right_panel.add_child(launch_btn)
	
	# Results Panel
	result_panel = PanelContainer.new()
	result_panel.set_anchors_preset(Control.PRESET_CENTER)
	result_panel.custom_minimum_size = Vector2(600, 500)
	result_panel.visible = false
	add_child(result_panel)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.98)
	style.set_border_width_all(2)
	style.border_color = Color(0.3, 0.5, 0.8)
	result_panel.add_theme_stylebox_override("panel", style)
	
	var result_vbox = VBoxContainer.new()
	result_vbox.add_theme_constant_override("separation", 15)
	result_panel.add_child(result_vbox)
	
	result_text = RichTextLabel.new()
	result_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	result_text.bbcode_enabled = true
	result_vbox.add_child(result_text)
	
	var close_btn = Button.new()
	close_btn.text = "Close & Try Again"
	close_btn.custom_minimum_size = Vector2(0, 40)
	close_btn.pressed.connect(func(): result_panel.visible = false)
	result_vbox.add_child(close_btn)
	
	_build_controls()
	_update_ui()

func _build_controls():
	var fields = ["bus", "power", "battery", "comms", "computer", "adcs", "life_support", "propulsion", "orbit", "launch_vehicle", "crew", "planned_months", "instruments"]
	
	for field in fields:
		var lbl = Label.new()
		lbl.text = LABELS.get(field, field.capitalize())
		left_panel.add_child(lbl)
		
		if field == "crew" or field == "planned_months":
			var spin = SpinBox.new()
			spin.set_meta("field_name", field)
			spin.max_value = 7 if field == "crew" else 120
			spin.min_value = 0 if field == "crew" else 1
			spin.value = GameManager.current_design.get(field, 0)
			spin.value_changed.connect(func(v): 
				if is_syncing: return
				GameManager.update_design(field, int(v))
				_update_ui()
			)
			left_panel.add_child(spin)
			continue
			
		if field == "instruments":
			var list_ui = ItemList.new()
			list_ui.set_meta("field_name", field)
			list_ui.select_mode = ItemList.SELECT_MULTI
			list_ui.custom_minimum_size = Vector2(0, 150)
			var ins_list = GameParts.PARTS["instruments"]
			for i in range(ins_list.size()):
				list_ui.add_item(ins_list[i]["name"])
				list_ui.set_item_metadata(i, ins_list[i]["id"])
				if ins_list[i]["id"] in GameManager.current_design.get("instruments", []):
					list_ui.select(i)
					
			list_ui.multi_selected.connect(func(_idx, _sel):
				if is_syncing: return
				var chosen = []
				for i in list_ui.get_selected_items():
					chosen.append(list_ui.get_item_metadata(i))
				GameManager.update_design("instruments", chosen)
				_update_ui()
			)
			left_panel.add_child(list_ui)
			continue
			
		var pick = OptionButton.new()
		pick.set_meta("field_name", field)
		var list = []
		
		if field == "orbit": 
			list = GameOrbits.ORBITS.values()
		elif field == "launch_vehicle":
			list = GameManager.launch_vehicles
		else: 
			var full_list = GameParts.PARTS.get(field, [])
			
			# Safely find the current bus class
			var current_bus_id = GameManager.current_design.get("bus", "")
			var current_bus_class = "standard"
			for b in GameParts.PARTS["bus"]:
				if b.get("id") == current_bus_id:
					current_bus_class = b.get("class", "standard")
					break
			
			var is_crewed_mission = GameManager.current_design.get("mission", "") == "m_station"
			
			for p in full_list:
				var part_class = p.get("class", "standard")
				
				# 1. Bus dropdown always shows compatible buses
				if field == "bus":
					if is_crewed_mission and part_class != "crewed":
						continue
					if not is_crewed_mission and part_class == "crewed":
						continue
					list.append(p)
					continue
				
				# 2. Life support and escape systems show everything
				if field in ["life_support", "escape_system"]:
					list.append(p)
					continue
					
				# 3. "None" options (prop_none, ls_none) are always valid
				if p["id"].ends_with("_none"):
					list.append(p)
					continue
					
				# 4. For everything else, match the bus class perfectly
				if part_class == current_bus_class:
					list.append(p)
		
		for i in range(list.size()):
			pick.add_item(list[i]["name"])
			pick.set_item_metadata(i, list[i]["id"])
			if list[i]["id"] == GameManager.current_design.get(field):
				pick.select(i)
		
		pick.item_selected.connect(func(idx): 
			if is_syncing: return
			var new_id = pick.get_item_metadata(idx)
			GameManager.update_design(field, str(new_id))
			
			if field == "bus":
				_fix_incompatible_parts()
				
			var new_dash = GameManager.get_dashboard()
			_update_ui_from_dashboard(new_dash)
			_rebuild_dropdowns_only()
		)
		
		left_panel.add_child(pick)

func _update_ui():
	is_syncing = true
	
	GameManager.difficulty_index = difficulty_picker.selected
	
	for field in ["bus", "power", "battery", "comms", "computer", "adcs", "life_support", "propulsion", "orbit", "launch_vehicle"]:
		var pick = _get_picker_for_field(field)
		if pick and pick is OptionButton:
			var target_id = GameManager.current_design.get(field)
			for i in range(pick.item_count):
				if pick.get_item_metadata(i) == target_id:
					pick.select(i)
					break
					
	for spin_field in ["crew", "planned_months"]:
		var spin = _get_picker_for_field(spin_field)
		if spin and spin is SpinBox:
			spin.value = GameManager.current_design.get(spin_field, 0)
		
	var list_ui = _get_picker_for_field("instruments")
	if list_ui and list_ui is ItemList:
		list_ui.deselect_all()
		for i in range(list_ui.item_count):
			if list_ui.get_item_metadata(i) in GameManager.current_design.get("instruments", []):
				list_ui.select(i)
	
	var d = GameManager.get_dashboard()
	_update_ui_from_dashboard(d)
	
	is_syncing = false

func _update_ui_from_dashboard(d: Dictionary):
	var t = "[b]MISSION DASHBOARD[/b]\n"
	t += "Mass: %.0f / %.0f kg\n" % [d.mass, d.launch_capacity]
	t += "Power: %.0f / %.0f W\n" % [d.power_use, d.power_gen]
	
	if d.budget == null:
		t += "Cost: $%.1fM (Unlimited Budget)\n" % d.total_cost
	else:
		t += "Cost: $%.1fM / $%.1fM Budget\n" % [d.total_cost, d.budget]
		if d.has("real_budget_source"):
			t += "[i]Note: %s[/i]\n" % d.real_budget_source
		
	dash_text.text = t
	
	var it = "[b]PROBLEMS[/b]\n"
	if d.issues.size() == 0: 
		it += "[color=green]All clear.[/color]"
	for i in d.issues:
		var c = "red" if i.severity == "block" else "orange"
		it += "[color=%s]%s[/color]\n%s\nFix: %s\n\n" % [c, i.what, i.why, i.fix]
	issues_text.text = it
	
	var is_host = multiplayer.multiplayer_peer is OfflineMultiplayerPeer or multiplayer.is_server()
	launch_btn.disabled = not d.can_launch or not is_host

func _on_launch():
	if not multiplayer.multiplayer_peer is OfflineMultiplayerPeer and not multiplayer.is_server():
		return
	GameManager.launch()

func show_result(r: Dictionary):
	var t = "[center][b]MISSION RESULT: %s[/b][/center]\n" % r.status
	t += "[center]Score: %d[/center]\n\n" % r.score
	t += "[b]Mission Log:[/b]\n"
	for line in r.log:
		t += "• " + line + "\n"
	result_text.text = t
	result_panel.visible = true

func _get_picker_for_field(field_name: String) -> Control:
	for child in left_panel.get_children():
		if child.has_meta("field_name") and child.get_meta("field_name") == field_name:
			return child
	return null

func _fix_incompatible_parts():
	var new_bus_id = GameManager.current_design.get("bus", "")
	var new_bus_class = "standard"
	for b in GameParts.PARTS["bus"]:
		if b["id"] == new_bus_id:
			new_bus_class = b.get("class", "standard")
			break
	
	# Auto-swap incompatible parts
	var parts_to_check = ["power", "battery", "comms", "computer", "adcs", "propulsion", "instruments"]
	for field in parts_to_check:
		var current_id = GameManager.current_design.get(field, "")
		
		if field == "instruments":
			var new_instruments = []
			for ins_id in current_id:
				var ins_part = _find_part_in_list("instruments", ins_id)
				if ins_part.get("class", "standard") == new_bus_class:
					new_instruments.append(ins_id)
			if new_instruments.size() != current_id.size():
				GameManager.update_design("instruments", new_instruments)
			else:
				if current_id.ends_with("_none"):
					continue # "None" is always valid, don't swap it
				var part = _find_part_in_list(field, current_id)
				if part.get("class", "standard") != new_bus_class:
					# Find the first valid replacement
					var list = GameParts.PARTS.get(field, [])
					for p in list:
						if p.get("class", "standard") == new_bus_class or p["id"].ends_with("_none"):
							GameManager.update_design(field, p["id"])
							break

func _find_part_in_list(category: String, id: String) -> Dictionary:
	for p in GameParts.PARTS.get(category, []):
		if p["id"] == id: return p
	return {}

func _rebuild_dropdowns_only():
	is_syncing = true
	for field in ["bus", "power", "battery", "comms", "computer", "adcs", "life_support", "propulsion", "orbit", "launch_vehicle"]:
		var pick = _get_picker_for_field(field)
		if pick and pick is OptionButton:
			var list = []
			if field == "orbit": 
				list = GameOrbits.ORBITS.values()
			elif field == "launch_vehicle":
				list = GameManager.launch_vehicles
			else: 
				var full_list = GameParts.PARTS.get(field, [])
				var current_bus_id = GameManager.current_design.get("bus", "")
				var current_bus_class = "standard"
				for b in GameParts.PARTS["bus"]:
					if b["id"] == current_bus_id:
						current_bus_class = b.get("class", "standard")
						break
				var is_crewed_mission = GameManager.current_design.get("mission", "") == "m_station"
				
				for p in full_list:
					var part_class = p.get("class", "standard")
					if field == "bus":
						if is_crewed_mission and part_class != "crewed": continue
						if not is_crewed_mission and part_class == "crewed": continue
						list.append(p)
						continue
					if field in ["life_support", "escape_system"]:
						list.append(p)
						continue
					if p["id"].ends_with("_none"):
						list.append(p)
						continue
					if part_class == current_bus_class:
						list.append(p)
						
			# Clear and repopulate the dropdown
			pick.clear()
			for i in range(list.size()):
				pick.add_item(list[i]["name"])
				pick.set_item_metadata(i, list[i]["id"])
				if list[i]["id"] == GameManager.current_design.get(field):
					pick.select(i)
	is_syncing = false
		