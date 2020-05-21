extends VBoxContainer

onready var path_holder : LineEdit = $InputField/PathToFolder

#Emitted when the user has confirmed what path to use.
signal path_confirmed(path_to_folder_string)

#Emitted when there is not a slash at the end of the filename.
signal path_entered_wrong()


#Check that the player inputted slashes.
#warning-ignore:unused_argument
func _process(delta : float) -> void :
	#Return if there is no text inputted.
	if path_holder.text == "" :
		$PathIncorrectMessage.hide()
		return
	
	if path_holder.text.ends_with("/") == false && path_holder.text.ends_with("\\") == false :
		$PathIncorrectMessage.show()
	
	else :
		$PathIncorrectMessage.hide()

func _on_Confirm_pressed():
	if path_holder.text.ends_with("/") || path_holder.text.ends_with("\\") :
		emit_signal("path_confirmed", path_holder.text)
	
	else :
		emit_signal("path_entered_wrong")
