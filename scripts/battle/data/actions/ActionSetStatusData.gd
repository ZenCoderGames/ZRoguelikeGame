extends ActionData

class_name ActionSetStatusData

const ID:String = "SET_STATUS"

var invulnerable:int
var rooted:int
var untargetable:int
var evasive:int
var uninterruptible:int
var immovable:int
var stunned:int

func _init(dataJS).(dataJS):
    if params.has("invulnerable"):
	    invulnerable = params["invulnerable"]
    if params.has("rooted"):
        rooted = params["rooted"]
    if params.has("untargetable"):
        untargetable = params["untargetable"]
    if params.has("evasive"):
        evasive = params["evasive"]
    if params.has("uninterruptible"):
        uninterruptible = params["uninterruptible"]
    if params.has("immovable"):
        immovable = params["immovable"]
    if params.has("stunned"):
        stunned = params["stunned"]