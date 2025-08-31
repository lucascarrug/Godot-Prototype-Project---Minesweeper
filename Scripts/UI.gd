extends Control

var faces = ActionFaces.new()

@onready var difficulty_button = $CanvasLayer/DifficultyButton
@onready var face_texture = $CanvasLayer/FaceTexture
@onready var flag_counter_label = $CanvasLayer/FlagCounter/FlagCounterLabel

var difficulty_string: String = ""
var state_string: String = ""
var dead: bool = false
var win: bool = false

## OVERRIDE FUNCTIONS.

func _ready() -> void:
	difficulty_string = "Easy"
	state_string = "Idle"

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("left_click") and (not dead and not win):
		face_texture.texture = faces.ActionFacesImages[difficulty_string]["Clicking"]
	elif not dead and not win:
		face_texture.texture = faces.ActionFacesImages[difficulty_string]["Idle"]

## SIGNALS.

func _on_difficulty_button_item_selected(index: int) -> void:
	match index:
		0: difficulty_string = "Easy"
		1: difficulty_string = "Medium"
		2: difficulty_string = "Hard"
	
	print(difficulty_string)
	dead = false
	win = false

func _on_minesweeper_flags_left_modified(value: int) -> void:
	flag_counter_label.text = str(value)

func _on_minesweeper_mines_explode() -> void:
	dead = true
	face_texture.texture = faces.ActionFacesImages[difficulty_string]["Dead"]
	difficulty_button.disabled = true

func _on_minesweeper_win_game() -> void:
	win = true
	face_texture.texture = faces.ActionFacesImages[difficulty_string]["Win"]
	print("UI: WIN")

func _on_minesweeper_exploding_animation_ended() -> void:
	difficulty_button.disabled = false
