extends Node

class_name AudioManager

@export var numMusicStreams:int = 3
@export var numSfxStreams:int = 5

var audioDataDict = {}

var audioCurrentPlayingMusicDict = {}
var audioMusicStreams = []

var audioCurrentPlayingSFXDict = {}
var audioSfxStreams = []

var isDisabled:bool = false

func _ready():
	GameGlobals.set_audio_manager(self)
	_init_data()
	_init_streams()

# PLAY MUSIC	
func play_music(id:String):
	if isDisabled:
		return
		
	var audioData:AudioData = _get_data(id)
	if audioData!=null:
		var audioStreamPlayer:AudioStreamPlayer2D = null
		if audioCurrentPlayingMusicDict.has(id):
			audioStreamPlayer = audioCurrentPlayingMusicDict[id]
		else:
			audioStreamPlayer = _get_free_music_stream()
			audioCurrentPlayingMusicDict[id] = audioStreamPlayer
		audioStreamPlayer.stream = audioData.stream
		audioStreamPlayer.set_volume_db(linear_to_db(audioData.volume))
		audioStreamPlayer.play()

func stop_music(id:String):
	if audioCurrentPlayingMusicDict.has(id):
		audioCurrentPlayingMusicDict[id].stop()
		audioCurrentPlayingMusicDict.erase(id)
		
func stop_all_music():
	for playingMusic in audioCurrentPlayingMusicDict.values():
		playingMusic.stop()
	audioCurrentPlayingMusicDict.clear()

# PLAY SFX
func play_sfx(id:String):
	if isDisabled:
		return
		
	var audioData:AudioData = _get_data(id)
	if audioData!=null:
		var audioStreamPlayer:AudioStreamPlayer2D = _get_free_sfx_stream()
		audioStreamPlayer.stream = audioData.stream
		audioStreamPlayer.set_volume_db(linear_to_db(audioData.volume))
		audioStreamPlayer.play()
		audioCurrentPlayingSFXDict[id] = audioStreamPlayer

func stop_sfx(id:String):
	if audioCurrentPlayingSFXDict.has(id):
		audioCurrentPlayingSFXDict[id].stop()
		audioCurrentPlayingSFXDict.erase(id)
		
func stop_all_sfx():
	for playingSfx in audioCurrentPlayingSFXDict.values():
		playingSfx.stop()
	audioCurrentPlayingSFXDict.clear()

# STREAMS
func _init_streams():
	for i in numMusicStreams:
		var newStream:AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		add_child(newStream)
		audioMusicStreams.append(newStream)

	for i in numSfxStreams:
		var newStream:AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		add_child(newStream)
		audioSfxStreams.append(newStream)

func _get_free_music_stream():
	for i in numMusicStreams:
		if !audioMusicStreams[i].is_playing():
			return audioMusicStreams[i]

	return audioSfxStreams[0]

func _get_free_sfx_stream():
	for i in numSfxStreams:
		if !audioSfxStreams[i].is_playing():
			return audioSfxStreams[i]

	return audioSfxStreams[0]

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

# SETTINGS
func set_as_disabled(val:bool):
	isDisabled = val
	if isDisabled:
		stop_all_music()
		stop_all_sfx()
