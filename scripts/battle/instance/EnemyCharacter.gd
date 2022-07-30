extends Character

class_name EnemyCharacter

func update():
	.update()

	# do highest priority valid action
	for action in actions:
		if action.can_execute():
			action.execute()
			break
