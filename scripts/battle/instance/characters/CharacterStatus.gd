class_name CharacterStatus

var flags:Dictionary = {}
var currentModifiers:Array

enum FLAGS { INVULNERABLE, ROOTED, UNTARGETABLE, EVASIVE, UNINTERRUPTIBLE, IMMOVABLE, STUNNED }

func update():
    var modifiersToBeRemoved:Array = []
    for modifier in currentModifiers:
        modifier.update()
        if modifier.is_done():
            modifiersToBeRemoved.append(modifier)

    for modifier in modifiersToBeRemoved:
        currentModifiers.erase(modifier)

func _does_modifier_exist(flagId):
    for modifier in currentModifiers:
        if modifier.id == flagId:
            return true

    return false

func set_invulnerable(val, numTurns):
    currentModifiers.append(CharacterStatusModifier.new(FLAGS.INVULNERABLE, numTurns))

func is_invulnerable():
    return _does_modifier_exist(FLAGS.INVULNERABLE)

func set_rooted(val, numTurns):
    currentModifiers.append(CharacterStatusModifier.new(FLAGS.ROOTED, numTurns))

func is_rooted():
    return _does_modifier_exist(FLAGS.ROOTED)

func set_untargetable(val, numTurns):
    currentModifiers.append(CharacterStatusModifier.new(FLAGS.UNTARGETABLE, numTurns))

func is_untargetable():
    return _does_modifier_exist(FLAGS.UNTARGETABLE)

func set_evasive(val, numTurns):
    currentModifiers.append(CharacterStatusModifier.new(FLAGS.EVASIVE, numTurns))

func is_evasive():
    return _does_modifier_exist(FLAGS.EVASIVE)

func set_uninterruptible(val, numTurns):
    currentModifiers.append(CharacterStatusModifier.new(FLAGS.UNINTERRUPTIBLE, numTurns))

func is_uninterruptible():
    return _does_modifier_exist(FLAGS.UNINTERRUPTIBLE)

func set_immovable(val, numTurns):
    currentModifiers.append(CharacterStatusModifier.new(FLAGS.IMMOVABLE, numTurns))

func is_immovable():
    return _does_modifier_exist(FLAGS.IMMOVABLE)

func set_stunned(val, numTurns):
    currentModifiers.append(CharacterStatusModifier.new(FLAGS.STUNNED, numTurns))

func is_stunned():
    return _does_modifier_exist(FLAGS.STUNNED)