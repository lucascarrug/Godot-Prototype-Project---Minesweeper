extends Node2D
class_name Minesweeper

@export var flagtable: TileMapLayer
@export var greentable: TileMapLayer
@export var spritetable: TileMapLayer
@export var orangetable: TileMapLayer

var C = Constants.new()

var exploration_map: Array[Array] = []
var mine_map: Array[Array] = []
var mines_set: bool = false

func _ready():
	set_greentable()
	set_orangetable()
	set_exploration_map()
	set_mine_map()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"):
		var tile_pos: Vector2i = get_clicked_tile()
		if not mines_set: set_mines(tile_pos)
		explore(tile_pos)
	if Input.is_action_just_pressed("right_click"):
		var tile_pos: Vector2i = get_clicked_tile()
		toggle_flag(tile_pos)
	if Input.is_action_just_pressed("space"):
		print_exploration_map()
		print_mine_map()

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

## MINE MAP

func set_mine_map(max_x: int = C.MAP_SIZE_X, max_y: int = C.MAP_SIZE_Y) -> void:
	for y in range(0, max_y):
		var col: Array[int] = []
		for x in range(0, max_x):
			col.append(0)
		mine_map.append(col)

func set_mines(first_pos: Vector2i) -> void:
	# Set number of mines.
	var mine_quantity = 10
	# Save mine positions.
	var mine_positions: Array[Vector2i] = []
	# Mines added counter.
	var mines_added = 0
	
	while mines_added < mine_quantity:
		var x = randi() % C.MAP_SIZE_X
		var y = randi() % C.MAP_SIZE_Y
		var new_mine: Vector2i = Vector2i(x,y)
			
		if not mine_positions.has(new_mine) and new_mine != first_pos: 
			mine_positions.append(new_mine)
			mines_added += 1
	
	# Put mines.
	for mine in mine_positions:
		var x = mine[0]
		var y = mine[1]
		mine_map[y][x] = -1
	
	mines_set = true
	
	set_proximity(mine_positions)
	set_sprite_table()

func set_proximity(mine_positions: Array[Vector2i]) -> void:
	# Set neightbors.
	var neighbors := [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1,  0),                  Vector2i(1,  0),
		Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1),
	]
	
	# Add one to mine neightbors.
	for mine in mine_positions:
		for offset in neighbors:
			var x = mine[0] + offset[0]
			var y = mine[1] + offset[1]
			
			if not out_of_map(x,y) and mine_map[y][x] != -1:
				mine_map[y][x] += 1

func out_of_map(x: int, y: int):
	if x < 0 or x >= C.MAP_SIZE_X or y < 0 or y >= C.MAP_SIZE_Y:
		return true
	return false

func set_sprite_table() -> void:
	for x in C.MAP_SIZE_X:
		for y in C.MAP_SIZE_Y:
			if mine_map[y][x] > 0 and mine_map[y][x] <= 8:
				var atlas_coords = C.number_tile[mine_map[y][x] - 1]
				#print("minemap[", x, ",", y,"] -> atlas_coords: ", atlas_coords)
				spritetable.set_cell(Vector2i(x,y), 0, atlas_coords)
			elif mine_map[y][x] == -1:
				spritetable.set_cell(Vector2i(x,y), 0, C.BOMB_TILE)

func print_mine_map() -> void:
	print("MINE MAP")
	for y in range(0, mine_map.size()):
		print(mine_map[y])

## EXPLORATION MAP

func set_exploration_map(max_x: int = C.MAP_SIZE_X, max_y: int = C.MAP_SIZE_Y) -> void:
	for y in range(0, max_y):
		var col: Array[int] = []
		for x in range(0, max_x):
			col.append(C.ExplorationMapStates.NOT_EXPLORED)
		exploration_map.append(col)

