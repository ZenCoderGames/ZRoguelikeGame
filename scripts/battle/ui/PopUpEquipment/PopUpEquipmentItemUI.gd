extends PanelContainer

class_name PopUpEquipmentItemUI

@onready var titlePanel:Panel = $"%TitlePanel"
@onready var nameLabel:Label = $"%UpgradeNameLabel"
@onready var descLabel:RichTextLabel = $"%UpgradeDescLabel"
@onready var soulCostContainer:HBoxContainer = $"%SoulCostContainer"
@onready var soulCostLabel:Label = $"%SoulCostLabel"
@onready var equipBtn:Button = $"%EquipButton"
@onready var discardBtn:Button = $"%DiscardButton"
@onready var equippedLabel:Label = $"%EquippedLabel"


var _parent:PopUpEquipmentUI
var _item:Item
var _soulCost:int
var _slot:int
var _idx:int

func init(idx:int, parent:PopUpEquipmentUI, item:Item, slot:int):
	_idx = idx
	_parent = parent
	_item = item
	_slot = slot
	if _item!=null:
		_soulCost = _item.data.soulCost
		nameLabel.text = _item.data.name
		descLabel.text = Utils.format_text(_item.data.description)
		soulCostLabel.text = str(_soulCost)
		equipBtn.text = str(_get_input_str(), "Swap")
	else:
		descLabel.text = Utils.format_text("Item can be equipped here.")
		soulCostContainer.visible = false
		equipBtn.text = str(_get_input_str(), "Equip")
	
	if _slot!=-1:
		titlePanel.self_modulate = Color(0, 0.882, 1)
	else:
		titlePanel.self_modulate = Color.LIGHT_GREEN
		nameLabel.text = str("(New) ", _item.data.name)

	equipBtn.connect("button_up",Callable(self,"_on_item_equipped"))
	discardBtn.connect("button_up",Callable(self,"_on_item_discarded"))
	discardBtn.text = str(_get_discard_input_str(), "Convert to Souls")
	equippedLabel.visible = false
	equipBtn.visible = false
	discardBtn.visible = false
	refresh()

func _on_item_equipped():
	UIEventManager.emit_signal("OnGenericUIEvent")
	_parent.item_equipped(_item, _slot)
	refresh()

func _on_item_discarded():
	UIEventManager.emit_signal("OnGenericUIEvent")
	_parent.item_discarded(_item, _slot)
	refresh()

func refresh():
	equippedLabel.visible = (_item!=null) and (_slot!=-1)
	equipBtn.visible = (_slot!=-1) and _parent.has_new_item()
	discardBtn.visible = (_item!=null)
	
var _isCancelMode:bool = false
func _process(delta: float) -> void:
	_isCancelMode = Input.is_action_pressed(Constants.INPUT_CANCEL_VENDOR_MODIFIER)
		
func _unhandled_input(event: InputEvent) -> void:
	if _idx==0:
		if event.is_action_pressed(Constants.INPUT_VENDOR_OPTION1):
			if _isCancelMode:
				_on_item_discarded()
			else:
				_on_item_equipped()
	elif _idx==1:
		if event.is_action_pressed(Constants.INPUT_VENDOR_OPTION2):
			if _isCancelMode:
				_on_item_discarded()
			else:
				_on_item_equipped()
	elif _idx==2:
		if event.is_action_pressed(Constants.INPUT_VENDOR_OPTION3):
			if _isCancelMode:
				_on_item_discarded()
			else:
				_on_item_equipped()

func _get_input_str():
	if Utils.is_joystick_enabled():
		if _idx==0:
			return "(Up) "
		elif _idx==1:
			return "(Right) "
		elif _idx==2:
			return "(Down) "
	else:
		if _idx==0:
			return "(Z) "
		elif _idx==1:
			return "(X) "
		elif _idx==2:
			return "(C) "
	
	return ""

func _get_discard_input_str():
	if Utils.is_joystick_enabled():
		if _idx==0:
			return "(L1+Up) "
		elif _idx==1:
			return "(L1+Right) "
		elif _idx==2:
			return "(L1+Down) "
	else:
		if _idx==0:
			return "(Alt+Z) "
		elif _idx==1:
			return "(Alt+X) "
		elif _idx==2:
			return "(Alt+C) "
	
	return ""
