
class_name ActionPlayAudio extends Action

func _init(actionData,parentChar):
	super(actionData,parentChar)
	pass

func execute():
	var playAudioData:ActionPlayAudioData = actionData as ActionPlayAudioData
	GameGlobals.audioManager.play_sfx(playAudioData.audioId)
