class_name Dungeon

extends Node

var rooms:Array = []
const intersectionBuffer:int = 0

var charCounter:int = 0
var player:PlayerCharacter = null
var turnsTaken:int = 0

var loadedScenes:Array = []
var itemSpawnedMap:Dictionary = {}

var dungeonData:DungeonData

var isDungeonPaused:bool
var isInitialized:bool
var inBackableMenu:bool
var isCustomRoomSetup:bool

var dungeonProgress:DungeonProgress

func _init():
	GameGlobals.set_dungeon(self)
	GameEventManager.connect("OnCleanUpForDungeonRecreation",Callable(self,"_on_cleanup_for_dungeon"))
	GameEventManager.connect("OnDungeonFloorCompleted",Callable(self,"_on_dungeon_floor_completed"))
	GameEventManager.connect("OnDungeonExited",Callable(self,"_on_dungeon_completed"))
	CombatEventManager.connect("OnAllEnemyTurnsCompleted",Callable(self,"_end_turn"))

func init(dungeonDataRef:DungeonData):
	dungeonData = dungeonDataRef
	isCustomRoomSetup = dungeonData.customRoomList.size()>0
	isDungeonPaused = false

func _on_dungeon_floor_completed():
	isDungeonPaused = true

func _on_dungeon_completed(isVictory:bool):
	isDungeonPaused = true

func create(recreatePlayer:bool) -> void:
	charCounter = 0

	_init_rooms()
	_init_connections()
	_init_corridoors()
	_init_path()
	_init_obstacles()
	_init_items()
	_init_upgrades()
	_init_vendors()
	_init_player(recreatePlayer)
	_init_enemies()
	_init_gold()
	# For tutorials
	if isCustomRoomSetup:
		_init_custom_rooms()

	CombatEventManager.emit_signal("OnCombatInitialized")
	isInitialized = true

	player.connect("OnTurnCompleted",Callable(self,"_on_player_turn_completed"))
	_init_turns()
	_start_turn()

	if recreatePlayer:
		dungeonProgress = DungeonProgress.new()
	else:
		dungeonProgress.on_dungeon_floor_completed()

	# Hack for some initialization issues with OnDungeonInitialized
	await get_tree().create_timer(0.1).timeout
	if recreatePlayer:
		GameGlobals.battleInstance.usePopUpEquipment = false
		_init_progression_modifiers()
		_init_level_modifiers()
		GameGlobals.battleInstance.usePopUpEquipment = true
		CombatEventManager.emit_signal("OnStartDungeon")
	
	CombatEventManager.emit_signal("OnStartFloor")

func _init_rooms():
	rooms = []
	
	# Dungeon Size
	var numRooms := dungeonData.numRooms
	var roomMinRows := dungeonData.roomMinRows
	var roomMaxRows := dungeonData.roomMaxRows
	var roomMinCols := dungeonData.roomMinCols
	var roomMaxCols := dungeonData.roomMaxCols
	
	# Choose a leaning direction for less sprawled paths
	var xDirn = 1 if randi() % 100 < 50 else -1
	var yDirn = 1 if randi() % 100 < 50 else -1
	# Room - maxRows, maxCols, StartX, StartY
	var numIterations = 0
	var maxIterations = 100
	while rooms.size() < numRooms:
		numIterations += 1
		if numIterations>=maxIterations:
			break
		
		randomize()
		var numR:int = roomMinRows + randi() % (roomMaxRows - roomMinRows + 1)
		var numC:int = roomMinCols + randi() % (roomMaxCols - roomMinCols + 1)
		var newRoom:DungeonRoom = DungeonRoom.new(rooms.size(), numR, numC, 0, 0)
		if rooms.size()>0:
			# Choose a random room to start on
			var startSpawnRoom:DungeonRoom = rooms[randi() % rooms.size()]
			# Choose to start either at different ends of the start room
			var startPosType = randi() % 4
			# top left
			if startPosType == 0:
				newRoom.startX = startSpawnRoom.startX
				newRoom.startY = startSpawnRoom.startY
			# bot left
			elif startPosType == 1:
				newRoom.startX = startSpawnRoom.startX
				newRoom.startY = startSpawnRoom.startY + startSpawnRoom.get_size().y - newRoom.get_size().y
			# top right
			elif startPosType == 1:
				newRoom.startX = startSpawnRoom.startX + startSpawnRoom.get_size().x - newRoom.get_size().x
				newRoom.startY = startSpawnRoom.startY
			# bot right
			elif startPosType == 1:
				newRoom.startX = startSpawnRoom.startX + startSpawnRoom.get_size().x - newRoom.get_size().x
				newRoom.startY = startSpawnRoom.startY + startSpawnRoom.get_size().y - newRoom.get_size().y
			# Choose a random direction
			var randomDirn := randi() % 2
			var moveX = 0
			var moveY = 0
			if randomDirn == 0 :
				moveX = xDirn
			elif randomDirn == 1:
				moveY = yDirn

			if isCustomRoomSetup:
				moveX = 1
				moveY = 0

			# move out of start spawn room
			while is_intersecting_with_room(newRoom, startSpawnRoom):
				newRoom.startX += moveX * 1 # Constants.STEP_X
				newRoom.startY += moveY * 1 # Constants.STEP_Y
				
			# if you are still intersecting with a room,
			# fail and find a different spawn room
			if is_intersecting_with_any_room(newRoom):
				newRoom = null
				continue
			
		# now that rooms isn't colliding, initialize
		newRoom.initialize()
		rooms.append(newRoom)
		
	startRoom = rooms[0]

