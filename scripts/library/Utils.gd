extends Node

class_name Cell

# DUNGEON
func create_scene(container:Array, name : String, prefab: PackedScene, group: String, cell:Object,
	x_offset: int = 0, y_offset: int = 0):
	var new_scene := prefab.instance()
	new_scene.position = Vector2(cell.pos.x + x_offset, cell.pos.y + y_offset)
	new_scene.name = name
	new_scene.add_to_group(group)

	container.append(new_scene)

	add_child(new_scene)
	return new_scene
