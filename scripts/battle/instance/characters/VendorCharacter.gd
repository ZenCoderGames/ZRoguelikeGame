# VendorCharacter.gd
extends Node2D

class_name VendorCharacter

@onready var root:Sprite2D = $"%Root"

var _data:VendorData
var cell:DungeonCell

func init(data:VendorData):
	_data = data

func activate():
	CombatEventManager.emit_signal("ShowVendor", self, _data)

func get_display_name():
	return _data.displayName

func get_description():
	return _data.description