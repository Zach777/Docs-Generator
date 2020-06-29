tool
extends Node

#Definitely go to https://www.markdownguide.org/
#Search Tables
#https://www.markdownguide.org/extended-syntax/
#Hello | Good evening | Good
#------|--------------|-----
#What is up | I am good | Oh wow

const EMPTY_COMMENT : String = "Somebody didn't leave a comment."
const FILE_TYPE : String = ".docsave"

var save_location : String = "res://addons/DocsGenerator/DocSaves/"

#Where in the default string the sections are located.
enum sections {
	Properties = 1,
	Methods = 2,
	Signals = 3,
	Enumerations = 4,
	Property_Descriptions = 5,
	Method_Descriptions = 6
}

#Actually parse the file.
func generate_doc_from_gd(gd_file_path : String) -> void :
	#Open the file for writing.
	_update_save_location(save_location)
	if _does_save_location_exist() == false :
		print("Save location " + save_location + " does not exist")
		return
	
	#Create a string that will be saved to the file.
	var save : PoolStringArray = _create_template_save_file(gd_file_path)
	
	#Keep track of where the section devisions are in the array.
	var section_locations : Array = [1,2,3,4,5,6,7]
	
	#Load the file that we will be parsing.
	#warning-ignore:return_value_discarded
	var file_loader : File = File.new()
	file_loader.open(gd_file_path, file_loader.READ)
	
	#Generate a doc.
	var line : String
	var store_lines : Array = [] #For when relevant text is over several lines.
	var last_line_was_comment : bool = false
	var stored_comment : String
	while file_loader.eof_reached() == false :
		line = file_loader.get_line()
		line = line.dedent()
		
		#Generate input for doc if the next line is a func or export.
		if last_line_was_comment :
			#Handle lines that are a part of multi line functions.
			if store_lines.empty() == false :
				var whole_function : String
				for text in store_lines :
					whole_function += text
				whole_function += line
				if whole_function.ends_with(":") :
					save = _handle_output_formatting(save, section_locations, whole_function + stored_comment)
				store_lines.clear()
			
			elif line.begins_with("func") :
				#Functions can be separated between multiple line.
				#Make sure to account for this.
				if line.ends_with(":") :
					save = _handle_output_formatting(save, section_locations, line + stored_comment)
				else :
					store_lines.append(line)
		
			elif(line.begins_with("export ") ||
					line.begins_with("signal ") ) :
				#Generate doc data.
				save = _handle_output_formatting(save, section_locations, line + stored_comment)
		
			elif line.begins_with("#warning-ignore") :
				#Skip past warning ignores.
				pass
		
			elif store_lines.empty() :
				last_line_was_comment = false
		
		#Store keywords without comments as well.
		elif line.begins_with("func ") :
			save = _handle_output_formatting(save, section_locations, line + "#" + EMPTY_COMMENT)
		
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
	
	#Write to the docs file.
	var at : int = 0
	for string in save :
		var save_string : String = ""
		if section_locations.has(at) :
			#Make sure the section actually has entries.
			var section_location : int = section_locations.find(at)
			var test : int = section_locations[section_location+1] - section_locations[section_location]
			if( section_locations.size() > section_location + 1 &&
				(section_locations[section_location+1] - section_locations[section_location]) == 1) :
				pass
			#The section is the last section or 
			else :
				save_string += "<br /> \n"
				save_string += "\n"
				save_string += string
				save_string += "\n" + "\n"
				file_to_save.store_line(save_string)
		else :
			save_string += string
			save_string += "\n"
			file_to_save.store_line(save_string)
		
		at += 1
	
	#Write out by closing the files.
	file_loader.close()
	file_to_save.close()

#Create a template array for saving documents.
func _create_template_save_file(path : String) -> PoolStringArray :
	var save : PoolStringArray = PoolStringArray(["# " + path])
	save.append("## Properties")
	save.append("## Methods")
	save.append("## Signals")
	save.append("## Enumerations")
	save.append("## Property Descriptions")
	save.append("## Method Descriptions")
	return save

#Check that the directory where docs get saved exists.
func _does_save_location_exist() -> bool :
	#Create the folder if it does not exist.
	var dir : Directory = Directory.new()
	if dir.dir_exists(save_location) == false :
		print("GDFileParser.gd could not find the directory " + save_location)
		return false
	
	return true