func _init_connections():
	# Try and find connections for each wall in each room
	for currentRoom in rooms:
		for room in rooms:
			if currentRoom == room:
				continue

			# check for Top connection
			findConnection(currentRoom.topConnection, room.botConnection, currentRoom.wallCellsTop, room.wallCellsBot, true)
			# check for Bot connection
			findConnection(currentRoom.botConnection, room.topConnection, currentRoom.wallCellsBot, room.wallCellsTop, true)
			# check for Left connection
			findConnection(currentRoom.leftConnection, room.rightConnection, currentRoom.wallCellsLeft, room.wallCellsRight, false)
			# check for Right connection
			findConnection(currentRoom.rightConnection, room.leftConnection, currentRoom.wallCellsRight, room.wallCellsLeft, false)
			

func findConnection(con1, con2, con1Array, con2Array, isYCheck):
	if con1==null and con2==null:
		# if this is an adjacent y room, continue to check it
		if (isYCheck and con1Array[0].is_y_adjacent(con2Array[0])) or\
			(!isYCheck and con1Array[0].is_x_adjacent(con2Array[0])):
			var arrayMidSize:int = con1Array.size()/2
			# check cells from the middle outwards
			for i in arrayMidSize:
				var c1:int = arrayMidSize - i
				var c2:int = arrayMidSize + i
				for conCell in con2Array:
					# found connection c1
					if c1>=0 and ((isYCheck and conCell.is_x_identical(con1Array[c1])) or (!isYCheck and conCell.is_y_identical(con1Array[c1]))):
						con1Array[c1].connect_cell(conCell)
						conCell.connect_cell(con1Array[c1])
						return
					# found connection c2
					if c2<arrayMidSize*2 and ((isYCheck and conCell.is_x_identical(con1Array[c2])) or (!isYCheck and conCell.is_y_identical(con1Array[c2]))):
						con1Array[c2].connect_cell(conCell)
						conCell.connect_cell(con1Array[c2])
						return

func _init_corridoors():
	for room in rooms:
		if room != startRoom:
			var dirnFromStart:Vector2 = Vector2(room.startX - startRoom.startX, room.startY - startRoom.startY)
			var displacement = dirnFromStart * randf_range(0.25, 0.75)
			room.move(displacement)
			

