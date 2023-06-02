extends Node

class_name AudioManager

@export var numStreams:int = 5

var audioDataDict = {}
var audioStreams = []

func _ready():
	GameGlobals.set_audio_manager(self)
	_init_data()
	_init_streams()

func play(id:String):
	var audioData:AudioData = _get_data(id)
	if audioData!=null:
		var audioStream = _get_free_stream()
		audioStream.stream = audioData.stream
		audioStream.play()

# STREAMS
func _init_streams():
	for i in numStreams:
		var newStream:AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		add_child(newStream)
		audioStreams.append(newStream)

func _get_free_stream():
	for i in numStreams:
		if !audioStreams[i].is_playing():
			return audioStreams[i]

	return audioStreams[0]

# DATA
func _init_data():
	var data = Utils.load_data_from_file("resource/data/audio.json")
	var audioDataJSList:Array = data["audio"]
	for audioDataJS in audioDataJSList:
		var newAudioData = AudioData.new(audioDataJS)
		audioDataDict[newAudioData.id] = newAudioData

func _get_data(id:String):
	if audioDataDict.has(id):
		return audioDataDict[id]
	else:
		print("ERROR: INVALID AUDIO ID Requested: " + id)
		return null
