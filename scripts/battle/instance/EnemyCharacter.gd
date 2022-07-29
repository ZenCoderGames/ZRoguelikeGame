extends Character

func update():
	.update()

	# if next to player, attack player
	if adjacent_character(Dungeon.player):
		if Dungeon.battleInstance.pauseAIAttack:
			return

		attack(Dungeon.player)
	else:
		if Dungeon.battleInstance.pauseAIMovement:
			return

		_path_find()
		#_wander()
		
# move randomly (first pass)
func _wander():
	var randomX = 0
	var randomY = 0
	if randi()%10<5:
		randomX = 1 if randi() % 100 < 50 else -1
	else:
		randomY = 1 if randi() % 100 < 50 else -1
	move(randomX, randomY)

func _path_find():
	var nextCell = cell.room.find_next_best_path_cell(cell)
	if nextCell!=null and nextCell!=cell:
		move(nextCell.col-cell.col, nextCell.row-cell.row)
