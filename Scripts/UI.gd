extends Control

@onready var center_container = $CenterContainer
@onready var difficulty_button = $CenterContainer/HBoxContainer/DifficultyButton
@onready var face_texture = $CenterContainer/HBoxContainer/FaceTexture
@onready var time_label = $CenterContainer/HBoxContainer/TimeLabel

func _ready() -> void:
	pass

func _on_minesweeper_screen_resized(size: Vector2i) -> void:
	center_container.size.x = size.x


func _on_difficulty_button_item_selected(index: int) -> void:
	print("item selected: ", index)
