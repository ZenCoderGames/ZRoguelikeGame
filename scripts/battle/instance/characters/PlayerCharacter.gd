extends Character

class_name PlayerCharacter

signal OnNearbyEntityFound(entity)
signal OnPlayerReachedExit()
signal OnPlayerReachedEnd()

func init(charData, teamVal):
	.init(charData, teamVal)

	Dungeon.connect("OnEnemyMovedAdjacentToPlayer", self, "on_enemy_moved_adjacent")

func update():
	.update()

	cell.room.update_path_map()

func take_damage(entity, dmg):
	if Dungeon.battleInstance.setPlayerInvulnerable:
		return
	
	.take_damage(entity, dmg)

func move_to_cell(newCell):
	.move_to_cell(newCell)

	check_for_nearby_entities()

	if newCell.is_exit():
		emit_signal("OnPlayerReachedExit")
	elif newCell.is_end():
		emit_signal("OnPlayerReachedEnd")
	
func on_enemy_moved_adjacent(enemy):
	check_for_nearby_entities()

func check_for_nearby_entities():
	notify_if_nearby_entity(cell.row-1, cell.col)
	notify_if_nearby_entity(cell.row+1, cell.col)
	notify_if_nearby_entity(cell.row, cell.col-1)
	notify_if_nearby_entity(cell.row, cell.col+1)

func notify_if_nearby_entity(r:int, c:int):
	var cell = currentRoom.get_cell(r, c)
	if cell!=null and cell.has_entity() and cell.is_entity_type(Constants.ENTITY_TYPE.DYNAMIC):
		emit_signal("OnNearbyEntityFound", cell.entityObject)
