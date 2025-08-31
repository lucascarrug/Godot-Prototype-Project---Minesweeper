extends Control

@onready var difficulty_button = $CanvasLayer/DifficultyButton
@onready var face_texture = $CanvasLayer/FaceTexture
@onready var flag_counter_label = $CanvasLayer/FlagCounter/FlagCounterLabel

func _ready() -> void:
	pass

func _on_difficulty_button_item_selected(index: int) -> void:
	print("item selected: ", index)


func _on_minesweeper_flags_left_modified(value: int) -> void:
	flag_counter_label.text = str(value)