var costFromStart:Dictionary = {}
var roomsToVisit:Array = []
var visitedRooms:Dictionary = {}
var reverse_path:Array = []
var startRoom
var furthestRoom 
func _init_path():
	# reset variables
	furthestRoom = null
	reverse_path = []
	visitedRooms = {}
	roomsToVisit = []
	costFromStart = {}
	# start with first room
	startRoom.isStartRoom = true
	costFromStart[startRoom] = 0
	roomsToVisit.append(startRoom)
	visitedRooms[startRoom] = true
	# do path calculations
	while roomsToVisit.size()>0:
		var currentRoom = roomsToVisit[0]
		for connection in currentRoom.connections:
			var connectedRoom = connection.connectedCell.room
			if visitedRooms.has(connectedRoom):
				continue
			roomsToVisit.append(connectedRoom)
			visitedRooms[connectedRoom] = true
			var pathCost = costFromStart[currentRoom]+1
			if !costFromStart.has(connectedRoom) or pathCost<costFromStart[connectedRoom]:
				costFromStart[connectedRoom] = pathCost
		roomsToVisit.remove_at(0)
	# find the furthest room
	var furthestCost:int = 0
	for room in rooms:
		if costFromStart.has(room):
			if costFromStart[room] > furthestCost:
				furthestCost = costFromStart[room]
				furthestRoom = room
		else:
			print("ERROR: room not in CostFromStart")
	furthestRoom.set_as_end_room()
	# find path
	reverse_path.append(furthestRoom)
	var room = furthestRoom
	while room!= startRoom:
		var shortestPathConnectedRoom = room.connections[0].connectedCell.room
		var shortestPathConnectionCost:int = costFromStart[shortestPathConnectedRoom]
		for connection in room.connections:
			var connectedRoom = connection.connectedCell.room
			var pathCost = costFromStart[connectedRoom]
			if pathCost < shortestPathConnectionCost:
				shortestPathConnectedRoom = connectedRoom
				shortestPathConnectionCost = pathCost
		room = shortestPathConnectedRoom
		room.isCriticalPathRoom = true
		reverse_path.append(room)
	reverse_path.append(startRoom)

func _init_enemies():
	if !GameGlobals.battleInstance.debugSpawnEnemyEncounter.is_empty():
		startRoom.generate_enemy_custom_encounter(GameGlobals.battleInstance.debugSpawnEnemyEncounter)

	if GameGlobals.battleInstance.dontSpawnEnemies:
		for room in rooms:
			if room.isEndRoom:
				room.setup_with_no_miniboss()
		return

	if isCustomRoomSetup:
		return
	
	var minCostPerRoom:int = dungeonData.enemyMinCostPerRoom
	var extraCostForSingleRoom:int = dungeonData.enemyExtraCostForSingleRoom
	var scalingCostPerRoom:int = dungeonData.enemyScalingCostPerRoom
	var numCriticalPathRooms = reverse_path.size();
	for room in rooms:
		if room.isStartRoom:
			if dungeonProgress!=null:
				room.generate_vendor("SOUL_VENDOR")
			continue
		
		if !costFromStart.has(room):
			print("ERROR: Room doesn't exist in cost from start")
			continue
		
		var encounterCost = minCostPerRoom + int(float(costFromStart[room])/float(numCriticalPathRooms) * float(scalingCostPerRoom))
		# single rooms
		if room.connections.size()==1:
			encounterCost = encounterCost + extraCostForSingleRoom
		
		var currentCost:int = 0
		var enemyDataList:Array = Utils.duplicate_array(GameGlobals.dataManager.enemyDataList)
		var itemsToRemove:Array = []
		for enemyData in enemyDataList:
			if enemyData.difficulty > dungeonData.enemyDifficultyHighestTier:
				itemsToRemove.append(enemyData)

		for items in itemsToRemove:
			enemyDataList.erase(items)

		# Miniboss
		if room.isEndRoom:
			var enemyData:CharacterData = enemyDataList[randi() % enemyDataList.size()]
			room.generate_miniboss(enemyData.id)

		while(currentCost<encounterCost):
			var enemyData:CharacterData = enemyDataList[randi() % enemyDataList.size()]
			if currentCost + enemyData.cost<=encounterCost:
				if room.generate_enemy(enemyData.id)!=null:
					currentCost = currentCost + enemyData.cost
				else:
					break
			else:
				enemyDataList.erase(enemyData)
				if enemyDataList.size()==0:
					break

func _init_obstacles():
	if GameGlobals.battleInstance.dontSpawnObstacles:
		return

	for room in rooms:
		if room.isStartRoom:
			continue

		room.generate_obstacles(dungeonData.obstacleChance, dungeonData.minObstacles, dungeonData.maxObstacles)

