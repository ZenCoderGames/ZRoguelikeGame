extends Node

# DUNGEON ROOM
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
