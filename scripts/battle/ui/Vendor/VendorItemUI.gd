extends PanelContainer

class_name VenderItemUI

@onready var nameLabel:Label = $"%UpgradeNameLabel"
@onready var descLabel:Label = $"%UpgradeDescLabel"
@onready var soulCostLabel:Label = $"%SoulCostLabel"
@onready var chooseBtn:Button = $"%ChooseButton"

var _parent:VendorUI
var _data
var _soulCost:int

func init(parent:VendorUI, data):
	_parent = parent
	_data = data
	_soulCost = _data.soulCost
	nameLabel.text = _data.name
	descLabel.text = _data.description
	soulCostLabel.text = str(_soulCost)
	chooseBtn.connect("button_up",Callable(self,"_on_item_chosen"))
	refresh()

func _on_item_chosen():
	GameGlobals.dungeon.player.consume_souls(_soulCost)
	CombatEventManager.emit_signal("OnVendorItemSelected", _data)
	UIEventManager.emit_signal("OnGenericUIEvent")
	_parent.item_bought()
	_soulCost = _soulCost * 2
	soulCostLabel.text = str(_soulCost)
	refresh()

func refresh():
	if _is_upgrade_owned() and _parent.onlyUniquePurchases():
		chooseBtn.disabled = true
		chooseBtn.text = "PURCHASED"
		return

	if _soulCost>0:
		var playerSouls:int = GameGlobals.dungeon.player.get_souls()
		var notEnoughCurrency:bool = playerSouls < _soulCost
		chooseBtn.disabled = notEnoughCurrency
		if notEnoughCurrency:
			chooseBtn.text = "NOT ENOUGH SOULS"
		else:
			chooseBtn.text = "BUY"
	else:
		chooseBtn.text = "SELECT"
		chooseBtn.disabled = false
		soulCostLabel.visible = false

func _is_upgrade_owned():
	if _data is AbilityData:
		return GameGlobals.dungeon.player.has_ability(_data)
	elif _data is SpecialData:
		return GameGlobals.dungeon.player.has_special(_data)
	elif _data is PassiveData:
		return GameGlobals.dungeon.player.has_passive(_data)

	return false
