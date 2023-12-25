class_name ActionSwapWithTarget extends Action

func _init(actionData,parentChar):
	super(actionData,parentChar)
	pass

func execute():
	var swapWithTargetData:ActionSwapWithTargetData = actionData as ActionSwapWithTargetData

	var targets:Array = character.get_targets()
	if targets.size()>0:
		var teleportTarget:Character = targets[0]
		swap_with_target(teleportTarget)

func swap_with_target(targetChar:Character):
	var prevCharCell:DungeonCell = character.cell
	var targetCell:DungeonCell = targetChar.cell
	targetCell.entityObject = character
	prevCharCell.entityObject = targetChar as Node
	targetChar.move_to_cell(prevCharCell)
	character.move_to_cell(targetCell)