func _init_items():
	if GameGlobals.battleInstance.dontSpawnItems:
		return

	if GameGlobals.battleInstance.debugSpawnItems.size()>0:
		for debugItem in GameGlobals.battleInstance.debugSpawnItems:
			startRoom.generate_item(debugItem)

	if isCustomRoomSetup:
		return

	var itemDataList = Utils.duplicate_array(GameGlobals.dataManager.itemDataList)
	itemDataList.shuffle()

	var numItems:int = dungeonData.itemCountMin + randi() % (dungeonData.itemCountMax - dungeonData.itemCountMin + 1)
	var maxItemsReached:bool = false
	var roomVisitedMap:Dictionary = {}

	# Single rooms only
	for room in rooms:
		if roomVisitedMap.has(room):
			continue

		if room.isStartRoom or room.connections.size()>1:
			continue

		for itemData in itemDataList:
			if itemData.tier > dungeonData.itemHeighestTier:
				continue

			if itemSpawnedMap.has(itemData.id) and itemSpawnedMap[itemData.id]>=itemData.maxCount:
				continue
			
			if itemData.tier>=1:
				roomVisitedMap[room] = true
				_spawn_item(room, itemData)
				numItems = numItems - 1
				if numItems==0:
					maxItemsReached = true
				break

		if maxItemsReached:
			break

	# If there are still remaining items to be populated
	if !maxItemsReached:
		for room in rooms:
			if roomVisitedMap.has(room):
				continue

			if room.isStartRoom:
				continue
	
			for itemData in itemDataList:
				if itemData.tier > dungeonData.itemHeighestTier:
					continue

				if itemSpawnedMap.has(itemData.id) and itemSpawnedMap[itemData.id]>=itemData.maxCount:
					continue
				
				if itemData.tier <= dungeonData.itemHeighestTier:
					_spawn_item(room, itemData)
					numItems = numItems - 1
					if numItems==0:
						maxItemsReached = true
					break
	
			if maxItemsReached:
				break

func _spawn_item(room, itemData):
	room.generate_item(itemData.id)
	if itemSpawnedMap.has(itemData.id):
		itemSpawnedMap[itemData.id] = itemSpawnedMap[itemData.id] + 1
	else:
		itemSpawnedMap[itemData.id] = 1

func _init_upgrades():
	if GameGlobals.battleInstance.debugSpawnSharedUpgrade:
		startRoom.generate_upgrade(Upgrade.UPGRADE_TYPE.SHARED)

	if GameGlobals.battleInstance.debugSpawnClassSpecificUpgrade:
		startRoom.generate_upgrade(Upgrade.UPGRADE_TYPE.CLASS_SPECIFIC)

	if GameGlobals.battleInstance.debugSpawnHybridUpgrade:
		startRoom.generate_upgrade(Upgrade.UPGRADE_TYPE.HYBRID)

	if isCustomRoomSetup:
		return

func _init_vendors():
	if !GameGlobals.battleInstance.debugSpawnVendors.is_empty():
		for vendor in GameGlobals.battleInstance.debugSpawnVendors:
			startRoom.generate_vendor(vendor)

	if isCustomRoomSetup:
		return

	if !GameGlobals.battleInstance.startWithClasses and dungeonProgress==null:
		startRoom.generate_vendor("MYSTIC_VENDOR")
	
	var specialRoom:DungeonRoom = rooms[rooms.size()/2]
	var specialVendors:Array = ["POTIONSMITH_VENDOR", "BLACKSMITH_VENDOR", "RUNESMITH_VENDOR"]
	specialVendors.shuffle()
	specialRoom.generate_vendor(specialVendors[0])

func _init_gold():
	if GameGlobals.battleInstance.debugGold>0:
		for i in GameGlobals.battleInstance.debugGold:
			startRoom.generate_gold()

	if dungeonData.totalGold>0:
		var gold:int = dungeonData.totalGold
		for room in rooms:
			if room.isStartRoom or room.isEndRoom:
				continue

			room.generate_gold()
			gold = gold - 1
			if gold==0:
				break

	if GameGlobals.battleInstance.debugSouls>0:
		player.gain_souls(GameGlobals.battleInstance.debugSouls)

