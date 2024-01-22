extends Node

# DUNGEON
func create_scene(container:Array, name : String, prefab: PackedScene, group: String, cell:DungeonCell,
	x_offset: int = 0, y_offset: int = 0):
	var new_scene := prefab.instantiate()
	new_scene.position = Vector2(cell.pos.x + x_offset, cell.pos.y + y_offset)
	new_scene.name = name
	new_scene.add_to_group(group)

	container.append(new_scene)

	add_child(new_scene)
	return new_scene

# GENERAL
func create_tween_float(node, fieldName, startPose, endPose, duration, transType, easeType):
	var tween = get_tree().create_tween()
	tween.tween_property(node, fieldName, endPose, duration).from(startPose).set_trans(transType).set_ease(easeType)
	return tween

func create_tween_vector2(node, fieldName, startPose, endPose, duration, transType, easeType):
	var tween = get_tree().create_tween()
	tween.tween_property(
		node, fieldName, 
		endPose, duration).from(startPose).set_trans(transType).set_ease(easeType)
	return tween

func create_return_tween_vector2(node, fieldName, startPose, endPose, duration, transType, easeType, delayDuration:float=-1):
	if delayDuration==-1:
		delayDuration = duration

	var tween = get_tree().create_tween()
	tween.tween_property(
		node, fieldName, endPose, duration).from(startPose).set_trans(transType).set_ease(easeType)
		
	await get_tree().create_timer(duration).timeout

	var return_tween = get_tree().create_tween()
	return_tween.tween_property(
		node, fieldName, startPose, duration).from(startPose).set_trans(transType).set_ease(easeType)

	return return_tween

func load_data_from_file(relativePath:String) -> Dictionary:
	var dataFilePath:String = str("res://",relativePath)
	if FileAccess.file_exists(dataFilePath):
		var file = FileAccess.open(dataFilePath, FileAccess.READ)
		var data_text = file.get_as_text()
		file.close()
		var test_json_conv = JSON.new()
		var parseResult = test_json_conv.parse(data_text)
		var data_parse = test_json_conv.get_data()
		if parseResult != OK:
			return {}
		return data_parse
	else:
		print("file not found " + dataFilePath)
		return {}

func do_hit_pause():
	get_tree().paused = true
	await get_tree().create_timer(0.5).timeout
	get_tree().paused = false

func is_relative_team(char1, char2, relativeTeamType:int):
	if char1 == char2:
		return false

	if relativeTeamType == Constants.RELATIVE_TEAM.ANY:
		return true

	if relativeTeamType == Constants.RELATIVE_TEAM.ALLY:
		return char1.team == char2.team and char2.team != Constants.TEAM.NPC

	if relativeTeamType == Constants.RELATIVE_TEAM.ENEMY:
		return char1.team != char2.team and char2.team != Constants.TEAM.NPC

	return false

func is_adjacent(char1, char2, _numTiles:int=1)->bool:
	var colDiff = abs(char1.cell.col - char2.cell.col)
	var rowDiff = abs(char1.cell.row - char2.cell.row)

	return (colDiff<=_numTiles and rowDiff==0) or (colDiff==0 and rowDiff<=_numTiles)

func get_data_from_json(jsonData, key, defaultVal):
	if jsonData.has(key):
		return jsonData[key]
	else:
		return defaultVal

func duplicate_array(arrayRef:Array)->Array:
	var newArray = []
	for item in arrayRef:
		newArray.append(item)
	return newArray

func convert_to_camel_case(string:String):
	var result = PackedStringArray()
	var i:int = 0
	for ch in string:
		if i==0:
			result.append(ch.to_upper())
		else:
			result.append(ch.to_lower())
		i = i + 1

	return ''.join(result)

func random_chance(chance:float):
	return randf() < chance

func freeze_frame(time_scale, duration):
	Engine.time_scale = time_scale
	await GameGlobals.battleInstance.get_tree().create_timer(time_scale * duration).timeout
	Engine.time_scale = 1.0

func clean_up_all_signals(node:Node):
	'''var allSignals = node.get_signal_list()
	for cur_signal in allSignals:
		var conns = node.get_signal_connection_list(cur_signal.name)
		for cur_conn in conns:
			node.disconnect(cur_conn.source, cur_conn.signal, cur_conn.target, cur_conn.method)
			#cur_conn.source.disconnect(, node, cur_conn.method_name)
	'''
	pass

# TODO: Keyword parsing
func format_text(val:String):
	return str("[center]", val, "[/center]")
