extends Character

class_name EnemyCharacter

func update():
	.update()

	if attackAction.can_execute():
		attackAction.execute()
	elif moveAction.can_execute():
		moveAction.execute()

func move_to_cell(newCell):
	.move_to_cell(newCell)

	if Dungeon.player!=null:
		if(newCell.is_rowcol_adjacent(Dungeon.player.cell)):
			Dungeon.emit_signal("OnEnemyMovedAdjacentToPlayer", self)
