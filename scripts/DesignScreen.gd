extends Control

const LABELS := {
	"bus": "Spacecraft bus", "power": "Power", "battery": "Battery",
	"comms": "Radio", "computer": "Computer", "adcs": "Pointing",
	"life_support": "Life support", "propulsion": "Propulsion",
	"orbit": "Orbit", "launch_vehicle": "Rocket", "crew": "Astronauts"
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
	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(main_vbox)
	
	# --- TOP BAR (Mission & Difficulty) ---
	var top_bar = HBoxContainer.new()
	top_bar.custom_minimum_size = Vector2(0, 40)
	top_bar.add_theme_constant_override("separation", 20)
	main_vbox.add_child(top_bar)
	
	var mission_label = Label.new()
	mission_label.text = "Mission:"
	top_bar.add_child(mission_label)
	
	mission_picker = OptionButton.new()
	mission_picker.add_item("Wildfire Watch Satellite", 0)
	mission_picker.add_item("Crew to Space Station", 1)
	mission_picker.add_item("Moon Ice Prospector", 2)
	mission_picker.item_selected.connect(func(_idx): _update_ui())
	top_bar.add_child(mission_picker)

	var diff_label = Label.new()
	diff_label.text = "Difficulty:"
	top_bar.add_child(diff_label)
	
	difficulty_picker = OptionButton.new()
	difficulty_picker.add_item("Easy (Unlimited)", 0)
	difficulty_picker.add_item("Medium (1.5x Budget)", 1)
	difficulty_picker.add_item("Hard (1.0x Budget)", 2)
	difficulty_picker.selected = 1
	difficulty_picker.item_selected.connect(func(_idx): _update_ui())
	top_bar.add_child(difficulty_picker)
	
	# --- MAIN CONTENT (Left & Right) ---
	var hbox = HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 20)
	main_vbox.add_child(hbox)
	
	# Left Side (Controls)
	var left_scroll = ScrollContainer.new()
	left_scroll.custom_minimum_size = Vector2(350, 0)
	hbox.add_child(left_scroll)
	
	left_panel = VBoxContainer.new()
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_panel.add_theme_constant_override("separation", 10)
	left_scroll.add_child(left_panel)
	
	# Right Side (Dashboard)
	var right_panel = VBoxContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.add_theme_constant_override("separation", 15)
	hbox.add_child(right_panel)
	
	dash_text = RichTextLabel.new()
	dash_text.custom_minimum_size = Vector2(0, 200)
	dash_text.bbcode_enabled = true
	right_panel.add_child(dash_text)
	
	issues_text = RichTextLabel.new()
	issues_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	issues_text.bbcode_enabled = true
	right_panel.add_child(issues_text)
	
	launch_btn = Button.new()
	launch_btn.text = "LAUNCH MISSION"
	launch_btn.custom_minimum_size = Vector2(0, 50)
	launch_btn.pressed.connect(_on_launch)
	right_panel.add_child(launch_btn)
	
	# --- RESULTS PANEL ---
	result_panel = PanelContainer.new()
	result_panel.set_anchors_preset(Control.PRESET_CENTER)
	result_panel.custom_minimum_size = Vector2(600, 500)
	result_panel.visible = false
	add_child(result_panel)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	style.set_border_width_all(2)
	style.border_color = Color(0.3, 0.5, 0.8)
	result_panel.add_theme_stylebox_override("panel", style)
	
	var result_vbox = VBoxContainer.new()
	result_panel.add_child(result_vbox)
	
	result_text = RichTextLabel.new()
	result_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	result_text.bbcode_enabled = true
	result_vbox.add_child(result_text)
	
	var close_btn = Button.new()
	close_btn.text = "Close & Try Again"
	close_btn.pressed.connect(func(): result_panel.visible = false)
	result_vbox.add_child(close_btn)
	
	_build_controls()
	_update_ui()

func _build_controls():
	var fields = ["bus", "power", "battery", "comms", "computer", "adcs", "life_support", "propulsion", "orbit", "launch_vehicle", "crew"]
	
	for field in fields:
		var lbl = Label.new()
		lbl.text = LABELS.get(field, field.capitalize())
		left_panel.add_child(lbl)
		
		if field == "crew":
			var spin = SpinBox.new()
			spin.max_value = 7
			spin.value = GameManager.current_design["crew"]
			spin.value_changed.connect(func(v): 
				GameManager.update_design("crew", int(v))
				_update_ui()
			)
			left_panel.add_child(spin)
			continue
			
		var pick = OptionButton.new()
		var list = []
		if field == "orbit": 
			list = GameOrbits.ORBITS.values()
		else: 
			list = GameParts.PARTS.get(field, [])
		
		for i in range(list.size()):
			pick.add_item(list[i]["name"])
			pick.set_item_metadata(i, list[i]["id"])
			if list[i]["id"] == GameManager.current_design.get(field):
				pick.select(i)
				
		pick.item_selected.connect(func(idx): 
			GameManager.update_design(field, pick.get_item_metadata(idx))
			_update_ui()
		)
		left_panel.add_child(pick)

func _update_ui():
	GameManager.difficulty_multiplier = [0.0, 1.5, 1.0][difficulty_picker.selected]
	GameManager.update_design("mission", ["m_satellite", "m_station", "m_moon"][mission_picker.selected])
	
	var d = GameManager.get_dashboard()
	
	var t = "[b]MISSION DASHBOARD[/b]\n"
	t += "Mass: %.0f / %.0f kg\n" % [d.mass, d.launch_capacity]
	t += "Power: %.0f / %.0f W\n" % [d.power_use, d.power_gen]
	
	if d.budget == null:
		t += "Cost: $%.1fM (Unlimited Budget)\n" % d.total_cost
	else:
		t += "Cost: $%.1fM / $%.1fM Budget\n" % [d.total_cost, d.budget]
		
	dash_text.text = t
	
	var it = "[b]PROBLEMS[/b]\n"
	if d.issues.size() == 0: 
		it += "[color=green]All clear.[/color]"
	for i in d.issues:
		var c = "red" if i.severity == "block" else "orange"
		it += "[color=%s]%s[/color]\n%s\nFix: %s\n\n" % [c, i.what, i.why, i.fix]
	issues_text.text = it
	
	# For testing purposes, let's ensure we can always launch if there are no "block" issues
	launch_btn.disabled = not d.can_launch

func _on_launch():
	# Print to the Godot Output console just in case the UI fails
	print("Launch button pressed. Running simulation...")
	
	var r = GameManager.launch()
	
	var t = "[center][b]MISSION RESULT: %s[/b][/center]\n" % r.status
	t += "[center]Score: %d[/center]\n\n" % r.score
	t += "[b]Mission Log:[/b]\n"
	for line in r.log:
		t += "• " + line + "\n"
		
	result_text.text = t
	result_panel.visible = true
	
	print("Result panel should be visible now.")