func _init_player(recreatePlayer:bool):
	var cell:DungeonCell = rooms[0].get_safe_starting_cell()
	if recreatePlayer:
		player = load_character(loadedScenes, cell, GameGlobals.dataManager.playerData, Constants.ENTITY_TYPE.DYNAMIC, Constants.pc, Constants.TEAM.PLAYER)
	else:
		player.init_for_next_dungeon()
		player.move_to_cell(cell)

# PROGRESSION MODIFIERS
var abilities:Array
var specials:Array
var passives:Array
var items:Array
var runes:Array
func _init_progression_modifiers():
	var enabledSkills:Array[String] = PlayerDataManager.currentPlayerData.get_enabled_skills(player.charData)
	for enabledSkill in enabledSkills:
		var skillData:SkillData = GameGlobals.dataManager.get_skill_data(enabledSkill)
		for dungeonModifierId in skillData.dungeonModifiers:
			var dungeonModData:DungeonModifierData = GameGlobals.dataManager.get_dungeon_modifier_data(dungeonModifierId)
			player.add_dungeon_modifier(dungeonModData)
			# Spawn Item
			if dungeonModData.spawnEquipment:
				var itemDataList = Utils.duplicate_array(GameGlobals.dataManager.itemDataList)
				itemDataList.shuffle()
				for itemData in itemDataList:
					if itemData.tier > dungeonData.itemHeighestTier:
						continue
					
					if itemData.is_consumable():
						continue

					_spawn_item(player.currentRoom, itemData)
					break
			# Spawn Consumable	
			if dungeonModData.spawnConsumable:
				var itemDataList = Utils.duplicate_array(GameGlobals.dataManager.itemDataList)
				itemDataList.shuffle()
				for itemData in itemDataList:
					if itemData.tier > dungeonData.itemHeighestTier:
						continue
					
					if !itemData.is_consumable():
						continue
						
					_spawn_item(player.currentRoom, itemData)
					break
			# Spawn Additional Item
			if dungeonModData.spawnAdditionalItem:
				var itemDataList = Utils.duplicate_array(GameGlobals.dataManager.itemDataList)
				itemDataList.shuffle()
				rooms.shuffle()
				for itemData in itemDataList:
					if itemData.tier > dungeonData.itemHeighestTier:
						continue
					
					if !itemData.is_consumable():
						continue
						
					for room in rooms:
						if room.isStartRoom:
							continue

						if room.isEndRoom:
							continue

						_spawn_item(room, itemData)
						break
						
					break

		for abilityId in skillData.abilities:
			var abilityData:AbilityData = GameGlobals.dataManager.get_ability_data(abilityId)
			player.add_ability(abilityData)
		for specialId in skillData.specials:
			var specialData:SpecialData = GameGlobals.dataManager.get_special_data(specialId)
			player.add_special(specialData)
		for passiveId in skillData.passives:
			var passiveData:PassiveData = GameGlobals.dataManager.get_passive_data(passiveId)
			player.add_passive(passiveData)
		for itemId in skillData.items:
			var itemData:ItemData = GameGlobals.dataManager.get_item_data(itemId)
			var item:Item = player.cell.room.generate_and_consume_item(player, itemData.id)
			player.equipment.equip_item(item, Equipment.GET_SLOT_FOR_TYPE(itemData)[0])

# LEVEL MODIFIERS
func _init_level_modifiers():
	var levelData:LevelData = GameGlobals.battleInstance.currentLevelData
	for dungeonModifierId in levelData.dungeonModifiers:
		player.add_dungeon_modifier(GameGlobals.dataManager.get_dungeon_modifier_data(dungeonModifierId))

func _init_custom_rooms():
	var i:int = 0
	for room in rooms:
		var customRoomData:DungeonCustomRoomData = dungeonData.customRoomList[i]
		_init_custom_room(customRoomData, room)
		i = i+1

