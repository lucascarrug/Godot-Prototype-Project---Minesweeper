extends Node2D
class_name Minesweeper

@export var greentable: TileMapLayer

var C = Constants.new()
var exploration_map: Array[Array] = []
var mine_map: Array[Array] = []

func _ready():
	set_tilemaplayer(C.MAP_SIZE_X, C.MAP_SIZE_Y)
	set_exploration_map(C.MAP_SIZE_X, C.MAP_SIZE_Y)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"):
		var tile_pos: Vector2i = get_clicked_tile()
		explore(tile_pos)
	if Input.is_action_just_pressed("right_click"):
		print_exploration_map()

func set_tilemaplayer(max_x: int = C.MAP_SIZE_X, max_y: int = C.MAP_SIZE_Y):
	var atlas: Vector2i
	for y in range(0, max_y):
		for x in range(0, max_x):
			atlas = get_atlas(x,y)
			greentable.set_cell(Vector2i(x,y), 0, atlas)

## EXPLORATION MAP

func set_exploration_map(max_x: int = C.MAP_SIZE_X, max_y: int = C.MAP_SIZE_Y) -> void:
	for y in range(0, max_y):
		var col: Array[int] = []
		for x in range(0, max_x):
			col.append(0)
		exploration_map.append(col)

func explore(tile_pos: Vector2i) -> void:
	exploration_map[tile_pos.y][tile_pos.x] += 1
	
func print_exploration_map() -> void:
	for y in range(0, exploration_map.size()):
		print(exploration_map[y])

func get_atlas(x: int, y: int) -> Vector2:
	var sum: int = x + y
	if ((x + y) % 2) == 0:
		return Vector2i(0,0)
	return Vector2i(1,0)
	
func get_clicked_tile() -> Vector2i:
	var local_pos = get_local_mouse_position()
	return Vector2i(local_pos.x / C.TILE_SIZE, local_pos.y / C.TILE_SIZE)
