extends Node

# PRELOADS
const Floor := preload("res://entity/Floor.tscn")
const Wall := preload("res://entity/Wall.tscn")
const Exit := preload("res://entity/Exit.tscn")
const End := preload("res://entity/End.tscn")
const Door := preload("res://entity/Door.tscn")

# GENERAL
enum DIRN_TYPE { LEFT, RIGHT, UP, DOWN }

# DUNGEON ROOM
const STEP_X: int = 36
const STEP_Y: int = 36

enum CELL_TYPE { NONE, FLOOR, CONNECTOR, EXIT, END }
enum ENTITY_TYPE { NONE, STATIC, DYNAMIC }

enum TEAM { NONE, PLAYER, ENEMY, NPC }
enum RELATIVE_TEAM { ANY, ALLY, ENEMY }

# PLAYER
enum ITEM_EQUIP_SLOT { NONE, WEAPON, ARMOR, SPELL_1, SPELL_2, SPELL_3, SPELL_4, RUNE_1, RUNE_2 }

# GROUPS
const pc: String = "pc"
const room: String = "room"
const room_floor: String = "floor"
const room_wall: String = "wall"
const room_exit: String = "exit"
const room_end: String = "end"
const room_door: String = "door"
const enemies: String = "enemies"
const items: String = "items"
const upgrades: String = "upgrades"
const vendors: String = "vendors"
const tutorialPickups: String = "tutorialPickups"

# INPUTS
const INPUT_EXIT_GAME: String = "exit"

const INPUT_TOGGLE_INVENTORY: String = "toggle_inventory"

const INPUT_MOVE_LEFT: String = "move_left"
const INPUT_MOVE_RIGHT: String = "move_right"
const INPUT_MOVE_UP: String = "move_up"
const INPUT_MOVE_DOWN: String = "move_down"
const INPUT_SKIP_TURN: String = "skip_turn"
const INPUT_BATTLE_MENU: String = "battle_menu"

const INPUT_CAM_ZOOM_OUT: String = "cam_zoom_out"
const INPUT_CAM_ZOOM_IN: String = "cam_zoom_in"

const INPUT_CAM_MOVE_LEFT: String = "cam_move_left"
const INPUT_CAM_MOVE_RIGHT: String = "cam_move_right"
const INPUT_CAM_MOVE_UP: String = "cam_move_up"
const INPUT_CAM_MOVE_DOWN: String = "cam_move_down"

const INPUT_VENDOR_OPTION1: String = "vendor_option_1"
const INPUT_VENDOR_OPTION2: String = "vendor_option_2"
const INPUT_VENDOR_OPTION3: String = "vendor_option_3"

const INPUT_CANCEL_VENDOR_MODIFIER: String = "cancel_vendor_modifier"
const INPUT_CANCEL_VENDOR_OPTION1: String = "cancel_vendor_option_1"
const INPUT_CANCEL_VENDOR_OPTION2: String = "cancel_vendor_option_2"
const INPUT_CANCEL_VENDOR_OPTION3: String = "cancel_vendor_option_3"

const INPUT_USE_SPECIAL1: String = "use_special_1"
const INPUT_USE_SPECIAL2: String = "use_special_2"
const INPUT_USE_SPECIAL3: String = "use_special_3"

const INPUT_MENU_ACCEPT: String = "menu_accept"

# GAMEPLAY
enum TRIGGER_CONDITION { NONE, ON_PRE_ATTACK, ON_PRE_HIT, ON_BLOCKED_HIT, ON_EVADED_HIT, ON_TAKE_HIT, ON_POST_HIT, ON_POST_ATTACK,\
							ON_KILL, ON_DEATH, ON_START_TURN, ON_END_TURN, ON_MOVE, ON_SPELL_ACTIVATE,\
							ON_ADD_STATUS_EFFECT_TO_SELF, ON_ADD_STATUS_EFFECT_TO_ENEMY, ON_NEAR_ENEMY,\
							ON_SPECIAL_ACTIVATE, ON_START_FLOOR, ON_SPECIAL_ADDED, ON_START_DUNGEON}


enum KEYWORDS { PROTECTION, PUSH, BARRIER, SPELL, KILL }

const SKIP_TURN_COOLDOWN:int = 15

# FEEL
const HIT_PAUSE_DEFAULT_AMOUNT:float = 0.075
const HIT_PAUSE_DEFAULT_DURATION:float = 0.05

const HIT_PAUSE_KILL_AMOUNT:float = 0.1
const HIT_PAUSE_KILL_DURATION:float = 0.1

const CAMERA_SHAKE_DEFAULT_TRAUMA:float = 0.05
const CAMERA_SHAKE_KILL_TRAUMA:float = 0.15

const TIME_BETWEEN_MOVES:float = 0.05 # unused
const TIME_BETWEEN_MOVES_ADJACENT_TO_PLAYER:float = 0.15 # unused
const CHARACTER_POST_ATTACK_DELAY:float = 0.1

const SHOW_DEATH_UI_TIME:float = 0.5
const DEATH_TO_MENU_TIME:float = 2.0

const HOLD_TIME_THRESHOLD:float = 0.35
const INPUT_CACHE_TIME_THRESHOLD:float = 4.5

const CAM_ZOOM_DEFAULT:Vector2 = Vector2(1.5, 1.5)
const CAM_ZOOM_COMBAT:Vector2 = Vector2(1.75, 1.75)
const CAM_ZOOM_EASE_TIME:float = 0.35

# ECONOMY
const GOLD_CONSTANT:int = 5
