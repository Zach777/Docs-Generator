tool
extends VBoxContainer


#Player confirmed what directory to search.
func _path_confirmed(path_to_folder_string : String) -> void:
	var file_array : Array
	file_array = $RecursiveGDFileGetter.list_all_gd_files_from_directory_relative(path_to_folder_string)
	for gd_file in file_array :
		$DocLoader.generate_doc_from_gd(path_to_folder_string + gd_file)
	
	$DocLoader.close_save_file()
