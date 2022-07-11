extends Node

class_name Cell

# DUNGEON
func vector_to_array(vector_coord: Vector2) -> Array:
	var x: int = ((vector_coord.x - Constants.START_X) / Constants.STEP_X) as int
	var y: int = ((vector_coord.y - Constants.START_Y) / Constants.STEP_Y) as int

	return [x, y]

func index_to_vector(x: int, y: int,
		x_offset: int = 0, y_offset: int = 0) -> Vector2:
	var x_vector: int = Constants.START_X + Constants.STEP_X * x + x_offset
	var y_vector: int = Constants.START_Y + Constants.STEP_Y * y + y_offset

	return Vector2(x_vector, y_vector)

func create_scene(name : String, prefab: PackedScene, group: String, cell:Object,
	x_offset: int = 0, y_offset: int = 0):
	var new_scene := prefab.instance()
	new_scene.position = Vector2(cell.pos.x + x_offset, cell.pos.y + y_offset)
	new_scene.name = name
	new_scene.add_to_group(group)

	add_child(new_scene)
	return new_scene
