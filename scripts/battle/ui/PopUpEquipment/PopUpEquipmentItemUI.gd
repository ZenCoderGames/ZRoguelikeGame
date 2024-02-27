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

func init(parent:PopUpEquipmentUI, item:Item, slot:int):
	_parent = parent
	_item = item
	_slot = slot
	if _item!=null:
		_soulCost = _item.data.soulCost
		nameLabel.text = _item.data.name
		descLabel.text = Utils.format_text(_item.data.description)
		soulCostLabel.text = str(_soulCost)
	else:
		descLabel.text = Utils.format_text("Item can be equipped here.")
		soulCostContainer.visible = false
	
	if _slot!=-1:
		titlePanel.self_modulate = Color(0, 0.882, 1)
	else:
		titlePanel.self_modulate = Color.LIGHT_GREEN
		nameLabel.text = str("(New) ", _item.data.name)

	equipBtn.connect("button_up",Callable(self,"_on_item_equipped"))
	discardBtn.connect("button_up",Callable(self,"_on_item_discarded"))
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
