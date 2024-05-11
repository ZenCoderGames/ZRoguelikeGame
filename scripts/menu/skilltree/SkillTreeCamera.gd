extends Camera2D

class_name SkillTreeCamera

@export var cam_offset = Vector2(0, 0)  # Maximum hor/ver shake in pixels.

func _init():
	UIEventManager.connect("ShowSkillTree", Callable(self, "_show_camera"))

func _show_camera(val:bool, skillTreeId:String):
	self.enabled = val
	if val:
		init()

func init():
	#self.position = player.cell.pos
	_update_camera_to_skilltree_center()

func _update_camera_to_skilltree_center():
	self.make_current()
	#Utils.create_tween_vector2(self, "position", self.position, player.cell.pos + cam_offset, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)


func _process(delta):
	# DEBUG
	_zoom_input()
	_move_input()

# DEBUG
func _zoom_input():
	var zoomVal:float = 0
	
	if Input.is_action_pressed(Constants.INPUT_CAM_ZOOM_OUT):
		zoomVal = 0.05
	elif Input.is_action_pressed(Constants.INPUT_CAM_ZOOM_IN):
		zoomVal = -0.05

	self.zoom.x += zoomVal
	self.zoom.y += zoomVal

func _move_input():
	var x:int = 0
	var y:int = 0
	
	if Input.is_action_pressed(Constants.INPUT_MOVE_LEFT):
		x = -1
	elif Input.is_action_pressed(Constants.INPUT_MOVE_RIGHT):
		x = 1
	
	if Input.is_action_pressed(Constants.INPUT_MOVE_UP):
		y = -1
	elif Input.is_action_pressed(Constants.INPUT_MOVE_DOWN):
		y = 1

	self.position += Vector2(x * 2, y * 2)
