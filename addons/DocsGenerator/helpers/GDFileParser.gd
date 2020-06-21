tool
extends Node

const FILE_TYPE : String = ".docsave"

var save_location : String = "res://addons/DocsGenerator/DocSaves/"


#Actually parse the file.
func generate_doc_from_gd(gd_file_path : String) -> void :
	#Open the file for writing.
	_update_save_location(save_location)
	if _does_save_location_exist() == false :
		print("Save location " + save_location + " does not exist")
		return
	
	#Create a string that will be saved to the file.
	var save_string : String = gd_file_path + "\n"
	
	#warning-ignore:return_value_discarded
	var file_loader : File = File.new()
	file_loader.open(gd_file_path, file_loader.READ)
	
	#Generate a doc.
	var line : String
	var last_line_was_comment : bool = false
	var stored_comment : String
	while file_loader.eof_reached() == false :
		line = file_loader.get_line()
		line = line.dedent()
		
		#Generate input for doc if the next line is a func or export.
		if last_line_was_comment :
			if _text_has_keywords(line) :
				#Generate doc data.
				save_string += (stored_comment + "\n")
				save_string += (line + "\n")
				save_string += "\n"
			elif line.begins_with("#warning-ignore") :
				#Skip past warning ignores.
				pass
		
			else :
				last_line_was_comment = false
		
		#Check if the line is a comment.
		elif line.begins_with("#") && line.begins_with("#warning-ignore") == false :
			last_line_was_comment = true
			stored_comment = line
	
	#Create the docs file.
	var file_name : String = gd_file_path.get_file()
	file_name = file_name.left(file_name.find(".", 0))
	file_name += FILE_TYPE #Add the file extension on the end.
	var file_to_save : File = File.new()
	file_to_save.open(save_location + file_name, file_to_save.WRITE_READ)
	print("We are creating the file " + (save_location + file_name))
	file_to_save.store_string(save_string)
	
	file_loader.close()
	file_to_save.close()

#Create directory where docs get saved if it does not exist.
func _does_save_location_exist() -> bool :
	#Create the folder if it does not exist.
	var dir : Directory = Directory.new()
	if dir.dir_exists(save_location) == false :
		print("GDFileParser.gd could not find the directory " + save_location)
		return false
	
	return true

#Checks to see if the text has important keywords.
func _text_has_keywords(text_to_check : String) -> bool :
	if( text_to_check.begins_with("func") || 
			text_to_check.begins_with("export") ||
			text_to_check.begins_with("signal")) :
		return true
	
	return false

#Prepare to save files in a new location.
func _update_save_location(new_save_location_string):
	if new_save_location_string != save_location :
		print("GDFileParser.gd updated save location")
		save_location = new_save_location_string
	
	
