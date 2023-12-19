# VendorCharacter.gd
extends Sprite2D

class_name VendorCharacter

var _data:VendorData
var cell:DungeonCell

func init(data:VendorData):
	_data = data
	self.self_modulate = Color(data.tintColor)

func activate():
	CombatEventManager.emit_signal("ShowVendor", self, _data)

func get_display_name():
	return _data.displayName

func get_description():
	return _data.description
