extends FileDialog

var can_resize : bool = false

#Do not let the window close itself.
func _ready() -> void :
	call_deferred("popup")
