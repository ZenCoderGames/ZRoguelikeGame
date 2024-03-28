extends Node

@onready var textureRect:TextureRect = $"%TextureRect"
@onready var xpLabel:Label = $"%XPLabel"

func init(charData:CharacterData):
	textureRect.texture = load(charData.spritePath)
	xpLabel.text = str(charData.xp)
