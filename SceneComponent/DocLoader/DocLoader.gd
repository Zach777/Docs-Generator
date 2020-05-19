extends Node


#File for testing out file loading.
var file_loader : File = File.new()
var file_to_save : File = File.new()

#The docs should have this in their description.
func _init() -> void :
	#warning-ignore:return_value_discarded
	file_to_save.open("res://Saved", file_to_save.WRITE_READ)

#Actually parse the file.
func generate_doc_from_gd(gd_file_path : String) -> void :
	#warning-ignore:return_value_discarded
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
			if line.begins_with("func") || line.begins_with("export") :
				#Generate doc data.
				file_to_save.store_line(stored_comment)
				file_to_save.store_line(line)
				file_to_save.store_line("")
			elif line.begins_with("warning-ignore:") :
				#Skip past warning ignores.
				pass
		
			else :
				last_line_was_comment = false
		
		#Check if the line is a comment.
		if line.begins_with("#") :
			last_line_was_comment = true
			stored_comment = line
	
	file_loader.close()
