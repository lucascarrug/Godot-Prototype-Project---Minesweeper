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
var can_touch: bool = true

var bombs_left: int = C.MINE_QUANTITY
var explore_counter: int = 0

func _ready():
	get_window().content_scale_size = Vector2i(C.MAP_SIZE_X * C.TILE_SIZE, C.MAP_SIZE_Y * C.TILE_SIZE + 80)
	reset_game()

func _input(event: InputEvent) -> void:
	if not can_touch:
		return
		
	if Input.is_action_just_pressed("left_click"):
		var tile_pos: Vector2i = get_clicked_tile()
		if not mines_set: set_mines(tile_pos)
		if tile_pos != Vector2i(-100,-100): explore(tile_pos)
	if Input.is_action_just_pressed("right_click"):
		var tile_pos: Vector2i = get_clicked_tile()
		toggle_flag(tile_pos)
	if Input.is_action_just_pressed("space"):
		print_exploration_map()
		print_mine_map()

## RESET TABLES

func reset_game() -> void:
	reset_greentable()
	reset_orangetable()
	reset_flagtable()
	reset_spritetable()
	set_exploration_map()
	set_mine_map()

func reset_greentable(max_x: int = C.MAP_SIZE_X, max_y: int = C.MAP_SIZE_Y):
	var atlas: Vector2i
	for y in range(0, max_y):
		for x in range(0, max_x):
			atlas = get_greentable_atlas(x,y)
			greentable.set_cell(Vector2i(x,y), 0, atlas)

func reset_orangetable(max_x: int = C.MAP_SIZE_X, max_y: int = C.MAP_SIZE_Y):
	var atlas: Vector2i
	for y in range(0, max_y):
		for x in range(0, max_x):
			atlas = get_orangetable_atlas(x,y)
			orangetable.set_cell(Vector2i(x,y), 0, atlas)

func reset_flagtable(max_x: int = C.MAP_SIZE_X, max_y: int = C.MAP_SIZE_Y):
	for y in range(0, max_y):
		for x in range(0, max_x):
			flagtable.erase_cell(Vector2i(x,y))
			
func reset_spritetable(max_x: int = C.MAP_SIZE_X, max_y: int = C.MAP_SIZE_Y):
	for y in range(0, max_y):
		for x in range(0, max_x):
			spritetable.erase_cell(Vector2i(x,y))

## MINE MAP

func set_mine_map(max_x: int = C.MAP_SIZE_X, max_y: int = C.MAP_SIZE_Y) -> void:
	for y in range(0, max_y):
		var col: Array[int] = []
		for x in range(0, max_x):
			col.append(0)
		mine_map.append(col)

func set_mines(first_pos: Vector2i) -> void:
	# Set number of mines.
	var mine_quantity = C.MINE_QUANTITY
	# Save mine positions.
	var mine_positions: Array[Vector2i] = []
	# Mines added counter.
	var mines_added = 0
	
	while mines_added < mine_quantity:
		# Random position for mine.
		var x = randi() % C.MAP_SIZE_X
		var y = randi() % C.MAP_SIZE_Y
		var new_mine: Vector2i = Vector2i(x,y)
		
		# Check if not repeated and not at first clicked cell.
		if mine_positions.has(new_mine) or new_mine == first_pos: 
			continue
		
		# Add if mine position is valid.
		mine_positions.append(new_mine)
		mines_added += 1
	
	# Put mines.
	for mine in mine_positions:
		var x = mine[0]
		var y = mine[1]
		mine_map[y][x] = -1
	
	mines_set = true
	
	set_proximity(mine_positions)
	set_spritetable()

func set_proximity(mine_positions: Array[Vector2i]) -> void:
	# Add one to mine neightbors.
	for mine in mine_positions:
		for offset in C.NEIGHTBORS:
			var x = mine[0] + offset[0]
			var y = mine[1] + offset[1]
			
			if not out_of_map(x,y) and mine_map[y][x] != -1:
				mine_map[y][x] += 1

func out_of_map(x: int, y: int):
	if x < 0 or x >= C.MAP_SIZE_X or y < 0 or y >= C.MAP_SIZE_Y:
		return true
	return false

func set_spritetable() -> void:
	for x in C.MAP_SIZE_X:
		for y in C.MAP_SIZE_Y:
			if mine_map[y][x] > 0 and mine_map[y][x] <= 8:
				var atlas_coords = C.number_tile[mine_map[y][x] - 1]
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
	# Simplify coords.
	var x = tile_pos.x
	var y = tile_pos.y
	
	# If explored exit or flag.
	if not exploration_map[y][x] == C.ExplorationMapStates.NOT_EXPLORED:
		return
		
	# If is 0.
	if mine_map[y][x] == 0:
		explore_neightbors(tile_pos)
	# If it is a mine.
	elif mine_map[y][x] == C.MINE:
		explode()
	# If is a number.
	else:
		exploration_map[y][x] = C.ExplorationMapStates.EXPLORED
		greentable.erase_cell(tile_pos)
		
func explore_neightbors(first_neightbor: Vector2i) -> void:
	# Set incomming and repeated neightbors arrays.
	var queue: Array[Vector2i] = [first_neightbor]
	var seen: Array[Vector2i] = []
	
	# While neightbor queue is not empty.
	while not queue.is_empty():
		
		# Check every neightbor.
		for offset in C.NEIGHTBORS:
			# Get neightbor coords.
			var x = queue[0][0] + offset[0]
			var y = queue[0][1] + offset[1]
			
			# Check is in map.
			if out_of_map(x,y): continue
			
			# If neightbor is 0 and not checked before.
			if mine_map[y][x] == 0 and not seen.has(Vector2i(x,y)) and not queue.has(Vector2i(x,y)):
				queue.append(Vector2i(x,y))
		
		seen.append(queue.pop_front())
	
	# Erase cells from seen.
	for tile in seen:
		for offset in C.NEIGHTBORS:
			# Get neightbor coords.
			var nx = tile[0] + offset[0]
			var ny = tile[1] + offset[1]
			
			# Check is in map.
			if out_of_map(nx,ny): continue
	
			exploration_map[ny][nx] = C.ExplorationMapStates.EXPLORED
			greentable.erase_cell(Vector2i(nx,ny))
			flagtable.erase_cell(Vector2i(nx,ny))
	
	# Erase origin.
	exploration_map[first_neightbor.y][first_neightbor.x] = C.ExplorationMapStates.EXPLORED
	greentable.erase_cell(first_neightbor)

func explode() -> void:
	# Can't touch more.
	can_touch = false
	
	# Create timer.
	var timer = Timer.new()
	timer.wait_time = 0.01
	timer.one_shot
	add_child(timer)
	
	# Go through the map.
	for y in C.MAP_SIZE_Y:
		for x in C.MAP_SIZE_X:
			timer.start()
			
			# If flag where not bomb.
			if mine_map[y][x] != C.MINE and exploration_map[y][x] == C.ExplorationMapStates.FLAG:
				spritetable.set_cell(Vector2i(x,y), 0, C.CROSS_TILE)
			
			# If flag where bomb.
			if mine_map[y][x] == C.MINE and exploration_map[y][x] == C.ExplorationMapStates.FLAG:
				pass
			else:
				greentable.erase_cell(Vector2i(x,y))
				
			# If explored not wait.
			if exploration_map[y][x] == 0: await timer.timeout

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

## EXTRA

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
	if local_pos.x < 0 or local_pos.y < 0:
		return Vector2i(-100, -100)
	return Vector2i(local_pos.x / C.TILE_SIZE, local_pos.y / C.TILE_SIZE)
