extends Node

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

# GENERAL
func create_tween_vector2(node, fieldName, startPose, endPose, duration, transType, easeType):
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(
		node, fieldName, 
		startPose, endPose, duration,
		transType, easeType)
	tween.start()

func create_return_tween_vector2(node, fieldName, startPose, endPose, duration, transType, easeType):
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(
		node, fieldName, 
		startPose, endPose, duration,
		transType, easeType)
	tween.start()

	yield(get_tree().create_timer(duration), "timeout")

	var return_tween = Tween.new()
	add_child(return_tween)
	return_tween.interpolate_property(
		node, fieldName, 
		endPose, startPose, duration,
		transType, easeType)
	return_tween.start()

func load_data_from_file(relativePath) -> JSON:
	var data_file = File.new()
	if data_file.open(str("res://",relativePath), File.READ) != OK:
		return null
	var data_text = data_file.get_as_text()
	data_file.close()
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		return null
	return data_parse.result
	#$Label.text = data["1"].name
