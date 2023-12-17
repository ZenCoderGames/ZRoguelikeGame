extends Control

class_name VendorUI

@onready var itemHolder:HBoxContainer = $"%Items"
@onready var title:Label = $"%Title"
@onready var backBtn:TextureButton = $"%BackButton"

const VendorItemUI := preload("res://ui/battle/VendorItemUI.tscn")

var initialized:bool = false

func init_from_data(vendorData:VendorData):
	if initialized:
		return

	var abilityList:Array = []
	
	title.text = "GENERAL PERK"
	var allowedGeneralAbilites:int = 3
	for abilityData in vendorData.perks:
		abilityList.append(abilityData)
		allowedGeneralAbilites = allowedGeneralAbilites - 1
		if allowedGeneralAbilites==0:
			break

	for abilityData in abilityList:
		var vendorItem = VendorItemUI.instantiate()
		itemHolder.add_child(vendorItem)
		vendorItem.init_from_data(abilityData)

	backBtn.connect("button_up",Callable(self,"_on_back_pressed"))

	UIEventManager.emit_signal("OnGenericUIEvent")

	initialized = true

func _on_back_pressed():
	CombatEventManager.emit_signal("OnVendorAbilitySelected", null)
	UIEventManager.emit_signal("OnGenericUIEvent")
