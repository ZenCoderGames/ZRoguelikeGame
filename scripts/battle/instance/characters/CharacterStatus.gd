class_name CharacterStatus

var flags:Dictionary = {}

enum FLAGS { INVULNERABLE, ROOTED, UNTARGETABLE, EVASIVE, UNINTERRUPTIBLE, IMMOVABLE, STUNNED, INVISIBLE }

func _init():
    flags[FLAGS.INVULNERABLE] = 0
    flags[FLAGS.ROOTED] = 0
    flags[FLAGS.UNTARGETABLE] = 0
    flags[FLAGS.EVASIVE] = 0
    flags[FLAGS.UNINTERRUPTIBLE] = 0
    flags[FLAGS.IMMOVABLE] = 0
    flags[FLAGS.STUNNED] = 0
    flags[FLAGS.INVISIBLE] = 0

func set_invulnerable(val):
    flags[FLAGS.INVULNERABLE] = flags[FLAGS.INVULNERABLE] + val

func is_invulnerable():
    return flags[FLAGS.INVULNERABLE]>0

func set_rooted(val):
    flags[FLAGS.ROOTED] = flags[FLAGS.ROOTED] + val

func is_rooted():
    return flags[FLAGS.ROOTED]>0

func set_untargetable(val):
    flags[FLAGS.UNTARGETABLE] = flags[FLAGS.UNTARGETABLE] + val

func is_untargetable():
    return flags[FLAGS.UNTARGETABLE]>0

func set_evasive(val):
    flags[FLAGS.EVASIVE] = flags[FLAGS.EVASIVE] + val

func is_evasive():
    return flags[FLAGS.EVASIVE]>0

func set_uninterruptible(val):
    flags[FLAGS.UNINTERRUPTIBLE] = flags[FLAGS.UNINTERRUPTIBLE] + val

func is_uninterruptible():
    return flags[FLAGS.UNINTERRUPTIBLE]>0

func set_immovable(val):
    flags[FLAGS.IMMOVABLE] = flags[FLAGS.IMMOVABLE] + val

func is_immovable():
    return flags[FLAGS.IMMOVABLE]>0

func set_stunned(val):
    flags[FLAGS.STUNNED] = flags[FLAGS.STUNNED] + val

func is_stunned():
    return flags[FLAGS.STUNNED]>0

func set_invisible(val):
    flags[FLAGS.INVISIBLE] = flags[FLAGS.INVISIBLE] + val

func is_invisible():
    return flags[FLAGS.INVISIBLE]>0