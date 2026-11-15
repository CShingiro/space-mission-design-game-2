extends Control

@onready var name_edit = $Center/Panel/VBox/NameRow/NameEdit
@onready var host_btn = $Center/Panel/VBox/ButtonRow/HostBtn
@onready var join_btn = $Center/Panel/VBox/ButtonRow/JoinBtn

func _ready():
	host_btn.pressed.connect(_on_host)
	join_btn.pressed.connect(_on_host)

func _on_host():
	GameManager.player_name = name_edit.text if name_edit.text != "" else "Player"
	get_tree().change_scene_to_file("res://scenes/RoleSelect.tscn")
