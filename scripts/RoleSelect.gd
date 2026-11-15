extends Control

const ROLE_IMAGES = {
	"Science Lead": "res://assets/images/role_science.png",
	"Spacecraft Lead": "res://assets/images/role_spacecraft.png",
	"Launch Lead": "res://assets/images/role_launch.png",
	"Ground Lead": "res://assets/images/role_ground.png"
}

func _ready():
	# 1. Background (full screen)
	var bg = TextureRect.new()
	bg.texture = load("res://assets/images/bg_planets.png")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.modulate = Color(0.5, 0.5, 0.5) # Darken it slightly so UI pops
	add_child(bg)
	
	# 2. Main Layout
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	add_child(vbox)
	
	var title = Label.new()
	title.text = "CHOOSE YOUR ROLE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	vbox.add_child(title)
	
	# 3. The 4-Card Grid
	var grid = GridContainer.new()
	grid.columns = 4
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid.add_theme_constant_override("h_separation", 20)
	vbox.add_child(grid)
	
	for role_name in ROLE_IMAGES:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(220, 300)
		btn.pressed.connect(func():
			GameManager.current_role = role_name
			get_tree().change_scene_to_file("res://scenes/design_screen.tscn")
		)
		
		var img = TextureRect.new()
		img.texture = load(ROLE_IMAGES[role_name])
		img.set_anchors_preset(Control.PRESET_FULL_RECT)
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		btn.add_child(img)
		
		var lbl = Label.new()
		lbl.text = role_name
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		lbl.offset_top = -40
		lbl.add_theme_font_size_override("font_size", 20)
		# Add a dark background to the text so it's readable
		var lbl_bg = ColorRect.new()
		lbl_bg.color = Color(0, 0, 0, 0.7)
		lbl_bg.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		lbl_bg.custom_minimum_size = Vector2(0, 40)
		btn.add_child(lbl_bg)
		btn.add_child(lbl)
		
		grid.add_child(btn)
		
	# 4. Back Button
	var back_btn = Button.new()
	back_btn.text = "Back to Menu"
	back_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	vbox.add_child(back_btn)
