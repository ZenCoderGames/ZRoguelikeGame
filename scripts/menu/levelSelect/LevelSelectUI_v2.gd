extends Panel

class_name LevelSelectUI_v2

@onready var backButton:TextureButton = $"%BackButton"
@onready var titleLabel:Label = $"%TitleLabel"
@onready var readyButton_Tutorial:Button = $"%Button_Tutorial"
@onready var readyButton_Campaign:Button = $"%Button_Campaign"
@onready var readyButton_Challenges:Button = $"%Button_Challenges"

var _myCharData:CharacterData

signal OnBackPressed

func init_from_data(charData:CharacterData):
	clean_up()

	_myCharData = charData

	backButton.connect("pressed",Callable(self,"_on_back_button_pressed"))
	readyButton_Tutorial.connect("pressed",Callable(self,"_on_tutorial_button_pressed"))
	readyButton_Campaign.connect("pressed",Callable(self,"_on_campaign_button_pressed"))
	readyButton_Challenges.connect("pressed",Callable(self,"_on_challenges_button_pressed"))

func clean_up():
	backButton.disconnect("pressed",Callable(self,"_on_back_button_pressed"))
	readyButton_Tutorial.disconnect("pressed",Callable(self,"_on_tutorial_button_pressed"))
	readyButton_Campaign.disconnect("pressed",Callable(self,"_on_campaign_button_pressed"))
	readyButton_Challenges.disconnect("pressed",Callable(self,"_on_challenges_button_pressed"))

func _on_back_button_pressed():
	emit_signal("OnBackPressed")

func _on_tutorial_button_pressed():
	GameEventManager.ready_to_battle(GameGlobals.dataManager.levelDict["LEVEL_TUTORIAL"])

func _on_campaign_button_pressed():
	GameEventManager.ready_to_battle(GameGlobals.dataManager.levelDict["LEVEL_CAMPAIGN"])

func _on_challenges_button_pressed():
	GameEventManager.ready_to_battle(GameGlobals.dataManager.levelDict["LEVEL_CHALLENGE"])
