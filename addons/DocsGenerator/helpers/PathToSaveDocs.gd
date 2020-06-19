tool
extends HBoxContainer


signal save_location_changed(new_save_location_string)


func _on_Confirm_pressed():
	emit_signal("save_location_changed", get_node("PathToFolder").text)
