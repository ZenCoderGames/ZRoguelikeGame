extends Character

class_name EnemyCharacter

func update():
	.update()

	for action in actions:
		if action.can_execute():
			action.execute()
			break
