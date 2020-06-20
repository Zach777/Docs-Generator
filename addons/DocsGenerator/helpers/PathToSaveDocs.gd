tool
extends HBoxContainer


#Save the location for later.
const SAVE_LOCATION : String = "res://addons/DocsGenerator/SaveLocation.sav"
const DEFAULT_PATH : String = "res://addons/DocsGenerator/"

signal save_location_changed(new_save_location_string)


func _ready() -> void :
	var file : File = File.new()
	#Create the save file if it does not exist.
	if file.file_exists(SAVE_LOCATION) == false :
		file.open(SAVE_LOCATION, file.WRITE)
		file.store_string(DEFAULT_PATH)
		return
		
	call_deferred("_setup_save_location")

func _on_Confirm_pressed():
	var location : String = $PathToFolder.text
	emit_signal("save_location_changed", location)
	
	#Store the updated location for later.
	var file : File = File.new()
	file.open(SAVE_LOCATION, file.WRITE)
	file.store_string(location)
	
func _setup_save_location() -> void :
	#Open the file and read the store location.
	var file : File = File.new()
	file.open(SAVE_LOCATION, file.READ)
	var location : String = file.get_line()
	if location == "" :
		return
	$PathToFolder.text = location
	emit_signal("save_location_changed", location)
