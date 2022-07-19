extends "res://scripts/battle/Character.gd"

func update():
	# if next to player, attack player
	if adjacent_character(Dungeon.player):
		if Dungeon.battleInstance.pauseAIAttack:
			return

		attack(Dungeon.player)
	else:
		if Dungeon.battleInstance.pauseAIMovement:
			return

		# move randomly (first pass)
		var randomX = 0
		var randomY = 0
		if randi()%10<5:
			randomX = 1 if randi() % 100 < 50 else -1
		else:
			randomY = 1 if randi() % 100 < 50 else -1
		move(randomX, randomY)
