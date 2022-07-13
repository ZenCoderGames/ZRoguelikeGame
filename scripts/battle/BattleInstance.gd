extends Node

func _ready():
	yield(get_tree(), "idle_frame")
	_create_dungeon()

func _create_dungeon():
	Dungeon.create()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(Constants.INPUT_RESET_DUNGEON):
		Dungeon.clean_up()
		Dungeon.create()
