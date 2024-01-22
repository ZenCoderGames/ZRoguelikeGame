extends MarginContainer

class_name InfoUI

@onready var titleLabel:Label = $Title/ColorRect/Label
@onready var contentLabel:RichTextLabel = $"%ContentLabel"

func showUI(title:String, content:String):
	titleLabel.text = title
	contentLabel.text = Utils.format_text(content)
	self.visible = true
	
func hideUI():
	self.visible = false
