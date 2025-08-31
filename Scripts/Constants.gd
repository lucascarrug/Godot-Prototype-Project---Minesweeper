class_name Constants extends Resource

## Tile.
const TILE_SIZE: int = 16

## Tileset.
const GREEN_TILE: 		Vector2i = Vector2i(0,0)
const DARK_GREEN_TILE: 	Vector2i = Vector2i(1,0)
const ORANGE_TILE: 		Vector2i = Vector2i(2,0)
const DARK_ORANGE_TILE: Vector2i = Vector2i(3,0)
const FLAG_TILE: 		Vector2i = Vector2i(4,0)
const BOMB_TILE: 		Vector2i = Vector2i(5,0)
const ONE_TILE: 		Vector2i = Vector2i(6,0)
const TWO_TILE:			Vector2i = Vector2i(0,1)
const THREE_TILE:		Vector2i = Vector2i(1,1)
const FOUR_TILE:  		Vector2i = Vector2i(2,1)
const FIVE_TILE:  		Vector2i = Vector2i(3,1)
const SIX_TILE:   		Vector2i = Vector2i(4,1)
const SEVEN_TILE: 		Vector2i = Vector2i(5,1)
const EIGHT_TILE: 		Vector2i = Vector2i(6,1)
const CROSS_TILE:		Vector2i = Vector2i(0,2)

var number_tile = [
	ONE_TILE,
	TWO_TILE,
	THREE_TILE,
	FOUR_TILE,
	FIVE_TILE,
	SIX_TILE,
	SEVEN_TILE,
	EIGHT_TILE]

## Mine map.
const MINE: int = -1
const MINE_QUANTITY: Array[int] = [10, 40, 90]

## Exploration map.
enum ExplorationMapStates {NOT_EXPLORED, EXPLORED, FLAG}

## TilemapLayer map.
const MAP_SIZE_X: Array[int] = [9, 16, 30]
const MAP_SIZE_Y: Array[int] = [9, 16, 30]

## Extras.
var NEIGHTBORS := [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1,  0),                  Vector2i(1,  0),
		Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1),
	]

## Difficulty.
enum GameDifficulty {EASY = 0, MEDIUM = 1, HARD = 2}

## UI.
const UI_SIZE: int = 40