func _init_custom_room(customRoomData:DungeonCustomRoomData, room:DungeonRoom):
	if customRoomData.tutorialPickUps.size()>0:
		for tutorialPickUpId in customRoomData.tutorialPickUps:
			room.generate_tutorial_pickup(tutorialPickUpId)

	if customRoomData.itemId:
		room.generate_item(customRoomData.itemId)
	
	if customRoomData.encounterId:
		room.generate_enemy_custom_encounter(customRoomData.encounterId)

	if customRoomData.vendorId:
		room.generate_vendor(customRoomData.vendorId)

# TURN LOGIC
func _init_turns():
	player.pre_update()
	player.cell.room.pre_update_entities()
	#player.update()
	for room in rooms:
		room.update_visibility()
	CombatEventManager.emit_signal("OnEndTurn")

func _start_turn():
	if isDungeonPaused:
		return

	CombatEventManager.emit_signal("OnStartTurn")

	# Pre Update
	player.pre_update()
	player.cell.room.pre_update_entities()

	if player.is_due_to_skip_turn():
		player.update()
	else:
		# Wait for Player Turn
		pass

func _on_player_turn_completed():
	player.update()

	CombatEventManager.emit_signal("OnPlayerTurnCompleted")

	if player.has_revived_this_turn():
		_end_turn()
	else:
		# Wait for Enemy Turns
		player.cell.room.update_entities()

	'''# Wait for Enemy Turns
	player.cell.room.update_entities()'''

func _end_turn():
	turnsTaken += 1

	# Post Update
	player.post_update()
	player.cell.room.post_update_entities()
	for room in rooms:
		room.update_visibility()

	CombatEventManager.emit_signal("OnEndTurn")

	if !player.isDead:
		_start_turn()

func add_to_dungeon_scenes(scene):
	loadedScenes.append(scene)

func _on_cleanup_for_dungeon(fullRefreshDungeon:bool=true):
	if fullRefreshDungeon:
		for loadedScene in loadedScenes:
			loadedScene.free()
		loadedScenes.clear()
	
	for room in rooms:
		room.clean_up()
	rooms.clear()
	
	if fullRefreshDungeon:
		turnsTaken = 0
		if player!=null and !player.is_queued_for_deletion():
			player.disconnect("OnTurnCompleted",Callable(self,"_on_player_turn_completed"))
		player = null
		dungeonProgress = null

	isInitialized = false

# HELPERS
func is_intersecting_with_any_room(testRoom):
	for room in rooms:
		if is_intersecting_with_room(testRoom, room) or\
			is_intersecting_with_room(room, testRoom) :
			return true
	
	return false
	
func is_intersecting_with_room(testRoom, room):
	return is_intersecting_with_room_test(testRoom, room) or\
			is_intersecting_with_room_test(room, testRoom)

func is_intersecting_with_room_test(testRoom, room):
	var p1 := Vector2(testRoom.startX, testRoom.startY)
	var p2 := Vector2(testRoom.startX + Constants.STEP_X * testRoom.maxCols, testRoom.startY)
	var p3 := Vector2(testRoom.startX, testRoom.startY + Constants.STEP_Y * testRoom.maxRows)
	var p4 := Vector2(testRoom.startX + Constants.STEP_X * testRoom.maxCols, testRoom.startY + Constants.STEP_Y * testRoom.maxRows)
	var p5 := Vector2(testRoom.get_center().x, testRoom.get_center().y)
	return room.is_point_inside(p1.x, p1.y, intersectionBuffer) or\
			room.is_point_inside(p2.x, p2.y, intersectionBuffer) or\
			room.is_point_inside(p3.x, p3.y, intersectionBuffer) or\
			room.is_point_inside(p4.x, p4.y, intersectionBuffer) or\
			room.is_point_inside(p5.x, p5.y, 0)

func load_character(parentContainer, cell, characterData, entityType, groupName, team):
	var charPrefab := load(str("res://", characterData.path))
	var charObject = Utils.create_scene(parentContainer, characterData.displayName, charPrefab, groupName, cell)
	cell.init_entity(charObject, entityType)
	charObject.init(charCounter, characterData, team)
	charCounter = charCounter + 1
	charObject.move_to_cell(cell)
	if team == Constants.TEAM.PLAYER:
		charObject.self_modulate = GameGlobals.battleInstance.view.playerDamageColor
	elif team == Constants.TEAM.ENEMY:
		charObject.self_modulate = GameGlobals.battleInstance.view.enemyDamageColor
	return charObject

