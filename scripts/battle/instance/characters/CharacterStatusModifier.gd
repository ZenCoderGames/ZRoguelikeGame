class_name CharacterStatusModifier

var id:int
var numTurnsLeft:int

func _init(flagIdVal:int, totalTurns:int):
    id = flagIdVal
    numTurnsLeft = totalTurns

func update():
    if numTurnsLeft==-1:
        return

    numTurnsLeft = numTurnsLeft - 1

func is_done():
    return numTurnsLeft==0