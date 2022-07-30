extends Character

class_name PlayerCharacter

func update():
	.update()

	cell.room.update_path_map()

func take_damage(entity, dmg):
	if Dungeon.battleInstance.setPlayerInvulnerable:
		return
	
	.take_damage(entity, dmg)
