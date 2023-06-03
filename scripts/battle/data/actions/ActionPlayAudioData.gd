
class_name ActionPlayAudioData extends ActionData

const ID:String = "PLAY_AUDIO"

var audioId:String

func _init(dataJS):
	super(dataJS) 
	audioId = Utils.get_data_from_json(dataJS["params"], "audioId", "INVALID_AUDIO_ID")
	
