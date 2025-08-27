extends Node2D
class_name Minesweeper

@export var greentable: TileMapLayer
@export var orangetable: TileMapLayer
@export var spritetable: TileMapLayer

var C = Constants.new()
var exploration_map: Array[Array] = []
var mine_map: Array[Array] = []

func _ready():
	set_greentable()
	set_orangetable()
	set_exploration_map()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"):
		var tile_pos: Vector2i = get_clicked_tile()
		explore(tile_pos)
	if Input.is_action_just_pressed("right_click"):
		var tile_pos: Vector2i = get_clicked_tile()
		toggle_flag(tile_pos)
	if Input.is_action_just_pressed("space"):
		print_exploration_map()

func set_greentable(max_x: int = C.MAP_SIZE_X, max_y: int = C.MAP_SIZE_Y):
	var atlas: Vector2i
	for y in range(0, max_y):
		for x in range(0, max_x):
			atlas = get_greentable_atlas(x,y)
			greentable.set_cell(Vector2i(x,y), 0, atlas)

func set_orangetable(max_x: int = C.MAP_SIZE_X, max_y: int = C.MAP_SIZE_Y):
	var atlas: Vector2i
	for y in range(0, max_y):
		for x in range(0, max_x):
			atlas = get_orangetable_atlas(x,y)
			orangetable.set_cell(Vector2i(x,y), 0, atlas)

## EXPLORATION MAP

func set_exploration_map(max_x: int = C.MAP_SIZE_X, max_y: int = C.MAP_SIZE_Y) -> void:
	for y in range(0, max_y):
		var col: Array[int] = []
		for x in range(0, max_x):
			col.append(C.ExplorationMapStates.NOT_EXPLORED)
		exploration_map.append(col)

func explore(tile_pos: Vector2i) -> void:
	if exploration_map[tile_pos.y][tile_pos.x] == C.ExplorationMapStates.NOT_EXPLORED:
		exploration_map[tile_pos.y][tile_pos.x] = C.ExplorationMapStates.EXPLORED

func toggle_flag(tile_pos: Vector2i) -> void:
	if exploration_map[tile_pos.y][tile_pos.x] == C.ExplorationMapStates.FLAG:
		exploration_map[tile_pos.y][tile_pos.x] = C.ExplorationMapStates.NOT_EXPLORED
	elif exploration_map[tile_pos.y][tile_pos.x] == C.ExplorationMapStates.NOT_EXPLORED:
		exploration_map[tile_pos.y][tile_pos.x] = C.ExplorationMapStates.FLAG

func print_exploration_map() -> void:
	print("EXPLORATION MAP")
	for y in range(0, exploration_map.size()):
		print(exploration_map[y])

func get_greentable_atlas(x: int, y: int) -> Vector2:
	var sum: int = x + y
	if (sum % 2) == 0:
		return Vector2i(0,0)
	return Vector2i(1,0)

func get_orangetable_atlas(x: int, y: int) -> Vector2:
	var sum: int = x + y
	if (sum % 2) == 0:
		return Vector2i(2,0)
	return Vector2i(3,0)

func get_clicked_tile() -> Vector2i:
	var local_pos = get_local_mouse_position()
	return Vector2i(local_pos.x / C.TILE_SIZE, local_pos.y / C.TILE_SIZE)
