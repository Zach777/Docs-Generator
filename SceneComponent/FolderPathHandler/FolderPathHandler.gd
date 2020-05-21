extends HBoxContainer

onready var path_holder : LineEdit = $PathToFolder

#Emitted when the user has confirmed what path to use.
signal path_confirmed(path_to_folder_string)

func _on_Confirm_pressed():
	emit_signal("path_confirmed", path_holder.text)