#Format the passed string and place it into the output array.
func _handle_output_formatting(output : PoolStringArray, 
								section_locations : Array, text : String) -> PoolStringArray :
	#Get the comment at the end of the text.
	var comment : String  = ""
	if text.find("#") != -1 :
		comment = text.right(text.find("#") + 1)
		text.erase(text.find("#"), comment.length() + 1)
		
	if text.begins_with("func ") :
		#Get the function name.
		text.erase(0, 4) #Erase the func from the beginning.
		var function_name : String
		function_name = text.left(text.find("("))
		text.erase(0, function_name.length())
		
		#Return type.
		var return_type : String
		var type_pointer_at : int = text.find("->")
		if type_pointer_at != -1 :
			return_type = text.right(type_pointer_at + 2)
			return_type = return_type.dedent()
			return_type.erase(return_type.find(":") - 1, 2)
			text.erase(type_pointer_at, text.right(type_pointer_at).length())
		else :
			return_type = "value"
			var function_end : int = text.find_last(":")
			text.erase(function_end, text.right(function_end).length())
		
		var arguments : Array = []
		var argument_types : Array = []
		text.erase(text.find("("), 1)
		text.erase(text.find(")"), 2)
		text.dedent()
		while text != "" :
			text = text.dedent()
			
			#Pay attention to only one argument at a time.
			var current : String
			var temp_loc : int = text.find(",")
			if temp_loc != -1 :
				current = text.left(temp_loc)
			else :
				current = text
			
			#Get the argument type if available.
			temp_loc = current.find(":")
			if temp_loc != -1 :
				var type : String = current.right(temp_loc + 1).dedent()
				argument_types.append(type)
				current.erase(temp_loc, current.right(temp_loc).length())
			else :
				argument_types.append("value")
			
			#Get the argument name.
			current.dedent()
			arguments.append(current)
			
			#Erase the processed argument.
			var comma_pos : int = text.find(",") + 1
			if comma_pos == 0 : #Find returns -1 but we added one.
				#Reached the last argument. Assign "" to string
				comma_pos = text.length()
			text.erase(0, text.left(comma_pos).length())
		
		#Write the output for methods.
#		var whole : String = return_type + " "
#		whole += "["+ function_name + "]"+ " ("
#		var at : int = 0
#		for argument in arguments :
#			whole += " " + argument_types[at]
#			whole += " "
#			whole += argument
#			at += 1
#
#			#Add whole comma if there are more arguments.
#			if at < arguments.size() :
#				whole += ","
#		whole += " )"

		var hyperlink : String = "(#"+function_name.dedent()
		var argument_string : String = " ("
		var at : int = 0
		while at < arguments.size() :
			if at > 0 :
				argument_string += ","
			argument_string += " "+argument_types[at]+" "+arguments[at]
			at += 1
		argument_string += " )"
		hyperlink += ")"
		hyperlink = hyperlink.to_lower()
		#Make sure hyperlink does not have double -- or spaces.
		hyperlink = hyperlink.replace("--", "-") 
		hyperlink = hyperlink.replace(" ", "")
		
		var whole : String = return_type+" "
		whole += "["+function_name+"]"+hyperlink+argument_string
		
		output = _store_output(output, section_locations, whole, sections.Methods)
		
		#Write the output for Method Descriptions.
		var a : String = "### "+function_name
		var b : String = "\n"+"- ● "+return_type+function_name+argument_string+"\n\n"+comment
		var c : String = "\n\n<br />\n-----\n"
		output = _store_output(output, section_locations, a+b+c, sections.Method_Descriptions)
		
	elif text.begins_with("signal ") :
		#Remove signal at the front.
		text.erase(0,7)
		
		#Initialize name variable for use later.
		var signal_name : String = ""
		var arguments : String = ""
		
		#Get the signal's arguments if possible.
		var paranthesis_begin : int = text.find("(")
		if paranthesis_begin != -1 :
			#Get the signal's name.
			signal_name = text.left(paranthesis_begin)
			
			#Remove the trailing ) and ( and signal name.
			text.erase(text.find(")"), 2)
			text.erase(0, paranthesis_begin + 1)
			
			#Get the signal arguments.
			arguments = text
			text.erase(0, arguments.length())
			
		#The signal does not have arguments.
		else:
			signal_name = text
			text.erase(0,signal_name.length())
		
		#Store the signal in the correct place.
		var completed_string : String = "- "+signal_name+" ( "+arguments+" )\n"
		completed_string += "\n"
		completed_string += comment + "\n"
		completed_string += "\n-----\n"
		output = _store_output(output, section_locations, completed_string, sections.Signals)

	return output

#Save output to the save string.
func _store_output(output : PoolStringArray, section_locations : Array,
						text : String, where_to_store : int) -> PoolStringArray :
	var place : int = section_locations[where_to_store]
	output.insert(place, text)
	
	#Increment all placements in section_locations.
	var at_location : int = where_to_store
	while at_location < section_locations.size() :
		section_locations[at_location] += 1
		
		at_location += 1
	
	return output

#Prepare to save files in a new location.
func _update_save_location(new_save_location_string : String):
	if new_save_location_string != save_location :
		print("GDFileParser.gd updated save location")
		save_location = new_save_location_string
	
	
