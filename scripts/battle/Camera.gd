extends Camera2D

var player

func _ready():
	Dungeon.connect("OnPlayerCreated", self, "_register_player") 
	
func _register_player(playerRef):
	player = playerRef
	player.connect("OnCharacterMove", self, "_update_camera") 

func _update_camera(x:int, y:int):
	self.position += Vector2(x * Constants.STEP_X, y * Constants.STEP_Y)

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
