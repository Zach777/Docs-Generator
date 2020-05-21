extends Node


#Return all gd files within passed directory relative to said directory.
func list_all_gd_files_from_directory_relative(directory_path : String) -> Array :
	var dir_array : Array = []
	
	#Load the directory we will be searching.
	var dir : Directory = Directory.new()
	var error = dir.open(directory_path)
	assert(error == 0)
	#warning-ignore:return_value_discarded
	dir.list_dir_begin(true, true)

	#Get all gd files within the directory and subdirectory.
	var current : String = dir.get_next()
	while current != "" :
		#Recursively travel into subdirectories.
		if dir.current_is_dir() :
			#Append a slash at the end of current.
			current += s()
			var new_array : Array
			new_array = list_all_gd_files_from_directory_relative(directory_path + current)
			
			var pos : int = 0
			while pos < new_array.size() - 1 :
				new_array[pos] = current + new_array[pos]
				dir_array.append(new_array[pos])
				pos += 1
			
		
		#Append any gd files to dir_array
		elif current.ends_with(".gd") :
			var relative_path_to_gd_file : String = current
			dir_array.append(relative_path_to_gd_file)
		
		#Go to the next object in the directory.
		current = dir.get_next()
	
	return dir_array

#Return the correct slash for the operating system.
func s() -> String :
	return "/"