func load_item(parentContainer, cell, itemData, entityType, groupName):
	var itemPrefab := load(str("res://", itemData.path))
	var itemObject = Utils.create_scene(parentContainer, itemData.name, itemPrefab, groupName, cell)
	cell.init_entity(itemObject, entityType)
	itemObject.init(itemData, cell)
	if itemData.is_gear():
		itemObject.self_modulate = GameGlobals.battleInstance.view.itemGearColor
	#if itemData.is_consumable():
	#	itemObject.self_modulate = GameGlobals.battleInstance.view.itemConsumableColor
	if itemData.is_spell():
		itemObject.self_modulate = GameGlobals.battleInstance.view.itemSpellColor
	return itemObject

func load_upgrade(parentContainer, cell, upgradeType, entityType, groupName):
	var upgradePath:String = ""
	if upgradeType == Upgrade.UPGRADE_TYPE.SHARED:
		upgradePath = "entity/upgrades/Upgrade_Shared.tscn"
	elif upgradeType == Upgrade.UPGRADE_TYPE.CLASS_SPECIFIC:
		upgradePath = "entity/upgrades/Upgrade_Class.tscn"
	elif upgradeType == Upgrade.UPGRADE_TYPE.HYBRID:
		upgradePath = "entity/upgrades/Upgrade_Hybrid.tscn"
	var upgradePrefab := load(str("res://", upgradePath))
	var upgradeObject = Utils.create_scene(parentContainer, "Upgrade", upgradePrefab, groupName, cell)
	cell.init_entity(upgradeObject, entityType)
	return upgradeObject

func load_vendor(parentContainer, cell, vendorId, entityType, groupName):
	var vendorData:VendorData = GameGlobals.dataManager.get_vendor_data(vendorId)
	var vendorPrefab := load(str("res://", vendorData.path))
	var vendorObject = Utils.create_scene(parentContainer, "Vendor", vendorPrefab, groupName, cell)
	vendorObject.init(vendorData)
	vendorObject.cell = cell
	cell.init_entity(vendorObject, entityType)
	return vendorObject

func load_tutorial_pickup(parentContainer, cell, tutorialPickupId, entityType, groupName):
	var tutorialPickupData:TutorialPickupData = GameGlobals.dataManager.get_tutorial_pickup_data(tutorialPickupId)
	var tutorialPickupDataPrefab := load("res://entity/tutorial/TutorialPickup.tscn")
	var tutorialPickupObject = Utils.create_scene(parentContainer, "TutorialPickup", tutorialPickupDataPrefab, groupName, cell)
	tutorialPickupObject.init(tutorialPickupData, cell)
	cell.init_entity(tutorialPickupObject, entityType)
	return tutorialPickupObject

func load_gold_pickup(parentContainer, cell, entityType, groupName):
	var goldPickupDataPrefab := load("res://entity/items/pickups/GoldPickup.tscn")
	var goldPickupObject = Utils.create_scene(parentContainer, "GoldPickup", goldPickupDataPrefab, groupName, cell)
	goldPickupObject.init(cell)
	cell.init_entity(goldPickupObject, entityType)
	return goldPickupObject

func load_vfx(parentContainer, path, cell, groupName):
	var vfxPrefab := load(str("res://", path))
	var vfxObject = Utils.create_scene(parentContainer, "VFX", vfxPrefab, groupName, cell)
	cell.init_vfx(vfxObject)
	return vfxObject

func get_adjacent_characters(character, relativeTeamType, numTiles:int=1):
	var currentPlayerRoom:DungeonRoom = player.currentRoom
	var adjacentChars:Array = []

	if Utils.is_relative_team(character, player, relativeTeamType) and Utils.is_adjacent(character, player, numTiles):
		adjacentChars.append(player)

	for enemy in currentPlayerRoom.enemies:
		if Utils.is_relative_team(character, enemy, relativeTeamType) and Utils.is_adjacent(character, enemy, numTiles):
			adjacentChars.append(enemy)
	
	return adjacentChars
