extends Control

func _ready():
	# 1. Build Background
	var bg = TextureRect.new()
	bg.texture = load("res://assets/images/bg_planets.png")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(bg)
	
	# 2. Build Center Panel
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	
	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(400, 0)
	vbox.add_theme_constant_override("separation", 20)
	center.add_child(vbox)
	
	# 3. Title
	var title = Label.new()
	title.text = "MISSION CONTROL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	vbox.add_child(title)
	
	# 4. Name Input
	var name_edit = LineEdit.new()
	name_edit.placeholder_text = "Enter your name"
	vbox.add_child(name_edit)
	
	# 5. Host Button
	var host_btn = Button.new()
	host_btn.text = "Host New Mission"
	host_btn.pressed.connect(func():
		# Save the name to our Autoload
		GameManager.player_name = name_edit.text if name_edit.text != "" else "Player"
		# Change scene using the exact snake_case path
		get_tree().change_scene_to_file("res://scenes/role_select.tscn")
	)
	vbox.add_child(host_btn)
