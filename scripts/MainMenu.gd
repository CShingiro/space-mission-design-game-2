extends Control

func _ready():
	var bg = TextureRect.new()
	bg.texture = load("res://assets/images/bg_planets.png")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(bg)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	
	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(400, 0)
	vbox.add_theme_constant_override("separation", 15)
	center.add_child(vbox)
	
	var title = Label.new()
	title.text = "MISSION CONTROL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	vbox.add_child(title)
	
	var name_edit = LineEdit.new()
	name_edit.placeholder_text = "Your Name"
	vbox.add_child(name_edit)
	
	var ip_edit = LineEdit.new()
	ip_edit.placeholder_text = "Host IP (e.g. 127.0.0.1)"
	ip_edit.text = "127.0.0.1"
	vbox.add_child(ip_edit)
	
	var host_btn = Button.new()
	host_btn.text = "Host Game"
	host_btn.pressed.connect(func():
		GameManager.player_name = name_edit.text if name_edit.text != "" else "Host"
		if GameManager.start_host():
			get_tree().change_scene_to_file("res://scenes/role_select.tscn")
	)
	vbox.add_child(host_btn)
	
	var join_btn = Button.new()
	join_btn.text = "Join Game"
	join_btn.pressed.connect(func():
		GameManager.player_name = name_edit.text if name_edit.text != "" else "Client"
		if GameManager.start_client(ip_edit.text):
			get_tree().change_scene_to_file("res://scenes/role_select.tscn")
	)
	vbox.add_child(join_btn)
	
	var solo_btn = Button.new()
	solo_btn.text = "Play Solo"
	solo_btn.pressed.connect(func():
		GameManager.player_name = name_edit.text if name_edit.text != "" else "Solo"
		GameManager.disconnect_peer()
		get_tree().change_scene_to_file("res://scenes/role_select.tscn")
	)
	vbox.add_child(solo_btn)
