class_name Constants extends Resource

## Tile.
const TILE_SIZE: int = 16

## Tileset.
const GREEN_TILE: Vector2i = Vector2i(0,0)
const DARK_GREEN_TILE: Vector2i = Vector2i(1,0)
const ORANGE_TILE: Vector2i = Vector2i(2,0)
const DARK_ORANGE_TILE: Vector2i = Vector2i(3,0)
const FLAG_TILE: Vector2i = Vector2i(4,0)

## Bomb map.
const BOMB = -1

## Exploration map.
enum ExplorationMapStates {NOT_EXPLORED, EXPLORED, FLAG}

## TilemapLayer map.
const MAP_SIZE_X: int = 8
const MAP_SIZE_Y: int = 8
