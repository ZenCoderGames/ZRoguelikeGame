extends "res://scripts/battle/Character.gd"

func update():
	.update()

	cell.room.update_path_map()
