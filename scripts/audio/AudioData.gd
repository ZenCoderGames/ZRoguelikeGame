class_name AudioData

var id:String
var stream:AudioStream
var volume:float

func _init(dataJS):
	id = dataJS["id"]
	volume = Utils.get_data_from_json(dataJS, "volume", 1.0)
	var path = dataJS["path"]
	stream = load(str("res://", path))
	if stream==null:
		print(str("ERROR: Invalid Audio Path: ", path))
