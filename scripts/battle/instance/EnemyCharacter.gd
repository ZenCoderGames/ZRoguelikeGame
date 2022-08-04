extends Character

class_name EnemyCharacter

func update():
	.update()

	# do highest priority valid action
	for action in actions:
		if action.can_execute():
			action.execute()
			break

func move_to_cell(newCell):
	.move_to_cell(newCell)

	if Dungeon.player!=null:
		if(newCell.is_rowcol_adjacent(Dungeon.player.cell)):
			Dungeon.emit_signal("OnEnemyMovedAdjacentToPlayer", self)
