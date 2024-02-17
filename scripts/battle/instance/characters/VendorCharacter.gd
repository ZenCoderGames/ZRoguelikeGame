# VendorCharacter.gd
extends Sprite2D

class_name VendorCharacter

var _data:VendorData
var cell:DungeonCell
@onready var hoverInfo:HoverInfo = $"%HoverInfo"

func init(data:VendorData):
	_data = data
	self.self_modulate = Color(data.tintColor)
	hoverInfo.setup_far("Vendor", "This is a Special Vendor. Get Close to Identify.")
	hoverInfo.setup(_data.displayName, _data.description, cell)

func activate():
	CombatEventManager.emit_signal("ShowVendor", self, _data)

func get_display_name():
	return _data.displayName

func get_description():
	return _data.description
