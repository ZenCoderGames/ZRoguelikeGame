extends PanelContainer

class_name VenderItemUI

@onready var nameLabel:Label = $"%UpgradeNameLabel"
@onready var descLabel:Label = $"%UpgradeDescLabel"
@onready var soulCostLabel:Label = $"%SoulCostLabel"
@onready var chooseBtn:Button = $"%ChooseButton"

var _parent:VendorUI
var _data

func init(parent:VendorUI, data):
	_parent = parent
	_data = data
	nameLabel.text = _data.name
	descLabel.text = _data.description
	soulCostLabel.text = str(_data.soulCost)
	chooseBtn.connect("button_up",Callable(self,"_on_item_chosen"))
	refresh()

func _on_item_chosen():
	var soulCost:int = _get_soul_cost()
	GameGlobals.dungeon.player.consume_souls(soulCost)
	CombatEventManager.emit_signal("OnVendorItemSelected", _data)
	UIEventManager.emit_signal("OnGenericUIEvent")
	_parent.item_bought()

func refresh():
	if _is_upgrade_owned() and _parent.onlyUniquePurchases():
		chooseBtn.disabled = true
		chooseBtn.text = "PURCHASED"
		return

	var soulCost:int = _get_soul_cost()
	if soulCost>0:
		var playerSouls:int = GameGlobals.dungeon.player.get_souls()
		var notEnoughCurrency:bool = playerSouls < soulCost
		chooseBtn.disabled = notEnoughCurrency
		if notEnoughCurrency:
			chooseBtn.text = "NOT ENOUGH SOULS"
		else:
			chooseBtn.text = "BUY"
	else:
		chooseBtn.text = "SELECT"
		chooseBtn.disabled = false
		soulCostLabel.visible = false

func _get_soul_cost():
	var soulCost:int = 0
	if _data!=null:
		soulCost = _data.soulCost
	return soulCost

func _is_upgrade_owned():
	if _data is AbilityData:
		return GameGlobals.dungeon.player.has_ability(_data)
	elif _data is SpecialData:
		return GameGlobals.dungeon.player.has_special(_data)
	elif _data is PassiveData:
		return GameGlobals.dungeon.player.has_passive(_data)

	return false
