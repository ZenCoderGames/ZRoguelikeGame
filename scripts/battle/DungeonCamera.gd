extends Camera2D

class_name DungeonCamera

var player

func _init():
	pass
	
func _ready():
	Dungeon.connect("OnPlayerCreated", self, "_register_player") 
	Dungeon.battleInstance.connect("OnDungeonInitialized", self, "_on_dungeon_init")
	
func _register_player(playerRef):
	player = playerRef
	player.connect("OnCharacterRoomChanged", self, "_update_camera")
	self.position = player.cell.pos
	_update_camera(player.cell.room)

func _update_camera(newRoom):
	Utils.create_tween_vector2(self, "position", self.position, newRoom.get_center(), 0.35, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

# DEBUG
func _process(delta):
	_zoom_input()
	_move_input()

func _zoom_input():
	var zoom:float = 0
	
	if Input.is_action_pressed(Constants.INPUT_CAM_ZOOM_OUT):
		zoom = 0.1
	elif Input.is_action_pressed(Constants.INPUT_CAM_ZOOM_IN):
		zoom = -0.1

	self.zoom.x += zoom
	self.zoom.y += zoom

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
