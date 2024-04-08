class_name SkillTreeData

var id:String
var type:String
var skillList:Array[SkillData]

func _init(dataJS):
	id = dataJS["id"]
	type = Utils.get_data_from_json(dataJS, "type", "INVALID_TYPE")

	var skillDataJSList = dataJS["skills"]
	for skillDataJS in skillDataJSList:
		var skillData:SkillData = SkillData.new(skillDataJS)
		skillList.append(skillData)
