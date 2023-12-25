class_name ActionTeleportToTarget extends Action

func _init(actionData,parentChar):
	super(actionData,parentChar)
	pass

func execute():
	var teleportToTargetData:ActionTeleportToTargetData = actionData as ActionTeleportToTargetData

	var targets:Array = character.get_targets()
	if targets.size()>0:
		var teleportTarget:Character = targets[0]
		# Do Damage
		HitResolutionManager.do_hit(character, teleportTarget, character.get_damage())
		# Teleport
		if character.cell.col>teleportTarget.cell.col:
			if teleport_to_cell(character.cell.row, teleportTarget.cell.col-1):
				return
		if character.cell.col<teleportTarget.cell.col:
			if teleport_to_cell(character.cell.row, teleportTarget.cell.col+1):
				return
		if character.cell.row>teleportTarget.cell.row:
			if teleport_to_cell(teleportTarget.cell.row-1, character.cell.col):
				return
		if character.cell.row<teleportTarget.cell.row:
			if teleport_to_cell(teleportTarget.cell.row+1, character.cell.col):
				return

func teleport_to_cell(row:int, col:int):
	var teleportCell:DungeonCell = character.cell.room.get_cell(row, col)
	if teleportCell.is_empty():
		character.cell.clear_entity()
		teleportCell.init_entity(character, Constants.ENTITY_TYPE.DYNAMIC)
		character.move_to_cell(teleportCell, false)
		return true

	return false
