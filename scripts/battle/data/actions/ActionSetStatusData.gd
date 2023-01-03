extends ActionData

class_name ActionSetStatusData

const ID:String = "SET_STATUS"

var invulnerable:int
var rooted:int # not implemented yet
var untargetable:int # not implemented yet
var evasive:int # not implemented yet
var uninterruptible:int # not implemented yet
var immovable:int # not implemented yet
var stunned:int
var invisible:int
var critical:int

func _init(dataJS).(dataJS):
    invulnerable = Utils.get_data_from_json(params, "invulnerable", false)
    rooted = Utils.get_data_from_json(params, "rooted", false)
    untargetable = Utils.get_data_from_json(params, "untargetable", false)
    evasive = Utils.get_data_from_json(params, "evasive", false)
    uninterruptible = Utils.get_data_from_json(params, "uninterruptible", false)
    immovable = Utils.get_data_from_json(params, "immovable", false)
    stunned = Utils.get_data_from_json(params, "stunned", false)
    invisible = Utils.get_data_from_json(params, "invisible", false)
    critical = Utils.get_data_from_json(params, "critical", false)