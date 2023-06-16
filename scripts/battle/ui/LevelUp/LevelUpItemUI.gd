extends PanelContainer

class_name LevelUpItemUI

@onready var nameLabel:Label = $"%UpgradeNameLabel"
@onready var descLabel:Label = $"%UpgradeDescLabel"
@onready var chooseBtn:Button = $"%ChooseButton"

var myAbilityData:AbilityData

func init_from_data(abilityData:AbilityData):
	myAbilityData = abilityData
	nameLabel.text = myAbilityData.name
	descLabel.text = myAbilityData.description
	chooseBtn.connect("button_up",Callable(self,"_on_item_chosen"))

func _on_item_chosen():
	CombatEventManager.emit_signal("OnLevelUpAbilitySelected", myAbilityData)
