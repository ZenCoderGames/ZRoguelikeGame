extends PanelContainer

class_name VenderItemUI

@onready var nameLabel:Label = $"%UpgradeNameLabel"
@onready var descLabel:Label = $"%UpgradeDescLabel"
@onready var soulCostLabel:Label = $"%SoulCostLabel"
@onready var chooseBtn:Button = $"%ChooseButton"

var myAbilityData:AbilityData

func init_from_data(abilityData:AbilityData):
	myAbilityData = abilityData
	nameLabel.text = myAbilityData.name
	descLabel.text = myAbilityData.description
	soulCostLabel.text = str(abilityData.soulCost)
	chooseBtn.connect("button_up",Callable(self,"_on_item_chosen"))

	var playerSouls:int = GameGlobals.dungeon.player.get_souls()
	chooseBtn.disabled = playerSouls < abilityData.soulCost

func _on_item_chosen():
	CombatEventManager.emit_signal("OnVendorAbilitySelected", myAbilityData)
	GameGlobals.dungeon.player.consume_souls(myAbilityData.soulCost)
	UIEventManager.emit_signal("OnGenericUIEvent")
