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
const INPUT_RESET_DUNGEON: String = "reset_dungeon"

const INPUT_MOVE_LEFT: String = "move_left"
const INPUT_MOVE_RIGHT: String = "move_right"
const INPUT_MOVE_UP: String = "move_up"
const INPUT_MOVE_DOWN: String = "move_down"

const INPUT_CAM_ZOOM_OUT: String = "cam_zoom_out"
const INPUT_CAM_ZOOM_IN: String = "cam_zoom_in"

const INPUT_CAM_MOVE_LEFT: String = "cam_move_left"
const INPUT_CAM_MOVE_RIGHT: String = "cam_move_right"
const INPUT_CAM_MOVE_UP: String = "cam_move_up"
const INPUT_CAM_MOVE_DOWN: String = "cam_move_down"
