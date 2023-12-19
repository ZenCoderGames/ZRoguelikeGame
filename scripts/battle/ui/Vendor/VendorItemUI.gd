extends PanelContainer

class_name VenderItemUI

@onready var nameLabel:Label = $"%UpgradeNameLabel"
@onready var descLabel:Label = $"%UpgradeDescLabel"
@onready var soulCostLabel:Label = $"%SoulCostLabel"
@onready var chooseBtn:Button = $"%ChooseButton"

var _parent:VendorUI
var _abilityData:AbilityData
var _specialData:SpecialData
var _passiveData:PassiveData

func init_as_ability(parent:VendorUI, abilityData:AbilityData):
	_parent = parent
	_abilityData = abilityData
	nameLabel.text = _abilityData.name
	descLabel.text = _abilityData.description
	soulCostLabel.text = str(_abilityData.soulCost)
	chooseBtn.connect("button_up",Callable(self,"_on_item_chosen"))
	refresh()

func init_as_special(parent:VendorUI, specialData:SpecialData):
	_parent = parent
	_specialData = specialData

	nameLabel.text = specialData.name
	descLabel.text = specialData.description
	soulCostLabel.visible = false
	chooseBtn.connect("button_up",Callable(self,"_on_item_chosen"))
	chooseBtn.disabled = false
	refresh()

func init_as_passive(parent:VendorUI, passiveData:PassiveData):
	_parent = parent
	_passiveData = passiveData

	nameLabel.text = _passiveData.name
	descLabel.text = _passiveData.description
	soulCostLabel.visible = false
	chooseBtn.connect("button_up",Callable(self,"_on_item_chosen"))
	chooseBtn.disabled = false
	refresh()

func _on_item_chosen():
	var soulCost:int = _get_soul_cost()
	GameGlobals.dungeon.player.consume_souls(soulCost)
	if _parent.is_ability():
		CombatEventManager.emit_signal("OnVendorItemSelected", _abilityData)
	elif _parent.is_special():
		CombatEventManager.emit_signal("OnVendorItemSelected", _specialData)
	elif _parent.is_passive():
		CombatEventManager.emit_signal("OnVendorItemSelected", _passiveData)
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

func _get_soul_cost():
	var soulCost:int = 0
	if _abilityData!=null:
		soulCost = _abilityData.soulCost
	elif _specialData!=null:
		soulCost = _specialData.soulCost
	elif _passiveData!=null:
		soulCost = _passiveData.soulCost
	return soulCost

func _is_upgrade_owned():
	if _parent.is_ability():
		return GameGlobals.dungeon.player.has_ability(_abilityData)
	elif _parent.is_special():
		return GameGlobals.dungeon.player.has_special(_specialData)
	elif _parent.is_passive():
		return GameGlobals.dungeon.player.has_passive(_passiveData)

	return false
