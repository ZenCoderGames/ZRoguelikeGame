extends ActionData

class_name ActionSetStatusData

const ID:String = "STATUS"

var invulnerable:bool
var rooted:bool
var untargetable:bool
var evasive:bool
var uninterruptible:bool
var immovable:bool
var stunned:bool

var numTurns:int = -1

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
    if params.has("numTurns"):
        numTurns = params["numTurns"]