func explore(tile_pos: Vector2i) -> void:
	var neighbors := [
		Vector2i(-1,-1), Vector2i(0,-1), Vector2i(1,-1),
		Vector2i(-1, 0),                 Vector2i(1, 0),
		Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
	]
	
	var x = tile_pos.x
	var y = tile_pos.y
	
	if exploration_map[y][x] == C.ExplorationMapStates.NOT_EXPLORED:
		if mine_map[y][x] == 0:
			var tiles_to_erase: Array[Vector2i] = explore_neightbors(tile_pos)
			
			for tile in tiles_to_erase:
				for offset in neighbors:
					# Get neightbor coords.
					var nx = tile[0] + offset[0]
					var ny = tile[1] + offset[1]
					
					# Check is in map.
					if out_of_map(nx,ny): continue
			
					exploration_map[ny][nx] = C.ExplorationMapStates.EXPLORED
					greentable.erase_cell(Vector2i(nx,ny))
			
			exploration_map[y][x] = C.ExplorationMapStates.EXPLORED
			greentable.erase_cell(tile_pos)
			
		elif mine_map[y][x] == C.BOMB:
			explode()
		else:
			exploration_map[y][x] = C.ExplorationMapStates.EXPLORED
			greentable.erase_cell(tile_pos)
		
func explore_neightbors(first_neightbor: Vector2i) -> Array[Vector2i]:
	# Define neightbors.
	var neighbors := [
		Vector2i(-1,-1), Vector2i(0,-1), Vector2i(1,-1),
		Vector2i(-1, 0),                 Vector2i(1, 0),
		Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
	]
	
	# Set incomming and repeated neightbors arrays.
	var clean_neightbors: Array[Vector2i] = []
	var seen_neightbors: Array[Vector2i] = []
	clean_neightbors.append(first_neightbor)
	
	# While clean neightbors are not empty.
	while not clean_neightbors.is_empty():
		# Check every neightbor.
		for offset in neighbors:
			# Get neightbor coords.
			var x = clean_neightbors[0][0] + offset[0]
			var y = clean_neightbors[0][1] + offset[1]
			
			# Check is in map.
			if out_of_map(x,y): continue
			
			# If neightbor is 0 and not checked before.
			if mine_map[y][x] == 0 and not seen_neightbors.has(Vector2i(x,y)) and not clean_neightbors.has(Vector2i(x,y)):
				clean_neightbors.append(Vector2i(x,y))
		
		var last = clean_neightbors.pop_front()
		seen_neightbors.append(last)
		print("New vector seen: ", last)
	
	return seen_neightbors

func explode() -> void:
	print("EXPLODE")

func toggle_flag(tile_pos: Vector2i) -> void:
	var x = tile_pos.x
	var y = tile_pos.y
	
	if exploration_map[y][x] == C.ExplorationMapStates.FLAG:
		exploration_map[y][x] = C.ExplorationMapStates.NOT_EXPLORED
		flagtable.erase_cell(Vector2i(x,y))
	elif exploration_map[y][x] == C.ExplorationMapStates.NOT_EXPLORED:
		exploration_map[y][x] = C.ExplorationMapStates.FLAG
		flagtable.set_cell(Vector2i(x,y), 0, C.FLAG_TILE)

func print_exploration_map() -> void:
	print("EXPLORATION MAP")
	for y in range(0, exploration_map.size()):
		print(exploration_map[y])

func get_greentable_atlas(x: int, y: int) -> Vector2:
	var sum: int = x + y
	if (sum % 2) == 0:
		return C.GREEN_TILE
	return C.DARK_GREEN_TILE

func get_orangetable_atlas(x: int, y: int) -> Vector2:
	var sum: int = x + y
	if (sum % 2) == 0:
		return C.ORANGE_TILE
	return C.DARK_ORANGE_TILE

func get_clicked_tile() -> Vector2i:
	var local_pos = get_local_mouse_position()
	return Vector2i(local_pos.x / C.TILE_SIZE, local_pos.y / C.TILE_SIZE)
