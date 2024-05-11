extends Node2D

class_name SkillTree

var _skillTreeData:SkillTreeData
var _selectedSkillData:SkillData

const SkillTreeNodeClass := preload("res://ui/skilltree/SkillTreeNode.tscn")
var skillTreeNodes:Array
var dictOfSkillTree:Dictionary
var startSkillNode:SkillTreeNode

const STARTING_ANGLE:float = 90
const STARTING_RADIUS:float = 150
var debugDrawNodes:Array

func _init():
	UIEventManager.connect("OnSkillUnlocked",Callable(self,"_refresh"))
	
func init_from_data(skillTreeId:String):
	_skillTreeData = GameGlobals.dataManager.skilltreeDict[skillTreeId]
	
	for skillData in _skillTreeData.skillList:
		_init_skill(skillData)
		
	_reposition_nodes()

func _refresh():
	for skillTreeNode in skillTreeNodes:
		var skillData:SkillData = skillTreeNode.get_skill_data()
		var hasBeenUnlocked:bool = PlayerDataManager.has_skill_been_unlocked(skillData.id)
		var isLocked:bool = false
		var hasParent:bool = !skillData.parentSkillId.is_empty()
		if hasParent and !GameGlobals.dataManager.is_skill_start_node(skillData.parentSkillId):
			var isParentUnlocked:bool = PlayerDataManager.has_skill_been_unlocked(skillData.parentSkillId)
			isLocked = !isParentUnlocked
		skillTreeNode.init_from_data(skillData, hasBeenUnlocked, isLocked)

func _init_skill(skillData:SkillData):
	var skillTreeNode = SkillTreeNodeClass.instantiate()
	add_child(skillTreeNode)
	var hasBeenUnlocked:bool = PlayerDataManager.has_skill_been_unlocked(skillData.id)
	var isLocked:bool = false
	var hasParent:bool = !skillData.parentSkillId.is_empty()
	if hasParent and !GameGlobals.dataManager.is_skill_start_node(skillData.parentSkillId):
		var isParentUnlocked:bool = PlayerDataManager.has_skill_been_unlocked(skillData.parentSkillId)
		isLocked = !isParentUnlocked
	skillTreeNode.init_from_data(skillData, hasBeenUnlocked, isLocked)
	skillTreeNodes.append(skillTreeNode)
	dictOfSkillTree[skillTreeNode.get_skill_data().id] = skillTreeNode
	if skillData.isStartNode:
		startSkillNode = skillTreeNode

func _reposition_nodes():
	startSkillNode.set_as_start_node()
	_place_node(startSkillNode, 0, 0, 0, 0)

func _place_node(skillTreeNode:SkillTreeNode, x, y, ang, rad):
	var posX:int = x + rad * cos(deg_to_rad(ang))
	var posY:int = y + rad * sin(deg_to_rad(ang))
	skillTreeNode.position = Vector2(posX, posY)
	debugDrawNodes.append(Vector2(posX, posY))
	#skillTreeNode.set_line_pos(x, y, posX, posY)
	skillTreeNode.connect("OnSkillSelected",Callable(self,"_on_skill_selected"))
	var children:Array = skillTreeNode.get_child_nodes()
	var childCount:int = children.size()
	if childCount>0:
		var childAng:int = 0
		var childNextAng:int = 0
		if childCount==2:
			childAng = ang + -45
			childNextAng = 90
		if childCount==3:
			childAng = ang + -180
			childNextAng = 90
			
		for child in children:
			dictOfSkillTree[child].set_parent(skillTreeNode)
			_place_node(dictOfSkillTree[child], posX, posY, childAng, STARTING_RADIUS)
			childAng = childAng + childNextAng

func _on_skill_selected(skillData:SkillData, isLocked:bool):
	UIEventManager.emit_signal("OnSkillNodeSelected", skillData, isLocked)
	_selectedSkillData = skillData

	for skillTreeNode in skillTreeNodes:
		skillTreeNode.set_selected(skillTreeNode.has_skill_data(skillData))

func _draw():
	if skillTreeNodes.size()>0:
		for skillTreeNode in skillTreeNodes:
			if skillTreeNode.has_parent():
				draw_line(skillTreeNode.position, skillTreeNode.get_parent_node().position, Color.LIGHT_SLATE_GRAY, 2.0)

func reset():
	for skillTreeNode in skillTreeNodes:
		remove_child(skillTreeNode)
		skillTreeNode.queue_free()
	skillTreeNodes.clear()
	dictOfSkillTree.clear()
	debugDrawNodes.clear()
