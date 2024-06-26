extends Camera2D

class_name DungeonCamera

var player

@export var cam_offset = Vector2(0, 0)  # Maximum hor/ver shake in pixels.

# Camera3D Shake Params
@onready var noise = FastNoiseLite.new()
var noise_y = 0

@export var decay = 0.8  # How quickly the shaking stops [0, 1].
@export var max_offset = Vector2(100.0, 100.0)  # Maximum hor/ver shake in pixels.
@export var max_roll = 0.1  # Maximum rotation in radians (use sparingly).

var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].

func _ready():
	# camera shake
	randomize()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi()
	noise.frequency = 0.25
	noise.fractal_lacunarity = 1
	noise.fractal_gain = 0.2
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	#noise.octaves = 2

	GameEventManager.connect("OnDungeonInitialized",Callable(self,"_on_dungeon_init"))
	GameEventManager.connect("OnCleanUpForDungeonRecreation",Callable(self,"_on_cleanup_for_dungeon"))
	GameEventManager.connect("OnNewLevelLoaded",Callable(self,"_on_dungeon_init"))
	GameEventManager.connect("OnDungeonExited",Callable(self,"_on_dungeon_exited"))

	CombatEventManager.connect("OnAnyAttack",Callable(self,"_on_any_attack"))
	CombatEventManager.connect("OnRoomCombatStarted",Callable(self,"_on_room_combat_started"))
	CombatEventManager.connect("OnRoomCombatEnded",Callable(self,"_on_room_combat_ended"))

	CombatEventManager.connect("OnAnyAttack",Callable(self,"_on_any_attack"))
	CombatEventManager.connect("OnZoomIn",Callable(self,"_on_zoom_in"))
	CombatEventManager.connect("OnZoomOut",Callable(self,"_on_zoom_out"))

func _on_dungeon_init():
	_register_player(GameGlobals.dungeon.player)
	self.visible = true

func _register_player(playerRef):
	player = playerRef
	#player.connect("OnCharacterRoomChanged",Callable(self,"_update_camera_to_room"))
	player.connect("OnCharacterMoveToCell",Callable(self,"_update_camera_to_player"))
	self.position = player.cell.pos
	_update_camera_to_player()

func _update_camera_to_room(newRoom):
	Utils.create_tween_vector2(self, "position", self.position, newRoom.get_center(), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

func _update_camera_to_player():
	Utils.create_tween_vector2(self, "position", self.position, player.cell.pos + cam_offset, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	self.make_current()

func _on_room_combat_started(_room):
	await GameGlobals.battleInstance.get_tree().create_timer(0.1).timeout
	Utils.create_tween_vector2(self, "zoom", self.zoom, Vector2(Constants.CAM_ZOOM_COMBAT.x, Constants.CAM_ZOOM_COMBAT.y), Constants.CAM_ZOOM_EASE_TIME, Tween.TRANS_LINEAR, Tween.EASE_OUT)

func _on_room_combat_ended(_room):
	await GameGlobals.battleInstance.get_tree().create_timer(0.25).timeout
	Utils.create_tween_vector2(self, "zoom", self.zoom, Vector2(Constants.CAM_ZOOM_DEFAULT.x, Constants.CAM_ZOOM_DEFAULT.y), Constants.CAM_ZOOM_EASE_TIME, Tween.TRANS_LINEAR, Tween.EASE_OUT)

func _on_dungeon_exited(isVictory:bool):
	await GameGlobals.battleInstance.get_tree().create_timer(Constants.DEATH_TO_MENU_TIME).timeout

	Utils.create_tween_vector2(self, "zoom", self.zoom, Vector2(Constants.CAM_ZOOM_COMBAT.x, Constants.CAM_ZOOM_COMBAT.y), Constants.CAM_ZOOM_EASE_TIME, Tween.TRANS_LINEAR, Tween.EASE_OUT)

# CAMERA SHAKE
func _on_any_attack(entity):
	if entity.isDead:
		add_trauma(Constants.CAMERA_SHAKE_KILL_TRAUMA)
	else:
		add_trauma(Constants.CAMERA_SHAKE_DEFAULT_TRAUMA)

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)

func shake():
	noise_y += 1
	self.rotation = max_roll * trauma * noise.get_noise_2d(noise.seed, noise_y)
	self.offset.x = cam_offset.x + max_offset.x * trauma * noise.get_noise_2d(noise.seed*2, noise_y)
	self.offset.y = cam_offset.y + max_offset.y * trauma * noise.get_noise_2d(noise.seed*3, noise_y)
	#noise.get_noise_2d(noise.seed, noise_y))

func _process(delta):
	# DEBUG
	_zoom_input()
	_move_input()

	if trauma>0:
		trauma = max(trauma - decay * delta, 0)
		shake()

# DEBUG
func _zoom_input():
	var zoomVal:float = 0
	
	if Input.is_action_pressed(Constants.INPUT_CAM_ZOOM_OUT):
		zoomVal = 0.1
	elif Input.is_action_pressed(Constants.INPUT_CAM_ZOOM_IN):
		zoomVal = -0.1

	self.zoom.x += zoomVal
	self.zoom.y += zoomVal

func _move_input():
	var x:int = 0
	var y:int = 0
	
	if Input.is_action_pressed(Constants.INPUT_CAM_MOVE_LEFT):
		x = -1
	elif Input.is_action_pressed(Constants.INPUT_CAM_MOVE_RIGHT):
		x = 1
	
	if Input.is_action_pressed(Constants.INPUT_CAM_MOVE_UP):
		y = -1
	elif Input.is_action_pressed(Constants.INPUT_CAM_MOVE_DOWN):
		y = 1

	self.position += Vector2(x * 20, y * 20)

func _on_cleanup_for_dungeon(fullRefreshDungeon:bool=true):
	if fullRefreshDungeon:
		if player!=null and !player.is_queued_for_deletion():
			player.disconnect("OnCharacterMoveToCell",Callable(self,"_update_camera_to_player"))

func _on_zoom_in():
	self.zoom.x += 0.1
	self.zoom.y += 0.1

func _on_zoom_out():
	self.zoom.x -= 0.1
	self.zoom.y -= 0.1
