extends Node

# DUNGEON ROOM
const MAX_ROWS: int = 15
const MAX_COLS: int = 21

const CENTER_ROW: int = 10
const CENTER_COL: int = 7

const ARROW_MARGIN: int = 32

const START_X: int = 50
const START_Y: int = 54
const STEP_X: int = 26
const STEP_Y: int = 34

enum CELL_TYPE { NONE, FLOOR, CONNECTOR }
enum ENTITY_TYPE { NONE, STATIC, DYNAMIC }

# GROUPS
const pc: String = "pc"
const room: String = "room"
const room_floor: String = "floor"
const room_wall: String = "wall"
const enemies: String = "enemies"

# INPUTS
const INPUT_EXIT_GAME: String = "exit"

const INPUT_MOVE_LEFT: String = "move_left"
const INPUT_MOVE_RIGHT: String = "move_right"
const INPUT_MOVE_UP: String = "move_up"
const INPUT_MOVE_DOWN: String = "move_down"
