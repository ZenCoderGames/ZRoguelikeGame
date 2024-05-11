extends Node

@onready var textureRect:TextureRect = $"%TextureRect"
@onready var xpLabel:Label = $"%XPLabel"

func init(charData:CharacterData, count:int):
	textureRect.texture = load(charData.spritePath)
	xpLabel.text = str(count)
	textureRect.tooltip_text = str(charData.get_display_name(), " Xp: ", charData.xp)
