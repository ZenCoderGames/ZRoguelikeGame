extends PanelContainer

class_name VendorItemUI

@onready var nameLabel:Label = $"%UpgradeNameLabel"
@onready var descLabel:RichTextLabel = $"%UpgradeDescLabel"
@onready var soulCostContainer:HBoxContainer = $"%SoulCostContainer"
@onready var soulCostLabel:Label = $"%SoulCostLabel"
@onready var chooseBtn:Button = $"%ChooseButton"

var _parent:VendorUI
var _data
var _soulCost:int
var _idx:int

func init(idx:int, parent:VendorUI, data):
	_idx = idx
	_parent = parent
	_data = data
	_soulCost = _data.soulCost * GameGlobals.dungeon.player._currentVendorCostMultiplier
	nameLabel.text = _data.name
	descLabel.text = Utils.format_text(_data.description)
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
		soulCostContainer.visible = true
		var playerSouls:int = GameGlobals.dungeon.player.get_souls()
		var notEnoughCurrency:bool = playerSouls < _soulCost
		chooseBtn.disabled = notEnoughCurrency
		if notEnoughCurrency:
			chooseBtn.text = "NOT ENOUGH SOULS"
		else:
			chooseBtn.text = str(_get_input_str(), "BUY")
	else:
		chooseBtn.text = str(_get_input_str(), "SELECT")
		chooseBtn.disabled = false
		soulCostContainer.visible = false

func _is_upgrade_owned():
	if _data is AbilityData:
		return GameGlobals.dungeon.player.has_ability(_data)
	elif _data is SpecialData:
		return GameGlobals.dungeon.player.has_special(_data)
	elif _data is PassiveData:
		return GameGlobals.dungeon.player.has_passive(_data)

	return false

func _unhandled_input(event: InputEvent) -> void:
	if chooseBtn.disabled:
		return
		
	if _idx==0:
		if event.is_action_pressed(Constants.INPUT_VENDOR_OPTION1):
			_on_item_chosen()
	elif _idx==1:
		if event.is_action_pressed(Constants.INPUT_VENDOR_OPTION2):
			_on_item_chosen()
	elif _idx==2:
		if event.is_action_pressed(Constants.INPUT_VENDOR_OPTION3):
			_on_item_chosen()

func _get_input_str():
	if _idx==0:
		return "(Z) "
	elif _idx==1:
		return "(X) "
	elif _idx==2:
		return "(C) "
	
	return ""
